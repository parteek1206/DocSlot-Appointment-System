<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Online Appointment Booking System</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
    <div class="header">
        <h2>Online Appointment Booking System</h2>
        <p>AIP Mini Project Portal</p>
    </div>

    <div class="container">
        <!-- Notification Alerts -->
        <%
            String msg = request.getParameter("msg");
            String error = request.getParameter("error");
            if (msg != null) {
        %>
            <div class="alert alert-success">Action successful: <%= msg %></div>
        <%
            }
            if (error != null) {
        %>
            <div class="alert alert-danger">Error: <%= error %></div>
        <%
            }
        %>

        <div class="grid-2">
            <!-- Login Box -->
            <div class="card">
                <h3>Sign In</h3>
                <form action="auth" method="post">
                    <input type="hidden" name="action" value="login">
                    
                    <label>Email Address</label>
                    <input type="email" name="email" required placeholder="Enter registered email">

                    <label>Password</label>
                    <input type="password" name="password" required placeholder="Enter password">

                    <button type="submit" class="btn btn-primary">Sign In</button>
                </form>
            </div>

            <!-- Registration Box -->
            <div class="card">
                <h3>Create Account</h3>
                <form action="auth" method="post">
                    <input type="hidden" name="action" value="register">

                    <label>Full Name</label>
                    <input type="text" name="fullName" required placeholder="e.g. John Doe">

                    <label>Email Address</label>
                    <input type="email" name="email" required placeholder="e.g. user@example.com">

                    <label>Password</label>
                    <input type="password" name="password" required placeholder="Create password">

                    <label>Select Role</label>
                    <select name="role" required>
                        <option value="USER">Service Seeker</option>
                        <option value="PROVIDER">Service Provider</option>
                    </select>

                    <button type="submit" class="btn btn-secondary">Register</button>
                </form>
            </div>
        </div>
    </div>
</body>
</html>