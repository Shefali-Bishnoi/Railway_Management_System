![image](https://github.com/user-attachments/assets/9cd19f44-bb87-47a2-ac90-e06ac42190f0)
<br/>A robust MySQL-based Railway Ticket Reservation System for managing train ticket bookings, cancellations, seat availability, payments, and special passenger concessions. It supports advanced features such as RAC (Reservation Against Cancellation), waitlisting, and real-time ticket tracking.

Project Overview
This system allows passengers to:
Book, modify, and cancel train tickets.
View train schedules and seat availability.
Make payments via various modes.
Track PNR status, RAC, and waitlist positions.
Receive concessions based on category (Senior Citizens, Students, Physically Challenged).

Key Features
🔹 Class-Based Booking: Sleeper, AC 1st/2nd/3rd Class, General, Executive.
🔹 RAC & Waitlist System: Auto-management and updates.
🔹 Payment Modes: UPI, Credit/Debit Card, Wallet, Net Banking.
🔹 Cancellations & Refunds: Based on timing and policy.
🔹 Fare Concessions:
Senior Citizens: 40%
Students: 25%
Physically Challenged: 75%

E-R Model
Entities:
Passenger, Train, Ticket, Payment, Station, Schedule, Coach, Seat, Distance, Cost, RAC, Waitlist, Cancellation, Ticket_Status_Log
Relationships:
Passenger ↔️ Ticket
Ticket ↔️ Train
Train ↔️ Schedule
Ticket ↔️ Payment

All relationships have defined primary keys, foreign keys, and cardinalities.

Relational Schema
Fully normalized (up to 3NF).
MySQL implementation includes:
✅ Tables with constraints and indices
✅ Views
✅ Stored procedures
✅ Triggers
✅ Sample data (CSV)

Setup Instructions

Prerequisites
MySQL: Version 8.0+

Sample Data Files: (e.g., station.csv, train.csv)

Configuration
Enable Local Infile
SET GLOBAL local_infile = 1;
Start MySQL with Infile Option
mysql --local-infile=1 -u root -p

Modify File Paths
Update LOAD DATA LOCAL INFILE file paths in your SQL script:
Windows: C:\\path\\to\\file.csv
Linux/Mac: /path/to/file.csv
Run the Script
mysql -u root -p < railway_management.sql

Key Database Tables
![image](https://github.com/user-attachments/assets/352f1083-43b9-4e8d-a38f-dcda3030e641)

Sample Queries
Check PNR Status
SELECT * FROM ticket_status_view WHERE pnr = 'PNR8254631';
View Train Schedule
CALL get_train_schedule(1);
Book a Ticket
CALL book_ticket(1, 1, 1, 2, 'AC First Class', '2023-08-05', 'UPI', @pnr, @status, @payment_id);
SELECT @pnr, @status, @payment_id;
Cancel a Ticket
CALL cancel_ticket('PNR8254631', @status, @refund_amount);
SELECT @status, @refund_amount;

Stored Procedures
![image](https://github.com/user-attachments/assets/ed7eed95-1adb-48a4-b1fc-335baf8bf725)

Triggers
![image](https://github.com/user-attachments/assets/931cd825-54c1-4b6b-b88b-609ff18fad4c)








   
