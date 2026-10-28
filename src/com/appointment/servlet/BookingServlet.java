package com.appointment.servlet;

import com.appointment.util.DBConnection;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/book")
public class BookingServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    // POST: Client appointment book karega (with Row Locking)
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || !"USER".equalsIgnoreCase((String) session.getAttribute("role"))) {
            response.sendRedirect("index.jsp?error=unauthorized");
            return;
        }

        int clientId = (int) session.getAttribute("userId");
        int slotId = Integer.parseInt(request.getParameter("slotId"));

        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false); // ACID Transaction shuru

            // 1. Row ko lock karein taaki doosra user simultaneous access na kare
            String lockSql = "SELECT status FROM slots WHERE slot_id = ? FOR UPDATE";
            PreparedStatement lockStmt = conn.prepareStatement(lockSql);
            lockStmt.setInt(1, slotId);
            ResultSet rs = lockStmt.executeQuery();

            if (rs.next() && "AVAILABLE".equalsIgnoreCase(rs.getString("status"))) {
                // 2. Slot status ko BOOKED update karein
                String updateSlotSql = "UPDATE slots SET status = 'BOOKED' WHERE slot_id = ?";
                PreparedStatement updateSlotStmt = conn.prepareStatement(updateSlotSql);
                updateSlotStmt.setInt(1, slotId);
                updateSlotStmt.executeUpdate();

                // 3. Appointments table me record insert karein
                String insertApptSql = "INSERT INTO appointments (slot_id, client_id, booking_status) VALUES (?, ?, 'CONFIRMED')";
                PreparedStatement insertApptStmt = conn.prepareStatement(insertApptSql);
                insertApptStmt.setInt(1, slotId);
                insertApptStmt.setInt(2, clientId);
                insertApptStmt.executeUpdate();

                conn.commit(); // Transaction Successful! Commit changes
                response.sendRedirect("user_dashboard.jsp?msg=booking_confirmed");
            } else {
                conn.rollback(); // Race condition: Kisi aur user ne book kar liya
                response.sendRedirect("user_dashboard.jsp?error=slot_already_booked");
            }
        } catch (Exception e) {
            if (conn != null) {
                try {
                    conn.rollback(); // Error aane par rollback
                } catch (Exception ex) {
                    ex.printStackTrace();
                }
            }
            e.printStackTrace();
            response.sendRedirect("user_dashboard.jsp?error=booking_failed");
        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                    conn.close();
                } catch (Exception ex) {
                    ex.printStackTrace();
                }
            }
        }
    }

    // GET: Appointment cancel karne ke liye (/book?action=cancel&apptId=...)
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null) {
            response.sendRedirect("index.jsp");
            return;
        }

        String action = request.getParameter("action");
        if ("cancel".equalsIgnoreCase(action)) {
            int apptId = Integer.parseInt(request.getParameter("apptId"));
            int slotId = Integer.parseInt(request.getParameter("slotId"));

            Connection conn = null;
            try {
                conn = DBConnection.getConnection();
                conn.setAutoCommit(false);

                // Status CANCELLED karein
                String cancelSql = "UPDATE appointments SET booking_status = 'CANCELLED' WHERE appointment_id = ?";
                PreparedStatement cancelStmt = conn.prepareStatement(cancelSql);
                cancelStmt.setInt(1, apptId);
                cancelStmt.executeUpdate();

                // Slot ko wapas AVAILABLE banayein
                String freeSlotSql = "UPDATE slots SET status = 'AVAILABLE' WHERE slot_id = ?";
                PreparedStatement freeSlotStmt = conn.prepareStatement(freeSlotSql);
                freeSlotStmt.setInt(1, slotId);
                freeSlotStmt.executeUpdate();

                conn.commit();
                response.sendRedirect("user_dashboard.jsp?msg=cancelled_successfully");
            } catch (Exception e) {
                if (conn != null) {
                    try { conn.rollback(); } catch (Exception ex) {}
                }
                e.printStackTrace();
                response.sendRedirect("user_dashboard.jsp?error=cancel_failed");
            } finally {
                if (conn != null) {
                    try {
                        conn.setAutoCommit(true);
                        conn.close();
                    } catch (Exception ex) {}
                }
            }
        }
    }
}