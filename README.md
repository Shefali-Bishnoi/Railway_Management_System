![image](https://github.com/user-attachments/assets/9cd19f44-bb87-47a2-ac90-e06ac42190f0)
<br/>A robust MySQL-based Railway Ticket Reservation System for managing train ticket bookings, cancellations, seat availability, payments, and special passenger concessions. It supports advanced features such as RAC (Reservation Against Cancellation), waitlisting, and real-time ticket tracking.

## Project Overview</br>
This system allows passengers to:
Book, modify, and cancel train tickets.</br>
View train schedules and seat availability.<br/>
Make payments via various modes.<br/>
Track PNR status, RAC, and waitlist positions.<br/>
Receive concessions based on category (Senior Citizens, Students, Physically Challenged).<br/>

## Key Features<br/>
🔹 Class-Based Booking: Sleeper, AC 1st/2nd/3rd Class, General, Executive.<br/>
🔹 RAC & Waitlist System: Auto-management and updates.<br/>
🔹 Payment Modes: UPI, Credit/Debit Card, Wallet, Net Banking.<br/>
🔹 Cancellations & Refunds: Based on timing and policy.<br/>
🔹 Fare Concessions:<br/>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;1. Senior Citizens: 40%<br/>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;2. Students: 25%<br/>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;3. Physically Challenged: 75%<br/>

## E-R Model<br/>
## Entities:<br/>
Passenger, Train, Ticket, Payment, Station, Schedule, Coach, Seat, Distance, Cost, RAC, Waitlist, Cancellation, Ticket_Status_Log<br/>
## Relationships:<br/>
Passenger ↔️ Ticket<br/>
Ticket ↔️ Train<br/>
Train ↔️ Schedule<br/>
Ticket ↔️ Payment<br/>

All relationships have defined primary keys, foreign keys, and cardinalities.<br/>

## Relational Schema<br/>
Fully normalized (up to 3NF).<br/>
MySQL implementation includes:<br/>
1.  Tables with constraints and indices<br/>
2.  Views<br/>
3.  Stored procedures<br/>
4.  Triggers<br/>
5.  Sample data (CSV)<br/>

## Setup Instructions<br/>

## Prerequisites<br/>
MySQL: Version 8.0+<br/>

Sample Data Files: (e.g., station.csv, train.csv)<br/>

## Configuration<br/>
Enable Local Infile<br/>
SET GLOBAL local_infile = 1;<br/>
Start MySQL with Infile Option<br/>
mysql --local-infile=1 -u root -p<br/>

## Modify File Paths<br/>
Update LOAD DATA LOCAL INFILE file paths in your SQL script:<br/>
Windows: C:\\path\\to\\file.csv<br/>
Linux/Mac: /path/to/file.csv<br/>
## Run the Script<br/>
mysql -u root -p < railway_management.sql<br/>

Key Database Tables<br/>
![image](https://github.com/user-attachments/assets/352f1083-43b9-4e8d-a38f-dcda3030e641)<br/>

## Sample Queries<br/>

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

## Queries</br>
1. ![image](https://github.com/user-attachments/assets/9252d9ed-bc1b-44fd-a6ae-d8682c37825a)</br>
![image](https://github.com/user-attachments/assets/bd7fcdef-c318-4eb3-91d1-c718f1b38c88)</br>

2. ![image](https://github.com/user-attachments/assets/cf2e2940-f407-4566-b19c-9c617d368843)</br>
![image](https://github.com/user-attachments/assets/c479cfe3-4382-485b-bbcd-54244bec0097)</br>

3. ![image](https://github.com/user-attachments/assets/4d31d0c5-3328-4a28-a2a6-aba82852cf9f)</br>
![image](https://github.com/user-attachments/assets/f8efcb62-704e-4ed3-b3eb-12ec7c602616)</br>

4. ![image](https://github.com/user-attachments/assets/6a28c87a-f6a2-42a9-b2db-9e837a03f3c3)</br>
![image](https://github.com/user-attachments/assets/8d576cab-a61a-45b6-943d-8d2c8d3f55a1)</br>

5. ![image](https://github.com/user-attachments/assets/6b317fc6-1f8a-4be8-bea0-9855f74c7d70)</br>
![image](https://github.com/user-attachments/assets/2b0e05fb-ea8c-4d50-9004-dea7d6bec461)</br>

6. ![image](https://github.com/user-attachments/assets/fe02a910-7803-427c-a653-e311284b26b2)</br>
![image](https://github.com/user-attachments/assets/8d14051f-7bd0-408f-bbf6-9c8ee60e75e1)</br>

7. ![image](https://github.com/user-attachments/assets/e11bb284-3fc4-4e29-a0f1-449c8e3b63e9)</br>
![image](https://github.com/user-attachments/assets/178a4ff5-beb3-418a-8ccb-036281d6939c)</br>

8. ![image](https://github.com/user-attachments/assets/ff23694c-321b-4ed8-8192-17b1901743e8)</br>
![image](https://github.com/user-attachments/assets/d7e2770d-99aa-4773-9cd8-c0cb1b199737)</br>

9. ![image](https://github.com/user-attachments/assets/63b104f4-8576-4ae8-a596-c0d0ccf8042d)</br>
![image](https://github.com/user-attachments/assets/5aff276d-19bb-4a57-a901-6b5673fe7076)</br>

10. ![image](https://github.com/user-attachments/assets/e03c40be-c871-4aed-b034-e65a06cbf75a)</br>
![image](https://github.com/user-attachments/assets/29f3a024-d448-4ac7-b7ec-8e8cb1c0ca76)</br>


## Additional Queries</br>

1. ![image](https://github.com/user-attachments/assets/55ae40bf-d21c-4f20-8f77-e9be4ceb6651)</br>
![image](https://github.com/user-attachments/assets/7b6d4c62-7c1f-4d07-850e-e0fa1bf20b69)</br>

2. ![image](https://github.com/user-attachments/assets/df8f7428-9e70-407e-8d87-f4426b8aa582)</br>
![image](https://github.com/user-attachments/assets/b0dfbf18-2594-4e46-998b-2f1e19cf6056)</br>

3. ![image](https://github.com/user-attachments/assets/2d4258d0-40ba-4ed9-b7bc-1d86c6a33b15)</br>
![image](https://github.com/user-attachments/assets/06aa5529-990e-4da8-9f91-601f3db4afa6)</br>





## Stored Procedures<br/>
![image](https://github.com/user-attachments/assets/ed7eed95-1adb-48a4-b1fc-335baf8bf725)<br/>

## Triggers<br/>
![image](https://github.com/user-attachments/assets/931cd825-54c1-4b6b-b88b-609ff18fad4c)<br/>


## Normalistion</br>

## First Normal Form (1NF)</br>

1. Each table has a clear primary key (e.g., passenger_id, train_id, station_id).</br>
2. All attributes contain atomic values (no multi-valued attributes).</br>
3. No repeating groups within tables.</br>

## Second Normal Form (2NF)</br>

1. All non-key attributes are fully dependent on their primary keys.</br>
2. Composite keys in tables like seat (train_id, coach_id, seat_number) properly identify records.</br>
3. Related data is separated into distinct tables (passengers, trains, stations, etc.).</br>

## Third Normal Form (3NF)</br>

1. No transitive dependencies between non-key attributes.</br>
2. Good example: The cost table separates pricing logic from train and coach tables.</br>
3. distance table properly normalizes the relationship between stations.</br>

## Specific Normalization Examples</br>

## Train and Coach separation:</br>
Train details and coach information are in separate tables, with coach referencing train_id</br>
## Station and Schedule separation:</br>
Station information is independent of train schedules</br>
## Payment and Ticket separation:</br>
Payment details are not embedded in the ticket table</br>
## Cost model normalization:</br>
Fare calculation factors are separated in their own table</br>

 
## Deliverables Checklist</br>
   E-R Diagram with entity descriptions</br>
   Relational Schema (Normalized)</br>
   Populated Sample Data (CSV + SQL)</br>
   SQL: Queries, Views, Triggers, Procedures</br>








   
