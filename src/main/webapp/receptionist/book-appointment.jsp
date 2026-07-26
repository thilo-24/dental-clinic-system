<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.sunrisedental.config.DatabaseConnection, java.sql.*" %>
<%
    if(session.getAttribute("user") == null || !"RECEPTIONIST".equals(session.getAttribute("role"))) {
        response.sendRedirect("../login.jsp?error=Access Denied: Receptionist Session Required");
        return;
    }
%>
<jsp:include page="../components/header.jsp" />

<!-- Advanced Design Token Underlays for Glassmorphic Front-Desk Booking Terminal -->
<style>
    .glass-schedule-hud {
        background: rgba(224, 242, 254, 0.75); /* Soft sky-blue undertone */
        backdrop-filter: blur(16px);
        -webkit-backdrop-filter: blur(16px);
        border: 1px solid rgba(255, 255, 255, 0.5);
        box-shadow: 0 8px 32px 0 rgba(15, 23, 42, 0.08);
    }
    .glass-form-card {
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
    <div class="absolute inset-0 z-0 bg-gradient-to-tr from-slate-950/85 via-slate-900/40 to-orange-950/20"></div>

    <div class="relative z-10 max-w-xl mx-auto space-y-6">

        <!-- Front-Desk Scheduling Header Navigation Block -->
        <div class="glass-schedule-hud rounded-2xl border border-white/40 p-5 shadow-lg shadow-slate-900/10">
            <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
                <div>
                    <div class="flex items-center gap-2">
                        <span class="inline-flex h-6 w-6 items-center justify-center rounded-md bg-orange-600 text-white shadow-sm shadow-orange-600/20">
                            <i class="fa-solid fa-calendar-plus text-[11px]"></i>
                        </span>
                        <h1 class="text-xl font-black tracking-tight text-slate-900 uppercase sm:text-2xl">Schedule Slot</h1>
                    </div>
                    <p class="mt-1 text-xs font-medium text-slate-500">Allocate new treatment sessions and reserve slots.</p>
                </div>
                
                <!-- Interactive Return to Dashboard View Button -->
                <a href="dashboard.jsp" class="inline-flex items-center gap-2 self-start sm:self-center rounded-xl border border-slate-200 bg-white/90 px-4 py-2 text-xs font-bold text-slate-700 shadow-sm transition-all hover:bg-slate-50 hover:text-slate-900 active:scale-[0.98] backdrop-blur-sm">
                    <i class="fa-solid fa-arrow-left-long text-slate-400"></i>
                    <span>Dashboard View</span>
                </a>
            </div>
        </div>

        <!-- Main Schedule Booking Action Form Card -->
        <div class="glass-form-card rounded-2xl border border-white/50 shadow-2xl overflow-hidden">
            
            <!-- Premium High-Contrast Brand Accent Strip -->
            <div class="h-1.5 bg-gradient-to-r from-orange-500 via-amber-500 to-yellow-500"></div>

            <div class="p-6 sm:p-8">
                <!-- Error Alert Message Toast Handling Frame -->
                <% if(request.getParameter("error") != null) { %>
                    <div id="errorToast" class="mb-6 flex items-center justify-between rounded-xl bg-rose-50/90 border border-rose-200 p-4 text-rose-800 shadow-sm transition-all duration-300 backdrop-blur-sm animate-fadeIn">
                        <div class="flex items-center gap-3">
                            <div class="flex h-8 w-8 items-center justify-center rounded-lg bg-rose-600 text-white shrink-0 shadow-sm">
                                <i class="fa-solid fa-triangle-exclamation"></i>
                            </div>
                            <p class="text-xs font-black leading-tight tracking-wide"><%= request.getParameter("error") %></p>
                        </div>
                        <button onclick="dismissError()" type="button" class="rounded-lg p-1 text-rose-500 hover:bg-rose-200/50 transition-colors">
                            <i class="fa-solid fa-xmark text-sm"></i>
                        </button>
                    </div>
                <% } %>

                <form action="${pageContext.request.contextPath}/AppointmentServlet" method="post" onsubmit="return validateAndLockForm(this)" class="space-y-5">
                    
                    <!-- Patient ID Reference Input Node (STRICT VALIDATION ENABLED) -->
                    <div class="group">
                        <div class="flex items-center justify-between mb-2">
                            <label class="block text-[10px] font-black tracking-wider text-slate-400 uppercase group-focus-within:text-orange-600 transition-colors">Validated Patient Reference ID <span class="text-rose-500">*</span></label>
                            <span id="patientIdError" class="hidden text-[10px] font-bold text-rose-600">Patient ID required</span>
                        </div>
                        <div class="relative">
                            <span class="absolute inset-y-0 left-0 flex items-center pl-3.5 pointer-events-none text-slate-400 z-10 group-focus-within:text-orange-500 transition-colors">
                                <i class="fa-solid fa-id-card text-xs"></i>
                            </span>
                            <input type="number" id="patientId" name="patientId" min="1" placeholder="e.g., 1042 (Look up via patient logs)" 
                                   class="w-full rounded-xl border border-slate-200/80 bg-slate-50/60 py-2.5 pl-10 pr-4 text-xs font-bold text-slate-800 placeholder-slate-400 focus:border-orange-500 focus:bg-white focus:outline-none focus:ring-1 focus:ring-orange-500 transition-all shadow-inner" required>
                        </div>
                    </div>

                    <!-- Dynamic Dental Surgeon Selection Dropdown Node -->
                    <div class="group">
                        <label class="block text-[10px] font-black tracking-wider text-slate-400 mb-2 uppercase group-focus-within:text-orange-600 transition-colors">Assigned Dental Surgeon <span class="text-rose-500">*</span></label>
                        <div class="relative">
                            <span class="absolute inset-y-0 left-0 flex items-center pl-3.5 pointer-events-none text-slate-400 z-10 group-focus-within:text-orange-500 transition-colors">
                                <i class="fa-solid fa-user-doctor text-xs"></i>
                            </span>
                            <select name="dentistName" 
                                    class="relative w-full rounded-xl border border-slate-200/80 bg-slate-50/60 py-2.5 pl-10 pr-10 text-xs font-bold text-slate-700 focus:border-orange-500 focus:bg-white focus:outline-none focus:ring-1 focus:ring-orange-500 transition-all appearance-none cursor-pointer shadow-inner" required>
                                <option value="" disabled selected>-- Select Active Doctor --</option>
                                <%
                                    try {
                                        Connection conn = DatabaseConnection.getInstance().getConnection();
                                        Statement stmt = conn.createStatement();
                                        // Fetch active doctors registered by Admin
                                        ResultSet rs = stmt.executeQuery("SELECT doctor_name, specialization FROM doctors WHERE is_active = TRUE ORDER BY doctor_name ASC");
                                        
                                        boolean hasDoctors = false;
                                        while(rs.next()) {
                                            hasDoctors = true;
                                            String docName = rs.getString("doctor_name");
                                            String spec = rs.getString("specialization");
                                            String specLabel = (spec != null && !spec.trim().isEmpty()) ? " (" + spec + ")" : "";
                                %>
                                    <option value="<%= docName %>"><%= docName %><%= specLabel %></option>
                                <%
                                        }
                                        if(!hasDoctors) {
                                %>
                                    <option value="" disabled>No active doctors available in system</option>
                                <%
                                        }
                                        rs.close();
                                        stmt.close();
                                    } catch (Exception e) {
                                %>
                                    <option value="">Error compiling doctor registry list...</option>
                                <%
                                    }
                                %>
                            </select>
                            <span class="absolute inset-y-0 right-0 flex items-center pr-3.5 pointer-events-none text-slate-400">
                                <i class="fa-solid fa-chevron-down text-[10px]"></i>
                            </span>
                        </div>
                    </div>

                    <!-- Core Treatment Factory Classification Select Input Node -->
                    <div class="group">
                        <label class="block text-[10px] font-black tracking-wider text-slate-400 mb-2 uppercase group-focus-within:text-orange-600 transition-colors">Treatment Classification <span class="text-rose-500">*</span></label>
                        <div class="relative">
                            <span class="absolute inset-y-0 left-0 flex items-center pl-3.5 pointer-events-none text-slate-400 z-10 group-focus-within:text-orange-500 transition-colors">
                                <i class="fa-solid fa-tooth text-xs"></i>
                            </span>
                            <select name="treatmentType" 
                                    class="relative w-full rounded-xl border border-slate-200/80 bg-slate-50/60 py-2.5 pl-10 pr-10 text-xs font-bold text-slate-700 focus:border-orange-500 focus:bg-white focus:outline-none focus:ring-1 focus:ring-orange-500 transition-all appearance-none cursor-pointer shadow-inner" required>
                                <option value="" disabled selected>-- Select Treatment --</option>
                                <%
                                    try {
                                        Connection conn = DatabaseConnection.getInstance().getConnection();
                                        Statement stmt = conn.createStatement();
                                        ResultSet rs = stmt.executeQuery("SELECT treatment_name, base_price FROM treatments ORDER BY treatment_name ASC");
                                        while(rs.next()) {
                                            String name = rs.getString("treatment_name");
                                            double price = rs.getDouble("base_price");
                                %>
                                    <option value="<%= name %>"><%= name %> (Base: <%= String.format("%,.2f", price) %> LKR)</option>
                                <%
                                        }
                                        rs.close(); 
                                        stmt.close();
                                    } catch (Exception e) {
                                %>
                                    <option value="">Error compiling dynamic data matrix...</option>
                                <%
                                    }
                                %>
                            </select>
                            <span class="absolute inset-y-0 right-0 flex items-center pr-3.5 pointer-events-none text-slate-400">
                                <i class="fa-solid fa-chevron-down text-[10px]"></i>
                            </span>
                        </div>
                    </div>

                    <!-- Synchronized Date & Time Metric Field Array Row -->
                    <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
                        <div class="group">
                            <label class="block text-[10px] font-black tracking-wider text-slate-400 mb-2 uppercase group-focus-within:text-orange-600 transition-colors">Target Date <span class="text-rose-500">*</span></label>
                            <input type="date" id="appointmentDate" name="appointmentDate" 
                                   class="w-full rounded-xl border border-slate-200/80 bg-slate-50/60 p-2.5 text-xs font-bold text-slate-800 focus:border-orange-500 focus:bg-white focus:outline-none focus:ring-1 focus:ring-orange-500 transition-all shadow-inner" required>
                        </div>
                        <div class="group">
                            <label class="block text-[10px] font-black tracking-wider text-slate-400 mb-2 uppercase group-focus-within:text-orange-600 transition-colors">Target Time <span class="text-rose-500">*</span></label>
                            <input type="time" name="appointmentTime" 
                                   class="w-full rounded-xl border border-slate-200/80 bg-slate-50/60 p-2.5 text-xs font-bold text-slate-800 focus:border-orange-500 focus:bg-white focus:outline-none focus:ring-1 focus:ring-orange-500 transition-all shadow-inner" required>
                        </div>
                    </div>

                    <!-- Submission Commit Action Button Framework Area -->
                    <div class="pt-4">
                        <button type="submit" id="submitBtn" 
                                class="w-full inline-flex items-center justify-center gap-2 rounded-xl bg-orange-600 px-5 py-3.5 text-xs font-black tracking-wide uppercase text-white shadow-md shadow-orange-600/10 transition-all hover:bg-orange-500 hover:shadow-lg active:scale-[0.98] focus:outline-none focus:ring-2 focus:ring-orange-500 focus:ring-offset-2">
                            <i class="fa-solid fa-calendar-plus text-sm"></i>
                            <span>Commit Booking Allocation</span>
                        </button>
                    </div>
                    
                </form>
            </div>
        </div>

    </div>
</div>

<!-- Form Interaction Safety Mechanics Client Side Architecture -->
<script>
    // Smooth opacity adjustments to clear out screen metrics
    function dismissError() {
        const errorToast = document.getElementById('errorToast');
        if(errorToast) {
            errorToast.style.opacity = '0';
            setTimeout(() => errorToast.remove(), 300);
        }
    }

    // Front-Desk safety rules framework: Restrict historical date selection parameters automatically
    document.addEventListener("DOMContentLoaded", () => {
        const dateInput = document.getElementById('appointmentDate');
        if(dateInput) {
            const today = new Date().toISOString().split('T')[0];
            dateInput.min = today;
        }
    });

    // Form validation check prior to submission
    function validateAndLockForm(formElement) {
        const patientIdInput = document.getElementById('patientId');
        const patientIdError = document.getElementById('patientIdError');
        const patientIdVal = patientIdInput ? patientIdInput.value.trim() : "";

        // Client validation: Ensure Patient ID exists and is greater than 0
        if (!patientIdVal || isNaN(patientIdVal) || parseInt(patientIdVal) <= 0) {
            if (patientIdError) patientIdError.classList.remove('hidden');
            if (patientIdInput) {
                patientIdInput.classList.add('border-rose-500', 'ring-1', 'ring-rose-500');
                patientIdInput.focus();
            }
            return false; // Cancel form submission
        }

        if (patientIdError) patientIdError.classList.add('hidden');

        // Prevent double submission once validated
        const btn = document.getElementById('submitBtn');
        if(btn) {
            btn.disabled = true;
            btn.classList.remove('bg-orange-600', 'hover:bg-orange-500');
            btn.classList.add('bg-slate-300', 'cursor-not-allowed', 'text-slate-500');
            btn.innerHTML = `<i class="fa-solid fa-circle-notch animate-spin text-sm"></i> <span>Processing Allocation...</span>`;
        }
        return true;
    }
</script>

<jsp:include page="../components/footer.jsp" />