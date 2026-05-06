-- MariaDB dump 10.19  Distrib 10.4.32-MariaDB, for Win64 (AMD64)
--
-- Host: localhost    Database: event_booking_system
-- ------------------------------------------------------
-- Server version	10.4.32-MariaDB

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Current Database: `event_booking_system`
--

CREATE DATABASE /*!32312 IF NOT EXISTS*/ `event_booking_system` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci */;

USE `event_booking_system`;

--
-- Table structure for table `bookings`
--

DROP TABLE IF EXISTS `bookings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `bookings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `event_id` int(11) NOT NULL,
  `tickets_count` int(11) NOT NULL,
  `payment_method` varchar(30) NOT NULL DEFAULT 'card',
  `upi_id` varchar(100) DEFAULT NULL,
  `card_holder_name` varchar(100) NOT NULL,
  `card_last4` char(4) NOT NULL,
  `card_brand` varchar(30) NOT NULL,
  `payment_status` varchar(20) NOT NULL DEFAULT 'paid',
  `status` varchar(20) NOT NULL DEFAULT 'confirmed',
  `cancelled_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_bookings_user_id` (`user_id`),
  KEY `idx_bookings_event_id` (`event_id`),
  CONSTRAINT `fk_bookings_event` FOREIGN KEY (`event_id`) REFERENCES `events` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_bookings_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bookings`
--

LOCK TABLES `bookings` WRITE;
/*!40000 ALTER TABLE `bookings` DISABLE KEYS */;
INSERT INTO `bookings` VALUES (1,3,1,2,'card',NULL,'Aditi Sharma','4242','Visa','paid','confirmed',NULL,'2026-05-04 18:22:20'),(2,3,2,1,'card',NULL,'Aditi Sharma','4444','Mastercard','paid','confirmed',NULL,'2026-05-04 18:22:20'),(3,3,3,1,'upi','aditi.sharma@oksbi','Aditi Sharma','ksbi','UPI','paid','confirmed',NULL,'2026-05-04 18:22:20'),(4,4,2,1,'upi','teju@uplxi','tejaswani','plxi','UPI','paid','confirmed',NULL,'2026-05-04 18:30:04');
/*!40000 ALTER TABLE `bookings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `event_reminders_sent`
--

DROP TABLE IF EXISTS `event_reminders_sent`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `event_reminders_sent` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `booking_id` int(11) NOT NULL,
  `reminder_hours` int(11) NOT NULL,
  `sent_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uniq_booking_reminder_hours` (`booking_id`,`reminder_hours`),
  KEY `idx_event_reminders_sent_at` (`sent_at`),
  CONSTRAINT `fk_event_reminders_booking` FOREIGN KEY (`booking_id`) REFERENCES `bookings` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `event_reminders_sent`
--

LOCK TABLES `event_reminders_sent` WRITE;
/*!40000 ALTER TABLE `event_reminders_sent` DISABLE KEYS */;
/*!40000 ALTER TABLE `event_reminders_sent` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `event_tags`
--

DROP TABLE IF EXISTS `event_tags`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `event_tags` (
  `event_id` int(11) NOT NULL,
  `tag_id` int(11) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`event_id`,`tag_id`),
  KEY `fk_event_tags_tag` (`tag_id`),
  CONSTRAINT `fk_event_tags_event` FOREIGN KEY (`event_id`) REFERENCES `events` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_event_tags_tag` FOREIGN KEY (`tag_id`) REFERENCES `tags` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `event_tags`
--

LOCK TABLES `event_tags` WRITE;
/*!40000 ALTER TABLE `event_tags` DISABLE KEYS */;
/*!40000 ALTER TABLE `event_tags` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `events`
--

DROP TABLE IF EXISTS `events`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `events` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(255) NOT NULL,
  `description` text NOT NULL,
  `category` varchar(60) NOT NULL DEFAULT 'Seminar',
  `date` datetime NOT NULL,
  `venue` varchar(255) NOT NULL,
  `seats` int(11) NOT NULL DEFAULT 0,
  `image_url` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_events_date` (`date`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `events`
--

LOCK TABLES `events` WRITE;
/*!40000 ALTER TABLE `events` DISABLE KEYS */;
INSERT INTO `events` VALUES (1,'AI Technical Fest 2026','An internal technical fest featuring AI project expo, coding sprint, and panel discussions by faculty.','Technical Fest','2026-06-10 10:00:00','Main Auditorium',118,'https://images.unsplash.com/photo-1519389950473-47ba0277781c?auto=format&fit=crop&w=1200&q=80','2026-05-04 18:22:20','2026-05-04 18:22:20'),(2,'Cloud Workshop: DevOps in Practice','Hands-on workshop on CI/CD, Docker pipelines, and cloud deployment strategies for students and faculty.','Workshop','2026-07-05 14:30:00','Lab 4, CS Block',59,'https://images.unsplash.com/photo-1451187580459-43490279c0fa?auto=format&fit=crop&w=1200&q=80','2026-05-04 18:22:20','2026-05-04 18:30:04'),(3,'Cybersecurity Seminar','Expert-led seminar on secure coding patterns, zero-trust architecture, and incident response playbooks.','Seminar','2026-08-12 11:00:00','Seminar Hall B',80,'https://images.unsplash.com/photo-1563013544-824ae1b704d3?auto=format&fit=crop&w=1200&q=80','2026-05-04 18:22:20','2026-05-04 18:22:20'),(4,'Data Science Research Colloquium','Faculty and postgraduate researchers present applied analytics work in healthcare, climate, and smart campus systems.','Colloquium','2026-09-03 09:30:00','Innovation Center',90,'https://images.unsplash.com/photo-1551288049-bebda4e38f71?auto=format&fit=crop&w=1200&q=80','2026-05-04 18:22:20','2026-05-04 18:22:20'),(5,'Hackathon Kickoff Night','A high-energy opening session with team formation, mentor introductions, sponsor challenges, and late-night coding pods.','Hackathon','2026-09-18 18:00:00','Central Computing Hub',150,'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?auto=format&fit=crop&w=1200&q=80','2026-05-04 18:22:20','2026-05-04 18:22:20'),(6,'UI/UX Design Sprint','A product design bootcamp covering rapid wireframing, accessibility reviews, usability testing, and portfolio critique.','Workshop','2026-10-02 13:00:00','Design Studio 2',45,'https://images.unsplash.com/photo-1522542550221-31fd19575a2d?auto=format&fit=crop&w=1200&q=80','2026-05-04 18:22:20','2026-05-04 18:22:20'),(7,'Robotics Arena Demo Day','Student teams showcase autonomous bots, embedded systems, and computer vision demos on a live challenge course.','Demo Day','2026-10-21 16:00:00','Mechanical Block Arena',110,'https://images.unsplash.com/photo-1535378917042-10a22c95931a?auto=format&fit=crop&w=1200&q=80','2026-05-04 18:22:20','2026-05-04 18:22:20'),(8,'Startup Founder Fireside','A candid evening conversation with alumni founders on product-market fit, fundraising, and building technical teams.','Talk','2026-11-07 17:30:00','Conference Hall A',70,'https://images.unsplash.com/photo-1515169067868-5387ec356754?auto=format&fit=crop&w=1200&q=80','2026-05-04 18:22:20','2026-05-04 18:22:20'),(9,'Annual Project Expo','Final-year capstone teams exhibit production-ready software, IoT systems, and AI prototypes to industry guests.','Expo','2026-11-28 10:30:00','Exhibition Pavilion',200,'https://images.unsplash.com/photo-1511578314322-379afb476865?auto=format&fit=crop&w=1200&q=80','2026-05-04 18:22:20','2026-05-04 18:22:20');
/*!40000 ALTER TABLE `events` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `notifications`
--

DROP TABLE IF EXISTS `notifications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `notifications` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `type` varchar(50) NOT NULL,
  `title` varchar(255) NOT NULL,
  `message` text NOT NULL,
  `related_event_id` int(11) DEFAULT NULL,
  `related_booking_id` int(11) DEFAULT NULL,
  `is_read` tinyint(1) DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `fk_notifications_event` (`related_event_id`),
  KEY `fk_notifications_booking` (`related_booking_id`),
  KEY `idx_notifications_user_id` (`user_id`),
  KEY `idx_notifications_is_read` (`is_read`),
  KEY `idx_notifications_created_at` (`created_at`),
  CONSTRAINT `fk_notifications_booking` FOREIGN KEY (`related_booking_id`) REFERENCES `bookings` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_notifications_event` FOREIGN KEY (`related_event_id`) REFERENCES `events` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_notifications_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `notifications`
--

LOCK TABLES `notifications` WRITE;
/*!40000 ALTER TABLE `notifications` DISABLE KEYS */;
INSERT INTO `notifications` VALUES (1,4,'payment_received','Payment Received ✓','We\'ve received your payment for \'React Advanced Concepts\' workshop.',NULL,NULL,1,'2026-05-04 18:25:32'),(2,4,'payment_received','Payment Received ✓','We\'ve received your payment for \'React Advanced Concepts\' workshop.',NULL,NULL,1,'2026-05-04 18:25:32'),(3,4,'booking_confirmed','Booking Confirmed ✓','Your booking for \'Advanced Web Development Workshop\' has been confirmed with 2 tickets.',NULL,NULL,1,'2026-05-04 18:25:32'),(4,4,'event_started','Event Starting Soon ⏰','\'Data Science Masterclass\' starts in 30 minutes. Join now!',NULL,NULL,1,'2026-05-04 18:25:32'),(5,4,'payment_received','Payment Received ✓','We\'ve received your payment for \'React Advanced Concepts\' workshop.',NULL,NULL,1,'2026-05-04 18:25:32'),(6,4,'booking_confirmed','Booking Confirmed','Your booking for \"Cloud Workshop: DevOps in Practice\" on 5/7/2026 has been confirmed with 1 ticket(s).',2,4,0,'2026-05-04 18:30:04');
/*!40000 ALTER TABLE `notifications` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `otp_verifications`
--

DROP TABLE IF EXISTS `otp_verifications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `otp_verifications` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `email` varchar(150) NOT NULL,
  `otp_code` varchar(10) NOT NULL,
  `purpose` varchar(50) NOT NULL,
  `expires_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `is_used` tinyint(1) DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_otp_user_email` (`user_id`,`email`),
  KEY `idx_otp_expires_at` (`expires_at`),
  CONSTRAINT `fk_otp_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `otp_verifications`
--

LOCK TABLES `otp_verifications` WRITE;
/*!40000 ALTER TABLE `otp_verifications` DISABLE KEYS */;
INSERT INTO `otp_verifications` VALUES (1,1,'mamitha@gmail.com','638863','payment','2026-05-04 18:28:34',0,'2026-05-04 18:23:34'),(2,4,'vtu27179@veltech.edu.in','220628','payment','2026-05-04 18:30:04',0,'2026-05-04 18:25:04'),(3,4,'vtu27179@veltech.edu.in','698564','payment','2026-05-04 18:29:46',1,'2026-05-04 18:29:20');
/*!40000 ALTER TABLE `otp_verifications` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tags`
--

DROP TABLE IF EXISTS `tags`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tags` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `color` varchar(7) DEFAULT '#007bff',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tags`
--

LOCK TABLES `tags` WRITE;
/*!40000 ALTER TABLE `tags` DISABLE KEYS */;
INSERT INTO `tags` VALUES (1,'Webinar','#3498db','2026-05-04 18:16:55'),(2,'Workshop','#e74c3c','2026-05-04 18:16:55'),(3,'Seminar','#2ecc71','2026-05-04 18:16:55'),(4,'Conference','#f39c12','2026-05-04 18:16:55'),(5,'Networking','#9b59b6','2026-05-04 18:16:55'),(6,'Training','#1abc9c','2026-05-04 18:16:55');
/*!40000 ALTER TABLE `tags` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `email` varchar(150) NOT NULL,
  `password` varchar(255) NOT NULL,
  `role` enum('user','admin') NOT NULL DEFAULT 'user',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'mamitha','mamitha@gmail.com','$2a$10$AR8wiDBGFqxic6WWf62LgeCjvy6lCzOkCa/fzyiBPtAbFiiPDhgLC','user','2026-05-04 18:21:23'),(2,'Department Admin','admin@college.edu','$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy','admin','2026-05-04 18:22:20'),(3,'Aditi Sharma','aditi@college.edu','$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy','user','2026-05-04 18:22:20'),(4,'tejaswani','vtu27179@veltech.edu.in','$2a$10$vy3F8mRzAkSIXxoSGhRUGObCMPxteY7PcPVecjNGYLcv5j5A21ccS','user','2026-05-04 18:24:29');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping events for database 'event_booking_system'
--

--
-- Dumping routines for database 'event_booking_system'
--
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-05-05  0:07:55
