CREATE DATABASE IF NOT EXISTS event_booking_system;
USE event_booking_system;

CREATE TABLE IF NOT EXISTS users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  email VARCHAR(150) NOT NULL UNIQUE,
  password VARCHAR(255) NOT NULL,
  role ENUM('user', 'admin') NOT NULL DEFAULT 'user',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS events (
  id INT AUTO_INCREMENT PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  description TEXT NOT NULL,
  category VARCHAR(60) NOT NULL DEFAULT 'Seminar',
  date DATETIME NOT NULL,
  venue VARCHAR(255) NOT NULL,
  seats INT NOT NULL DEFAULT 0,
  image_url TEXT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_events_date (date)
);

SET @event_category_exists = (
  SELECT COUNT(*)
  FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_SCHEMA = 'event_booking_system' AND TABLE_NAME = 'events' AND COLUMN_NAME = 'category'
);
SET @event_category_sql = IF(
  @event_category_exists = 0,
  'ALTER TABLE events ADD COLUMN category VARCHAR(60) NOT NULL DEFAULT ''Seminar'' AFTER description',
  'SELECT 1'
);
PREPARE event_category_stmt FROM @event_category_sql;
EXECUTE event_category_stmt;
DEALLOCATE PREPARE event_category_stmt;

SET @event_price_exists = (
  SELECT COUNT(*)
  FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_SCHEMA = 'event_booking_system' AND TABLE_NAME = 'events' AND COLUMN_NAME = 'price'
);
SET @event_price_sql = IF(
  @event_price_exists = 0,
  'ALTER TABLE events ADD COLUMN price DECIMAL(10, 2) NOT NULL DEFAULT 0.00 AFTER seats',
  'SELECT 1'
);
PREPARE event_price_stmt FROM @event_price_sql;
EXECUTE event_price_stmt;
DEALLOCATE PREPARE event_price_stmt;

CREATE TABLE IF NOT EXISTS bookings (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  event_id INT NOT NULL,
  tickets_count INT NOT NULL,
  payment_method VARCHAR(30) NOT NULL DEFAULT 'card',
  upi_id VARCHAR(100) NULL,
  card_holder_name VARCHAR(100) NOT NULL,
  card_last4 CHAR(4) NOT NULL,
  card_brand VARCHAR(30) NOT NULL,
  payment_status VARCHAR(20) NOT NULL DEFAULT 'paid',
  status VARCHAR(20) NOT NULL DEFAULT 'confirmed',
  cancelled_at TIMESTAMP NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_bookings_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  CONSTRAINT fk_bookings_event FOREIGN KEY (event_id) REFERENCES events(id) ON DELETE CASCADE,
  INDEX idx_bookings_user_id (user_id),
  INDEX idx_bookings_event_id (event_id)
);

SET @booking_status_exists = (
  SELECT COUNT(*)
  FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_SCHEMA = 'event_booking_system' AND TABLE_NAME = 'bookings' AND COLUMN_NAME = 'status'
);
SET @booking_status_sql = IF(
  @booking_status_exists = 0,
  'ALTER TABLE bookings ADD COLUMN status VARCHAR(20) NOT NULL DEFAULT ''confirmed'' AFTER payment_status',
  'SELECT 1'
);
PREPARE booking_status_stmt FROM @booking_status_sql;
EXECUTE booking_status_stmt;
DEALLOCATE PREPARE booking_status_stmt;

SET @cancelled_at_exists = (
  SELECT COUNT(*)
  FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_SCHEMA = 'event_booking_system' AND TABLE_NAME = 'bookings' AND COLUMN_NAME = 'cancelled_at'
);
SET @cancelled_at_sql = IF(
  @cancelled_at_exists = 0,
  'ALTER TABLE bookings ADD COLUMN cancelled_at TIMESTAMP NULL AFTER status',
  'SELECT 1'
);
PREPARE cancelled_at_stmt FROM @cancelled_at_sql;
EXECUTE cancelled_at_stmt;
DEALLOCATE PREPARE cancelled_at_stmt;

SET @payment_method_exists = (
  SELECT COUNT(*)
  FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_SCHEMA = 'event_booking_system' AND TABLE_NAME = 'bookings' AND COLUMN_NAME = 'payment_method'
);
SET @payment_method_sql = IF(
  @payment_method_exists = 0,
  'ALTER TABLE bookings ADD COLUMN payment_method VARCHAR(30) NOT NULL DEFAULT ''card''',
  'SELECT 1'
);
PREPARE payment_method_stmt FROM @payment_method_sql;
EXECUTE payment_method_stmt;
DEALLOCATE PREPARE payment_method_stmt;

SET @card_holder_name_exists = (
  SELECT COUNT(*)
  FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_SCHEMA = 'event_booking_system' AND TABLE_NAME = 'bookings' AND COLUMN_NAME = 'card_holder_name'
);
SET @card_holder_name_sql = IF(
  @card_holder_name_exists = 0,
  'ALTER TABLE bookings ADD COLUMN card_holder_name VARCHAR(100) NOT NULL DEFAULT ''Demo User''',
  'SELECT 1'
);
PREPARE card_holder_name_stmt FROM @card_holder_name_sql;
EXECUTE card_holder_name_stmt;
DEALLOCATE PREPARE card_holder_name_stmt;

SET @upi_id_exists = (
  SELECT COUNT(*)
  FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_SCHEMA = 'event_booking_system' AND TABLE_NAME = 'bookings' AND COLUMN_NAME = 'upi_id'
);
SET @upi_id_sql = IF(
  @upi_id_exists = 0,
  'ALTER TABLE bookings ADD COLUMN upi_id VARCHAR(100) NULL AFTER payment_method',
  'SELECT 1'
);
PREPARE upi_id_stmt FROM @upi_id_sql;
EXECUTE upi_id_stmt;
DEALLOCATE PREPARE upi_id_stmt;

SET @card_last4_exists = (
  SELECT COUNT(*)
  FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_SCHEMA = 'event_booking_system' AND TABLE_NAME = 'bookings' AND COLUMN_NAME = 'card_last4'
);
SET @card_last4_sql = IF(
  @card_last4_exists = 0,
  'ALTER TABLE bookings ADD COLUMN card_last4 CHAR(4) NOT NULL DEFAULT ''0000''',
  'SELECT 1'
);
PREPARE card_last4_stmt FROM @card_last4_sql;
EXECUTE card_last4_stmt;
DEALLOCATE PREPARE card_last4_stmt;

SET @card_brand_exists = (
  SELECT COUNT(*)
  FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_SCHEMA = 'event_booking_system' AND TABLE_NAME = 'bookings' AND COLUMN_NAME = 'card_brand'
);
SET @card_brand_sql = IF(
  @card_brand_exists = 0,
  'ALTER TABLE bookings ADD COLUMN card_brand VARCHAR(30) NOT NULL DEFAULT ''Visa''',
  'SELECT 1'
);
PREPARE card_brand_stmt FROM @card_brand_sql;
EXECUTE card_brand_stmt;
DEALLOCATE PREPARE card_brand_stmt;

SET @payment_status_exists = (
  SELECT COUNT(*)
  FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_SCHEMA = 'event_booking_system' AND TABLE_NAME = 'bookings' AND COLUMN_NAME = 'payment_status'
);
SET @payment_status_sql = IF(
  @payment_status_exists = 0,
  'ALTER TABLE bookings ADD COLUMN payment_status VARCHAR(20) NOT NULL DEFAULT ''paid''',
  'SELECT 1'
);
PREPARE payment_status_stmt FROM @payment_status_sql;
EXECUTE payment_status_stmt;
DEALLOCATE PREPARE payment_status_stmt;

SET @booking_amount_exists = (
  SELECT COUNT(*)
  FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_SCHEMA = 'event_booking_system' AND TABLE_NAME = 'bookings' AND COLUMN_NAME = 'amount'
);
SET @booking_amount_sql = IF(
  @booking_amount_exists = 0,
  'ALTER TABLE bookings ADD COLUMN amount DECIMAL(10, 2) NOT NULL DEFAULT 0.00 AFTER tickets_count',
  'SELECT 1'
);
PREPARE booking_amount_stmt FROM @booking_amount_sql;
EXECUTE booking_amount_stmt;
DEALLOCATE PREPARE booking_amount_stmt;

-- Tags table for event categorization
CREATE TABLE IF NOT EXISTS tags (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL UNIQUE,
  color VARCHAR(7) DEFAULT '#007bff',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Junction table for events and tags (many-to-many relationship)
CREATE TABLE IF NOT EXISTS event_tags (
  event_id INT NOT NULL,
  tag_id INT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (event_id, tag_id),
  CONSTRAINT fk_event_tags_event FOREIGN KEY (event_id) REFERENCES events(id) ON DELETE CASCADE,
  CONSTRAINT fk_event_tags_tag FOREIGN KEY (tag_id) REFERENCES tags(id) ON DELETE CASCADE
);

-- Notifications table for real-time notifications
CREATE TABLE IF NOT EXISTS notifications (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  type VARCHAR(50) NOT NULL,
  title VARCHAR(255) NOT NULL,
  message TEXT NOT NULL,
  related_event_id INT NULL,
  related_booking_id INT NULL,
  is_read BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_notifications_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  CONSTRAINT fk_notifications_event FOREIGN KEY (related_event_id) REFERENCES events(id) ON DELETE SET NULL,
  CONSTRAINT fk_notifications_booking FOREIGN KEY (related_booking_id) REFERENCES bookings(id) ON DELETE SET NULL,
  INDEX idx_notifications_user_id (user_id),
  INDEX idx_notifications_is_read (is_read),
  INDEX idx_notifications_created_at (created_at)
);

-- Insert default tags
INSERT IGNORE INTO tags (name, color) VALUES
  ('Webinar', '#3498db'),
  ('Workshop', '#e74c3c'),
  ('Seminar', '#2ecc71'),
  ('Conference', '#f39c12'),
  ('Networking', '#9b59b6'),
  ('Training', '#1abc9c');

-- OTP verifications table for temporary OTP storage
CREATE TABLE IF NOT EXISTS otp_verifications (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  email VARCHAR(150) NOT NULL,
  otp_code VARCHAR(10) NOT NULL,
  purpose VARCHAR(50) NOT NULL, -- 'login', 'booking', 'payment', etc.
  expires_at TIMESTAMP NOT NULL,
  is_used BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_otp_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  INDEX idx_otp_user_email (user_id, email),
  INDEX idx_otp_expires_at (expires_at)
);

-- Tracks automated email reminders so users do not receive duplicate reminders
CREATE TABLE IF NOT EXISTS event_reminders_sent (
  id INT AUTO_INCREMENT PRIMARY KEY,
  booking_id INT NOT NULL,
  reminder_hours INT NOT NULL,
  sent_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_event_reminders_booking FOREIGN KEY (booking_id) REFERENCES bookings(id) ON DELETE CASCADE,
  UNIQUE KEY uniq_booking_reminder_hours (booking_id, reminder_hours),
  INDEX idx_event_reminders_sent_at (sent_at)
);
