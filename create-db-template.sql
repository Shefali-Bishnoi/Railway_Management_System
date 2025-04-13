-- Create database
CREATE DATABASE IF NOT EXISTS railway_management;
USE railway_management;

-- Passenger table
CREATE TABLE passenger (
    passenger_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    age INT NOT NULL,
    gender ENUM('Male', 'Female', 'Other') NOT NULL,
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(15) NOT NULL,
    address VARCHAR(255),
    concession_category ENUM('Senior Citizen', 'Student', 'General', 'Physically Challenged') DEFAULT 'General'
);

-- Train table
CREATE TABLE train (
    train_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    type ENUM('Shatabdi', 'Vande Bharat', 'Rajdhani', 'Express', 'Passenger', 'Superfast') NOT NULL
);

-- Station table
CREATE TABLE station (
    station_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    code VARCHAR(10) UNIQUE NOT NULL,
    city VARCHAR(50) NOT NULL,
    state VARCHAR(50) NOT NULL,
    number_of_platforms INT DEFAULT 1
);

-- Coach table (modified to include RAC and available seat tracking)
CREATE TABLE coach (
    coach_id INT AUTO_INCREMENT PRIMARY KEY,
    train_id INT NOT NULL,
    coach_name VARCHAR(10) NOT NULL,
    class_type ENUM('AC First Class', 'AC Second Class', 'AC Third Class', 'Sleeper', 'General', 'Executive') NOT NULL,
    total_seats INT NOT NULL,
    total_rac_seats INT NOT NULL DEFAULT 0,
    available_rac_seats INT NOT NULL DEFAULT 0,
    available_seats INT NOT NULL DEFAULT 0,
    FOREIGN KEY (train_id) REFERENCES train(train_id) ON DELETE CASCADE,
    UNIQUE KEY unique_coach_train (train_id, coach_name)
);

-- Seat table
CREATE TABLE seat (
    train_id INT NOT NULL,
    coach_id INT,
    seat_number INT,
    FOREIGN KEY (train_id) REFERENCES train(train_id) ON DELETE CASCADE,
    FOREIGN KEY (coach_id) REFERENCES coach(coach_id) ON DELETE CASCADE,
    PRIMARY KEY (train_id, coach_id, seat_number)
);

-- Schedule table
CREATE TABLE schedule (
    schedule_id INT AUTO_INCREMENT PRIMARY KEY,
    train_id INT NOT NULL,
    station_id INT NOT NULL,
    arrival_time TIME,
    departure_time TIME,
    day_number INT DEFAULT 1 COMMENT 'Day 1 = day of start, Day 2 = next day, etc.',
    stop_number INT NOT NULL COMMENT 'Sequence of stops',
    FOREIGN KEY (train_id) REFERENCES train(train_id) ON DELETE CASCADE,
    FOREIGN KEY (station_id) REFERENCES station(station_id) ON DELETE CASCADE,
    UNIQUE KEY unique_schedule (train_id, station_id, day_number)
);

-- Distance table
CREATE TABLE distance (
    distance_id INT AUTO_INCREMENT PRIMARY KEY,
    from_station_id INT NOT NULL,
    to_station_id INT NOT NULL,
    distance_km DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (from_station_id) REFERENCES station(station_id),
    FOREIGN KEY (to_station_id) REFERENCES station(station_id),
    UNIQUE KEY unique_route (from_station_id, to_station_id)
);

-- Cost table
CREATE TABLE cost (
    cost_id INT AUTO_INCREMENT PRIMARY KEY,
    class_type ENUM('AC First Class', 'AC Second Class', 'AC Third Class', 'Sleeper', 'General', 'Executive') NOT NULL,
    train_type ENUM('Shatabdi', 'Vande Bharat', 'Rajdhani', 'Express', 'Passenger', 'Superfast') NOT NULL,
    base_fare DECIMAL(10, 2) NOT NULL,
    per_km_charge DECIMAL(8, 2) NOT NULL,
    UNIQUE KEY unique_cost (class_type, train_type)
);

-- Ticket table
CREATE TABLE ticket (
    ticket_id INT AUTO_INCREMENT PRIMARY KEY,
    pnr VARCHAR(10) UNIQUE NOT NULL,
    passenger_id INT NOT NULL,
    train_id INT NOT NULL,
    from_station_id INT NOT NULL,
    to_station_id INT NOT NULL,
    coach_id INT,
    seat_number INT,
    journey_date DATE NOT NULL,
    booking_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    status ENUM('Confirmed', 'Waiting', 'Cancelled', 'RAC') DEFAULT 'Confirmed',
    fare DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (passenger_id) REFERENCES passenger(passenger_id),
    FOREIGN KEY (from_station_id) REFERENCES station(station_id),
    FOREIGN KEY (to_station_id) REFERENCES station(station_id),
    FOREIGN KEY (train_id, coach_id, seat_number) REFERENCES seat(train_id, coach_id, seat_number)
);

-- RAC (Reservation Against Cancellation) table
CREATE TABLE rac (
    rac_id INT AUTO_INCREMENT PRIMARY KEY,
    ticket_id INT NOT NULL,
    position INT NOT NULL,
    status ENUM('RAC', 'Confirmed', 'Cancelled') DEFAULT 'RAC',
    last_updated DATETIME DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY unique_position (ticket_id, position),
    FOREIGN KEY (ticket_id) REFERENCES ticket(ticket_id)
);

-- Waitlist table
CREATE TABLE waitlist (
    waitlist_id INT AUTO_INCREMENT PRIMARY KEY,
    ticket_id INT NOT NULL,
    position INT NOT NULL,
    status ENUM('Waiting', 'Confirmed', 'RAC', 'Cancelled') DEFAULT 'Waiting',
    last_updated DATETIME DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY unique_position (position),
    FOREIGN KEY (ticket_id) REFERENCES ticket(ticket_id)
);

-- Payment table
CREATE TABLE payment (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    ticket_id INT NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    payment_mode ENUM('Credit Card', 'Debit Card', 'UPI', 'Net Banking', 'Wallet') NOT NULL,
    payment_status ENUM('Pending', 'Completed', 'Failed', 'Refunded') NOT NULL DEFAULT 'Pending',
    transaction_id VARCHAR(50) UNIQUE,
    payment_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (ticket_id) REFERENCES ticket(ticket_id) ON DELETE CASCADE
);

-- Cancellation table
CREATE TABLE cancellation (
    cancellation_id INT AUTO_INCREMENT PRIMARY KEY,
    ticket_id INT NOT NULL,
    cancellation_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    refund_amount DECIMAL(10, 2),
    cancellation_charge DECIMAL(10, 2),
    FOREIGN KEY (ticket_id) REFERENCES ticket(ticket_id)
);

-- Ticket status log table
CREATE TABLE ticket_status_log (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    ticket_id INT NOT NULL,
    old_status VARCHAR(20) NOT NULL,
    new_status VARCHAR(20) NOT NULL,
    change_date DATETIME NOT NULL,
    FOREIGN KEY (ticket_id) REFERENCES ticket(ticket_id)
);

-- View to check ticket status by PNR
CREATE VIEW ticket_status_view AS
SELECT 
    t.pnr, 
    p.name AS passenger_name,
    tr.name AS train_name,
    s1.name AS from_station,
    s2.name AS to_station,
    t.journey_date,
    c.coach_name,
    t.seat_number,
    t.status
FROM 
    ticket t
    JOIN passenger p ON t.passenger_id = p.passenger_id
    JOIN train tr ON t.train_id = tr.train_id
    JOIN station s1 ON t.from_station_id = s1.station_id
    JOIN station s2 ON t.to_station_id = s2.station_id
    LEFT JOIN coach c ON t.coach_id = c.coach_id;

-- View to check train schedule
CREATE VIEW train_schedule_view AS
SELECT 
    t.train_id,
    t.name AS train_name,
    t.type AS train_type,
    s.name AS station_name,
    sc.arrival_time,
    sc.departure_time,
    sc.day_number,
    sc.stop_number
FROM 
    train t
    JOIN schedule sc ON t.train_id = sc.train_id
    JOIN station s ON sc.station_id = s.station_id
ORDER BY 
    t.train_id, sc.day_number, sc.stop_number;

-- View to show available seats (updated)
CREATE VIEW available_seats_view AS
SELECT 
    t.train_id,
    t.name AS train_name,
    c.coach_id,
    c.coach_name,
    c.class_type,
    c.total_seats,
    c.available_seats,
    c.total_rac_seats,
    c.available_rac_seats
FROM 
    train t
    JOIN coach c ON t.train_id = c.train_id;

-- View for payment status
CREATE VIEW payment_status_view AS
SELECT
    p.payment_id,
    t.pnr,
    pas.name AS passenger_name,
    t.journey_date,
    tr.name AS train_name,
    p.amount,
    p.payment_mode,
    p.payment_status,
    p.transaction_id,
    p.payment_date
FROM
    payment p
    JOIN ticket t ON p.ticket_id = t.ticket_id
    JOIN passenger pas ON t.passenger_id = pas.passenger_id
    JOIN train tr ON t.train_id = tr.train_id;

-- View for RAC tickets
CREATE VIEW rac_tickets_view AS
SELECT
    t.pnr,
    p.name AS passenger_name,
    tr.name AS train_name,
    r.position AS rac_position,
    t.journey_date,
    s1.name AS from_station,
    s2.name AS to_station,
    c.coach_name,
    c.class_type
FROM
    ticket t
    JOIN rac r ON t.ticket_id = r.ticket_id
    JOIN passenger p ON t.passenger_id = p.passenger_id
    JOIN train tr ON t.train_id = tr.train_id
    JOIN station s1 ON t.from_station_id = s1.station_id
    JOIN station s2 ON t.to_station_id = s2.station_id
    LEFT JOIN coach c ON t.coach_id = c.coach_id
WHERE
    r.status = 'RAC';

-- View for waitlist tickets
CREATE VIEW waitlist_tickets_view AS
SELECT
    t.pnr,
    p.name AS passenger_name,
    tr.name AS train_name,
    w.position AS waitlist_position,
    t.journey_date,
    s1.name AS from_station,
    s2.name AS to_station,
    c.coach_name,
    c.class_type
FROM
    ticket t
    JOIN waitlist w ON t.ticket_id = w.ticket_id
    JOIN passenger p ON t.passenger_id = p.passenger_id
    JOIN train tr ON t.train_id = tr.train_id
    JOIN station s1 ON t.from_station_id = s1.station_id
    JOIN station s2 ON t.to_station_id = s2.station_id
    LEFT JOIN coach c ON t.coach_id = c.coach_id
WHERE
    w.status = 'Waiting';

-- Stored procedure to calculate fare
DELIMITER //
CREATE PROCEDURE calculate_fare(
    IN p_train_id INT,
    IN p_from_station_id INT,
    IN p_to_station_id INT,
    IN p_class_type VARCHAR(50),
    IN p_concession_category VARCHAR(50),
    OUT p_fare DECIMAL(10, 2)
)
BEGIN
    DECLARE v_train_type VARCHAR(50);
    DECLARE v_base_fare DECIMAL(10, 2);
    DECLARE v_per_km_charge DECIMAL(8, 2);
    DECLARE v_distance DECIMAL(10, 2) DEFAULT 0;
    DECLARE v_concession_percent INT DEFAULT 0;
    
    -- Get train type
    SELECT type INTO v_train_type FROM train WHERE train_id = p_train_id;
    
    -- Get base fare and per km charge
    SELECT base_fare, per_km_charge 
    INTO v_base_fare, v_per_km_charge 
    FROM cost 
    WHERE class_type = p_class_type AND train_type = v_train_type;
    
    -- Calculate total distance
    WITH RECURSIVE route_stations AS (
        SELECT 
            station_id, 
            stop_number
        FROM 
            schedule
        WHERE 
            train_id = p_train_id
    )
    SELECT 
        SUM(d.distance_km) INTO v_distance
    FROM 
        route_stations rs1
        JOIN route_stations rs2 ON rs1.stop_number < rs2.stop_number
        JOIN distance d ON (d.from_station_id = rs1.station_id AND d.to_station_id = rs2.station_id)
    WHERE 
        rs1.station_id = p_from_station_id AND rs2.station_id = p_to_station_id;
    
    -- If direct distance not found, use individual segments
    IF v_distance = 0 THEN
        SELECT distance_km INTO v_distance FROM distance 
        WHERE (from_station_id = p_from_station_id AND to_station_id = p_to_station_id)
        OR (from_station_id = p_to_station_id AND to_station_id = p_from_station_id)
        LIMIT 1;
    END IF;
    
    -- Apply concession if applicable
    CASE p_concession_category
        WHEN 'Senior Citizen' THEN SET v_concession_percent = 40;
        WHEN 'Student' THEN SET v_concession_percent = 25;
        WHEN 'Physically Challenged' THEN SET v_concession_percent = 75;
        ELSE SET v_concession_percent = 0;
    END CASE;
    
    -- Calculate final fare
    SET p_fare = (v_base_fare + (v_per_km_charge * v_distance));
    SET p_fare = p_fare - (p_fare * v_concession_percent / 100);
    
END //
DELIMITER ;

-- Book ticket procedure (updated)
DELIMITER //
CREATE PROCEDURE book_ticket(
    IN p_passenger_id INT,
    IN p_train_id INT,
    IN p_from_station_id INT,
    IN p_to_station_id INT,
    IN p_class_type VARCHAR(50),
    IN p_journey_date DATE,
    IN p_payment_mode VARCHAR(50),
    OUT p_pnr VARCHAR(10),
    OUT p_status VARCHAR(20),
    OUT p_payment_id INT
)
BEGIN
    DECLARE v_coach_id INT;
    DECLARE v_seat_number INT;
    DECLARE v_fare DECIMAL(10, 2);
    DECLARE v_concession_category VARCHAR(50);
    DECLARE v_pnr VARCHAR(10);
    DECLARE v_ticket_id INT;
    DECLARE v_rac_position INT;
    DECLARE v_waitlist_position INT;
    DECLARE v_available_seats INT;
    DECLARE v_available_rac_seats INT;
    DECLARE v_transaction_id VARCHAR(50);
    DECLARE v_status VARCHAR(50);
    
    -- Start transaction
    START TRANSACTION;
    
    -- Get concession category for the passenger
    SELECT concession_category INTO v_concession_category 
    FROM passenger 
    WHERE passenger_id = p_passenger_id;
    
    -- Find available coach of the requested class type
    SELECT coach_id, available_seats, available_rac_seats 
    INTO v_coach_id, v_available_seats, v_available_rac_seats
    FROM coach 
    WHERE train_id = p_train_id 
    AND class_type = p_class_type
    AND (available_seats > 0 OR available_rac_seats > 0)
    LIMIT 1;
    
    -- If no coach found with available seats or RAC
    IF v_coach_id IS NULL THEN
        -- Get any coach for waitlist
        SELECT coach_id INTO v_coach_id
        FROM coach 
        WHERE train_id = p_train_id 
        AND class_type = p_class_type
        LIMIT 1;
        
        SET v_status = 'Waiting';
    ELSE
        -- Find available seat if available
        IF v_available_seats > 0 THEN
            SELECT seat_number INTO v_seat_number
            FROM seat s
            WHERE s.train_id = p_train_id 
            AND s.coach_id = v_coach_id
            AND NOT EXISTS (
                SELECT 1 FROM ticket t 
                WHERE t.train_id = s.train_id 
                AND t.coach_id = s.coach_id 
                AND t.seat_number = s.seat_number
                AND t.journey_date = p_journey_date
                AND t.status = 'Confirmed'
            )
            LIMIT 1;
            
            SET v_status = 'Confirmed';
        ELSEIF v_available_rac_seats > 0 THEN
            SET v_status = 'RAC';
        END IF;
    END IF;
    
    -- Calculate fare
    CALL calculate_fare(p_train_id, p_from_station_id, p_to_station_id, p_class_type, v_concession_category, v_fare);
    
    -- Generate PNR
    SET v_pnr = CONCAT('PNR', LPAD(FLOOR(RAND() * 10000000), 7, '0'));
    
    -- Generate transaction ID
    SET v_transaction_id = CONCAT('TXN', LPAD(FLOOR(RAND() * 1000000000), 9, '0'));
    
    -- Insert ticket
    INSERT INTO ticket (
        pnr, passenger_id, train_id, from_station_id, to_station_id,
        coach_id, seat_number, journey_date, booking_date, status, fare
    ) VALUES (
        v_pnr, p_passenger_id, p_train_id, p_from_station_id, p_to_station_id,
        v_coach_id, IF(v_status = 'Confirmed', v_seat_number, NULL), p_journey_date, 
        NOW(), v_status, v_fare
    );
    
    SET v_ticket_id = LAST_INSERT_ID();
    
    -- Update seat counts and add to RAC/waitlist
    IF v_status = 'Confirmed' THEN
        UPDATE coach 
        SET available_seats = available_seats - 1
        WHERE coach_id = v_coach_id;
    ELSEIF v_status = 'RAC' THEN
        UPDATE coach 
        SET available_rac_seats = available_rac_seats - 1
        WHERE coach_id = v_coach_id;
        
        -- Get next RAC position
        SELECT IFNULL(MAX(position), 0) + 1 INTO v_rac_position 
        FROM rac 
        WHERE ticket_id IN (
            SELECT ticket_id 
            FROM ticket 
            WHERE train_id = p_train_id 
            AND journey_date = p_journey_date
            AND coach_id = v_coach_id
        );
        
        INSERT INTO rac (ticket_id, position, status)
        VALUES (v_ticket_id, v_rac_position, 'RAC');
    ELSEIF v_status = 'Waiting' THEN
        -- Get next waitlist position
        SELECT IFNULL(MAX(position), 0) + 1 INTO v_waitlist_position 
        FROM waitlist 
        WHERE ticket_id IN (
            SELECT ticket_id 
            FROM ticket 
            WHERE train_id = p_train_id 
            AND journey_date = p_journey_date
            AND coach_id = v_coach_id
        );
        
        INSERT INTO waitlist (ticket_id, position, status)
        VALUES (v_ticket_id, v_waitlist_position, 'Waiting');
    END IF;
    
    -- Create payment entry
    INSERT INTO payment (ticket_id, amount, payment_mode, payment_status, transaction_id)
    VALUES (v_ticket_id, v_fare, p_payment_mode, 'Pending', v_transaction_id);
    
    SET p_payment_id = LAST_INSERT_ID();
    
    -- Return values
    SET p_pnr = v_pnr;
    SET p_status = v_status;
    
    COMMIT;
END //
DELIMITER ;

-- Cancel ticket procedure (updated)
DELIMITER //
CREATE PROCEDURE cancel_ticket(
    IN p_pnr VARCHAR(10), 
    OUT p_status VARCHAR(20),
    OUT p_refund_amount DECIMAL(10, 2)
)
BEGIN
    DECLARE v_ticket_id INT;
    DECLARE v_train_id INT;
    DECLARE v_journey_date DATE;
    DECLARE v_coach_id INT;
    DECLARE v_seat_number INT;
    DECLARE v_fare DECIMAL(10, 2);
    DECLARE v_status VARCHAR(20);
    DECLARE v_cancellation_charge DECIMAL(10, 2);
    DECLARE v_days_to_journey INT;
    DECLARE v_next_rac_ticket_id INT;
    DECLARE v_next_waitlist_ticket_id INT;
    
    -- Start transaction
    START TRANSACTION;
    
    -- Get ticket details
    SELECT 
        ticket_id, train_id, journey_date, coach_id, seat_number, fare, status
    INTO 
        v_ticket_id, v_train_id, v_journey_date, v_coach_id, v_seat_number, v_fare, v_status
    FROM 
        ticket
    WHERE 
        pnr = p_pnr;
    
    -- Calculate days to journey
    SET v_days_to_journey = DATEDIFF(v_journey_date, CURDATE());
    
    -- Calculate cancellation charge based on days to journey
    IF v_days_to_journey > 7 THEN
        SET v_cancellation_charge = v_fare * 0.10;
    ELSEIF v_days_to_journey > 3 THEN
        SET v_cancellation_charge = v_fare * 0.25;
    ELSEIF v_days_to_journey > 1 THEN
        SET v_cancellation_charge = v_fare * 0.50;
    ELSE
        SET v_cancellation_charge = v_fare * 0.75;
    END IF;
    
    -- Calculate refund amount
    SET p_refund_amount = v_fare - v_cancellation_charge;
    
    -- Update ticket status to cancelled
    UPDATE ticket SET status = 'Cancelled' WHERE ticket_id = v_ticket_id;
    
    -- Insert into cancellation table
    INSERT INTO cancellation (
        ticket_id, cancellation_date, refund_amount, cancellation_charge
    ) VALUES (
        v_ticket_id, NOW(), p_refund_amount, v_cancellation_charge
    );
    
    -- Update payment status to refunded
    UPDATE payment SET payment_status = 'Refunded' WHERE ticket_id = v_ticket_id;
    
    -- Handle seat updates based on ticket status
    IF v_status = 'Confirmed' THEN
        -- Increment available seats
        UPDATE coach 
        SET available_seats = available_seats + 1
        WHERE coach_id = v_coach_id;
        
        -- Upgrade RAC to confirmed
        SELECT ticket_id INTO v_next_rac_ticket_id
        FROM rac
        WHERE status = 'RAC'
        AND ticket_id IN (
            SELECT ticket_id 
            FROM ticket 
            WHERE train_id = v_train_id 
            AND journey_date = v_journey_date
            AND coach_id = v_coach_id
        )
        ORDER BY position
        LIMIT 1;
        
        IF v_next_rac_ticket_id IS NOT NULL THEN
            UPDATE ticket 
            SET status = 'Confirmed', 
                seat_number = v_seat_number 
            WHERE ticket_id = v_next_rac_ticket_id;
            
            UPDATE rac 
            SET status = 'Confirmed' 
            WHERE ticket_id = v_next_rac_ticket_id;
            
            -- Update RAC positions
            UPDATE rac 
            SET position = position - 1
            WHERE position > (
                SELECT position 
                FROM rac 
                WHERE ticket_id = v_next_rac_ticket_id
            )
            AND status = 'RAC';
            
            -- Upgrade waitlist to RAC
            SELECT ticket_id INTO v_next_waitlist_ticket_id
            FROM waitlist
            WHERE status = 'Waiting'
            AND ticket_id IN (
                SELECT ticket_id 
                FROM ticket 
                WHERE train_id = v_train_id 
                AND journey_date = v_journey_date
                AND coach_id = v_coach_id
            )
            ORDER BY position
            LIMIT 1;
            
            IF v_next_waitlist_ticket_id IS NOT NULL THEN
                UPDATE ticket 
                SET status = 'RAC' 
                WHERE ticket_id = v_next_waitlist_ticket_id;
                
                UPDATE waitlist 
                SET status = 'RAC' 
                WHERE ticket_id = v_next_waitlist_ticket_id;
                
                INSERT INTO rac (ticket_id, position, status)
                SELECT v_next_waitlist_ticket_id, 
                       IFNULL(MAX(position), 0) + 1, 
                       'RAC'
                FROM rac
                WHERE ticket_id IN (
                    SELECT ticket_id 
                    FROM ticket 
                    WHERE train_id = v_train_id 
                    AND journey_date = v_journey_date
                    AND coach_id = v_coach_id
                );
                
                -- Increment available RAC seats
                UPDATE coach 
                SET available_rac_seats = available_rac_seats + 1
                WHERE coach_id = v_coach_id;
                
                -- Update waitlist positions
                UPDATE waitlist 
                SET position = position - 1
                WHERE position > (
                    SELECT position 
                    FROM waitlist 
                    WHERE ticket_id = v_next_waitlist_ticket_id
                )
                AND status = 'Waiting';
            END IF;
        END IF;
    ELSEIF v_status = 'RAC' THEN
        -- Increment available RAC seats
        UPDATE coach 
        SET available_rac_seats = available_rac_seats + 1
        WHERE coach_id = v_coach_id;
        
        -- Update RAC status and positions
        UPDATE rac 
        SET status = 'Cancelled' 
        WHERE ticket_id = v_ticket_id;
        
        UPDATE rac 
        SET position = position - 1
        WHERE position > (
            SELECT position 
            FROM rac 
            WHERE ticket_id = v_ticket_id
        )
        AND status = 'RAC';
        
        -- Upgrade waitlist to RAC
        SELECT ticket_id INTO v_next_waitlist_ticket_id
        FROM waitlist
        WHERE status = 'Waiting'
        AND ticket_id IN (
            SELECT ticket_id 
            FROM ticket 
            WHERE train_id = v_train_id 
            AND journey_date = v_journey_date
            AND coach_id = v_coach_id
        )
        ORDER BY position
        LIMIT 1;
        
        IF v_next_waitlist_ticket_id IS NOT NULL THEN
            UPDATE ticket 
            SET status = 'RAC' 
            WHERE ticket_id = v_next_waitlist_ticket_id;
            
            UPDATE waitlist 
            SET status = 'RAC' 
            WHERE ticket_id = v_next_waitlist_ticket_id;
            
            INSERT INTO rac (ticket_id, position, status)
            SELECT v_next_waitlist_ticket_id, 
                   IFNULL(MAX(position), 0) + 1, 
                   'RAC'
            FROM rac
            WHERE ticket_id IN (
                SELECT ticket_id 
                FROM ticket 
                WHERE train_id = v_train_id 
                AND journey_date = v_journey_date
                AND coach_id = v_coach_id
            );
            
            -- Update waitlist positions
            UPDATE waitlist 
            SET position = position - 1
            WHERE position > (
                SELECT position 
                FROM waitlist 
                WHERE ticket_id = v_next_waitlist_ticket_id
            )
            AND status = 'Waiting';
        END IF;
    ELSEIF v_status = 'Waiting' THEN
        -- Update waitlist status and positions
        UPDATE waitlist 
        SET status = 'Cancelled' 
        WHERE ticket_id = v_ticket_id;
        
        UPDATE waitlist 
        SET position = position - 1
        WHERE position > (
            SELECT position 
            FROM waitlist 
            WHERE ticket_id = v_ticket_id
        )
        AND status = 'Waiting';
    END IF;
    
    -- Return status
    SET p_status = 'Cancelled';
    
    COMMIT;
END //
DELIMITER ;

-- Procedure to confirm payment
DELIMITER //
CREATE PROCEDURE confirm_payment(
    IN p_payment_id INT,
    IN p_transaction_id VARCHAR(50),
    OUT p_status VARCHAR(20)
)
BEGIN
    UPDATE payment 
    SET payment_status = 'Completed'
    WHERE payment_id = p_payment_id AND transaction_id = p_transaction_id;
    
    IF ROW_COUNT() > 0 THEN
        SET p_status = 'Success';
    ELSE
        SET p_status = 'Failed';
    END IF;
END //
DELIMITER ;

-- Procedure to get payment history for a passenger
DELIMITER //
CREATE PROCEDURE get_payment_history(IN p_passenger_id INT)
BEGIN
    SELECT 
        py.payment_id,
        t.pnr,
        py.amount,
        py.payment_mode,
        py.payment_status,
        py.transaction_id,
        py.payment_date,
        tr.name AS train_name,
        s1.name AS from_station,
        s2.name AS to_station,
        t.journey_date
    FROM 
        payment py
        JOIN ticket t ON py.ticket_id = t.ticket_id
        JOIN train tr ON t.train_id = tr.train_id
        JOIN station s1 ON t.from_station_id = s1.station_id
        JOIN station s2 ON t.to_station_id = s2.station_id
    WHERE 
        t.passenger_id = p_passenger_id
    ORDER BY 
        py.payment_date DESC;
END //
DELIMITER ;

-- Procedure to get RAC tickets
DELIMITER //
CREATE PROCEDURE get_rac_tickets(IN p_train_id INT, IN p_journey_date DATE)
BEGIN
    SELECT 
        t.pnr,
        p.name AS passenger_name,
        r.position AS rac_position,
        t.journey_date,
        c.coach_name,
        c.class_type
    FROM 
        ticket t
        JOIN rac r ON t.ticket_id = r.ticket_id
        JOIN passenger p ON t.passenger_id = p.passenger_id
        LEFT JOIN coach c ON t.coach_id = c.coach_id
    WHERE 
        t.train_id = p_train_id
        AND t.journey_date = p_journey_date
        AND r.status = 'RAC'
    ORDER BY 
        r.position;
END //
DELIMITER ;

-- Procedure to get waitlist tickets
DELIMITER //
CREATE PROCEDURE get_waitlist_tickets(IN p_train_id INT, IN p_journey_date DATE)
BEGIN
    SELECT 
        t.pnr,
        p.name AS passenger_name,
        w.position AS waitlist_position,
        t.journey_date,
        c.coach_name,
        c.class_type
    FROM 
        ticket t
        JOIN waitlist w ON t.ticket_id = w.ticket_id
        JOIN passenger p ON t.passenger_id = p.passenger_id
        LEFT JOIN coach c ON t.coach_id = c.coach_id
    WHERE 
        t.train_id = p_train_id
        AND t.journey_date = p_journey_date
        AND w.status = 'Waiting'
    ORDER BY 
        w.position;
END //
DELIMITER ;

-- Procedure to find trains between stations
DELIMITER //
CREATE PROCEDURE find_trains_between_stations(IN p_from_station_id INT, IN p_to_station_id INT)
BEGIN
    SELECT DISTINCT 
        t.train_id, 
        t.name AS train_name,
        t.type AS train_type,
        s1.departure_time AS departure_time,
        s2.arrival_time AS arrival_time
    FROM 
        train t
        JOIN schedule s1 ON t.train_id = s1.train_id AND s1.station_id = p_from_station_id
        JOIN schedule s2 ON t.train_id = s2.train_id AND s2.station_id = p_to_station_id
    WHERE 
        s1.stop_number < s2.stop_number;
END //
DELIMITER ;

-- Procedure to get ticket by PNR
DELIMITER //
CREATE PROCEDURE get_ticket_by_pnr(IN p_pnr VARCHAR(10))
BEGIN
    SELECT 
        t.pnr,
        p.name AS passenger_name,
        tr.name AS train_name,
        s1.name AS from_station,
        s2.name AS to_station,
        c.coach_name,
        t.seat_number,
        t.journey_date,
        t.booking_date,
        t.status,
        t.fare
    FROM 
        ticket t
        JOIN passenger p ON t.passenger_id = p.passenger_id
        JOIN train tr ON t.train_id = tr.train_id
        JOIN station s1 ON t.from_station_id = s1.station_id
        JOIN station s2 ON t.to_station_id = s2.station_id
        LEFT JOIN coach c ON t.coach_id = c.coach_id
    WHERE 
        t.pnr = p_pnr;
END //
DELIMITER ;

-- Procedure to get passenger tickets
DELIMITER //
CREATE PROCEDURE get_passenger_tickets(IN p_passenger_id INT)
BEGIN
    SELECT 
        t.pnr,
        tr.name AS train_name,
        s1.name AS from_station,
        s2.name AS to_station,
        t.journey_date,
        t.status,
        t.fare
    FROM 
        ticket t
        JOIN train tr ON t.train_id = tr.train_id
        JOIN station s1 ON t.from_station_id = s1.station_id
        JOIN station s2 ON t.to_station_id = s2.station_id
    WHERE 
        t.passenger_id = p_passenger_id
    ORDER BY 
        t.journey_date;
END //
DELIMITER ;

-- Procedure to get train schedule
DELIMITER //
CREATE PROCEDURE get_train_schedule(IN p_train_id INT)
BEGIN
    SELECT 
        s.name AS station_name,
        sc.arrival_time,
        sc.departure_time,
        sc.day_number,
        sc.stop_number
    FROM 
        schedule sc
        JOIN station s ON sc.station_id = s.station_id
    WHERE 
        sc.train_id = p_train_id
    ORDER BY 
        sc.day_number, sc.stop_number;
END //
DELIMITER ;

-- Trigger for ticket status change
DELIMITER //
CREATE TRIGGER after_ticket_update
AFTER UPDATE ON ticket
FOR EACH ROW
BEGIN
    -- If status changes from confirmed to cancelled, log the change
    IF OLD.status = 'Confirmed' AND NEW.status = 'Cancelled' THEN
        INSERT INTO ticket_status_log (ticket_id, old_status, new_status, change_date)
        VALUES (NEW.ticket_id, OLD.status, NEW.status, NOW());
    END IF;
END //
DELIMITER ;

-- Trigger to update waitlist positions after a cancellation
DELIMITER //
CREATE TRIGGER after_waitlist_status_change
AFTER UPDATE ON waitlist
FOR EACH ROW
BEGIN
    -- If a waitlist ticket is moved to RAC or confirmed, reorder the remaining waitlist tickets
    IF OLD.status = 'Waiting' AND (NEW.status = 'RAC' OR NEW.status = 'Confirmed') THEN
        UPDATE waitlist w
        SET w.position = w.position - 1
        WHERE w.position > OLD.position AND w.status = 'Waiting';
    END IF;
END //
DELIMITER ;

-- Trigger to update RAC positions after a confirmation
DELIMITER //
CREATE TRIGGER after_rac_status_change
AFTER UPDATE ON rac
FOR EACH ROW
BEGIN
    -- If a RAC ticket is confirmed, reorder the remaining RAC tickets
    IF OLD.status = 'RAC' AND NEW.status = 'Confirmed' THEN
        UPDATE rac r
        SET r.position = r.position - 1
        WHERE r.position > OLD.position AND r.status = 'RAC';
    END IF;
END //
DELIMITER ;

-- Initialize coach seat counts (run after inserting coaches)
UPDATE coach 
SET available_seats = total_seats,
    total_rac_seats = FLOOR(total_seats * 0.1),
    available_rac_seats = FLOOR(total_seats * 0.1)
WHERE available_seats = 0;

DELIMITER //
CREATE TRIGGER after_ticket_insert
AFTER INSERT ON ticket
FOR EACH ROW
BEGIN
    -- If status is Confirmed, decrement available seats
    IF NEW.status = 'Confirmed' THEN
        UPDATE coach 
        SET available_seats = available_seats - 1
        WHERE coach_id = NEW.coach_id;
    END IF;
    
    -- If status is RAC, decrement available RAC seats
    IF NEW.status = 'RAC' THEN
        UPDATE coach 
        SET available_rac_seats = available_rac_seats - 1
        WHERE coach_id = NEW.coach_id;
    END IF;
END //
DELIMITER ;


--load data into tables
LOAD DATA LOCAL INFILE 'C:\\Users\\hp\\Desktop\\Database Project\\station.csv'
INTO TABLE station
FIELDS TERMINATED BY ',' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'C:\\Users\\hp\\Desktop\\Database Project\\train.csv'
INTO TABLE train
FIELDS TERMINATED BY ',' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'C:\\Users\\hp\\Desktop\\Database Project\\passenger.csv'
INTO TABLE passenger
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"'
ESCAPED BY '\\'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'C:\\Users\\hp\\Desktop\\Database Project\\cost.csv'
INTO TABLE cost
FIELDS TERMINATED BY ',' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'C:\\Users\\hp\\Desktop\\Database Project\\coach.csv'
INTO TABLE coach
FIELDS TERMINATED BY ',' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'C:\\Users\\hp\\Desktop\\Database Project\\seat.csv'
INTO TABLE seat
FIELDS TERMINATED BY ',' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'C:\\Users\\hp\\Desktop\\Database Project\\schedule.csv'
INTO TABLE schedule
FIELDS TERMINATED BY ',' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'C:\\Users\\hp\\Desktop\\Database Project\\distance.csv'
INTO TABLE distance
FIELDS TERMINATED BY ',' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SET FOREIGN_KEY_CHECKS = 0;
LOAD DATA LOCAL INFILE 'C:\\Users\\hp\\Desktop\\Database Project\\ticket.csv'
INTO TABLE ticket
FIELDS TERMINATED BY ',' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
SET FOREIGN_KEY_CHECKS = 1;

LOAD DATA LOCAL INFILE 'C:\\Users\\hp\\Desktop\\Database Project\\rac.csv'
INTO TABLE rac
FIELDS TERMINATED BY ',' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'C:\\Users\\hp\\Desktop\\Database Project\\waitlist.csv'
INTO TABLE waitlist
FIELDS TERMINATED BY ',' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'C:\\Users\\hp\\Desktop\\Database Project\\payment.csv'
INTO TABLE payment
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(payment_id, ticket_id, amount, payment_mode, payment_status, transaction_id, payment_date);

LOAD DATA LOCAL INFILE 'C:\\Users\\hp\\Desktop\\Database Project\\cancellation.csv'
INTO TABLE cancellation
FIELDS TERMINATED BY ',' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;


LOAD DATA LOCAL INFILE 'C:\\Users\\hp\\Desktop\\Database Project\\ticket_status_log.csv'
INTO TABLE ticket_status_log
FIELDS TERMINATED BY ',' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

--Queries
-- Query to track PNR status for a given ticket
-- This provides comprehensive information about a ticket using its PNR number
SELECT 
    t.pnr,
    p.name AS passenger_name,
    tr.name AS train_name,
    s1.name AS from_station,
    s2.name AS to_station,
    c.coach_name,
    t.seat_number,
    t.journey_date,
    t.status,
    t.fare,
    CASE 
        WHEN t.status = 'Waiting' THEN (
            SELECT position FROM waitlist WHERE ticket_id = t.ticket_id
        )
        WHEN t.status = 'RAC' THEN (
            SELECT position FROM rac WHERE ticket_id = t.ticket_id
        )
        ELSE NULL
    END AS position
FROM 
    ticket t
    JOIN passenger p ON t.passenger_id = p.passenger_id
    JOIN train tr ON t.train_id = tr.train_id
    JOIN station s1 ON t.from_station_id = s1.station_id
    JOIN station s2 ON t.to_station_id = s2.station_id
    LEFT JOIN coach c ON t.coach_id = c.coach_id
WHERE 
    t.pnr = 'PNR8254631'; 

-- Query to lookup the complete schedule for a given train
-- Shows all stations, arrival/departure times, and day numbers in sequence
SELECT 
    t.name AS train_name,
    t.type AS train_type,
    s.name AS station_name,
    s.code AS station_code,
    sc.arrival_time,
    sc.departure_time,
    sc.day_number,
    sc.stop_number
FROM 
    train t
    JOIN schedule sc ON t.train_id = sc.train_id
    JOIN station s ON sc.station_id = s.station_id
WHERE 
    t.train_id = 1 
ORDER BY 
    sc.day_number, sc.stop_number;

-- Query to check available seats for a specific train, date and class
-- Returns coach details with availability information
SELECT 
    t.name AS train_name,
    c.coach_name,
    c.class_type,
    c.total_seats,
    c.available_seats,
    c.total_rac_seats,
    c.available_rac_seats,
    (
        SELECT COUNT(*) 
        FROM waitlist w 
        JOIN ticket tk ON w.ticket_id = tk.ticket_id 
        WHERE tk.train_id = t.train_id 
        AND tk.journey_date = '2023-08-05' 
        AND tk.coach_id = c.coach_id
        AND w.status = 'Waiting'
    ) AS waitlist_count
FROM 
    train t
    JOIN coach c ON t.train_id = c.train_id
WHERE 
    t.train_id = 2 
    AND c.class_type = 'AC First Class';

-- Query to list all confirmed passengers traveling on a specific train on a given date
-- Includes seat and coach information for each passenger
SELECT 
    p.passenger_id,
    p.name AS passenger_name,
    p.age,
    p.gender,
    t.pnr,
    c.coach_name,
    t.seat_number,
    s1.name AS boarding_station,
    s2.name AS destination_station
FROM 
    ticket t
    JOIN passenger p ON t.passenger_id = p.passenger_id
    JOIN coach c ON t.coach_id = c.coach_id
    JOIN station s1 ON t.from_station_id = s1.station_id
    JOIN station s2 ON t.to_station_id = s2.station_id
WHERE 
    t.train_id = 3 -- Replace with actual train_id
    AND t.journey_date = '2023-07-18' -- Replace with actual date
    AND t.status = 'Confirmed'
ORDER BY 
    c.coach_name, t.seat_number;


-- Query to retrieve all waitlisted passengers for a particular train
-- Includes waitlist position for each passenger
SELECT 
    p.name AS passenger_name,
    p.age,
    p.gender,
    t.pnr,
    c.class_type,
    w.position AS waitlist_position,
    t.journey_date,
    s1.name AS from_station,
    s2.name AS to_station
FROM 
    ticket t
    JOIN passenger p ON t.passenger_id = p.passenger_id
    JOIN waitlist w ON t.ticket_id = w.ticket_id
    LEFT JOIN coach c ON t.coach_id = c.coach_id
    JOIN station s1 ON t.from_station_id = s1.station_id
    JOIN station s2 ON t.to_station_id = s2.station_id
WHERE 
    t.train_id = 7 
    AND t.journey_date = '2023-07-26'
    AND TRIM(LOWER(t.status)) = 'waiting'
ORDER BY 
    w.position;


-- Query to find total amount that needs to be refunded for cancelling a train
-- Calculates refund for all active tickets on a specific train and date
SELECT 
    SUM(t.fare) AS total_refund_amount,
    COUNT(*) AS total_tickets_to_refund
FROM 
    ticket t
WHERE 
    t.train_id = 4 
    AND t.journey_date = '2023-08-31' 
    AND t.status IN ('Confirmed', 'RAC', 'Waiting');

-- Query to calculate total revenue generated from ticket bookings over a specified period
-- Breaks down revenue by train type and payment status
SELECT 
    tr.type AS train_type,
    COUNT(t.ticket_id) AS tickets_sold,
    SUM(t.fare) AS total_revenue,
    SUM(CASE WHEN py.payment_status = 'Completed' THEN t.fare ELSE 0 END) AS realized_revenue,
    SUM(CASE WHEN py.payment_status = 'Pending' THEN t.fare ELSE 0 END) AS pending_revenue
FROM 
    ticket t
    JOIN train tr ON t.train_id = tr.train_id
    JOIN payment py ON t.ticket_id = py.ticket_id
WHERE 
    t.booking_date BETWEEN '2023-07-01' AND '2023-07-03' 
GROUP BY 
    tr.type
ORDER BY 
    total_revenue DESC;


-- Query to get cancellation records with refund status
-- Provides detailed information about cancelled tickets and refund amounts
SELECT 
    t.pnr,
    p.name AS passenger_name,
    tr.name AS train_name,
    t.journey_date,
    c.cancellation_date,
    t.fare AS original_fare,
    c.cancellation_charge,
    c.refund_amount,
    py.payment_status
FROM 
    cancellation c
    JOIN ticket t ON c.ticket_id = t.ticket_id
    JOIN passenger p ON t.passenger_id = p.passenger_id
    JOIN train tr ON t.train_id = tr.train_id
    JOIN payment py ON t.ticket_id = py.ticket_id
WHERE 
    c.cancellation_date BETWEEN '2023-07-01' AND '2023-07-31' 
ORDER BY 
    c.cancellation_date DESC;

-- Query to find the busiest route based on passenger count
-- Identifies popular routes by counting tickets between station pairs
SELECT 
    s1.name AS from_station,
    s2.name AS to_station,
    COUNT(*) AS passenger_count,
    SUM(t.fare) AS total_revenue
FROM 
    ticket t
    JOIN station s1 ON t.from_station_id = s1.station_id
    JOIN station s2 ON t.to_station_id = s2.station_id
WHERE 
    t.journey_date BETWEEN '2023-07-01' AND '2023-07-31'
    AND t.status = 'Confirmed'
GROUP BY 
    t.from_station_id, t.to_station_id
ORDER BY 
    passenger_count DESC
LIMIT 10;

-- Query to generate an itemized bill for a ticket including all charges
-- Breaks down the fare components
SELECT 
    t.pnr,
    p.name AS passenger_name,
    tr.name AS train_name,
    t.journey_date,
    s1.name AS from_station,
    s2.name AS to_station,
    c.coach_name,
    c.class_type,
    t.seat_number,
    d.distance_km,
    co.base_fare,
    (d.distance_km * co.per_km_charge) AS distance_charge,
    CASE 
        WHEN p.concession_category = 'Senior Citizen' THEN (co.base_fare + (d.distance_km * co.per_km_charge)) * 0.4
        WHEN p.concession_category = 'Student' THEN (co.base_fare + (d.distance_km * co.per_km_charge)) * 0.25
        WHEN p.concession_category = 'Physically Challenged' THEN (co.base_fare + (d.distance_km * co.per_km_charge)) * 0.75
        ELSE 0
    END AS concession_amount,
    t.fare AS total_fare,
    py.payment_mode,
    py.payment_status
FROM 
    ticket t
    JOIN passenger p ON t.passenger_id = p.passenger_id
    JOIN train tr ON t.train_id = tr.train_id
    JOIN station s1 ON t.from_station_id = s1.station_id
    JOIN station s2 ON t.to_station_id = s2.station_id
    LEFT JOIN coach c ON t.coach_id = c.coach_id
    LEFT JOIN payment py ON t.ticket_id = py.ticket_id
    LEFT JOIN distance d ON (d.from_station_id = t.from_station_id AND d.to_station_id = t.to_station_id)
    LEFT JOIN cost co ON co.class_type = c.class_type AND co.train_type = tr.type
WHERE 
    t.pnr = 'PNR8254631';


--Additional Queries
-- Query to analyze station traffic and revenue
-- Identifies busy stations and their contribution to revenue
SELECT 
    s.name AS station_name,
    s.city,
    s.state,
    COUNT(CASE WHEN t.from_station_id = s.station_id THEN 1 END) AS departures,
    COUNT(CASE WHEN t.to_station_id = s.station_id THEN 1 END) AS arrivals,
    COUNT(*) AS total_traffic,
    SUM(t.fare) AS total_revenue
FROM 
    station s
    LEFT JOIN ticket t ON s.station_id = t.from_station_id OR s.station_id = t.to_station_id
WHERE 
    t.journey_date BETWEEN '2023-07-01' AND '2023-07-31' 
GROUP BY 
    s.station_id
ORDER BY 
    total_traffic DESC;


-- Query to analyze revenue by train class and type
-- Helps identify most profitable train and class combinations
SELECT 
    tr.type AS train_type,
    c.class_type,
    COUNT(*) AS tickets_sold,
    SUM(t.fare) AS total_revenue,
    AVG(t.fare) AS average_fare,
    MIN(t.fare) AS minimum_fare,
    MAX(t.fare) AS maximum_fare
FROM 
    ticket t
    JOIN train tr ON t.train_id = tr.train_id
    JOIN coach c ON t.coach_id = c.coach_id
WHERE 
    t.booking_date BETWEEN '2023-07-01' AND '2023-07-31' 
    AND t.status = 'Confirmed'
GROUP BY 
    tr.type, c.class_type
ORDER BY 
    total_revenue DESC;

-- Query to analyze concession usage patterns
-- Helps understand the impact of concessions on revenue
SELECT 
    p.concession_category,
    COUNT(*) AS tickets_booked,
    SUM(t.fare) AS total_fare_after_concession,
    AVG(t.fare) AS average_fare,
    -- Calculate approximate fare before concession
    CASE 
        WHEN p.concession_category = 'Senior Citizen' THEN SUM(t.fare) / 0.6 -- 40% discount
        WHEN p.concession_category = 'Student' THEN SUM(t.fare) / 0.75 -- 25% discount
        WHEN p.concession_category = 'Physically Challenged' THEN SUM(t.fare) / 0.25 -- 75% discount
        ELSE SUM(t.fare)
    END AS estimated_fare_before_concession,
    -- Calculate approximate concession amount
    CASE 
        WHEN p.concession_category = 'Senior Citizen' THEN SUM(t.fare) * (1/0.6 - 1) -- 40% discount
        WHEN p.concession_category = 'Student' THEN SUM(t.fare) * (1/0.75 - 1) -- 25% discount
        WHEN p.concession_category = 'Physically Challenged' THEN SUM(t.fare) * (1/0.25 - 1) -- 75% discount
        ELSE 0
    END AS estimated_concession_amount
FROM 
    passenger p
    JOIN ticket t ON p.passenger_id = t.passenger_id
WHERE 
    t.booking_date BETWEEN '2023-07-01' AND '2023-07-31' 
GROUP BY 
    p.concession_category
ORDER BY 
    tickets_booked DESC;