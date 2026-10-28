package com.appointment.servlet;

import com.appointment.util.DBConnection;
import java.io.IOException;
import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.Time;
import java.time.LocalTime;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/slots")
public class SlotServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    // POST: Provider naye slots generate karega
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || !"PROVIDER".equalsIgnoreCase((String) session.getAttribute("role"))) {
            response.sendRedirect("index.jsp?error=unauthorized");
            return;
        }

        int providerId = (int) session.getAttribute("userId");
        String dateStr = request.getParameter("slotDate");
        String startTimeStr = request.getParameter("startTime"); // e.g. "09:00"
        String endTimeStr = request.getParameter("endTime");     // e.g. "12:00"
        int duration = 30; // 30-minute default interval

        try (Connection conn = DBConnection.getConnection()) {
            LocalTime start = LocalTime.parse(startTimeStr);
            LocalTime end = LocalTime.parse(endTimeStr);
            Date slotDate = Date.valueOf(dateStr);

            String sql = "INSERT INTO slots (provider_id, slot_date, start_time, end_time, status) " +
                         "VALUES (?, ?, ?, ?, 'AVAILABLE') " +
                         "ON DUPLICATE KEY UPDATE status = status"; // duplicate time block reject karega
            
            PreparedStatement stmt = conn.prepareStatement(sql);

            // Loop lagakar 30-30 min ke slots table me insert karna
            while (start.plusMinutes(duration).isBefore(end) || start.plusMinutes(duration).equals(end)) {
                LocalTime nextTime = start.plusMinutes(duration);
                stmt.setInt(1, providerId);
                stmt.setDate(2, slotDate);
                stmt.setTime(3, Time.valueOf(start));
                stmt.setTime(4, Time.valueOf(nextTime));
                stmt.addBatch();
                start = nextTime;
            }

            stmt.executeBatch();
            response.sendRedirect("provider_dashboard.jsp?msg=slots_generated");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("provider_dashboard.jsp?error=generation_failed");
        }
    }

    // GET: Client ya Provider calendar ke available slots view karenge
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String providerIdStr = request.getParameter("providerId");
        String dateStr = request.getParameter("date");

        if (providerIdStr != null && dateStr != null) {
            request.setAttribute("selectedProviderId", providerIdStr);
            request.setAttribute("selectedDate", dateStr);
            request.getRequestDispatcher("user_dashboard.jsp").forward(request, response);
        } else {
            response.sendRedirect("user_dashboard.jsp");
        }
    }
}