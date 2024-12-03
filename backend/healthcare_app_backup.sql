-- MySQL dump 10.13  Distrib 9.1.0, for macos14 (arm64)
--
-- Host: localhost    Database: healthcare_app
-- ------------------------------------------------------
-- Server version	9.1.0

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `equipment`
--

DROP TABLE IF EXISTS `equipment`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `equipment` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `status` varchar(50) DEFAULT 'Available',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `category_id` int DEFAULT NULL,
  `serial_number` varchar(100) DEFAULT NULL,
  `location` varchar(255) DEFAULT NULL,
  `purchase_date` date DEFAULT NULL,
  `last_maintenance` date DEFAULT NULL,
  `next_maintenance` date DEFAULT NULL,
  `notes` text,
  `maintenance_interval` int DEFAULT '90',
  PRIMARY KEY (`id`),
  KEY `category_id` (`category_id`),
  CONSTRAINT `equipment_ibfk_1` FOREIGN KEY (`category_id`) REFERENCES `equipment_categories` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `equipment`
--

LOCK TABLES `equipment` WRITE;
/*!40000 ALTER TABLE `equipment` DISABLE KEYS */;
INSERT INTO `equipment` VALUES (1,'Wheelchair #1','Available','2024-11-21 16:00:40','2024-11-25 14:40:05',7,'WC001','Floor 1 Storage','2024-01-15','2024-11-25','2025-02-23','Standard wheelchair, weight capacity 300lbs',90),(2,'Blood Pressure Monitor','Available','2024-11-21 16:00:40','2024-11-25 14:41:45',2,'BP101','Room 201','2023-12-01','2024-11-25','2025-02-23','Digital BP monitor with adult and pediatric cuffs',90),(3,'Defibrillator','Available','2024-11-21 16:00:40','2024-12-02 20:46:17',4,'DEF202','Emergency Room','2023-11-15','2024-12-02','2025-03-02','AED with adult and pediatric pads',90),(4,'Patient Bed #1','Available','2024-11-21 16:00:40','2024-11-25 14:41:01',7,'BED303','Room 105','2023-10-01','2024-11-25','2025-02-23','Electric adjustable bed',90),(5,'Ventilator','Available','2024-11-21 16:00:40','2024-11-22 01:54:28',2,'VEN404','ICU Room 3','2023-09-15','2024-11-21','2025-02-19','ICU grade ventilator',90),(6,'Surgical Light','Available','2024-11-21 16:00:40','2024-11-22 01:48:47',3,'SL505','OR 1','2023-08-01','2024-11-21','2025-02-19','LED surgical light system',90),(7,'X-Ray Machine','Available','2024-11-21 16:00:40','2024-11-25 14:40:57',5,'XR606','Radiology','2023-07-15','2024-11-25','2025-02-23','Digital X-ray system',90),(8,'Infusion Pump','Available','2024-11-21 16:00:40','2024-12-02 20:44:31',2,'IP707','Floor 2','2023-11-30','2024-12-02','2025-03-02','Smart infusion pump system',90),(9,'ECG Machine','Available','2024-11-21 16:00:40','2024-11-25 14:40:53',2,'ECG808','Cardiology','2023-12-15','2024-11-25','2025-02-23','12-lead ECG system',90),(10,'Ultrasound','Available','2024-11-21 16:00:40','2024-11-25 14:40:48',5,'US909','Room 302','2023-10-20','2024-11-25','2025-02-23','Portable ultrasound unit',90);
/*!40000 ALTER TABLE `equipment` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `equipment_categories`
--

DROP TABLE IF EXISTS `equipment_categories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `equipment_categories` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `description` text,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `equipment_categories`
--

LOCK TABLES `equipment_categories` WRITE;
/*!40000 ALTER TABLE `equipment_categories` DISABLE KEYS */;
INSERT INTO `equipment_categories` VALUES (1,'Medical Devices','Standard medical equipment and devices','2024-11-21 15:57:38'),(2,'Monitoring Equipment','Patient monitoring systems','2024-11-21 15:57:38'),(3,'Surgical Tools','Equipment used in surgical procedures','2024-11-21 15:57:38'),(4,'Emergency Equipment','Emergency and life-support equipment','2024-11-21 15:57:38'),(5,'Diagnostic Equipment','Equipment used for patient diagnosis','2024-11-21 15:57:38'),(6,'Therapy Equipment','Equipment used in therapeutic procedures','2024-11-21 15:57:38'),(7,'Patient Care','General patient care equipment','2024-11-21 15:57:38');
/*!40000 ALTER TABLE `equipment_categories` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `maintenance_history`
--

DROP TABLE IF EXISTS `maintenance_history`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `maintenance_history` (
  `id` int NOT NULL AUTO_INCREMENT,
  `equipment_id` int NOT NULL,
  `date` date NOT NULL,
  `type` varchar(50) DEFAULT NULL,
  `performed_by` varchar(100) DEFAULT NULL,
  `notes` text,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `equipment_id` (`equipment_id`),
  CONSTRAINT `maintenance_history_ibfk_1` FOREIGN KEY (`equipment_id`) REFERENCES `equipment` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=39 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `maintenance_history`
--

LOCK TABLES `maintenance_history` WRITE;
/*!40000 ALTER TABLE `maintenance_history` DISABLE KEYS */;
INSERT INTO `maintenance_history` VALUES (1,1,'2024-01-15','Scheduled','John Smith','Regular maintenance check - replaced filters','2024-11-21 19:08:11'),(2,1,'2023-10-15','Scheduled','Mike Johnson','Quarterly maintenance - all systems normal','2024-11-21 19:08:11'),(3,2,'2024-02-01','Emergency','Sarah Wilson','Fixed display malfunction','2024-11-21 19:08:11'),(4,2,'2023-11-15','Scheduled','John Smith','Regular calibration and testing','2024-11-21 19:08:11'),(5,3,'2024-01-20','Preventive','Mike Johnson','Updated software and performed safety checks','2024-11-21 19:08:11'),(6,4,'2024-02-10','Scheduled','Sarah Wilson','Quarterly maintenance - replaced worn parts','2024-11-21 19:08:11'),(7,5,'2024-01-05','Emergency','John Smith','Repaired power supply issue','2024-11-21 19:08:11'),(8,6,'2024-02-05','Scheduled','Mike Johnson','Regular maintenance and cleaning','2024-11-21 19:08:11'),(9,7,'2024-01-25','Preventive','Sarah Wilson','Calibration and safety inspection','2024-11-21 19:08:11'),(10,8,'2024-02-15','Scheduled','John Smith','Quarterly check - all systems functioning properly','2024-11-21 19:08:11'),(13,4,'2024-11-21','Regular Maintenance','Staff','Monthly inspection','2024-11-22 01:33:11'),(14,2,'2024-11-21','Regular Maintenance','Staff','Regular calibration','2024-11-22 01:36:39'),(15,1,'2024-11-21','Regular Maintenance','Staff','Quarterly maintenance check','2024-11-22 01:39:39'),(16,3,'2024-11-21','Regular Maintenance','Staff','Software update and testing','2024-11-22 01:45:25'),(17,6,'2024-11-21','Regular Maintenance','Staff','Regular maintenance completed','2024-11-22 01:48:47'),(18,5,'2024-11-21','Regular Maintenance','Staff','Quarterly maintenance','2024-11-22 01:54:28'),(19,1,'2024-11-25','Regular Maintenance','Staff','Scheduled maintenance','2024-11-25 14:40:05'),(21,10,'2024-11-25','Regular Maintenance','Staff','Scheduled maintenance','2024-11-25 14:40:48'),(22,9,'2024-11-25','Regular Maintenance','Staff','Scheduled maintenance','2024-11-25 14:40:53'),(23,8,'2024-11-25','Regular Maintenance','Staff','Scheduled maintenance','2024-11-25 14:40:55'),(24,7,'2024-11-25','Regular Maintenance','Staff','Scheduled maintenance','2024-11-25 14:40:57'),(25,4,'2024-11-25','Regular Maintenance','Staff','Scheduled maintenance','2024-11-25 14:41:01'),(26,2,'2024-11-25','Regular Maintenance','Staff','Scheduled maintenance','2024-11-25 14:41:45'),(31,8,'2024-12-02','Regular Maintenance','Staff','Scheduled maintenance','2024-12-02 20:34:59'),(36,8,'2024-12-02','Regular Maintenance','Staff','Scheduled maintenance','2024-12-02 20:44:31'),(38,3,'2024-12-02','Regular Maintenance','Staff','Scheduled maintenance','2024-12-02 20:46:17');
/*!40000 ALTER TABLE `maintenance_history` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `maintenance_schedule`
--

DROP TABLE IF EXISTS `maintenance_schedule`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `maintenance_schedule` (
  `id` int NOT NULL AUTO_INCREMENT,
  `equipment_id` int NOT NULL,
  `scheduled_date` date NOT NULL,
  `type` varchar(50) DEFAULT NULL,
  `notes` text,
  `status` varchar(50) DEFAULT 'Scheduled',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `completion_date` date DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_equipment_id` (`equipment_id`),
  KEY `idx_status` (`status`),
  CONSTRAINT `maintenance_schedule_ibfk_1` FOREIGN KEY (`equipment_id`) REFERENCES `equipment` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=40 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `maintenance_schedule`
--

LOCK TABLES `maintenance_schedule` WRITE;
/*!40000 ALTER TABLE `maintenance_schedule` DISABLE KEYS */;
INSERT INTO `maintenance_schedule` VALUES (1,1,'2024-11-26','Regular','Quarterly maintenance check','Completed','2024-11-21 19:08:12','2024-11-21'),(2,2,'2024-11-23','Calibration','Regular calibration','Completed','2024-11-21 19:08:12','2024-11-21'),(3,3,'2024-12-01','Preventive','Software update and testing','Completed','2024-11-21 19:08:12','2024-11-21'),(4,4,'2024-11-22','Regular','Monthly inspection','Completed','2024-11-21 19:08:12','2024-11-21'),(5,5,'2024-12-06','Regular','Quarterly maintenance','Completed','2024-11-21 19:08:12','2024-11-21'),(7,3,'2025-02-19','Regular Maintenance','Scheduled maintenance','Completed','2024-11-22 01:45:25','2024-12-02'),(8,6,'2025-02-22','Regular Maintenance','','Completed','2024-11-22 01:47:52','2024-11-21'),(9,6,'2025-02-19','Regular Maintenance','Scheduled maintenance','Scheduled','2024-11-22 01:48:47',NULL),(10,1,'2024-11-22','Regular Maintenance','Scheduled maintenance','Completed','2024-11-22 01:54:13','2024-11-25'),(11,2,'2024-11-22','Regular Maintenance','Scheduled maintenance','Completed','2024-11-22 01:54:13','2024-11-25'),(12,4,'2024-11-22','Regular Maintenance','Scheduled maintenance','Completed','2024-11-22 01:54:13','2024-11-25'),(13,7,'2024-11-22','Regular Maintenance','Scheduled maintenance','Completed','2024-11-22 01:54:13','2024-11-25'),(14,8,'2024-11-22','Regular Maintenance','Scheduled maintenance','Completed','2024-11-22 01:54:13','2024-11-25'),(15,9,'2024-11-22','Regular Maintenance','Scheduled maintenance','Completed','2024-11-22 01:54:13','2024-11-25'),(16,10,'2024-11-22','Regular Maintenance','Scheduled maintenance','Completed','2024-11-22 01:54:13','2024-11-25'),(18,5,'2025-02-19','Regular Maintenance','Scheduled maintenance','Scheduled','2024-11-22 01:54:28',NULL),(19,1,'2025-02-23','Regular Maintenance','Scheduled maintenance','Scheduled','2024-11-25 14:40:05',NULL),(21,10,'2025-02-23','Regular Maintenance','Scheduled maintenance','Scheduled','2024-11-25 14:40:48',NULL),(22,9,'2025-02-23','Regular Maintenance','Scheduled maintenance','Scheduled','2024-11-25 14:40:53',NULL),(23,8,'2025-02-23','Regular Maintenance','Scheduled maintenance','Completed','2024-11-25 14:40:55','2024-12-02'),(24,7,'2025-02-23','Regular Maintenance','Scheduled maintenance','Scheduled','2024-11-25 14:40:57',NULL),(25,4,'2025-02-23','Regular Maintenance','Scheduled maintenance','Scheduled','2024-11-25 14:41:01',NULL),(26,2,'2025-02-23','Regular Maintenance','Scheduled maintenance','Scheduled','2024-11-25 14:41:45',NULL),(32,8,'2025-03-02','Regular Maintenance','Scheduled maintenance','Completed','2024-12-02 20:34:59','2024-12-02'),(37,8,'2025-03-02','Regular Maintenance','Scheduled maintenance','Scheduled','2024-12-02 20:44:31',NULL),(39,3,'2025-03-02','Regular Maintenance','Scheduled maintenance','Scheduled','2024-12-02 20:46:17',NULL);
/*!40000 ALTER TABLE `maintenance_schedule` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2024-12-02 16:28:18
