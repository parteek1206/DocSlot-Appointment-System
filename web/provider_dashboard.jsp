<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, com.appointment.util.DBConnection" %>
<%
    // Session validation for PROVIDER
    if (session == null || !"PROVIDER".equalsIgnoreCase((String) session.getAttribute("role"))) {
        response.sendRedirect("index.jsp?error=unauthorized");
        return;
    }
    int providerId = (int) session.getAttribute("userId");
    String userName = (String) session.getAttribute("userName");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Provider Dashboard - Manage Schedule</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
    <div class="navbar">
        <h2>Online Appointment System</h2>
        <div>
            <span>Welcome, <strong><%= userName %></strong> (Provider)</span>
            <a href="auth?action=logout" class="btn-logout">Logout</a>
        </div>
    </div>

    <div class="container">
        <%
            String msg = request.getParameter("msg");
            String error = request.getParameter("error");
            if (msg != null) {
        %>
            <div class="alert alert-success">Update: <%= msg %></div>
        <%
            }
            if (error != null) {
        %>
            <div class="alert alert-danger">Error: <%= error %></div>
        <%
            }
        %>

        <!-- 1. Generate Slots Form -->
        <div class="card">
            <h3>Configure Working Hours & Generate 30-Min Slots</h3>
            <form action="slots" method="post" class="filter-form">
                <div>
                    <label>Date:</label>
                    <input type="date" name="slotDate" required>
                </div>
                <div>
                    <label>Shift Start Time:</label>
                    <input type="time" name="startTime" value="09:00" required>
                </div>
                <div>
                    <label>Shift End Time:</label>
                    <input type="time" name="endTime" value="13:00" required>
                </div>
                <div>
                    <label>&nbsp;</label>
                    <button type="submit" class="btn btn-primary">+ Generate Slots</button>
                </div>
            </form>
        </div>

        <!-- 2. Upcoming Booked Consultations -->
        <div class="card">
            <h3>Upcoming Client Appointments</h3>
            <table class="table">
                <thead>
                    <tr>
                        <th>Appt ID</th>
                        <th>Client Name</th>
                        <th>Client Email</th>
                        <th>Date</th>
                        <th>Time Window</th>
                        <th>Status</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                        try (Connection conn = DBConnection.getConnection()) {
                            String sql = "SELECT a.appointment_id, a.booking_status, s.slot_date, s.start_time, s.end_time, u.full_name, u.email " +
                                         "FROM appointments a " +
                                         "JOIN slots s ON a.slot_id = s.slot_id " +
                                         "JOIN users u ON a.client_id = u.user_id " +
                                         "WHERE s.provider_id = ? ORDER BY s.slot_date DESC, s.start_time ASC";
                            PreparedStatement ps = conn.prepareStatement(sql);
                            ps.setInt(1, providerId);
                            ResultSet rs = ps.executeQuery();

                            boolean hasData = false;
                            while (rs.next()) {
                                hasData = true;
                                String status = rs.getString("booking_status");
                    %>
                        <tr>
                            <td>APT-<%= rs.getInt("appointment_id") %></td>
                            <td><strong><%= rs.getString("full_name") %></strong></td>
                            <td><%= rs.getString("email") %></td>
                            <td><%= rs.getDate("slot_date") %></td>
                            <td><%= rs.getString("start_time").substring(0, 5) %> - <%= rs.getString("end_time").substring(0, 5) %></td>
                            <td><span class="badge <%= status.toLowerCase() %>"><%= status %></span></td>
                        </tr>
                    <%
                            }
                            if (!hasData) {
                    %>
                        <tr>
                            <td colspan="6" style="text-align:center;">No client bookings scheduled yet.</td>
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