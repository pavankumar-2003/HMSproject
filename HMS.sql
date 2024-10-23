create database HMS;
use HMS;
-- Role-Based Access Control
CREATE TABLE roles (
    role_id INT IDENTITY(1,1) PRIMARY KEY,
    role_name NVARCHAR(50) NOT NULL
);
------------------------------------------------------------------------
-- Users Table to handle login and role-based access
CREATE TABLE users (
    user_id INT IDENTITY(1,1) PRIMARY KEY,
    username NVARCHAR(100) NOT NULL UNIQUE,
    password NVARCHAR(255) NOT NULL,
    role_id INT NOT NULL,
    FOREIGN KEY (role_id) REFERENCES roles(role_id)
);
--------------------------------------------------------------------------
-- Doctors Table
CREATE TABLE doctors (
    doctor_id INT IDENTITY(1,1) PRIMARY KEY,
    user_id INT NOT NULL, -- Links to the users table for login
    name NVARCHAR(100) NOT NULL,
    specialization NVARCHAR(100) NOT NULL,
    contact_number NVARCHAR(15) NOT NULL,
    email NVARCHAR(100),
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- Receptionists Table
CREATE TABLE receptionists (
    receptionist_id INT IDENTITY(1,1) PRIMARY KEY,
    user_id INT NOT NULL, -- Links to the users table for login
    name NVARCHAR(100) NOT NULL,
    contact_number NVARCHAR(15) NOT NULL,
    email NVARCHAR(100),
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- Patients Table
CREATE TABLE patients (
    patient_id INT IDENTITY(1,1) PRIMARY KEY,
    name NVARCHAR(100) NOT NULL,
    age INT NOT NULL,
    gender NVARCHAR(10) NOT NULL CHECK (gender IN ('Male', 'Female', 'Other')),
    contact_number NVARCHAR(15),
    address NVARCHAR(255),
    email NVARCHAR(100),
    medical_history VARCHAR(MAX)
);

-- Appointments Table
CREATE TABLE appointments (
    appointment_id INT IDENTITY(1,1) PRIMARY KEY,
    patient_id INT NOT NULL,
    doctor_id INT NOT NULL,
    receptionist_id INT, -- Optional, if managed by a receptionist
    appointment_date DATE NOT NULL,
    appointment_time TIME NOT NULL,
    reason_for_visit NVARCHAR(255),
    
    -- Foreign Key Relationships
    FOREIGN KEY (patient_id) REFERENCES patients(patient_id) ON DELETE CASCADE,  -- Delete appointments if patient is deleted
    FOREIGN KEY (doctor_id) REFERENCES doctors(doctor_id) ON DELETE NO ACTION,   -- No cascade on doctor deletion, modify to fit your needs
    FOREIGN KEY (receptionist_id) REFERENCES receptionists(receptionist_id) ON DELETE SET NULL  -- Set receptionist_id to NULL if receptionist is deleted
);


-- Medical Records Table
CREATE TABLE medical_records (
    record_id INT IDENTITY(1,1) PRIMARY KEY,
    patient_id INT NOT NULL,
    doctor_id INT NOT NULL,
    record_date DATE NOT NULL,
    description TEXT,
    prescription TEXT,
    FOREIGN KEY (patient_id) REFERENCES patients(patient_id) ON DELETE CASCADE,
    FOREIGN KEY (doctor_id) REFERENCES doctors(doctor_id) ON DELETE CASCADE
);

-- Indexing for optimized search and retrieval
CREATE INDEX idx_patient_name ON patients (name);
CREATE INDEX idx_doctor_name ON doctors (name);
CREATE INDEX idx_appointment_date ON appointments (appointment_date);


------------------------------------------------------------------------------------------
CREATE PROCEDURE AddDoctor
    @UserID INT,
    @Name NVARCHAR(100),
    @Specialization NVARCHAR(100),
    @ContactNumber NVARCHAR(15),
    @Email NVARCHAR(100)
AS
BEGIN
    INSERT INTO doctors (user_id, name, specialization, contact_number, email)
    VALUES (@UserID, @Name, @Specialization, @ContactNumber, @Email);
END;

----------------------------------------------------------------------------------------
CREATE PROCEDURE UpdateDoctor
    @DoctorID INT,
    @Name NVARCHAR(100),
    @Specialization NVARCHAR(100),
    @ContactNumber NVARCHAR(15),
    @Email NVARCHAR(100)
AS
BEGIN
    UPDATE doctors
    SET name = @Name,
        specialization = @Specialization,
        contact_number = @ContactNumber,
        email = @Email
    WHERE doctor_id = @DoctorID;
END;
-------------------------------------------------------------------------------------
CREATE PROCEDURE DeleteDoctor
    @DoctorID INT
AS
BEGIN
    DELETE FROM doctors
    WHERE doctor_id = @DoctorID;
END;

--------------------------------------------------------------------------------------
CREATE PROCEDURE GetAllDoctors
AS
BEGIN
    SELECT doctor_id, user_id, name, specialization, contact_number, email
    FROM doctors
    ORDER BY name; 
END;
---------------------------------------------------------------------------------

CREATE PROCEDURE AddReceptionist
    @Name NVARCHAR(100),
    @ContactNumber NVARCHAR(15),
    @Email NVARCHAR(100),
    @UserID INT  -- Assuming UserID is required
AS
BEGIN
    INSERT INTO receptionists (user_id, name, contact_number, email)
    VALUES (@UserID, @Name, @ContactNumber, @Email);
END;

CREATE PROCEDURE UpdateReceptionist
    @ReceptionistID INT,
    @Name NVARCHAR(100),
    @ContactNumber NVARCHAR(15),
    @Email NVARCHAR(100)
AS
BEGIN
    UPDATE receptionists
    SET name = @Name,
        contact_number = @ContactNumber,
        email = @Email
    WHERE receptionist_id = @ReceptionistID;
END;

CREATE PROCEDURE DeleteReceptionist
    @ReceptionistID INT
AS
BEGIN
    DELETE FROM receptionists
    WHERE receptionist_id = @ReceptionistID;
END;


CREATE PROCEDURE GetAllReceptionists
AS
BEGIN
    SELECT receptionist_id, user_id, name, contact_number, email
    FROM receptionists
    ORDER BY name;  
END;
---------------------------------------------------------------------------------
CREATE PROCEDURE AddPatient
    @Name NVARCHAR(100),
    @Age INT,
    @Gender NVARCHAR(10),
    @ContactNumber NVARCHAR(15),
    @Address NVARCHAR(255),
    @Email NVARCHAR(100),
    @MedicalHistory TEXT
AS
BEGIN
    INSERT INTO patients (name, age, gender, contact_number, address, email, medical_history)
    VALUES (@Name, @Age, @Gender, @ContactNumber, @Address, @Email, @MedicalHistory);
END;
---------------------------------------------------------------------------------
CREATE PROCEDURE UpdatePatient
    @PatientID INT,
    @Name NVARCHAR(100),
    @Age INT,
    @Gender NVARCHAR(10),
    @ContactNumber NVARCHAR(15),
    @Address NVARCHAR(255),
    @Email NVARCHAR(100),
    @MedicalHistory TEXT
AS
BEGIN
    UPDATE patients
    SET name = @Name,
        age = @Age,
        gender = @Gender,
        contact_number = @ContactNumber,
        address = @Address,
        email = @Email,
        medical_history = @MedicalHistory
    WHERE patient_id = @PatientID;
END;
---------------------------------------------------------------------------------
CREATE PROCEDURE DeletePatient
    @PatientID INT
AS
BEGIN
    DELETE FROM patients
    WHERE patient_id = @PatientID;
END;
---------------------------------------------------------------------------------
CREATE PROCEDURE ScheduleAppointment
    @PatientID INT,
    @DoctorID INT,
    @ReceptionistID INT,
    @AppointmentDate DATE,
    @AppointmentTime TIME,
    @ReasonForVisit NVARCHAR(255)
AS
BEGIN
    INSERT INTO appointments (patient_id, doctor_id, receptionist_id, appointment_date, appointment_time, reason_for_visit)
    VALUES (@PatientID, @DoctorID, @ReceptionistID, @AppointmentDate, @AppointmentTime, @ReasonForVisit);
END;
---------------------------------------------------------------------------------
CREATE PROCEDURE UpdateAppointment
    @AppointmentID INT,
    @PatientID INT,
    @DoctorID INT,
    @ReceptionistID INT,
    @AppointmentDate DATE,
    @AppointmentTime TIME,
    @ReasonForVisit NVARCHAR(255)
AS
BEGIN
    UPDATE appointments
    SET patient_id = @PatientID,
        doctor_id = @DoctorID,
        receptionist_id = @ReceptionistID,
        appointment_date = @AppointmentDate,
        appointment_time = @AppointmentTime,
        reason_for_visit = @ReasonForVisit
    WHERE appointment_id = @AppointmentID;
END;
---------------------------------------------------------------------------------
CREATE PROCEDURE CancelAppointment
    @AppointmentID INT
AS
BEGIN
    DELETE FROM appointments
    WHERE appointment_id = @AppointmentID;
END;

---------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE GetDoctorAppointments
    @DoctorID INT
AS
BEGIN
    SELECT a.appointment_id, p.name AS patient_name, a.appointment_date, a.appointment_time, a.reason_for_visit
    FROM appointments a
    JOIN patients p ON a.patient_id = p.patient_id
    WHERE a.doctor_id = @DoctorID
    ORDER BY a.appointment_date, a.appointment_time;
END;
---------------------------------------------------------------------------------
CREATE PROCEDURE GetDoctorPatients
    @DoctorID INT
AS
BEGIN
    -- Select distinct patient information excluding medical_history
    SELECT DISTINCT p.patient_id, p.name, p.age, p.gender, p.contact_number
    FROM patients p
    JOIN appointments a ON p.patient_id = a.patient_id
    WHERE a.doctor_id = @DoctorID
    ORDER BY p.name;

    -- Select medical_history separately (if needed)
    SELECT p.patient_id, p.medical_history
    FROM patients p
    JOIN appointments a ON p.patient_id = a.patient_id
    WHERE a.doctor_id = @DoctorID;
END;