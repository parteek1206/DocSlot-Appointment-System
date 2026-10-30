# Online Appointment Booking System

An enterprise-grade, role-based scheduling and appointment booking platform engineered with Java Servlets (Jakarta EE 11), JSP, JDBC, and MySQL, adhering strictly to the Model-View-Controller (MVC) architectural pattern. The system implements ACID-compliant database locking to eliminate concurrency race conditions and prevent double-booking of identical time slots.

---

## 🚀 Key Features

* **Multi-Role Authentication & Access Control**:
  * **System Administrator**: Full platform visibility, real-time metric cards (total clients, active providers, scheduled consultations), user registry, and master appointment audit log.
  * **Service Provider (Consultant/Doctor)**: Configure custom working hours/shifts, auto-generate granular 30-minute consultation slots, and track incoming client bookings.
  * **Service Seeker (Client/User)**: Real-time provider and calendar date filtering, interactive slot reservation grid, and self-service appointment cancellation.
* **Concurrency Locking & Double-Booking Prevention**:
  * Atomic transactional handling (`SELECT ... FOR UPDATE` & unique slot-state constraints) prevents race conditions when simultaneous booking requests target the same slot.
* **Modern SaaS Interface**:
  * Light-theme design system featuring deep teal branding (`#0f766e`), soft rounded cards, responsive metrics, and dynamic session dropdowns.
* **Robust Enterprise Data Layer**:
  * Pure JDBC persistence with prepared statements for SQL injection prevention and deterministic connection life-cycle management.

---

## 🛠️ Tech Stack

* **Backend**: Java 17+, Jakarta EE 11 (Jakarta Servlets, Session Filters), JDBC
* **Frontend**: JavaServer Pages (JSP), Modern CSS3, HTML5, Vanilla JavaScript
* **Database**: MySQL Server 8.0 (InnoDB Storage Engine)
* **Application Server**: Apache Tomcat 11.0.x
* **Tooling & IDE**: Visual Studio Code, Git, GitHub, MySQL Workbench / Command Line Client

---

## 📂 Project Structure

```text
Online-appointment-booking-system/
├── database/
│   └── schema.sql                  # DDL, relational constraints, and seed data
├── src/
│   └── com/
│       └── appointment/
│           ├── servlet/            # Controller layer
│           │   ├── AuthServlet.java      # Login, registration & session invalidation
│           │   ├── BookingServlet.java   # Atomic booking & cancellation workflow
│           │   └── SlotServlet.java      # Provider shift parsing & 30-min slot generator
│           └── util/
│               └── DBConnection.java     # Relational database connection factory
├── web/
│   ├── css/
│   │   └── style.css               # Global stylesheet & design variables
│   ├── admin_dashboard.jsp         # Global management & transaction audit ledger
│   ├── index.jsp                   # Authentication portal (Sign In / Sign Up)
│   ├── provider_dashboard.jsp      # Shift configuration & client roster
│   └── user_dashboard.jsp          # Live availability search & booking dashboard
├── .gitignore
└── README.md                       # Project documentation

⚙️ Database Schema Overview
The relational schema comprises three primary normalized entities:
users: Contains authenticated entities (user_id, full_name, email, password_hash, role, created_at).
slots: Stores discretized provider availability blocks (slot_id, provider_id, slot_date, start_time, end_time, status).
appointments: Audit records of confirmed consultations (appointment_id, slot_id, client_id, booking_status, created_at).

💻 Local Setup & Deployment
1. Database Configuration
Import the database schema into your local MySQL instance:
mysql -u root -p < database/schema.sql

Verify the credentials inside src/com/appointment/util/DBConnection.java:
private static final String URL = "jdbc:mysql://localhost:3306/appointment_db";
private static final String USER = "root";
private static final String PASSWORD = "your_mysql_password";

2. Deploy on Apache Tomcat 11
1.Compile the Java source files into classes targeting WEB-INF/classes/.
2.Copy the project root or build artifact into the Tomcat deployment folder:
<TOMCAT_HOME>/webapps/appointment/

3.Start Tomcat using <TOMCAT_HOME>/bin/startup.bat (Windows) or startup.sh (Linux/macOS).

4.Launch your browser and navigate to:
http://localhost:8080/appointment/index.jsp
