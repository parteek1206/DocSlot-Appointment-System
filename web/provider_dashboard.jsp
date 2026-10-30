<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, com.appointment.util.DBConnection" %>
<%
    if (session == null || !"PROVIDER".equalsIgnoreCase((String) session.getAttribute("role"))) {
        response.sendRedirect("index.jsp?error=session_expired");
        return;
    }

    Object pObj = session.getAttribute("userId");
    if (pObj == null) pObj = session.getAttribute("user_id");
    int providerId = (pObj instanceof Integer) ? (Integer) pObj : Integer.parseInt(pObj.toString());

    String providerName = (String) session.getAttribute("userName");
    if (providerName == null) providerName = (String) session.getAttribute("user_name");
    if (providerName == null) providerName = "Provider";

    String initials = "P";
    if (!providerName.trim().isEmpty()) {
        String clean = providerName.replaceAll("\\(.*\\)", "").trim();
        String[] parts = clean.split("\\s+");
        if (parts.length > 1) {
            initials = ("" + parts[0].charAt(0) + parts[parts.length - 1].charAt(0)).toUpperCase();
        } else if (parts.length == 1 && !parts[0].isEmpty()) {
            initials = ("" + parts[0].charAt(0)).toUpperCase();
        }
    }

    String rawMsg = request.getParameter("msg");
    String rawError = request.getParameter("error");

    String displayNotice = null;
    String displayError = null;

    if (rawMsg != null) {
        String t = rawMsg.trim();
        if ("slots_generated".equalsIgnoreCase(t) || "success".equalsIgnoreCase(t)) {
            displayNotice = "Time slots generated successfully for the selected shift.";
        } else if (!t.isEmpty()) {
            displayNotice = t.replace("<", "&lt;").replace(">", "&gt;");
        }
    }

    if (rawError != null && !rawError.trim().isEmpty()) {
        displayError = rawError.trim().replace("<", "&lt;").replace(">", "&gt;");
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Provider Workspace - Online Appointment Booking System</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <style>
        :root {
            --brand: #0f766e;
            --brand-hover: #115e59;
            --brand-soft: #f0fdfa;
            --brand-border: #ccfbf1;
            --page-bg: #f5f7fa;
            --surface: #ffffff;
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
            font-family: 'Inter', -apple-system, sans-serif;
        }

        body {
            background-color: var(--page-bg);
            color: var(--text-main);
            min-height: 100vh;
            display: flex;
            flex-direction: column;
        }

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

        .brand-mark svg { width: 22px; height: 22px; }

        .brand-name {
            font-size: 1.02rem;
            font-weight: 750;
            letter-spacing: -0.02em;
            color: var(--text-main);
            line-height: 1.25;
        }

        .brand-name span { display: block; color: var(--brand); }

        .header-right {
            display: flex;
            align-items: center;
            gap: 14px;
            position: relative;
        }

        .provider-tag {
            background: #f0fdfa;
            color: var(--brand);
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
            background: #f8fafc;
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
            max-width: 220px;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }

        .account-dropdown {
            position: absolute;
            top: calc(100% + 10px);
            right: 0;
            width: 240px;
            background: var(--surface);
            border: 1px solid var(--border);
            border-radius: var(--radius-md);
            box-shadow: var(--shadow-dropdown);
            padding: 8px;
            display: none;
            flex-direction: column;
            z-index: 60;
        }

        .account-dropdown.show { display: flex; }

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
            font-size: 0.88rem;
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

        .dropdown-link:hover { background: var(--danger-bg); }
        .dropdown-link svg { width: 17px; height: 17px; }

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
            margin-bottom: 22px;
        }

        .slot-form-grid {
            display: grid;
            grid-template-columns: 1.2fr 1fr 1fr auto;
            gap: 18px;
            align-items: end;
            background: #f8fafc;
            border: 1px solid var(--border);
            padding: 22px 24px;
            border-radius: var(--radius-md);
        }

        @media (max-width: 900px) {
            .slot-form-grid { grid-template-columns: 1fr; }
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

        .btn-generate {
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

        .btn-generate:hover {
            background: var(--brand-hover);
            box-shadow: 0 4px 14px rgba(15, 118, 110, 0.25);
        }

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

        tbody tr:last-child td { border-bottom: none; }
        tbody tr:hover { background: #fcfdfe; }

        .badge {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 5px 12px;
            border-radius: 999px;
            font-size: 0.78rem;
            font-weight: 700;
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
            <a href="provider_dashboard.jsp" class="brand">
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
                <span class="provider-tag">Provider Workspace</span>

                <button type="button" class="user-menu-btn" onclick="toggleDropdown(event)">
                    <span class="user-avatar"><%= initials %></span>
                    <span class="user-name"><%= providerName %></span>
                    <svg fill="none" stroke="currentColor" viewBox="0 0 24 24" style="width:14px; height:14px; color:var(--text-muted);"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7"/></svg>
                </button>

                <div class="account-dropdown" id="accountMenu">
                    <div class="dropdown-header">
                        <span>Signed In As</span>
                        <b><%= providerName %></b>
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
        <% if (displayNotice != null) { %>
            <div class="alert alert-ok">
                <svg fill="none" stroke="currentColor" viewBox="0 0 24 24" style="width:18px;height:18px;"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"/></svg>
                <span><%= displayNotice %></span>
            </div>
        <% } %>
        <% if (displayError != null) { %>
            <div class="alert alert-err">
                <svg fill="none" stroke="currentColor" viewBox="0 0 24 24" style="width:18px;height:18px;"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>
                <span><%= displayError %></span>
            </div>
        <% } %>

        <!-- SECTION 1: Configure Shift & Generate Slots -->
        <section class="card">
            <div class="card-header">
                <h2>Configure Working Hours &amp; Generate 30-Min Slots</h2>
                <p>Define your consulting date, working shift start, and shift end time to populate bookable intervals for clients.</p>
            </div>

            <form action="slots" method="post">
                <input type="hidden" name="action" value="generate">

                <div class="slot-form-grid">
                    <div class="form-group">
                        <label for="slotDate">Consulting Date</label>
                        <!-- name="slotDate" karein -->
                        <input type="date" id="slotDate" name="slotDate" class="form-control" required>
                    </div>

                    <div class="form-group">
                        <label for="startTime">Shift Start Time</label>
                        <input type="time" id="startTime" name="startTime" class="form-control" value="09:00" required>
                    </div>

                    <div class="form-group">
                        <label for="endTime">Shift End Time</label>
                        <input type="time" id="endTime" name="endTime" class="form-control" value="13:00" required>
                    </div>

                    <div>
                        <button type="submit" class="btn-generate">
                            <svg fill="none" stroke="currentColor" viewBox="0 0 24 24" style="width:17px;height:17px;"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6"/></svg>
                            <span>Generate Slots</span>
                        </button>
                    </div>
                </div>
            </form>
        </section>

        <!-- SECTION 2: Upcoming Client Bookings Table -->
        <section class="card">
            <div class="card-header">
                <h2>Upcoming Client Appointments</h2>
                <p>Real-time log of confirmed consultations booked by service seekers.</p>
            </div>

            <div class="table-wrap">
                <table>
                    <thead>
                        <tr>
                            <th>Appt Ref</th>
                            <th>Client Full Name</th>
                            <th>Client Registered Email</th>
                            <th>Scheduled Date</th>
                            <th>Time Window</th>
                            <th>Booking Status</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            try (Connection conn = DBConnection.getConnection()) {
                                String sql = "SELECT a.appointment_id, a.booking_status, s.slot_date, s.start_time, s.end_time, u.full_name, u.email " +
                                             "FROM appointments a " +
                                             "JOIN slots s ON a.slot_id = s.slot_id " +
                                             "JOIN users u ON a.client_id = u.user_id " +
                                             "WHERE s.provider_id = ? " +
                                             "ORDER BY s.slot_date ASC, s.start_time ASC";
                                PreparedStatement ps = conn.prepareStatement(sql);
                                ps.setInt(1, providerId);
                                ResultSet rs = ps.executeQuery();

                                boolean hasData = false;
                                while (rs.next()) {
                                    hasData = true;
                                    int apptId = rs.getInt("appointment_id");
                                    String cName = rs.getString("full_name");
                                    String cEmail = rs.getString("email");
                                    Date aDate = rs.getDate("slot_date");
                                    Time aTime = rs.getTime("start_time");
                                    Time eTime = rs.getTime("end_time");
                                    String status = rs.getString("booking_status");
                                    boolean isConfirmed = "CONFIRMED".equalsIgnoreCase(status);
                        %>
                            <tr>
                                <td><b>#APT-<%= apptId %></b></td>
                                <td><b><%= cName %></b></td>
                                <td><%= cEmail %></td>
                                <td><%= aDate %></td>
                                <td><%= aTime.toString().substring(0, 5) %> - <%= eTime.toString().substring(0, 5) %></td>
                                <td>
                                    <span class="badge <%= isConfirmed ? "confirmed" : "cancelled" %>">
                                        <%= status %>
                                    </span>
                                </td>
                            </tr>
                        <%
                                }
                                if (!hasData) {
                        %>
                            <tr>
                                <td colspan="6" class="empty-box">No booked appointments found. Generate open slots above to accept client reservations.</td>
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
            var d = document.getElementById('slotDate');
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