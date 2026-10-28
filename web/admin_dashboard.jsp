<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, com.appointment.util.DBConnection" %>
<%
    // Session validation for ADMIN
    if (session == null || !"ADMIN".equalsIgnoreCase((String) session.getAttribute("role"))) {
        response.sendRedirect("index.jsp?error=unauthorized");
        return;
    }
    String userName = (String) session.getAttribute("userName");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Admin Dashboard - System Management</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
    <div class="navbar">
        <h2>Online Appointment System</h2>
        <div>
            <span>Welcome, <strong><%= userName %></strong> (Administrator)</span>
            <a href="auth?action=logout" class="btn-logout">Logout</a>
        </div>
    </div>

    <div class="container">
        <!-- Metric Cards -->
        <%
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
        <div class="grid-3">
            <div class="card stat-card">
                <h4>Total Clients</h4>
                <p class="stat-number"><%= totalUsers %></p>
            </div>
            <div class="card stat-card">
                <h4>Active Providers</h4>
                <p class="stat-number"><%= totalProviders %></p>
            </div>
            <div class="card stat-card">
                <h4>Total Appointments</h4>
                <p class="stat-number"><%= totalBookings %></p>
            </div>
        </div>

        <!-- 1. Registered Users Registry -->
        <div class="card">
            <h3>Registered System Users</h3>
            <table class="table">
                <thead>
                    <tr>
                        <th>User ID</th>
                        <th>Full Name</th>
                        <th>Email Address</th>
                        <th>Role</th>
                        <th>Created At</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                        try (Connection conn = DBConnection.getConnection()) {
                            Statement stmt = conn.createStatement();
                            ResultSet rs = stmt.executeQuery("SELECT user_id, full_name, email, role, created_at FROM users ORDER BY user_id DESC");
                            while (rs.next()) {
                    %>
                        <tr>
                            <td>#<%= rs.getInt("user_id") %></td>
                            <td><%= rs.getString("full_name") %></td>
                            <td><%= rs.getString("email") %></td>
                            <td><span class="badge <%= rs.getString("role").toLowerCase() %>"><%= rs.getString("role") %></span></td>
                            <td><%= rs.getTimestamp("created_at") %></td>
                        </tr>
                    <%
                            }
                        } catch (Exception e) { e.printStackTrace(); }
                    %>
                </tbody>
            </table>
        </div>

        <!-- 2. Master Appointments Ledger -->
        <div class="card">
            <h3>Master Appointments Audit Ledger</h3>
            <table class="table">
                <thead>
                    <tr>
                        <th>Appt ID</th>
                        <th>Client</th>
                        <th>Provider</th>
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
                    %>
                        <tr>
                            <td>APT-<%= rs.getInt("appointment_id") %></td>
                            <td><%= rs.getString("client_name") %></td>
                            <td><%= rs.getString("provider_name") %></td>
                            <td><%= rs.getDate("slot_date") %></td>
                            <td><%= rs.getString("start_time").substring(0, 5) %> - <%= rs.getString("end_time").substring(0, 5) %></td>
                            <td><span class="badge <%= status.toLowerCase() %>"><%= status %></span></td>
                        </tr>
                    <%
                            }
                            if (!hasData) {
                    %>
                        <tr>
                            <td colspan="6" style="text-align:center;">No appointment transactions recorded yet.</td>
                        </tr>
                    <%
                            }
                        } catch (Exception e) { e.printStackTrace(); }
                    %>
                </tbody>
            </table>
        </div>
    </div>
</body>
</html>