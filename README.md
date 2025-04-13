![image](https://github.com/user-attachments/assets/9cd19f44-bb87-47a2-ac90-e06ac42190f0)
<br/>A robust MySQL-based Railway Ticket Reservation System for managing train ticket bookings, cancellations, seat availability, payments, and special passenger concessions. It supports advanced features such as RAC (Reservation Against Cancellation), waitlisting, and real-time ticket tracking.

<u>Project Overview</u>
This system allows passengers to:
Book, modify, and cancel train tickets.</br>
View train schedules and seat availability.<br/>
Make payments via various modes.<br/>
Track PNR status, RAC, and waitlist positions.<br/>
Receive concessions based on category (Senior Citizens, Students, Physically Challenged).<br/>

Key Features<br/>
🔹 Class-Based Booking: Sleeper, AC 1st/2nd/3rd Class, General, Executive.<br/>
🔹 RAC & Waitlist System: Auto-management and updates.<br/>
🔹 Payment Modes: UPI, Credit/Debit Card, Wallet, Net Banking.<br/>
🔹 Cancellations & Refunds: Based on timing and policy.<br/>
🔹 Fare Concessions:<br/>
    Senior Citizens: 40%<br/>
    Students: 25%<br/>
    Physically Challenged: 75%<br/>

E-R Model<br/>
Entities:<br/>
Passenger, Train, Ticket, Payment, Station, Schedule, Coach, Seat, Distance, Cost, RAC, Waitlist, Cancellation, Ticket_Status_Log<br/>
Relationships:<br/>
Passenger ↔️ Ticket<br/>
Ticket ↔️ Train<br/>
Train ↔️ Schedule<br/>
Ticket ↔️ Payment<br/>

All relationships have defined primary keys, foreign keys, and cardinalities.<br/>

Relational Schema<br/>
Fully normalized (up to 3NF).<br/>
MySQL implementation includes:<br/>
✅ Tables with constraints and indices<br/>
✅ Views<br/>
✅ Stored procedures<br/>
✅ Triggers<br/>
✅ Sample data (CSV)<br/>

Setup Instructions<br/>

Prerequisites<br/>
MySQL: Version 8.0+<br/>

Sample Data Files: (e.g., station.csv, train.csv)<br/>

Configuration<br/>
Enable Local Infile<br/>
SET GLOBAL local_infile = 1;<br/>
Start MySQL with Infile Option<br/>
mysql --local-infile=1 -u root -p<br/>

Modify File Paths<br/>
Update LOAD DATA LOCAL INFILE file paths in your SQL script:<br/>
Windows: C:\\path\\to\\file.csv<br/>
Linux/Mac: /path/to/file.csv<br/>
Run the Script<br/>
mysql -u root -p < railway_management.sql<br/>

Key Database Tables<br/>
![image](https://github.com/user-attachments/assets/352f1083-43b9-4e8d-a38f-dcda3030e641)<br/>

Sample Queries<br/>
Check PNR Status<br/>
SELECT * FROM ticket_status_view WHERE pnr = 'PNR8254631';<br/>
View Train Schedule<br/>
CALL get_train_schedule(1);<br/>
Book a Ticket<br/>
CALL book_ticket(1, 1, 1, 2, 'AC First Class', '2023-08-05', 'UPI', @pnr, @status, @payment_id);<br/>
SELECT @pnr, @status, @payment_id;<br/>
Cancel a Ticket<br/>
CALL cancel_ticket('PNR8254631', @status, @refund_amount);<br/>
SELECT @status, @refund_amount;<br/>

Stored Procedures<br/>
![image](https://github.com/user-attachments/assets/ed7eed95-1adb-48a4-b1fc-335baf8bf725)<br/>

Triggers<br/>
![image](https://github.com/user-attachments/assets/931cd825-54c1-4b6b-b88b-609ff18fad4c)<br/>








   
