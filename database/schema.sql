-- Create Database
CREATE DATABASE IF NOT EXISTS appointment_db;
USE appointment_db;

-- 1. Users Table (Role-Based Access)
CREATE TABLE IF NOT EXISTS users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role ENUM('USER', 'PROVIDER', 'ADMIN') NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. Provider Schedules Table (Availability Templates)
CREATE TABLE IF NOT EXISTS provider_schedules (
    schedule_id INT PRIMARY KEY AUTO_INCREMENT,
    provider_id INT NOT NULL,
    day_of_week ENUM('MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN') NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    slot_duration INT DEFAULT 30,
    FOREIGN KEY (provider_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- 3. Slots Table (Granular Windows + No Duplicate Constraint)
CREATE TABLE IF NOT EXISTS slots (
    slot_id INT PRIMARY KEY AUTO_INCREMENT,
    provider_id INT NOT NULL,
    slot_date DATE NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    status ENUM('AVAILABLE', 'BOOKED', 'BLOCKED') DEFAULT 'AVAILABLE',
    FOREIGN KEY (provider_id) REFERENCES users(user_id) ON DELETE CASCADE,
    -- Core constraint from our project report:
    CONSTRAINT unique_provider_slot UNIQUE (provider_id, slot_date, start_time)
);

-- 4. Appointments Table (Atomic Booking Records)
CREATE TABLE IF NOT EXISTS appointments (
    appointment_id INT PRIMARY KEY AUTO_INCREMENT,
    slot_id INT UNIQUE NOT NULL,
    client_id INT NOT NULL,
    booking_status ENUM('CONFIRMED', 'CANCELLED', 'COMPLETED') DEFAULT 'CONFIRMED',
    booking_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (slot_id) REFERENCES slots(slot_id) ON DELETE CASCADE,
    FOREIGN KEY (client_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- Initial Dummy Data for Testing (Password: '123456')
INSERT INTO users (full_name, email, password_hash, role) VALUES 
('Admin User', 'admin@system.com', '123456', 'ADMIN'),
('Dr. Sharma', 'doctor@system.com', '123456', 'PROVIDER'),
('Parteek Gaba', 'parteek@system.com', '123456', 'USER')
ON DUPLICATE KEY UPDATE user_id=user_id;