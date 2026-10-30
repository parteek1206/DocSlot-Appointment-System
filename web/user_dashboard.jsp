<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, com.appointment.util.DBConnection" %>
<%
    if (session == null || !"USER".equalsIgnoreCase((String) session.getAttribute("role"))) {
        response.sendRedirect("index.jsp?error=session_expired");
        return;
    }
    
    Object uidObj = session.getAttribute("userId");
    if (uidObj == null) uidObj = session.getAttribute("user_id");
    int clientId = (uidObj instanceof Integer) ? (Integer) uidObj : Integer.parseInt(uidObj.toString());
    
    String userName = (String) session.getAttribute("userName");
    if (userName == null) userName = (String) session.getAttribute("user_name");
    if (userName == null) userName = "User";

    String initials = "U";
    if (!userName.trim().isEmpty()) {
        String clean = userName.replaceAll("\\(.*\\)", "").trim();
        String[] parts = clean.split("\\s+");
        if (parts.length > 1) {
            initials = ("" + parts[0].charAt(0) + parts[parts.length - 1].charAt(0)).toUpperCase();
        } else if (parts.length == 1 && !parts[0].isEmpty()) {
            initials = ("" + parts[0].charAt(0)).toUpperCase();
        }
    }

    String rawMsg = request.getParameter("msg");
    String rawError = request.getParameter("error");

    String userNotice = null;
    String userError = null;

    if (rawMsg != null) {
        String t = rawMsg.trim();
        if ("booked".equalsIgnoreCase(t) || "success".equalsIgnoreCase(t) || "booking_confirmed".equalsIgnoreCase(t)) {
            userNotice = "Your appointment slot has been reserved successfully!";
        } else if ("cancelled".equalsIgnoreCase(t)) {
            userNotice = "The appointment has been cancelled successfully.";
        } else if (!t.isEmpty()) {
            userNotice = t.replace("<", "&lt;").replace(">", "&gt;");
        }
    }

    if (rawError != null && !rawError.trim().isEmpty()) {
        String t = rawError.trim();
        if ("slot_unavailable".equalsIgnoreCase(t) || "conflict".equalsIgnoreCase(t)) {
            userError = "This appointment slot is no longer available. Please select another slot.";
        } else {
            userError = t.replace("<", "&lt;").replace(">", "&gt;");
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Seeker Dashboard - Online Appointment Booking System</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <style>
        :root {
            --brand: #0f766e;
            --brand-hover: #115e59;
            --brand-soft: #f0fdfa;
            --brand-border: #ccfbf1;
            --page-bg: #f5f7fa;
            --surface: #ffffff;
            --surface-hover: #f8fafc;
            --text-main: #1e293b;
            --text-muted: #64748b;
            --border: #e2e8f0;
            --success-bg: #ecfdf5;
            --success-text: #065f46;
            --success-border: #a7f3d0;
            --danger-bg: #fef2f2;
            --danger-text: #991b1b;
            --danger-border: #fecaca;
            --radius-md: 12px;
            --radius-lg: 18px;
            --shadow-card: 0 10px 30px rgba(15, 23, 42, 0.05);
            --shadow-dropdown: 0 16px 36px rgba(15, 23, 42, 0.12);
        }

        *, *::before, *::after {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: 'Inter', -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
        }

        body {
            background-color: var(--page-bg);
            color: var(--text-main);
            min-height: 100vh;
            display: flex;
            flex-direction: column;
        }

        /* Header Navigation */
        .site-header {
            background: rgba(255, 255, 255, 0.98);
            border-bottom: 1px solid var(--border);
            position: sticky;
            top: 0;
            z-index: 50;
        }

        .header-inner {
            max-width: 1240px;
            margin: 0 auto;
            padding: 14px 28px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .brand {
            display: inline-flex;
            align-items: center;
            gap: 12px;
            text-decoration: none;
        }

        .brand-mark {
            width: 40px;
            height: 40px;
            border-radius: 12px;
            background: var(--brand);
            color: #ffffff;
            display: grid;
            place-items: center;
            box-shadow: 0 4px 12px rgba(15, 118, 110, 0.2);
        }

        .brand-mark svg {
            width: 22px;
            height: 22px;
        }

        .brand-name {
            font-size: 1.02rem;
            font-weight: 750;
            letter-spacing: -0.02em;
            color: var(--text-main);
            line-height: 1.25;
        }

        .brand-name span {
            display: block;
            color: var(--brand);
        }

        .header-right {
            display: flex;
            align-items: center;
            gap: 16px;
            position: relative;
        }

        .portal-pill {
            background: #f0fdfa;
            color: #0f766e;
            border: 1px solid #ccfbf1;
            padding: 6px 14px;
            border-radius: 999px;
            font-size: 0.8rem;
            font-weight: 650;
        }

        .user-menu-btn {
            display: flex;
            align-items: center;
            gap: 10px;
            background: var(--surface);
            border: 1px solid var(--border);
            padding: 5px 14px 5px 6px;
            border-radius: 999px;
            cursor: pointer;
            transition: all 0.18s ease;
        }

        .user-menu-btn:hover {
            border-color: #cbd5e1;
            background: var(--surface-hover);
        }

        .user-avatar {
            width: 32px;
            height: 32px;
            border-radius: 50%;
            background: var(--brand);
            color: #ffffff;
            display: grid;
            place-items: center;
            font-size: 0.8rem;
            font-weight: 700;
        }

        .user-name {
            font-size: 0.88rem;
            font-weight: 650;
            color: var(--text-main);
            max-width: 200px;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }

        .account-dropdown {
            position: absolute;
            top: calc(100% + 10px);
            right: 0;
            width: 230px;
            background: var(--surface);
            border: 1px solid var(--border);
            border-radius: var(--radius-md);
            box-shadow: var(--shadow-dropdown);
            padding: 8px;
            display: none;
            flex-direction: column;
            z-index: 60;
        }

        .account-dropdown.show {
            display: flex;
        }

        .dropdown-header {
            padding: 10px 12px;
            border-bottom: 1px solid var(--border);
            margin-bottom: 6px;
        }

        .dropdown-header span {
            display: block;
            font-size: 0.74rem;
            color: var(--text-muted);
            text-transform: uppercase;
            font-weight: 700;
        }

        .dropdown-header b {
            font-size: 0.9rem;
            color: var(--text-main);
        }

        .dropdown-link {
            display: flex;
            align-items: center;
            gap: 10px;
            padding: 10px 12px;
            border-radius: 8px;
            text-decoration: none;
            font-size: 0.88rem;
            font-weight: 600;
            color: var(--danger-text);
            transition: background 0.15s ease;
        }

        .dropdown-link:hover {
            background: var(--danger-bg);
        }

        .dropdown-link svg {
            width: 17px;
            height: 17px;
        }

        /* Workspace */
        .workspace {
            max-width: 1240px;
            margin: 0 auto;
            padding: 40px 28px 70px;
            width: 100%;
        }

        .alert {
            display: flex;
            align-items: center;
            gap: 12px;
            padding: 14px 18px;
            border-radius: 12px;
            margin-bottom: 26px;
            font-size: 0.92rem;
            font-weight: 550;
        }

        .alert-ok {
            background: var(--success-bg);
            border: 1px solid var(--success-border);
            color: var(--success-text);
        }

        .alert-err {
            background: var(--danger-bg);
            border: 1px solid var(--danger-border);
            color: var(--danger-text);
        }

        .card {
            background: var(--surface);
            border: 1px solid var(--border);
            border-radius: var(--radius-lg);
            padding: 30px 34px;
            margin-bottom: 32px;
            box-shadow: var(--shadow-card);
        }

        .card-header {
            margin-bottom: 22px;
        }

        .card-header h2 {
            font-size: 1.3rem;
            font-weight: 750;
            color: var(--text-main);
            letter-spacing: -0.025em;
        }

        .card-header p {
            color: var(--text-muted);
            font-size: 0.9rem;
            margin-top: 4px;
        }

        /* Filter Form */
        .filter-grid {
            display: grid;
            grid-template-columns: 1.4fr 1.1fr auto;
            gap: 18px;
            align-items: end;
            background: #f8fafc;
            border: 1px solid var(--border);
            padding: 22px 24px;
            border-radius: var(--radius-md);
        }

        @media (max-width: 900px) {
            .filter-grid {
                grid-template-columns: 1fr;
            }
        }

        .form-group {
            display: flex;
            flex-direction: column;
            gap: 6px;
        }

        .form-group label {
            font-size: 0.82rem;
            font-weight: 700;
            color: var(--text-muted);
            text-transform: uppercase;
            letter-spacing: 0.04em;
        }

        .form-control {
            width: 100%;
            height: 48px;
            padding: 0 14px;
            background: var(--surface);
            border: 1.5px solid var(--border);
            border-radius: 10px;
            font-size: 0.94rem;
            color: var(--text-main);
            outline: none;
            transition: all 0.18s ease;
        }

        .form-control:focus {
            border-color: var(--brand);
            box-shadow: 0 0 0 3px rgba(15, 118, 110, 0.12);
        }

        .btn-brand {
            height: 48px;
            padding: 0 24px;
            background: var(--brand);
            color: #ffffff;
            border: none;
            border-radius: 10px;
            font-size: 0.94rem;
            font-weight: 700;
            cursor: pointer;
            transition: all 0.18s ease;
            white-space: nowrap;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
        }

        .btn-brand:hover {
            background: var(--brand-hover);
            box-shadow: 0 4px 14px rgba(15, 118, 110, 0.25);
        }

        /* Slots Grid */
        .slots-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(210px, 1fr));
            gap: 16px;
            margin-top: 14px;
        }

        .slot-card {
            background: #ffffff;
            border: 1.5px solid var(--border);
            border-radius: 12px;
            padding: 18px 20px;
            transition: all 0.18s ease;
            display: flex;
            flex-direction: column;
            gap: 12px;
            justify-content: space-between;
        }

        .slot-card.available {
            border-color: var(--brand-border);
            background: #fcfefe;
        }

        .slot-card.booked {
            background: #f8fafc;
            opacity: 0.75;
        }

        .slot-time {
            font-size: 1.02rem;
            font-weight: 750;
            color: var(--text-main);
        }

        .badge-slot-res {
            display: inline-block;
            background: #f1f5f9;
            color: #94a3b8;
            padding: 5px 10px;
            border-radius: 6px;
            font-size: 0.78rem;
            font-weight: 650;
            text-align: center;
        }

        /* Table */
        .table-wrap {
            overflow-x: auto;
            border: 1px solid var(--border);
            border-radius: 12px;
        }

        table {
            width: 100%;
            border-collapse: collapse;
            text-align: left;
        }

        thead th {
            background: #f8fafc;
            color: var(--text-muted);
            font-size: 0.79rem;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.05em;
            padding: 15px 22px;
            border-bottom: 1px solid var(--border);
        }

        tbody td {
            padding: 16px 22px;
            font-size: 0.93rem;
            color: var(--text-main);
            border-bottom: 1px solid var(--border);
            vertical-align: middle;
        }

        tbody tr:last-child td {
            border-bottom: none;
        }

        tbody tr:hover {
            background: #fcfdfe;
        }

        .badge {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 5px 12px;
            border-radius: 999px;
            font-size: 0.78rem;
            font-weight: 700;
            letter-spacing: 0.02em;
        }

        .badge.confirmed {
            background: var(--success-bg);
            color: var(--success-text);
            border: 1px solid var(--success-border);
        }

        .badge.cancelled {
            background: var(--danger-bg);
            color: var(--danger-text);
            border: 1px solid var(--danger-border);
        }

        .btn-cancel {
            padding: 6px 14px;
            border-radius: 8px;
            font-size: 0.84rem;
            font-weight: 650;
            text-decoration: none;
            color: var(--danger-text);
            background: #ffffff;
            border: 1px solid var(--danger-border);
            transition: all 0.15s ease;
            display: inline-block;
        }

        .btn-cancel:hover {
            background: var(--danger-bg);
        }

        .empty-box {
            text-align: center;
            padding: 44px 20px;
            color: var(--text-muted);
            font-size: 0.92rem;
        }

        .site-footer {
            margin-top: auto;
            border-top: 1px solid var(--border);
            background: var(--surface);
            padding: 20px;
            text-align: center;
            font-size: 0.82rem;
            color: var(--text-muted);
        }
    </style>
</head>
<body>

    <header class="site-header">
        <div class="header-inner">
            <a href="user_dashboard.jsp" class="brand">
                <span class="brand-mark">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <rect x="3" y="4" width="18" height="18" rx="2" ry="2"></rect>
                        <line x1="16" y1="2" x2="16" y2="6"></line>
                        <line x1="8" y1="2" x2="8" y2="6"></line>
                        <line x1="3" y1="10" x2="21" y2="10"></line>
                    </svg>
                </span>
                <span class="brand-name">Online Appointment<span>Booking System</span></span>
            </a>

            <div class="header-right">
                <span class="portal-pill">Seeker Portal</span>

                <button type="button" class="user-menu-btn" onclick="toggleDropdown(event)">
                    <span class="user-avatar"><%= initials %></span>
                    <span class="user-name"><%= userName %></span>
                    <svg fill="none" stroke="currentColor" viewBox="0 0 24 24" style="width:14px; height:14px; color:var(--text-muted);"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7"/></svg>
                </button>

                <div class="account-dropdown" id="accountMenu">
                    <div class="dropdown-header">
                        <span>Signed In As</span>
                        <b><%= userName %> (Client)</b>
                    </div>
                    <a href="auth?action=logout" class="dropdown-link">
                        <svg fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1"/></svg>
                        <span>Sign Out</span>
                    </a>
                </div>
            </div>
        </div>
    </header>

    <main class="workspace">
        <% if (userNotice != null) { %>
            <div class="alert alert-ok">
                <svg fill="none" stroke="currentColor" viewBox="0 0 24 24" style="width:18px;height:18px;"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"/></svg>
                <span><%= userNotice %></span>
            </div>
        <% } %>
        <% if (userError != null) { %>
            <div class="alert alert-err">
                <svg fill="none" stroke="currentColor" viewBox="0 0 24 24" style="width:18px;height:18px;"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>
                <span><%= userError %></span>
            </div>
        <% } %>

        <!-- SECTION 1: Find & Filter Consultation Slots -->
        <section class="card">
            <div class="card-header">
                <h2>Find &amp; Book Consultation Slots</h2>
                <p>Select your desired consultant and target date to inspect live available appointment windows.</p>
            </div>

            <form action="slots" method="get">
                <div class="filter-grid">
                    <div class="form-group">
                        <label for="providerId">Select Service Provider</label>
                        <select id="providerId" name="providerId" class="form-control" required>
                            <option value="">-- Choose Consultant --</option>
                            <%
                                try (Connection conn = DBConnection.getConnection()) {
                                    PreparedStatement ps = conn.prepareStatement("SELECT user_id, full_name FROM users WHERE role = 'PROVIDER' ORDER BY user_id ASC");
                                    ResultSet rs = ps.executeQuery();
                                    while (rs.next()) {
                            %>
                                <option value="<%= rs.getInt("user_id") %>"><%= rs.getString("full_name") %></option>
                            <%
                                    }
                                } catch (Exception e) { e.printStackTrace(); }
                            %>
                        </select>
                    </div>

                    <div class="form-group">
                        <label for="dateSelect">Select Date</label>
                        <input type="date" id="dateSelect" name="date" class="form-control" required>
                    </div>

                    <div>
                        <button type="submit" class="btn-brand">
                            <svg fill="none" stroke="currentColor" viewBox="0 0 24 24" style="width:17px;height:17px;"><circle cx="11" cy="11" r="8"></circle><line x1="21" y1="21" x2="16.65" y2="16.65"></line></svg>
                            <span>Check Availability</span>
                        </button>
                    </div>
                </div>
            </form>
        </section>

        <!-- SECTION 2: Dynamic Available Slots Grid (When filter requested) -->
        <%
            String selectedProvider = (String) request.getAttribute("selectedProviderId");
            String selectedDate = (String) request.getAttribute("selectedDate");

            if (selectedProvider != null && selectedDate != null) {
        %>
            <section class="card">
                <div class="card-header">
                    <h2>Available Time Windows (<%= selectedDate %>)</h2>
                    <p>Click on an open time window to instantly confirm your consultation booking.</p>
                </div>

                <div class="slots-grid">
                    <%
                        try (Connection conn = DBConnection.getConnection()) {
                            String sql = "SELECT slot_id, start_time, end_time, status FROM slots WHERE provider_id = ? AND slot_date = ? ORDER BY start_time ASC";
                            PreparedStatement ps = conn.prepareStatement(sql);
                            ps.setInt(1, Integer.parseInt(selectedProvider));
                            ps.setDate(2, Date.valueOf(selectedDate));
                            ResultSet rs = ps.executeQuery();

                            boolean hasSlots = false;
                            while (rs.next()) {
                                hasSlots = true;
                                int slotId = rs.getInt("slot_id");
                                String start = rs.getString("start_time");
                                String end = rs.getString("end_time");
                                String status = rs.getString("status");
                                boolean isAvail = "AVAILABLE".equalsIgnoreCase(status);
                    %>
                        <div class="slot-card <%= isAvail ? "available" : "booked" %>">
                            <div>
                                <div style="font-size:0.76rem; font-weight:700; color:var(--text-muted); text-transform:uppercase; margin-bottom:4px;">Slot Interval</div>
                                <div class="slot-time"><%= start.substring(0, 5) %> - <%= end.substring(0, 5) %></div>
                            </div>
                            <div>
                                <% if (isAvail) { %>
                                    <form action="book" method="post" style="margin:0;">
                                        <input type="hidden" name="slotId" value="<%= slotId %>">
                                        <button type="submit" class="btn-brand" style="width:100%; height:40px; font-size:0.86rem;">Book Slot</button>
                                    </form>
                                <% } else { %>
                                    <div class="badge-slot-res">Reserved</div>
                                <% } %>
                            </div>
                        </div>
                    <%
                            }
                            if (!hasSlots) {
                    %>
                        <div class="empty-box" style="grid-column: 1 / -1;">No slots generated by the selected consultant for this date.</div>
                    <%
                            }
                        } catch (Exception e) { e.printStackTrace(); }
                    %>
                </div>
            </section>
        <%
            }
        %>

        <!-- SECTION 3: Active Bookings Ledger -->
        <section class="card">
            <div class="card-header">
                <h2>My Scheduled Appointments</h2>
                <p>Chronological ledger of your registered appointments and live booking states.</p>
            </div>

            <div class="table-wrap">
                <table>
                    <thead>
                        <tr>
                            <th>Appt Ref</th>
                            <th>Provider / Consultant</th>
                            <th>Consultation Date</th>
                            <th>Time Window</th>
                            <th>Status</th>
                            <th>Action</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            try (Connection conn = DBConnection.getConnection()) {
                                String sql = "SELECT a.appointment_id, a.booking_status, s.slot_id, s.slot_date, s.start_time, s.end_time, u.full_name " +
                                             "FROM appointments a " +
                                             "JOIN slots s ON a.slot_id = s.slot_id " +
                                             "JOIN users u ON s.provider_id = u.user_id " +
                                             "WHERE a.client_id = ? ORDER BY s.slot_date DESC, s.start_time DESC";
                                PreparedStatement ps = conn.prepareStatement(sql);
                                ps.setInt(1, clientId);
                                ResultSet rs = ps.executeQuery();

                                boolean hasAppt = false;
                                while (rs.next()) {
                                    hasAppt = true;
                                    int apptId = rs.getInt("appointment_id");
                                    int slotId = rs.getInt("slot_id");
                                    String status = rs.getString("booking_status");
                                    boolean isConfirmed = "CONFIRMED".equalsIgnoreCase(status);
                        %>
                            <tr>
                                <td><b>#APT-<%= apptId %></b></td>
                                <td><b><%= rs.getString("full_name") %></b></td>
                                <td><%= rs.getDate("slot_date") %></td>
                                <td><%= rs.getString("start_time").substring(0, 5) %> - <%= rs.getString("end_time").substring(0, 5) %></td>
                                <td>
                                    <span class="badge <%= isConfirmed ? "confirmed" : "cancelled" %>">
                                        <%= status %>
                                    </span>
                                </td>
                                <td>
                                    <% if (isConfirmed) { %>
                                        <a href="book?action=cancel&apptId=<%= apptId %>&slotId=<%= slotId %>" 
                                           class="btn-cancel" 
                                           onclick="return confirm('Are you sure you want to cancel appointment #APT-<%= apptId %>?');">Cancel</a>
                                    <% } else { %>
                                        <span style="color:var(--text-muted); font-size:0.84rem;">Closed</span>
                                    <% } %>
                                </td>
                            </tr>
                        <%
                                }
                                if (!hasAppt) {
                        %>
                            <tr>
                                <td colspan="6" class="empty-box">No appointments found. Choose a consultant and date above to reserve a slot.</td>
                            </tr>
                        <%
                                }
                            } catch (Exception e) { e.printStackTrace(); }
                        %>
                    </tbody>
                </table>
            </div>
        </section>
    </main>

    <footer class="site-footer">
        &copy; <%= java.time.Year.now().getValue() %> Online Appointment Booking System. All rights reserved.
    </footer>

    <script>
        (function initToday() {
            var today = new Date().toISOString().split('T')[0];
            var d = document.getElementById('dateSelect');
            if (d && !d.value) {
                d.min = today;
                d.value = today;
            }
        })();

        function toggleDropdown(e) {
            e.stopPropagation();
            document.getElementById('accountMenu').classList.toggle('show');
        }

        window.addEventListener('click', function() {
            var m = document.getElementById('accountMenu');
            if (m) m.classList.remove('show');
        });
    </script>
</body>
</html>