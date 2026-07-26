package com.sunrisedental.controller;

import java.io.IOException;
import java.net.URLEncoder;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.UUID;

import com.sunrisedental.config.DatabaseConnection;
import com.sunrisedental.factory.Treatment;
import com.sunrisedental.factory.TreatmentFactory;
import com.sunrisedental.util.AppointmentValidationUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/AppointmentServlet")
public class AppointmentServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String patientIdParam = request.getParameter("patientId");
        String dentistName = request.getParameter("dentistName");
        String treatmentType = request.getParameter("treatmentType");
        String appDate = request.getParameter("appointmentDate");
        String appTime = request.getParameter("appointmentTime");

        // 1. Check for missing or empty form fields
        if (patientIdParam == null || treatmentType == null || appDate == null || appTime == null || dentistName == null ||
            patientIdParam.trim().isEmpty() || treatmentType.trim().isEmpty() || appDate.trim().isEmpty() || 
            appTime.trim().isEmpty() || dentistName.trim().isEmpty()) {
            
            response.sendRedirect("receptionist/book-appointment.jsp?error=" + URLEncoder.encode("All assignment parameters are mandatory.", "UTF-8"));
            return;
        }

        // 2. Validate Patient ID numeric format
        int patientId;
        try {
            patientId = Integer.parseInt(patientIdParam.trim());
            if (patientId <= 0) {
                response.sendRedirect("receptionist/book-appointment.jsp?error=" + URLEncoder.encode("Patient ID must be a positive number.", "UTF-8"));
                return;
            }
        } catch (NumberFormatException e) {
            response.sendRedirect("receptionist/book-appointment.jsp?error=" + URLEncoder.encode("Invalid Patient ID format. Please enter a numerical ID.", "UTF-8"));
            return;
        }

        // 3. Time Parsing and 2-Hour Conflict Validation
        String formattedTime = appTime.trim();
        if (formattedTime.length() == 5) {
            formattedTime += ":00";
        }

        LocalDate bookingDate = LocalDate.parse(appDate.trim());
        LocalTime bookingTime = LocalTime.parse(formattedTime);

        boolean isAvailable = AppointmentValidationUtil.isDoctorAvailable(dentistName.trim(), bookingDate, bookingTime);
        if (!isAvailable) {
            response.sendRedirect("receptionist/book-appointment.jsp?error=" + 
                    URLEncoder.encode(dentistName + " is unavailable at " + appTime + ".Doctors require a 30-minute window between appointments.", "UTF-8"));
            return;
        }

        Connection conn = null;
        PreparedStatement checkPatientPs = null;
        PreparedStatement checkDoctorPs = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DatabaseConnection.getInstance().getConnection();

            // 4. Foreign key check against patients(id)
            String checkPatientSql = "SELECT id FROM patients WHERE id = ?";
            checkPatientPs = conn.prepareStatement(checkPatientSql);
            checkPatientPs.setInt(1, patientId);
            rs = checkPatientPs.executeQuery();

            if (!rs.next()) {
                response.sendRedirect("receptionist/book-appointment.jsp?error=" + URLEncoder.encode("Patient ID " + patientId + " is not registered in the system.", "UTF-8"));
                return;
            }
            rs.close();

            // 5. Verify Doctor Admin Control (Is Active & Mapping Check)
            String checkDoctorSql = "SELECT d.id FROM doctors d " +
                                    "JOIN doctor_treatments dt ON d.id = dt.doctor_id " +
                                    "JOIN treatments t ON dt.treatment_id = t.id " +
                                    "WHERE d.doctor_name = ? AND d.is_active = TRUE AND t.treatment_name = ?";
            checkDoctorPs = conn.prepareStatement(checkDoctorSql);
            checkDoctorPs.setString(1, dentistName.trim());
            checkDoctorPs.setString(2, treatmentType.trim());
            rs = checkDoctorPs.executeQuery();

            if (!rs.next()) {
                response.sendRedirect("receptionist/book-appointment.jsp?error=" + 
                        URLEncoder.encode("Selected doctor is either inactive or not authorized by Admin for this treatment.", "UTF-8"));
                return;
            }

            // 6. Resolve treatment details using Factory pattern
            Treatment treatment = TreatmentFactory.getTreatment(treatmentType.trim());
            if (treatment == null) {
                throw new IllegalArgumentException("Unknown core identity structure mappings.");
            }
            
            double baseFee = treatment.getBasePrice();
            String verifiedName = treatment.getTreatmentName();

            // 7. Generate appointment reference code
            String appointmentNumber = "APP-" + UUID.randomUUID().toString().substring(0, 8).toUpperCase();

            // 8. Insert record into appointments table
            String sql = "INSERT INTO appointments (appointment_number, patient_id, dentist_name, " +
                         "treatment_type, appointment_date, appointment_time, consultation_fee, payment_status) " +
                         "VALUES (?, ?, ?, ?, ?, ?, ?, 'PENDING')";

            ps = conn.prepareStatement(sql);
            ps.setString(1, appointmentNumber);
            ps.setInt(2, patientId);
            ps.setString(3, dentistName.trim());
            ps.setString(4, verifiedName);
            ps.setString(5, appDate.trim());
            ps.setString(6, formattedTime);
            ps.setDouble(7, baseFee);

            ps.executeUpdate();

            response.sendRedirect("receptionist/dashboard.jsp?msg=" + URLEncoder.encode("Appointment " + appointmentNumber + " Booked Successfully!", "UTF-8"));

        } catch (IllegalArgumentException e) {
            e.printStackTrace();
            response.sendRedirect("receptionist/book-appointment.jsp?error=" + URLEncoder.encode("Invalid treatment selection.", "UTF-8"));
        } catch (SQLException e) {
            e.printStackTrace();
            response.sendRedirect("receptionist/book-appointment.jsp?error=" + URLEncoder.encode("Database transaction fault: " + e.getMessage(), "UTF-8"));
        } finally {
            if (rs != null) { try { rs.close(); } catch (SQLException e) { e.printStackTrace(); } }
            if (checkPatientPs != null) { try { checkPatientPs.close(); } catch (SQLException e) { e.printStackTrace(); } }
            if (checkDoctorPs != null) { try { checkDoctorPs.close(); } catch (SQLException e) { e.printStackTrace(); } }
            if (ps != null) { try { ps.close(); } catch (SQLException e) { e.printStackTrace(); } }
        }
    }
}