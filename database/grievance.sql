CREATE DATABASE IF NOT EXISTS smart_grievance;

USE smart_grievance;

-- =========================================
-- USERS TABLE
-- =========================================

CREATE TABLE users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(15),
    username VARCHAR(50) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    role ENUM('CITIZEN', 'OFFICER', 'ADMIN') NOT NULL,
    officer_level INT NULL,
    department_id INT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


-- =========================================
-- DEPARTMENTS TABLE
-- =========================================

CREATE TABLE departments (
    department_id INT PRIMARY KEY AUTO_INCREMENT,
    department_name VARCHAR(100) NOT NULL,
    description VARCHAR(500)
);


-- =========================================
-- COMPLAINTS TABLE
-- =========================================

CREATE TABLE complaints (
    complaint_id INT PRIMARY KEY AUTO_INCREMENT,
    citizen_id INT NOT NULL,
    department_id INT NOT NULL,

    title VARCHAR(200) NOT NULL,
    category VARCHAR(100) NOT NULL,
    priority ENUM('HIGH', 'MEDIUM', 'LOW') NOT NULL DEFAULT 'MEDIUM',
    description TEXT NOT NULL,
    location VARCHAR(255) NOT NULL,

    image VARCHAR(255),

    status VARCHAR(30) DEFAULT 'PENDING',

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY (citizen_id)
        REFERENCES users(user_id),

    FOREIGN KEY (department_id)
        REFERENCES departments(department_id)
);


-- =========================================
-- COMPLAINT ASSIGNMENTS TABLE
-- =========================================

CREATE TABLE complaint_assignments (
    assignment_id INT PRIMARY KEY AUTO_INCREMENT,

    complaint_id INT NOT NULL,
    officer_id INT NOT NULL,

    escalation_level INT DEFAULT 1,

    assigned_at DATETIME NOT NULL,
    deadline DATETIME NOT NULL,

    status VARCHAR(30) DEFAULT 'PENDING',

    escalated_at DATETIME NULL,

    remarks VARCHAR(500),

    FOREIGN KEY (complaint_id)
        REFERENCES complaints(complaint_id),

    FOREIGN KEY (officer_id)
        REFERENCES users(user_id)
);


-- =========================================
-- DEPARTMENTS
-- =========================================

INSERT INTO departments
(department_name, description)
VALUES
('Roads',
 'Road construction and maintenance'),

('Water Supply',
 'Water supply related complaints'),

('Electricity',
 'Electricity related complaints'),

('Sanitation',
 'Sanitation related complaints'),

('Drainage',
 'Drainage and sewerage complaints'),

('Garbage Collection',
 'Garbage collection and waste management'),

('Street Lighting',
 'Street lighting related complaints');


-- =========================================
-- ADMIN ACCOUNT
-- =========================================

INSERT INTO users
(
    name,
    email,
    phone,
    username,
    password,
    role
)
VALUES
(
    'System Administrator',
    'admin@grievance.com',
    '9999999999',
    'admin',
    'admin123',
    'ADMIN'
);