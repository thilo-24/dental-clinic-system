<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.sunrisedental.config.DatabaseConnection, java.sql.*" %>
<%
    if(session.getAttribute("user") == null || !"RECEPTIONIST".equals(session.getAttribute("role"))) {
        response.sendRedirect("../login.jsp?error=Access Denied: Receptionist Session Required");
        return;
    }
%>
<jsp:include page="../components/header.jsp" />

<!-- jsPDF Library for Client-Side PDF Generation -->
<script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf/2.5.1/jspdf.umd.min.js"></script>

<!-- Advanced Design Token Underlays for Glassmorphic Front-Desk Terminal Architecture -->
<style>
    .glass-billing-hud {
        background: rgba(224, 242, 254, 0.75); /* Soft sky-blue undertone */
        backdrop-filter: blur(16px);
        -webkit-backdrop-filter: blur(16px);
        border: 1px solid rgba(255, 255, 255, 0.5);
        box-shadow: 0 8px 32px 0 rgba(15, 23, 42, 0.08);
    }
    .glass-ledger-card {
        background: rgba(255, 255, 255, 0.85);
        backdrop-filter: blur(10px);
        -webkit-backdrop-filter: blur(10px);
        border: 1px solid rgba(255, 255, 255, 0.6);
        transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
    }
</style>

<!-- High-Fidelity Modern Dental Clinic Backdrop Container -->
<div class="relative min-h-[88vh] rounded-3xl overflow-hidden p-4 sm:p-6 lg:p-10 border border-slate-200/60 shadow-xl bg-cover bg-center transition-all duration-700"
     style="background-image: url('https://images.unsplash.com/photo-1629909613654-28e377c37b09?auto=format&fit=crop&w=1920&q=80');">
    
    <!-- Precise Color Masking Layer to Stabilize Data Grid Contrast Vectors -->
    <div class="absolute inset-0 z-0 bg-gradient-to-tr from-slate-950/85 via-slate-900/40 to-emerald-950/20"></div>

    <div class="relative z-10 max-w-5xl mx-auto space-y-6">

        <!-- Front-Desk Workspace Header & Navigation Block -->
        <div class="glass-billing-hud rounded-2xl border border-white/40 p-5 sm:p-6 shadow-lg shadow-slate-900/10">
            <div class="flex flex-col md:flex-row md:items-center md:justify-between gap-4">
                <div>
                    <div class="flex items-center gap-2">
                        <span class="inline-flex h-6 w-6 items-center justify-center rounded-md bg-emerald-600 text-white shadow-sm shadow-emerald-600/20">
                            <i class="fa-solid fa-receipt text-[11px]"></i>
                        </span>
                        <h1 class="text-xl font-black tracking-tight text-slate-900 uppercase sm:text-2xl">Financial Settlement Center</h1>
                    </div>
                    <p class="mt-1 text-xs sm:text-sm font-medium text-slate-500">Collect clinical consultation fees, manage invoice status records, and issue receipts.</p>
                </div>
                
                <!-- Navigation Return Anchor -->
                <a href="dashboard.jsp" class="inline-flex items-center gap-2 self-start md:self-center rounded-xl border border-slate-200 bg-white/90 px-4 py-2 text-xs font-bold text-slate-700 shadow-sm transition-all hover:bg-slate-50 hover:text-slate-900 active:scale-[0.98] backdrop-blur-sm">
                    <i class="fa-solid fa-arrow-left-long text-slate-400"></i>
                    <span>Dashboard View</span>
                </a>
            </div>
        </div>

        <!-- Dynamic Real-Time Filtration Matrix Toolbar -->
        <div class="glass-billing-hud flex flex-col sm:flex-row items-center justify-between gap-4 rounded-2xl border border-white/40 p-4 shadow-md">
            <div class="relative w-full sm:max-w-md group">
                <input type="text" id="billingSearch" onkeyup="filterBillingTable()" 
                       placeholder="Quick filter by patient name or appointment ID..." 
                       class="w-full rounded-xl border border-slate-200/80 bg-slate-50/60 py-2.5 pl-4 pr-10 text-xs font-bold text-slate-700 placeholder-slate-400 focus:border-emerald-500 focus:bg-white focus:outline-none focus:ring-1 focus:ring-emerald-500 transition-all shadow-inner" />
                       
                <!-- Right-aligned icon with z-10 priority layer -->
                <span class="absolute inset-y-0 right-0 z-10 flex items-center pr-3.5 pointer-events-none text-slate-400 group-focus-within:text-emerald-500 transition-colors">
                    <i class="fa-solid fa-magnifying-glass text-xs"></i>
                </span>
            </div>        
            <div class="flex items-center gap-2 self-stretch sm:self-auto justify-end rounded-xl bg-rose-50/90 px-3.5 py-2 text-xs font-black text-rose-700 border border-rose-100/80 shadow-sm backdrop-blur-sm">
                <i class="fa-solid fa-circle-dollar-to-slot text-rose-500 text-sm animate-pulse"></i>
                <span class="tracking-wide uppercase text-[10px]">Awaiting Payment: <span id="pendingCounter" class="font-black font-mono text-xs bg-rose-200/60 px-1.5 py-0.5 rounded ml-0.5">0</span> Bills</span>
            </div>
        </div>

        <!-- Master Operations Ledger Data Grid Table -->
        <div class="glass-ledger-card overflow-hidden rounded-2xl border border-white/50 shadow-2xl flex flex-col justify-between min-h-[450px]">
            <div class="overflow-x-auto">
                <table class="w-full border-collapse text-left text-xs text-slate-600">
                    <thead>
                        <tr class="border-b border-slate-200 bg-slate-100/60 font-black uppercase tracking-wider text-slate-400 text-[10px]">
                            <th scope="col" class="px-6 py-4.5">App No</th>
                            <th scope="col" class="px-6 py-4.5">Patient Profile</th>
                            <th scope="col" class="px-6 py-4.5">Treatment Category</th>
                            <th scope="col" class="px-6 py-4.5">Outstanding Amount (Inc. 20% Tax)</th>
                            <th scope="col" class="px-6 py-4.5">Schedule Details</th>
                            <th scope="col" class="px-6 py-4.5 text-center">Action Framework</th>
                        </tr>
                    </thead>
                    <tbody id="billingTableBody" class="divide-y divide-slate-100 font-medium">
                    <%
                        int pendingRecordCount = 0;
                        try {
                            Connection conn = DatabaseConnection.getInstance().getConnection();
                            String sql = "SELECT a.id, a.appointment_number, p.name AS patient_name, a.treatment_type, " +
                                         "a.consultation_fee, a.appointment_date, a.appointment_time " +
                                         "FROM appointments a JOIN patients p ON a.patient_id = p.id " +
                                         "WHERE a.payment_status = 'PENDING' ORDER BY a.appointment_date ASC, a.appointment_time ASC";
                            
                            Statement stmt = conn.createStatement();
                            ResultSet rs = stmt.executeQuery(sql);
                            
                            while(rs.next()) {
                                pendingRecordCount++;
                                
                                double baseFee = rs.getDouble("consultation_fee");
                                double totalFeeWithTax = baseFee * 1.20; 
                                String escapedPatientName = rs.getString("patient_name").replace("'", "\\'");
                                String escapedTreatmentType = rs.getString("treatment_type").replace("'", "\\'");
                    %>
                        <tr class="billing-row transition-all duration-200 hover:bg-emerald-50/40 group">
                            <!-- App Number Badge Module -->
                            <td class="whitespace-nowrap px-6 py-4 font-bold text-slate-900">
                                <span class="inline-flex items-center gap-1 rounded-lg bg-slate-100 border border-slate-300/60 px-2 py-1 text-[11px] font-mono font-bold text-slate-700 shadow-inner group-hover:bg-white group-hover:border-slate-400/60 transition-colors">
                                    <%= rs.getString("appointment_number") %>
                                </span>
                            </td>
                            
                            <!-- Patient Structural Profile Entity Identifier -->
                            <td class="whitespace-nowrap px-6 py-4 text-sm font-black text-slate-900 searchable-patient group-hover:text-emerald-950 transition-colors">
                                <%= rs.getString("patient_name") %>
                            </td>
                            
                            <!-- Treatment Category Verification Tag -->
                            <td class="whitespace-nowrap px-6 py-4 text-slate-700">
                                <div class="flex items-center gap-2">
                                    <div class="flex h-6 w-6 items-center justify-center rounded-md bg-slate-100 text-[10px] text-slate-500 border border-slate-200 group-hover:bg-emerald-600 group-hover:text-white group-hover:border-transparent shadow-sm transition-all duration-300">
                                        <i class="fa-solid fa-tooth"></i>
                                    </div>
                                    <span class="font-bold tracking-wide"><%= rs.getString("treatment_type") %></span>
                                </div>
                            </td>
                            
                            <!-- Dynamic Monospaced Currency Component displaying calculated Gross Cost Matrix -->
                            <td class="whitespace-nowrap px-6 py-4 font-mono text-sm font-black text-rose-600 bg-rose-50/30 group-hover:bg-rose-50/70 transition-colors">
                                <div class="flex flex-col">
                                    <span class="text-xs text-slate-400 font-sans font-normal">Base: <%= String.format("%,.2f", baseFee) %></span>
                                    <span><%= String.format("%,.2f LKR", totalFeeWithTax) %></span>
                                </div>
                            </td>
                            
                            <!-- Multi-Layer Temporal Metric Cell -->
                            <td class="whitespace-nowrap px-6 py-4 text-slate-500 text-[11px]">
                                <div class="flex flex-col gap-0.5">
                                    <span class="font-bold text-slate-800 flex items-center gap-1">
                                        <i class="fa-regular fa-calendar text-[10px] text-slate-400"></i><%= rs.getDate("appointment_date") %>
                                    </span>
                                    <span class="font-semibold flex items-center gap-1 text-slate-500">
                                        <i class="fa-regular fa-clock text-[10px] text-slate-400"></i><%= rs.getTime("appointment_time") %>
                                    </span>
                                </div>
                            </td>
                            
                            <!-- Settle Invoicing Interface Submission Engine (Triggers PDF & AJAX Settlement) -->
                            <td class="whitespace-nowrap px-6 py-4 text-center">
                                <button type="button" 
                                        onclick="settleAndDownloadPDF(this, '<%= rs.getInt("id") %>', '<%= rs.getString("appointment_number") %>', '<%= escapedPatientName %>', '<%= escapedTreatmentType %>', <%= baseFee %>, <%= totalFeeWithTax %>, '<%= rs.getDate("appointment_date") %>')"
                                        class="settle-btn inline-flex items-center gap-1.5 rounded-xl bg-emerald-600 px-4 py-2 text-[11px] font-black tracking-wide uppercase text-white shadow-sm shadow-emerald-600/10 transition-all hover:bg-emerald-500 hover:shadow-md active:scale-95 focus:outline-none focus:ring-2 focus:ring-emerald-500 focus:ring-offset-2">
                                    <i class="fa-solid fa-file-pdf text-[10px]"></i>
                                    <span>SETTLE BILL</span>
                                </button>
                            </td>
                        </tr>
                    <%
                            }
                            if (pendingRecordCount == 0) {
                    %>
                        <tr id="emptyRow">
                            <td colspan="6" class="px-6 py-16 text-center text-sm font-bold text-slate-400 bg-slate-50/30">
                                <div class="flex flex-col items-center justify-center gap-3">
                                    <div class="h-12 w-12 rounded-full bg-slate-100 flex items-center justify-center border border-slate-200 text-slate-400 shadow-inner">
                                        <i class="fa-solid fa-folder-open text-xl"></i>
                                    </div>
                                    <span class="tracking-wide text-xs uppercase font-black text-slate-400">No outstanding medical bills found on file. Clear balance architecture.</span>
                                </div>
                            </td>
                        </tr>
                    <%
                            }
                            rs.close();
                            stmt.close();
                        } catch (Exception e) {
                    %>
                        <tr>
                            <td colspan="6" class="px-6 py-12 text-center text-xs font-bold text-rose-600 bg-rose-50/40">
                                <div class="flex flex-col items-center justify-center gap-2">
                                    <i class="fa-solid fa-triangle-exclamation text-xl animate-bounce"></i>
                                    <span>Error parsing ledger data arrays from database pool context. Verify configuration parameters.</span>
                                </div>
                            </td>
                        </tr>
                    <%
                        }
                    %>
                    </tbody>
                </table>
            </div>
            
            <!-- Terminal Balance Info Alert Banner Footer -->
            <div class="p-4 bg-emerald-50/80 border-t border-emerald-200/60 flex gap-3 items-start mt-auto backdrop-blur-sm">
                <i class="fa-solid fa-shield-halved text-emerald-600 text-sm mt-0.5"></i>
                <p class="text-[11px] font-semibold leading-relaxed text-emerald-900">
                    <strong class="font-bold">Transaction Integrity Notice:</strong> Executing a payment operation registers changes instantly to the centralized clinical log matrix. Ensure physical payment verification is complete before validating transaction execution frames.
                </p>
            </div>
        </div>

    </div>
</div>

<!-- Dashboard Settlement Control Action Engine JS Architecture -->
<script>
    const { jsPDF } = window.jspdf;

    async function settleAndDownloadPDF(button, appointmentId, appNumber, patientName, treatmentType, baseFee, totalWithTax, appDate) {
        // Lock Button UI State during processing
        button.disabled = true;
        const originalHtml = button.innerHTML;
        button.classList.remove('bg-emerald-600', 'hover:bg-emerald-500');
        button.classList.add('bg-slate-300', 'cursor-not-allowed', 'text-slate-500');
        button.innerHTML = `<i class="fa-solid fa-circle-notch animate-spin text-[10px]"></i> <span>Processing...</span>`;

        try {
            // Send AJAX update to BillingServlet
            const response = await fetch('${pageContext.request.contextPath}/BillingServlet', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded',
                },
                body: new URLSearchParams({
                    'appointmentId': appointmentId
                })
            });

            if (!response.ok) {
                throw new Error('Database settlement update failed.');
            }

            // Generate & Trigger PDF Download
            generateInvoicePDF(appNumber, patientName, treatmentType, baseFee, totalWithTax, appDate);

            // Animate and remove settled table row
            const row = button.closest('tr');
            row.style.transition = "all 0.4s ease";
            row.style.opacity = "0";
            setTimeout(() => {
                row.remove();
                recalculateTotalPending();
            }, 400);

        } catch (error) {
            alert("Settlement Error: " + error.message);
            button.disabled = false;
            button.classList.remove('bg-slate-300', 'cursor-not-allowed', 'text-slate-500');
            button.classList.add('bg-emerald-600', 'hover:bg-emerald-500');
            button.innerHTML = originalHtml;
        }
    }

	    function generateInvoicePDF(appNumber, patientName, treatmentType, baseFee, totalWithTax, appDate) {
	        const doc = new jsPDF();
	        const taxAmount = totalWithTax - baseFee;
	
	        // Header Styling
	        doc.setFillColor(16, 185, 129); // Emerald accent
	        doc.rect(0, 0, 210, 30, 'F');
	
	        doc.setTextColor(255, 255, 255);
	        doc.setFont("helvetica", "bold");
	        doc.setFontSize(18);
	        doc.text("SUNRISE DENTAL CLINIC", 14, 18);
	        doc.setFontSize(10);
	        doc.text("OFFICIAL SETTLEMENT RECEIPT", 14, 25);
	
	        // Metadata Block
	        doc.setTextColor(50, 50, 50);
	        doc.setFontSize(10);
	        doc.setFont("helvetica", "normal");
	        
	        // Fixed string concatenation to avoid JSP EL parser collision
	        doc.text("Receipt Date: " + new Date().toLocaleDateString(), 140, 40);
	        doc.text("App Ref No: " + appNumber, 140, 46);
	        doc.text("Appointment Date: " + appDate, 140, 52);
	
	        doc.setFont("helvetica", "bold");
	        doc.text("PATIENT INFORMATION", 14, 40);
	        doc.setFont("helvetica", "normal");
	        doc.text("Patient Name: " + patientName, 14, 46);
	        doc.text("Treatment: " + treatmentType, 14, 52);
	
	        // Table Header
	        doc.setFillColor(241, 245, 249);
	        doc.rect(14, 65, 182, 10, 'F');
	        doc.setFont("helvetica", "bold");
	        doc.text("Description", 18, 71);
	        doc.text("Amount (LKR)", 160, 71);
	
	        // Table Content
	        doc.setFont("helvetica", "normal");
	        doc.text(treatmentType + " - Base Fee", 18, 83);
	        doc.text(baseFee.toFixed(2), 160, 83);
	
	        doc.text("Tax / Service Charge (20%)", 18, 91);
	        doc.text(taxAmount.toFixed(2), 160, 91);
	
	        // Divider Line
	        doc.setLineWidth(0.5);
	        doc.line(14, 98, 196, 98);
	
	        // Total
	        doc.setFont("helvetica", "bold");
	        doc.setFontSize(12);
	        doc.text("TOTAL PAID:", 18, 108);
	        doc.text(totalWithTax.toFixed(2) + " LKR", 160, 108);
	
	        // Footer Note
	        doc.setFontSize(9);
	        doc.setFont("helvetica", "italic");
	        doc.setTextColor(120, 120, 120);
	        doc.text("Thank you for choosing Sunrise Dental Clinic. Wish you a healthy smile!", 14, 130);
	
	        // Trigger Save/Download
	        doc.save("Invoice_" + appNumber + "_" + patientName.replace(/\s+/g, '_') + ".pdf");
	    }

    function recalculateTotalPending() {
        const rows = document.querySelectorAll('.billing-row');
        let counter = rows.length;
        document.getElementById('pendingCounter').textContent = counter;
        
        if(counter === 0) {
            const tbody = document.getElementById('billingTableBody');
            tbody.innerHTML = `<tr id="emptyRow"><td colspan="6" class="px-6 py-16 text-center text-sm font-bold text-slate-400 bg-slate-50/30"><div class="flex flex-col items-center justify-center gap-3"><div class="h-12 w-12 rounded-full bg-slate-100 flex items-center justify-center border border-slate-200 text-slate-400 shadow-inner"><i class="fa-solid fa-folder-open text-xl"></i></div><span class="tracking-wide text-xs uppercase font-black text-slate-400">No outstanding medical bills found on file. Clear balance architecture.</span></div></td></tr>`;
        }
    }

    function filterBillingTable() {
        const query = document.getElementById('billingSearch').value.toLowerCase();
        const rows = document.querySelectorAll('.billing-row');
        
        rows.forEach(row => {
            const name = row.querySelector('.searchable-patient').textContent.toLowerCase();
            const appNum = row.querySelector('.inline-flex').textContent.toLowerCase();
            
            if(name.includes(query) || appNum.includes(query)) {
                row.style.display = '';
            } else {
                row.style.display = 'none';
            }
        });
    }

    document.addEventListener("DOMContentLoaded", () => {
        document.getElementById('pendingCounter').textContent = "<%= pendingRecordCount %>";
    });
</script>

<jsp:include page="../components/footer.jsp" />