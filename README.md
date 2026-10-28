# DocSlot - Role-Based Appointment Management System

A full-stack web application designed for booking and scheduling appointments between clients and service providers. Built using Java Servlets, Jakarta EE 11, JDBC, JSP, and MySQL, following the Model-View-Controller (MVC) architectural pattern.

---

## 🚀 Features

- **Multi-Role Authentication**:
  - **Admin**: Monitor appointments, manage users, and view platform statistics.
  - **Provider (Doctor/Consultant)**: Define available time slots and track incoming bookings.
  - **User (Patient/Client)**: Browse available time slots, book appointments, and cancel existing bookings.
- **Dynamic Slot Availability**: Real-time updates prevent double-booking of identical time slots.
- **Responsive UI**: Custom CSS interface for seamless interaction across desktop and tablet screens.
- **Robust Data Layer**: JDBC-driven persistence using MySQL with connection pooling principles.

---

## 🛠️ Tech Stack

- **Backend**: Java Servlets (Jakarta EE 11), JDBC
- **Frontend**: JSP (JavaServer Pages), HTML5, CSS3, JavaScript
- **Database**: MySQL Server 8.0
- **Application Server**: Apache Tomcat 11
- **Tooling**: Visual Studio Code, Git, MySQL Command Line Client

---

## 📂 Project Structure

```text
DocSlot-Appointment-System/
├── database/
│   └── schema.sql                 # Database creation and test seed data
├── src/
│   └── com/
│       └── appointment/
│           ├── servlet/           # Controller layer (AuthServlet, BookingServlet, SlotServlet)
│           └── util/              # Database connectivity (DBConnection.java)
├── web/
│   ├── css/
│   │   └── style.css              # Custom styling
│   ├── admin_dashboard.jsp        # Admin overview portal
│   ├── index.jsp                  # Authentication / Landing page
│   ├── provider_dashboard.jsp     # Slot management portal
│   └── user_dashboard.jsp         # Appointment booking dashboard
├── .gitignore
└── README.md
