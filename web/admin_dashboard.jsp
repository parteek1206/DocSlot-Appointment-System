<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, com.appointment.util.DBConnection" %>
<%
    if (session == null || !"ADMIN".equalsIgnoreCase((String) session.getAttribute("role"))) {
        response.sendRedirect("index.jsp?error=unauthorized");
        return;
    }
    
    String userName = (String) session.getAttribute("userName");
    if (userName == null) userName = (String) session.getAttribute("user_name");
    if (userName == null) userName = "Administrator";

    int totalUsers = 0, totalProviders = 0, totalBookings = 0;
    try (Connection conn = DBConnection.getConnection()) {
        Statement stmt = conn.createStatement();
        ResultSet rs1 = stmt.executeQuery("SELECT COUNT(*) FROM users WHERE role = 'USER'");
        if (rs1.next()) totalUsers = rs1.getInt(1);

        ResultSet rs2 = stmt.executeQuery("SELECT COUNT(*) FROM users WHERE role = 'PROVIDER'");
        if (rs2.next()) totalProviders = rs2.getInt(1);

        ResultSet rs3 = stmt.executeQuery("SELECT COUNT(*) FROM appointments");
        if (rs3.next()) totalBookings = rs3.getInt(1);
    } catch (Exception e) { e.printStackTrace(); }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard - System Management</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <style>
        :root {
            --brand: #0f766e;
            --brand-hover: #115e59;
            --brand-soft: #f0fdfa;
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

        .admin-badge {
            background: #fef3c7;
            color: #92400e;
            border: 1px solid #fde68a;
            padding: 5px 12px;
            border-radius: 999px;
            font-size: 0.78rem;
            font-weight: 700;
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

        .user-avatar {
            width: 32px;
            height: 32px;
            border-radius: 50%;
            background: #0f766e;
            color: #ffffff;
            display: grid;
            place-items: center;
            font-size: 0.8rem;
            font-weight: 700;
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

        .dropdown-header b { font-size: 0.88rem; color: var(--text-main); }

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

        /* Stat Metrics Grid */
        .stat-grid {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 20px;
            margin-bottom: 32px;
        }

        @media (max-width: 800px) {
            .stat-grid { grid-template-columns: 1fr; }
        }

        .stat-card {
            background: var(--surface);
            border: 1px solid var(--border);
            border-radius: var(--radius-lg);
            padding: 24px 28px;
            box-shadow: var(--shadow-card);
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .stat-meta h4 {
            font-size: 0.84rem;
            font-weight: 700;
            color: var(--text-muted);
            text-transform: uppercase;
            letter-spacing: 0.05em;
            margin-bottom: 6px;
        }

        .stat-number {
            font-size: 2.2rem;
            font-weight: 800;
            color: var(--text-main);
            letter-spacing: -0.03em;
        }

        .stat-icon {
            width: 48px;
            height: 48px;
            border-radius: 12px;
            background: var(--brand-soft);
            color: var(--brand);
            display: grid;
            place-items: center;
        }

        .stat-icon svg { width: 24px; height: 24px; }

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

        .role-pill {
            display: inline-block;
            padding: 4px 10px;
            border-radius: 999px;
            font-size: 0.75rem;
            font-weight: 750;
            text-transform: uppercase;
        }

        .role-user { background: #eff6ff; color: #1d4ed8; border: 1px solid #bfdbfe; }
        .role-provider { background: #f0fdfa; color: #0f766e; border: 1px solid #99f6e4; }
        .role-admin { background: #fef3c7; color: #92400e; border: 1px solid #fde68a; }

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
            <a href="admin_dashboard.jsp" class="brand">
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
                <span class="admin-badge">Admin Control Panel</span>

                <button type="button" class="user-menu-btn" onclick="toggleDropdown(event)">
                    <span class="user-avatar">AD</span>
                    <span style="font-size:0.88rem; font-weight:650;"><%= userName %></span>
                    <svg fill="none" stroke="currentColor" viewBox="0 0 24 24" style="width:14px; height:14px; color:var(--text-muted);"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7"/></svg>
                </button>

                <div class="account-dropdown" id="accountMenu">
                    <div class="dropdown-header">
                        <span>Signed In As</span>
                        <b><%= userName %> (Super Admin)</b>
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
        <!-- 3 Stat Metrics -->
        <div class="stat-grid">
            <div class="stat-card">
                <div class="stat-meta">
                    <h4>Total Clients</h4>
                    <div class="stat-number"><%= totalUsers %></div>
                </div>
                <div class="stat-icon">
                    <svg fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z"/></svg>
                </div>
            </div>

            <div class="stat-card">
                <div class="stat-meta">
                    <h4>Active Providers</h4>
                    <div class="stat-number"><%= totalProviders %></div>
                </div>
                <div class="stat-icon">
                    <svg fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4"/></svg>
                </div>
            </div>

            <div class="stat-card">
                <div class="stat-meta">
                    <h4>Total Appointments</h4>
                    <div class="stat-number"><%= totalBookings %></div>
                </div>
                <div class="stat-icon">
                    <svg fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z"/></svg>
                </div>
            </div>
        </div>

        <!-- 1. Registered Users Registry -->
        <section class="card">
            <div class="card-header">
                <h2>Registered System Users</h2>
                <p>Global directory of registered clients, consulting providers, and system administrators.</p>
            </div>

            <div class="table-wrap">
                <table>
                    <thead>
                        <tr>
                            <th>User ID</th>
                            <th>Full Legal Name</th>
                            <th>Email Address</th>
                            <th>Assigned Role</th>
                            <th>Registration Timestamp</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            try (Connection conn = DBConnection.getConnection()) {
                                Statement stmt = conn.createStatement();
                                ResultSet rs = stmt.executeQuery("SELECT user_id, full_name, email, role, created_at FROM users ORDER BY user_id DESC");
                                while (rs.next()) {
                                    String r = rs.getString("role").toUpperCase();
                                    String rClass = "role-user";
                                    if ("PROVIDER".equals(r)) rClass = "role-provider";
                                    if ("ADMIN".equals(r)) rClass = "role-admin";
                        %>
                            <tr>
                                <td><b>#<%= rs.getInt("user_id") %></b></td>
                                <td><b><%= rs.getString("full_name") %></b></td>
                                <td><%= rs.getString("email") %></td>
                                <td><span class="role-pill <%= rClass %>"><%= r %></span></td>
                                <td><%= rs.getTimestamp("created_at") %></td>
                            </tr>
                        <%
                                }
                            } catch (Exception e) { e.printStackTrace(); }
                        %>
                    </tbody>
                </table>
            </div>
        </section>

        <!-- 2. Master Appointments Ledger -->
        <section class="card">
            <div class="card-header">
                <h2>Master Appointments Audit Ledger</h2>
                <p>Cross-system transaction log detailing scheduled consultations, assigned doctors, and current states.</p>
            </div>

            <div class="table-wrap">
                <table>
                    <thead>
                        <tr>
                            <th>Appt Ref</th>
                            <th>Client Legal Name</th>
                            <th>Service Provider</th>
                            <th>Date</th>
                            <th>Time Window</th>
                            <th>Status</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            try (Connection conn = DBConnection.getConnection()) {
                                String sql = "SELECT a.appointment_id, a.booking_status, s.slot_date, s.start_time, s.end_time, " +
                                             "u1.full_name AS client_name, u2.full_name AS provider_name " +
                                             "FROM appointments a " +
                                             "JOIN slots s ON a.slot_id = s.slot_id " +
                                             "JOIN users u1 ON a.client_id = u1.user_id " +
                                             "JOIN users u2 ON s.provider_id = u2.user_id " +
                                             "ORDER BY a.appointment_id DESC";
                                Statement stmt = conn.createStatement();
                                ResultSet rs = stmt.executeQuery(sql);

                                boolean hasData = false;
                                while (rs.next()) {
                                    hasData = true;
                                    String status = rs.getString("booking_status");
                                    boolean isConf = "CONFIRMED".equalsIgnoreCase(status);
                        %>
                            <tr>
                                <td><b>#APT-<%= rs.getInt("appointment_id") %></b></td>
                                <td><%= rs.getString("client_name") %></td>
                                <td><b><%= rs.getString("provider_name") %></b></td>
                                <td><%= rs.getDate("slot_date") %></td>
                                <td><%= rs.getString("start_time").substring(0, 5) %> - <%= rs.getString("end_time").substring(0, 5) %></td>
                                <td>
                                    <span class="role-pill <%= isConf ? "role-provider" : "role-admin" %>">
                                        <%= status %>
                                    </span>
                                </td>
                            </tr>
                        <%
                                }
                                if (!hasData) {
                        %>
                            <tr>
                                <td colspan="6" style="text-align:center; padding:36px; color:var(--text-muted);">No appointment transactions recorded yet.</td>
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