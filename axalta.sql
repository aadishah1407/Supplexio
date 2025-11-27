-- MySQL dump 10.13  Distrib 8.0.43, for Win64 (x86_64)
--
-- Host: localhost    Database: axalta
-- ------------------------------------------------------
-- Server version	8.0.43

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `auction_deliveries`
--

DROP TABLE IF EXISTS `auction_deliveries`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `auction_deliveries` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `auction_id` bigint unsigned NOT NULL,
  `supplier_id` bigint unsigned NOT NULL,
  `winning_amount` double NOT NULL,
  `delivered_quantity` int DEFAULT '0',
  `status` enum('PENDING','DELIVERED','CANCELLED') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'PENDING',
  `delivery_date` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `auction_id` (`auction_id`),
  KEY `supplier_id` (`supplier_id`),
  CONSTRAINT `auction_deliveries_ibfk_1` FOREIGN KEY (`auction_id`) REFERENCES `reverse_auctions` (`id`),
  CONSTRAINT `auction_deliveries_ibfk_2` FOREIGN KEY (`supplier_id`) REFERENCES `suppliers` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=58 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `auction_deliveries`
--

LOCK TABLES `auction_deliveries` WRITE;
/*!40000 ALTER TABLE `auction_deliveries` DISABLE KEYS */;
INSERT INTO `auction_deliveries` VALUES (1,2,1,9000,90,'DELIVERED','2025-07-02 09:18:45','2025-06-30 09:24:20','2025-07-02 09:18:45'),(25,3,1,34570,30,'DELIVERED','2025-07-02 09:09:05','2025-06-30 13:47:35','2025-07-02 09:09:05'),(26,5,1,8000,1,'DELIVERED','2025-07-03 14:12:47','2025-07-02 09:49:30','2025-07-03 14:12:47'),(27,6,1,51780,1,'DELIVERED','2025-09-21 06:22:56','2025-07-03 14:15:20','2025-09-21 06:22:56'),(49,9,1,9000,1,'DELIVERED','2025-09-23 07:25:54','2025-09-22 03:11:27','2025-09-23 07:25:54'),(50,8,1,10000,38,'DELIVERED','2025-10-01 08:46:37','2025-09-22 10:31:42','2025-10-01 08:46:37'),(51,10,1,90000,38,'DELIVERED','2025-10-01 08:46:37','2025-09-23 07:26:03','2025-10-01 08:46:37'),(52,11,1,1111,70,'DELIVERED','2025-10-01 08:46:37','2025-09-23 09:07:46','2025-10-01 08:46:37'),(53,12,1,89000,70,'DELIVERED','2025-10-01 08:46:37','2025-09-23 09:44:12','2025-10-01 08:46:37'),(54,13,1,8900,11,'DELIVERED','2025-10-09 09:25:31','2025-10-09 08:35:58','2025-10-09 09:25:31'),(55,14,1,5600,8,'DELIVERED','2025-10-09 11:59:18','2025-10-09 10:18:18','2025-10-09 11:59:18'),(56,15,1,9800,0,'PENDING',NULL,'2025-10-09 12:00:18','2025-10-09 12:00:18'),(57,16,1,10000,0,'PENDING',NULL,'2025-10-09 12:12:01','2025-10-09 12:12:01');
/*!40000 ALTER TABLE `auction_deliveries` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `auction_inventory_sync`
--

DROP TABLE IF EXISTS `auction_inventory_sync`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `auction_inventory_sync` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `inventory_id` int NOT NULL,
  `product_id` bigint unsigned DEFAULT NULL,
  `auction_id` bigint unsigned DEFAULT NULL,
  `sync_status` enum('PENDING','AUCTION_CREATED','COMPLETED') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'PENDING',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `inventory_id` (`inventory_id`),
  KEY `product_id` (`product_id`),
  KEY `auction_id` (`auction_id`),
  CONSTRAINT `auction_inventory_sync_ibfk_1` FOREIGN KEY (`inventory_id`) REFERENCES `inventory` (`id`),
  CONSTRAINT `auction_inventory_sync_ibfk_2` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`),
  CONSTRAINT `auction_inventory_sync_ibfk_3` FOREIGN KEY (`auction_id`) REFERENCES `reverse_auctions` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `auction_inventory_sync`
--

LOCK TABLES `auction_inventory_sync` WRITE;
/*!40000 ALTER TABLE `auction_inventory_sync` DISABLE KEYS */;
/*!40000 ALTER TABLE `auction_inventory_sync` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `auction_invitations`
--

DROP TABLE IF EXISTS `auction_invitations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `auction_invitations` (
  `auction_id` bigint unsigned NOT NULL,
  `supplier_id` bigint unsigned NOT NULL,
  `status` enum('PENDING','ACCEPTED','DECLINED') DEFAULT 'PENDING',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`auction_id`,`supplier_id`),
  KEY `supplier_id` (`supplier_id`),
  CONSTRAINT `auction_invitations_ibfk_1` FOREIGN KEY (`auction_id`) REFERENCES `reverse_auctions` (`id`),
  CONSTRAINT `auction_invitations_ibfk_2` FOREIGN KEY (`supplier_id`) REFERENCES `suppliers` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `auction_invitations`
--

LOCK TABLES `auction_invitations` WRITE;
/*!40000 ALTER TABLE `auction_invitations` DISABLE KEYS */;
INSERT INTO `auction_invitations` VALUES (1,1,'PENDING','2025-06-27 17:04:49'),(2,1,'PENDING','2025-06-30 08:39:22'),(3,1,'PENDING','2025-06-30 10:38:13'),(4,1,'PENDING','2025-07-02 09:28:12'),(5,1,'PENDING','2025-07-02 09:48:51'),(6,1,'PENDING','2025-07-03 14:13:17'),(8,1,'PENDING','2025-09-21 05:15:03'),(9,1,'PENDING','2025-09-21 06:32:59'),(10,1,'PENDING','2025-09-23 07:24:47'),(11,1,'PENDING','2025-09-23 09:07:03'),(12,1,'PENDING','2025-09-23 09:43:34'),(13,1,'PENDING','2025-10-09 08:35:10'),(14,1,'PENDING','2025-10-09 09:26:11'),(15,1,'PENDING','2025-10-09 11:59:31'),(16,1,'PENDING','2025-10-09 12:11:26');
/*!40000 ALTER TABLE `auction_invitations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bid_chart_data`
--

DROP TABLE IF EXISTS `bid_chart_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bid_chart_data` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `auction_id` bigint unsigned NOT NULL,
  `supplier_id` bigint unsigned NOT NULL,
  `bid_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `amount` double NOT NULL,
  `supplier_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `bid_id` bigint unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `auction_id` (`auction_id`),
  KEY `supplier_id` (`supplier_id`),
  CONSTRAINT `bid_chart_data_ibfk_1` FOREIGN KEY (`auction_id`) REFERENCES `reverse_auctions` (`id`),
  CONSTRAINT `bid_chart_data_ibfk_2` FOREIGN KEY (`supplier_id`) REFERENCES `suppliers` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bid_chart_data`
--

LOCK TABLES `bid_chart_data` WRITE;
/*!40000 ALTER TABLE `bid_chart_data` DISABLE KEYS */;
INSERT INTO `bid_chart_data` VALUES (1,2,1,'2025-06-30 09:11:23',12000,'Vaibhav Suthar',32),(2,2,1,'2025-06-30 09:11:30',9000,'Vaibhav Suthar',33),(3,3,1,'2025-06-30 10:28:52',34570,'Vaibhav Suthar',34),(4,5,1,'2025-07-02 09:49:08',8000,'Vaibhav Suthar',35),(5,6,1,'2025-07-03 14:13:38',51780,'Vaibhav Suthar',36),(6,8,1,'2025-09-21 05:15:35',18000,'Vaibhav Suthar',37),(7,8,1,'2025-09-21 06:33:15',10000,'Vaibhav Suthar',38),(8,9,1,'2025-09-21 06:33:53',9000,'Vaibhav Suthar',39),(9,10,1,'2025-09-23 07:25:13',90000,'Vaibhav Suthar',40),(10,11,1,'2025-09-23 09:07:21',1111,'Vaibhav Suthar',41),(11,12,1,'2025-09-23 09:43:56',89000,'Vaibhav Suthar',42),(12,13,1,'2025-10-09 08:35:30',8900,'Vaibhav Suthar',43),(13,14,1,'2025-10-09 09:26:29',6000,'Vaibhav Suthar',44),(14,14,1,'2025-10-09 10:04:54',5600,'Vaibhav Suthar',45),(15,15,1,'2025-10-09 12:00:01',9800,'Vaibhav Suthar',46),(16,16,1,'2025-10-09 12:11:47',10000,'Vaibhav Suthar',47);
/*!40000 ALTER TABLE `bid_chart_data` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bids`
--

DROP TABLE IF EXISTS `bids`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bids` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `auction_id` bigint unsigned NOT NULL,
  `supplier_id` bigint unsigned DEFAULT NULL,
  `user_id` bigint unsigned DEFAULT NULL,
  `amount` decimal(10,2) DEFAULT '0.00',
  `bid_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `supplier_name` varchar(255) DEFAULT NULL,
  `bid_id` bigint unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `auction_id` (`auction_id`),
  KEY `supplier_id` (`supplier_id`),
  CONSTRAINT `bids_ibfk_1` FOREIGN KEY (`auction_id`) REFERENCES `reverse_auctions` (`id`),
  CONSTRAINT `bids_ibfk_2` FOREIGN KEY (`supplier_id`) REFERENCES `suppliers` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=48 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bids`
--

LOCK TABLES `bids` WRITE;
/*!40000 ALTER TABLE `bids` DISABLE KEYS */;
INSERT INTO `bids` VALUES (32,2,1,NULL,12000.00,'2025-06-30 09:11:23',NULL,NULL),(33,2,1,NULL,9000.00,'2025-06-30 09:11:30',NULL,NULL),(34,3,1,NULL,34570.00,'2025-06-30 10:28:52',NULL,NULL),(35,5,1,NULL,8000.00,'2025-07-02 09:49:08',NULL,NULL),(36,6,1,NULL,51780.00,'2025-07-03 14:13:38',NULL,NULL),(37,8,1,NULL,18000.00,'2025-09-21 05:15:35',NULL,NULL),(38,8,1,NULL,10000.00,'2025-09-21 06:33:15',NULL,NULL),(39,9,1,NULL,9000.00,'2025-09-21 06:33:53',NULL,NULL),(40,10,1,NULL,90000.00,'2025-09-23 07:25:13',NULL,NULL),(41,11,1,NULL,1111.00,'2025-09-23 09:07:21',NULL,NULL),(42,12,1,NULL,89000.00,'2025-09-23 09:43:56',NULL,NULL),(43,13,1,NULL,8900.00,'2025-10-09 08:35:30',NULL,NULL),(44,14,1,NULL,6000.00,'2025-10-09 09:26:29',NULL,NULL),(45,14,1,NULL,5600.00,'2025-10-09 10:04:54',NULL,NULL),(46,15,1,NULL,9800.00,'2025-10-09 12:00:01',NULL,NULL),(47,16,1,NULL,10000.00,'2025-10-09 12:11:47',NULL,NULL);
/*!40000 ALTER TABLE `bids` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `inventory`
--

DROP TABLE IF EXISTS `inventory`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `inventory` (
  `id` int NOT NULL AUTO_INCREMENT,
  `item_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `quantity` int NOT NULL,
  `min_threshold` int NOT NULL,
  `max_threshold` int NOT NULL,
  `kanban_status` enum('Low','Medium','High') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'Medium',
  `needs_auction` tinyint(1) DEFAULT '0',
  `auction_started` tinyint(1) DEFAULT '0',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `inventory`
--

LOCK TABLES `inventory` WRITE;
/*!40000 ALTER TABLE `inventory` DISABLE KEYS */;
INSERT INTO `inventory` VALUES (1,'Steel Rods',103,20,100,'High',0,0,'2025-06-23 14:24:56','2025-10-09 11:59:18'),(2,'Copper Sheets',71,10,80,'Medium',0,0,'2025-06-23 14:24:56','2025-10-09 09:25:31'),(3,'Aluminum Plates',158,40,120,'High',0,0,'2025-06-23 14:24:56','2025-11-08 11:12:01'),(4,'Plastic Granules',121,60,200,'Medium',0,0,'2025-06-23 14:24:56','2025-07-03 14:12:47'),(5,'Paint Buckets',155,25,100,'High',0,0,'2025-06-23 14:24:56','2025-10-09 06:53:18'),(6,'Portland Cement',200,50,250,'High',0,0,'2025-11-26 07:55:07','2025-11-26 07:55:07'),(7,'Red Clay Bricks',5000,2000,10000,'High',0,0,'2025-11-26 07:55:07','2025-11-26 07:55:07'),(8,'River Sand',50,20,100,'Medium',0,0,'2025-11-26 07:55:07','2025-11-26 07:55:07'),(9,'Gravel 20mm',40,15,80,'Medium',0,0,'2025-11-26 07:55:07','2025-11-26 07:55:07'),(10,'TMT Steel Bars 12mm',300,100,500,'High',0,0,'2025-11-26 07:55:07','2025-11-26 07:55:07'),(11,'Plywood Sheet 18mm',100,30,200,'High',0,0,'2025-11-26 07:55:07','2025-11-26 07:55:07'),(12,'Ceramic Floor Tiles',150,50,250,'High',0,0,'2025-11-26 07:55:07','2025-11-26 07:55:07'),(13,'Wall Putty',80,20,150,'High',0,0,'2025-11-26 07:55:07','2025-11-26 07:55:07'),(14,'Emulsion Paint (White)',40,10,100,'Medium',0,0,'2025-11-26 07:55:07','2025-11-26 07:55:07'),(15,'PVC Pipe 4 inch',120,40,200,'High',0,0,'2025-11-26 07:55:07','2025-11-26 07:55:07'),(16,'Galvanized Iron Sheet',60,20,120,'High',0,0,'2025-11-26 07:55:07','2025-11-26 07:55:07'),(17,'Electrical Wire 2.5mm',75,25,150,'High',0,0,'2025-11-26 07:55:07','2025-11-26 07:55:07'),(18,'Circuit Breaker 32A',200,100,400,'High',0,0,'2025-11-26 07:55:07','2025-11-26 07:55:07'),(19,'LED Bulb 9W',500,200,1000,'High',0,0,'2025-11-26 07:55:07','2025-11-26 07:55:07'),(20,'Teak Wood Log',10,5,20,'Medium',0,0,'2025-11-26 07:55:07','2025-11-26 07:55:07'),(21,'Safety Helmet',150,50,300,'High',0,0,'2025-11-26 07:55:07','2025-11-26 07:55:07'),(22,'Safety Gloves',300,100,600,'High',0,0,'2025-11-26 07:55:07','2025-11-26 07:55:07'),(23,'Measuring Tape 5m',100,30,200,'High',0,0,'2025-11-26 07:55:07','2025-11-26 07:55:07'),(24,'Claw Hammer',50,20,100,'Medium',0,0,'2025-11-26 07:55:07','2025-11-26 07:55:07'),(25,'Angle Grinder',25,10,50,'Medium',0,0,'2025-11-26 07:55:07','2025-11-26 07:55:07'),(26,'Drill Machine',30,15,60,'Medium',0,0,'2025-11-26 07:55:07','2025-11-26 07:55:07'),(27,'Screwdriver Set',80,25,150,'High',0,0,'2025-11-26 07:55:07','2025-11-26 07:55:07'),(28,'Welding Rods',60,20,120,'High',0,0,'2025-11-26 07:55:07','2025-11-26 07:55:07'),(29,'Cutting Disc 4 inch',500,200,1000,'High',0,0,'2025-11-26 07:55:07','2025-11-26 07:55:07'),(30,'Hex Bolt M10',1000,300,2000,'High',0,0,'2025-11-26 07:55:07','2025-11-26 07:55:07'),(31,'Drywall Screw',200,50,400,'High',0,0,'2025-11-26 07:55:07','2025-11-26 07:55:07'),(32,'Silicon Sealant',120,30,250,'High',0,0,'2025-11-26 07:55:07','2025-11-26 07:55:07'),(33,'Wood Glue 500g',90,25,180,'High',0,0,'2025-11-26 07:55:07','2025-11-26 07:55:07'),(34,'Masking Tape',150,50,300,'High',0,0,'2025-11-26 07:55:07','2025-11-26 07:55:07'),(35,'Paint Roller',70,20,150,'High',0,0,'2025-11-26 07:55:07','2025-11-26 07:55:07'),(36,'Thinner',45,15,100,'Medium',0,0,'2025-11-26 07:55:07','2025-11-26 07:55:07'),(37,'Glass Wool',30,10,60,'High',0,0,'2025-11-26 07:55:07','2025-11-26 07:55:07'),(38,'Bitumen Primer',40,15,80,'Medium',0,0,'2025-11-26 07:55:07','2025-11-26 07:55:07'),(39,'Scaffolding Pipe',100,30,200,'High',0,0,'2025-11-26 07:55:07','2025-11-26 07:55:07'),(40,'Swivel Coupler',400,100,800,'High',0,0,'2025-11-26 07:55:07','2025-11-26 07:55:07'),(41,'Concrete Nail 2 inch',150,50,300,'High',0,0,'2025-11-26 07:55:07','2025-11-26 07:55:07'),(42,'Granite Slab',200,50,400,'High',0,0,'2025-11-26 07:55:07','2025-11-26 07:55:07'),(43,'Marble Chips',100,30,200,'High',0,0,'2025-11-26 07:55:07','2025-11-26 07:55:07'),(44,'UPVC Window Frame',25,10,50,'Medium',0,0,'2025-11-26 07:55:07','2025-11-26 07:55:07'),(45,'Wooden Door Frame',40,15,80,'Medium',0,0,'2025-11-26 07:55:07','2025-11-26 07:55:07'),(46,'Flush Door',60,20,120,'High',0,0,'2025-11-26 07:55:07','2025-11-26 07:55:07'),(47,'Brass Door Handle',80,25,160,'High',0,0,'2025-11-26 07:55:07','2025-11-26 07:55:07'),(48,'Padlock 50mm',120,40,240,'High',0,0,'2025-11-26 07:55:07','2025-11-26 07:55:07'),(49,'Door Hinge',300,100,600,'High',0,0,'2025-11-26 07:55:07','2025-11-26 07:55:07'),(50,'Tower Bolt',250,80,500,'High',0,0,'2025-11-26 07:55:07','2025-11-26 07:55:07'),(51,'Gate Valve 1 inch',60,20,120,'High',0,0,'2025-11-26 07:55:07','2025-11-26 07:55:07'),(52,'CPVC Elbow',500,150,1000,'High',0,0,'2025-11-26 07:55:07','2025-11-26 07:55:07'),(53,'Water Tank 500L',20,5,40,'Medium',0,0,'2025-11-26 07:55:07','2025-11-26 07:55:07'),(54,'Kitchen Sink',35,10,70,'High',0,0,'2025-11-26 07:55:07','2025-11-26 07:55:07'),(55,'Wash Basin',40,15,80,'Medium',0,0,'2025-11-26 07:55:07','2025-11-26 07:55:07'),(56,'Angle Valve',100,30,200,'High',0,0,'2025-11-26 07:55:07','2025-11-26 07:55:07'),(57,'Shower Head',50,15,100,'High',0,0,'2025-11-26 07:55:07','2025-11-26 07:55:07'),(58,'Extension Cord',60,20,120,'High',0,0,'2025-11-26 07:55:07','2025-11-26 07:55:07'),(59,'Ceiling Fan',80,25,160,'High',0,0,'2025-11-26 07:55:07','2025-11-26 07:55:07'),(60,'Exhaust Fan',45,15,90,'Medium',0,0,'2025-11-26 07:55:07','2025-11-26 07:55:07'),(61,'Switch Socket',200,50,400,'High',0,0,'2025-11-26 07:55:07','2025-11-26 07:55:07'),(62,'Distribution Board',30,10,60,'High',0,0,'2025-11-26 07:55:07','2025-11-26 07:55:07'),(63,'Cable Tie',150,50,300,'High',0,0,'2025-11-26 07:55:07','2025-11-26 07:55:07'),(64,'Insulation Tape',300,100,600,'High',0,0,'2025-11-26 07:55:07','2025-11-26 07:55:07'),(65,'Solar Panel 200W',15,5,30,'High',0,0,'2025-11-26 07:55:07','2025-11-26 07:55:07'),(66,'Inverter Battery',20,5,40,'Medium',0,0,'2025-11-26 07:55:07','2025-11-26 07:55:07'),(67,'Generator 5kVA',5,2,10,'Medium',0,0,'2025-11-26 07:55:07','2025-11-26 07:55:07'),(68,'Concrete Mixer',8,3,15,'Medium',0,0,'2025-11-26 07:55:07','2025-11-26 07:55:07'),(69,'Vibrator Needle',12,5,20,'Medium',0,0,'2025-11-26 07:55:07','2025-11-26 07:55:07'),(70,'Chain Block 1 Ton',15,5,30,'High',0,0,'2025-11-26 07:55:07','2025-11-26 07:55:07'),(71,'Hydraulic Jack',25,10,50,'Medium',0,0,'2025-11-26 07:55:07','2025-11-26 07:55:07'),(72,'Wheelbarrow',30,10,60,'High',0,0,'2025-11-26 07:55:07','2025-11-26 07:55:07'),(73,'Shovel',80,25,160,'High',0,0,'2025-11-26 07:55:07','2025-11-26 07:55:07'),(74,'Pickaxe',60,20,120,'High',0,0,'2025-11-26 07:55:07','2025-11-26 07:55:07'),(75,'Hoe',50,15,100,'High',0,0,'2025-11-26 07:55:07','2025-11-26 07:55:07'),(76,'Rake',40,10,80,'High',0,0,'2025-11-26 07:55:07','2025-11-26 07:55:07'),(77,'Water Hose',35,10,70,'High',0,0,'2025-11-26 07:55:07','2025-11-26 07:55:07'),(78,'Sprinkler',80,25,160,'High',0,0,'2025-11-26 07:55:07','2025-11-26 07:55:07'),(79,'Grass Trimmer',20,5,40,'Medium',0,0,'2025-11-26 07:55:07','2025-11-26 07:55:07'),(80,'Pesticide Sprayer',30,10,60,'High',0,0,'2025-11-26 07:55:07','2025-11-26 07:55:07'),(81,'Barbed Wire',50,15,100,'High',0,0,'2025-11-26 07:55:07','2025-11-26 07:55:07'),(82,'Chain Link Mesh',25,8,50,'High',0,0,'2025-11-26 07:55:07','2025-11-26 07:55:07'),(83,'Steel Pipe 2 inch',100,30,200,'High',0,0,'2025-11-26 07:55:07','2025-11-26 07:55:07'),(84,'Square Tube',120,40,240,'High',0,0,'2025-11-26 07:55:07','2025-11-26 07:55:07'),(85,'Flat Bar',150,50,300,'High',0,0,'2025-11-26 07:55:07','2025-11-26 07:55:07'),(86,'Aluminum Section',80,25,160,'High',0,0,'2025-11-26 07:55:07','2025-11-26 07:55:07'),(87,'Glass Sheet 5mm',60,20,120,'High',0,0,'2025-11-26 07:55:07','2025-11-26 07:55:07'),(88,'Acrylic Sheet',40,10,80,'Medium',0,0,'2025-11-26 07:55:07','2025-11-26 07:55:07'),(89,'Rubber Sheet',50,15,100,'High',0,0,'2025-11-26 07:55:07','2025-11-26 07:55:07'),(90,'Tarpaulin',70,20,140,'High',0,0,'2025-11-26 07:55:07','2025-11-26 07:55:07'),(91,'Rope 10mm',100,30,200,'High',0,0,'2025-11-26 07:55:07','2025-11-26 07:55:07'),(92,'Packing Tape',500,150,1000,'High',0,0,'2025-11-26 07:55:07','2025-11-26 07:55:07'),(93,'Stretch Film',120,40,240,'High',0,0,'2025-11-26 07:55:07','2025-11-26 07:55:07'),(94,'Corrugated Box',1000,300,2000,'High',0,0,'2025-11-26 07:55:07','2025-11-26 07:55:07'),(95,'Bubble Wrap',60,20,120,'High',0,0,'2025-11-26 07:55:07','2025-11-26 07:55:07'),(96,'Fire Extinguisher',40,15,80,'Medium',0,0,'2025-11-26 07:55:07','2025-11-26 07:55:07'),(97,'First Aid Kit',30,10,60,'High',0,0,'2025-11-26 07:55:07','2025-11-26 07:55:07'),(98,'Safety Shoes',60,20,120,'High',0,0,'2025-11-26 07:55:07','2025-11-26 07:55:07'),(99,'Reflective Vest',200,50,400,'High',0,0,'2025-11-26 07:55:07','2025-11-26 07:55:07'),(100,'Traffic Cone',50,15,100,'High',0,0,'2025-11-26 07:55:07','2025-11-26 07:55:07');
/*!40000 ALTER TABLE `inventory` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `payments`
--

DROP TABLE IF EXISTS `payments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `payments` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `po_id` bigint unsigned NOT NULL,
  `amount` double NOT NULL,
  `status` varchar(20) NOT NULL DEFAULT 'PENDING',
  `payment_method` varchar(20) DEFAULT NULL,
  `transaction_id` varchar(100) DEFAULT NULL,
  `payment_date` timestamp NULL DEFAULT NULL,
  `activated_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `remarks` text,
  PRIMARY KEY (`id`),
  KEY `po_id` (`po_id`),
  CONSTRAINT `payments_ibfk_1` FOREIGN KEY (`po_id`) REFERENCES `purchase_orders` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `payments`
--

LOCK TABLES `payments` WRITE;
/*!40000 ALTER TABLE `payments` DISABLE KEYS */;
INSERT INTO `payments` VALUES (1,7,9000,'PENDING','NOT_SELECTED',NULL,NULL,NULL,'2025-09-23 09:40:36',NULL),(2,1,34570,'PENDING','NOT_SELECTED',NULL,NULL,NULL,'2025-09-23 09:40:36',NULL),(3,2,8000,'PENDING','NOT_SELECTED',NULL,NULL,NULL,'2025-09-23 09:40:36',NULL),(4,3,51780,'PENDING','NOT_SELECTED',NULL,NULL,NULL,'2025-09-23 09:40:36',NULL),(5,5,10000,'PENDING','NOT_SELECTED',NULL,NULL,NULL,'2025-09-23 09:40:36',NULL),(6,4,9000,'PENDING','NOT_SELECTED',NULL,NULL,NULL,'2025-09-23 09:40:36',NULL),(7,6,90000,'PENDING','NOT_SELECTED',NULL,NULL,NULL,'2025-09-23 09:40:36',NULL),(8,8,1111,'PENDING','NOT_SELECTED',NULL,NULL,NULL,'2025-09-23 09:40:36',NULL),(16,9,89000,'PENDING','NOT_SELECTED',NULL,NULL,NULL,'2025-09-23 09:44:39',NULL),(17,10,8900,'PENDING','NOT_SELECTED',NULL,NULL,NULL,'2025-10-09 08:36:22',NULL),(18,11,5600,'PENDING','NOT_SELECTED',NULL,NULL,NULL,'2025-10-09 10:19:00',NULL),(19,12,9800,'PENDING','NOT_SELECTED',NULL,NULL,NULL,'2025-10-09 12:01:12',NULL),(20,13,10000,'PENDING','NOT_SELECTED',NULL,NULL,NULL,'2025-10-09 12:12:06',NULL);
/*!40000 ALTER TABLE `payments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `products`
--

DROP TABLE IF EXISTS `products`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `products` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `description` text,
  `category` varchar(100) DEFAULT 'General',
  `base_price` decimal(10,2) DEFAULT '0.00',
  `unit` varchar(50) DEFAULT 'pcs',
  `stock_quantity` int DEFAULT '0',
  `inventory_id` bigint DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=101 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `products`
--

LOCK TABLES `products` WRITE;
/*!40000 ALTER TABLE `products` DISABLE KEYS */;
INSERT INTO `products` VALUES (1,'Steel Rods','Auto-generated product for inventory item: Steel Rods','General',0.00,'pcs',103,1,'2025-06-27 16:53:53'),(2,'Copper Sheets','Auto-generated product for inventory item: Copper Sheets','General',0.00,'pcs',71,2,'2025-06-27 16:53:53'),(3,'Aluminum Plates','Auto-generated product for inventory item: Aluminum Plates','General',0.00,'pcs',158,3,'2025-06-27 16:53:53'),(4,'Plastic Granules','Auto-generated product for inventory item: Plastic Granules','General',0.00,'pcs',121,4,'2025-06-27 16:53:53'),(5,'Paint Buckets','Auto-generated product for inventory item: Paint Buckets','General',0.00,'pcs',155,5,'2025-06-27 16:53:53'),(6,'Portland Cement','High-grade 50kg bag of cement for general construction','Construction',8.50,'bags',200,6,'2025-11-26 07:55:07'),(7,'Red Clay Bricks','Standard fired clay bricks for masonry work','Construction',0.45,'pcs',5000,7,'2025-11-26 07:55:07'),(8,'River Sand','Fine river sand for concrete mixing and plastering','Construction',45.00,'ton',50,8,'2025-11-26 07:55:07'),(9,'Gravel 20mm','Crushed stone aggregate for concrete foundations','Construction',55.00,'ton',40,9,'2025-11-26 07:55:07'),(10,'TMT Steel Bars 12mm','High-strength reinforcement bars for structural support','Steel',12.00,'pcs',300,10,'2025-11-26 07:55:07'),(11,'Plywood Sheet 18mm','Marine grade waterproof plywood 8x4 feet','Wood',45.00,'pcs',100,11,'2025-11-26 07:55:07'),(12,'Ceramic Floor Tiles','60x60cm vitrified floor tiles, white marble finish','Flooring',15.00,'box',150,12,'2025-11-26 07:55:07'),(13,'Wall Putty','White cement-based putty for wall smoothening','Finishing',12.50,'bags',80,13,'2025-11-26 07:55:07'),(14,'Emulsion Paint (White)','Interior acrylic emulsion paint, 20L bucket','Paint',85.00,'pcs',40,14,'2025-11-26 07:55:07'),(15,'PVC Pipe 4 inch','Rigid PVC pipe for drainage and sewage systems','Plumbing',18.00,'pcs',120,15,'2025-11-26 07:55:07'),(16,'Galvanized Iron Sheet','Corrugated GI sheet for roofing, 10ft length','Roofing',22.50,'pcs',60,16,'2025-11-26 07:55:07'),(17,'Electrical Wire 2.5mm','Copper insulated wire coil, Red, 90m length','Electrical',35.00,'roll',75,17,'2025-11-26 07:55:07'),(18,'Circuit Breaker 32A','Double pole MCB for residential distribution boards','Electrical',8.50,'pcs',200,18,'2025-11-26 07:55:07'),(19,'LED Bulb 9W','Cool daylight LED bulb, energy efficient','Electrical',1.50,'pcs',500,19,'2025-11-26 07:55:07'),(20,'Teak Wood Log','Raw teak wood log for furniture manufacturing','Wood',1200.00,'cft',10,20,'2025-11-26 07:55:07'),(21,'Safety Helmet','Industrial safety helmet, yellow, hard plastic','Safety',4.50,'pcs',150,21,'2025-11-26 07:55:07'),(22,'Safety Gloves','Cotton knitted gloves with rubber grip','Safety',1.20,'pair',300,22,'2025-11-26 07:55:07'),(23,'Measuring Tape 5m','Retractable steel measuring tape with rubber casing','Tools',3.50,'pcs',100,23,'2025-11-26 07:55:07'),(24,'Claw Hammer','16oz steel claw hammer with fiberglass handle','Tools',8.00,'pcs',50,24,'2025-11-26 07:55:07'),(25,'Angle Grinder','800W electric angle grinder for cutting and grinding','Tools',45.00,'pcs',25,25,'2025-11-26 07:55:07'),(26,'Drill Machine','Impact drill 650W with variable speed control','Tools',55.00,'pcs',30,26,'2025-11-26 07:55:07'),(27,'Screwdriver Set','6-piece magnetic tip screwdriver set','Tools',12.00,'set',80,27,'2025-11-26 07:55:07'),(28,'Welding Rods','Mild steel welding electrodes, 3.15mm','Welding',15.00,'box',60,28,'2025-11-26 07:55:07'),(29,'Cutting Disc 4 inch','Abrasive cutting wheel for metal','Consumables',0.80,'pcs',500,29,'2025-11-26 07:55:07'),(30,'Hex Bolt M10','High-tensile steel hex bolt with nut','Fasteners',0.25,'pcs',1000,30,'2025-11-26 07:55:07'),(31,'Drywall Screw','Black phosphate drywall screws, 25mm','Fasteners',5.00,'box',200,31,'2025-11-26 07:55:07'),(32,'Silicon Sealant','Clear silicone sealant for glass and aluminium','Adhesives',4.50,'pcs',120,32,'2025-11-26 07:55:07'),(33,'Wood Glue 500g','Synthetic resin adhesive for wood bonding','Adhesives',3.00,'pcs',90,33,'2025-11-26 07:55:07'),(34,'Masking Tape','2-inch painter masking tape','Consumables',1.50,'roll',150,34,'2025-11-26 07:55:07'),(35,'Paint Roller','9-inch paint roller with tray','Paint',6.00,'set',70,35,'2025-11-26 07:55:07'),(36,'Thinner','General purpose paint thinner, 5L can','Paint',18.00,'pcs',45,36,'2025-11-26 07:55:07'),(37,'Glass Wool','Thermal insulation roll for roofing','Insulation',35.00,'roll',30,37,'2025-11-26 07:55:07'),(38,'Bitumen Primer','Waterproofing bitumen primer for roofs','Waterproofing',25.00,'bucket',40,38,'2025-11-26 07:55:07'),(39,'Scaffolding Pipe','Galvanized steel pipe for scaffolding, 6m','Construction',28.00,'pcs',100,39,'2025-11-26 07:55:07'),(40,'Swivel Coupler','Forged steel swivel coupler for scaffolding','Construction',3.50,'pcs',400,40,'2025-11-26 07:55:07'),(41,'Concrete Nail 2 inch','Hardened steel nails for concrete walls','Fasteners',2.00,'box',150,41,'2025-11-26 07:55:07'),(42,'Granite Slab','Polished black galaxy granite slab','Flooring',65.00,'sqft',200,42,'2025-11-26 07:55:07'),(43,'Marble Chips','White marble chips for terrazzo flooring','Flooring',8.00,'bag',100,43,'2025-11-26 07:55:07'),(44,'UPVC Window Frame','Standard sliding UPVC window frame 4x4','Fixtures',120.00,'pcs',25,44,'2025-11-26 07:55:07'),(45,'Wooden Door Frame','Solid sal wood door frame 7x3 feet','Fixtures',55.00,'pcs',40,45,'2025-11-26 07:55:07'),(46,'Flush Door','Waterproof flush door shutter 30mm','Fixtures',45.00,'pcs',60,46,'2025-11-26 07:55:07'),(47,'Brass Door Handle','Antique finish brass door handle set','Hardware',15.00,'set',80,47,'2025-11-26 07:55:07'),(48,'Padlock 50mm','Heavy duty brass padlock with 3 keys','Hardware',8.50,'pcs',120,48,'2025-11-26 07:55:07'),(49,'Door Hinge','Stainless steel 4 inch door hinge','Hardware',1.50,'pair',300,49,'2025-11-26 07:55:07'),(50,'Tower Bolt','Aluminum tower bolt 6 inch','Hardware',2.00,'pcs',250,50,'2025-11-26 07:55:07'),(51,'Gate Valve 1 inch','Brass gate valve for water control','Plumbing',12.00,'pcs',60,51,'2025-11-26 07:55:07'),(52,'CPVC Elbow','90 degree elbow for CPVC pipes','Plumbing',0.50,'pcs',500,52,'2025-11-26 07:55:07'),(53,'Water Tank 500L','Triple layer plastic water storage tank','Plumbing',75.00,'pcs',20,53,'2025-11-26 07:55:07'),(54,'Kitchen Sink','Stainless steel single bowl sink','Plumbing',45.00,'pcs',35,54,'2025-11-26 07:55:07'),(55,'Wash Basin','Ceramic wall hung wash basin, white','Plumbing',30.00,'pcs',40,55,'2025-11-26 07:55:07'),(56,'Angle Valve','Chrome plated brass angle valve','Plumbing',5.50,'pcs',100,56,'2025-11-26 07:55:07'),(57,'Shower Head','Overhead rain shower, chrome finish','Plumbing',18.00,'pcs',50,57,'2025-11-26 07:55:07'),(58,'Extension Cord','4-way extension board with 5m wire','Electrical',12.00,'pcs',60,58,'2025-11-26 07:55:07'),(59,'Ceiling Fan','1200mm high speed ceiling fan, white','Electrical',35.00,'pcs',80,59,'2025-11-26 07:55:07'),(60,'Exhaust Fan','10 inch ventilation exhaust fan','Electrical',22.00,'pcs',45,60,'2025-11-26 07:55:07'),(61,'Switch Socket','Modular 6A switch and socket combined','Electrical',3.50,'pcs',200,61,'2025-11-26 07:55:07'),(62,'Distribution Board','8-way metal distribution board enclosure','Electrical',15.00,'pcs',30,62,'2025-11-26 07:55:07'),(63,'Cable Tie','100mm nylon cable ties, pack of 100','Electrical',1.00,'pack',150,63,'2025-11-26 07:55:07'),(64,'Insulation Tape','PVC electrical insulation tape, black','Electrical',0.50,'roll',300,64,'2025-11-26 07:55:07'),(65,'Solar Panel 200W','Monocrystalline solar panel','Electrical',150.00,'pcs',15,65,'2025-11-26 07:55:07'),(66,'Inverter Battery','150Ah tubular battery for home UPS','Electrical',180.00,'pcs',20,66,'2025-11-26 07:55:07'),(67,'Generator 5kVA','Diesel generator set for backup power','Machinery',1200.00,'pcs',5,67,'2025-11-26 07:55:07'),(68,'Concrete Mixer','Portable concrete mixer machine with motor','Machinery',850.00,'pcs',8,68,'2025-11-26 07:55:07'),(69,'Vibrator Needle','Concrete vibrator needle with nozzle','Machinery',120.00,'pcs',12,69,'2025-11-26 07:55:07'),(70,'Chain Block 1 Ton','Manual chain pulley block for lifting','Machinery',65.00,'pcs',15,70,'2025-11-26 07:55:07'),(71,'Hydraulic Jack','10 ton hydraulic bottle jack','Tools',35.00,'pcs',25,71,'2025-11-26 07:55:07'),(72,'Wheelbarrow','Heavy duty steel wheelbarrow','Tools',45.00,'pcs',30,72,'2025-11-26 07:55:07'),(73,'Shovel','Square point steel shovel with wooden handle','Tools',10.00,'pcs',80,73,'2025-11-26 07:55:07'),(74,'Pickaxe','Steel pickaxe head with wooden handle','Tools',12.50,'pcs',60,74,'2025-11-26 07:55:07'),(75,'Hoe','Garden hoe for leveling soil','Tools',8.00,'pcs',50,75,'2025-11-26 07:55:07'),(76,'Rake','Steel garden rake','Tools',7.50,'pcs',40,76,'2025-11-26 07:55:07'),(77,'Water Hose','1 inch flexible garden hose, 30m','Gardening',25.00,'roll',35,77,'2025-11-26 07:55:07'),(78,'Sprinkler','Rotating brass impact sprinkler','Gardening',6.00,'pcs',80,78,'2025-11-26 07:55:07'),(79,'Grass Trimmer','Electric grass trimmer and edger','Gardening',55.00,'pcs',20,79,'2025-11-26 07:55:07'),(80,'Pesticide Sprayer','16L knapsack manual sprayer','Gardening',22.00,'pcs',30,80,'2025-11-26 07:55:07'),(81,'Barbed Wire','Galvanized barbed wire for fencing, 10kg','Fencing',18.00,'roll',50,81,'2025-11-26 07:55:07'),(82,'Chain Link Mesh','GI chain link fencing mesh roll','Fencing',45.00,'roll',25,82,'2025-11-26 07:55:07'),(83,'Steel Pipe 2 inch','Mild steel hollow round pipe, 6m','Steel',20.00,'pcs',100,83,'2025-11-26 07:55:07'),(84,'Square Tube','MS square tube 40x40mm, 6m','Steel',18.00,'pcs',120,84,'2025-11-26 07:55:07'),(85,'Flat Bar','MS flat bar 50x6mm','Steel',12.00,'pcs',150,85,'2025-11-26 07:55:07'),(86,'Aluminum Section','Aluminum extrusion for partitions','Aluminum',28.00,'kg',80,86,'2025-11-26 07:55:07'),(87,'Glass Sheet 5mm','Clear float glass sheet','Glass',22.00,'sqm',60,87,'2025-11-26 07:55:07'),(88,'Acrylic Sheet','Clear acrylic sheet 3mm','Plastics',45.00,'sheet',40,88,'2025-11-26 07:55:07'),(89,'Rubber Sheet','Industrial rubber sheet 2mm','Rubber',15.00,'meter',50,89,'2025-11-26 07:55:07'),(90,'Tarpaulin','Heavy duty blue waterproof tarpaulin','General',25.00,'pcs',70,90,'2025-11-26 07:55:07'),(91,'Rope 10mm','Nylon rope coil','General',12.00,'roll',100,91,'2025-11-26 07:55:07'),(92,'Packing Tape','Brown packing tape 3 inch','Packaging',1.00,'roll',500,92,'2025-11-26 07:55:07'),(93,'Stretch Film','Pallet wrap stretch film roll','Packaging',8.00,'roll',120,93,'2025-11-26 07:55:07'),(94,'Corrugated Box','Cardboard carton box large','Packaging',1.50,'pcs',1000,94,'2025-11-26 07:55:07'),(95,'Bubble Wrap','Protective bubble wrap roll','Packaging',15.00,'roll',60,95,'2025-11-26 07:55:07'),(96,'Fire Extinguisher','ABC powder fire extinguisher 4kg','Safety',35.00,'pcs',40,96,'2025-11-26 07:55:07'),(97,'First Aid Kit','Industrial wall mount first aid box','Safety',25.00,'pcs',30,97,'2025-11-26 07:55:07'),(98,'Safety Shoes','Steel toe safety shoes, black','Safety',28.00,'pair',60,98,'2025-11-26 07:55:07'),(99,'Reflective Vest','High visibility safety vest, orange','Safety',3.00,'pcs',200,99,'2025-11-26 07:55:07'),(100,'Traffic Cone','750mm PVC traffic cone with reflective strip','Safety',12.00,'pcs',50,100,'2025-11-26 07:55:07');
/*!40000 ALTER TABLE `products` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `purchase_orders`
--

DROP TABLE IF EXISTS `purchase_orders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `purchase_orders` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `auction_id` bigint unsigned NOT NULL,
  `supplier_id` bigint unsigned NOT NULL,
  `product_id` bigint unsigned NOT NULL,
  `po_number` varchar(50) NOT NULL,
  `supplier_name` varchar(255) NOT NULL,
  `supplier_email` varchar(255) NOT NULL,
  `supplier_address` varchar(255) DEFAULT NULL,
  `supplier_phone` varchar(50) DEFAULT NULL,
  `product_name` varchar(255) NOT NULL,
  `product_description` text,
  `quantity` int NOT NULL,
  `unit` varchar(20) DEFAULT NULL,
  `unit_price` double NOT NULL,
  `total_amount` double NOT NULL,
  `tax_amount` double NOT NULL,
  `grand_total` double NOT NULL,
  `status` varchar(20) NOT NULL DEFAULT 'DRAFT',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `sent_at` timestamp NULL DEFAULT NULL,
  `delivery_date` date DEFAULT NULL,
  `delivery_address` varchar(255) DEFAULT NULL,
  `incoterm` varchar(255) DEFAULT NULL,
  `notes` text,
  `company_name` varchar(255) DEFAULT NULL,
  `material` varchar(255) DEFAULT NULL,
  `amount` double NOT NULL DEFAULT '0',
  `incoterm_location` varchar(255) DEFAULT NULL,
  `terms` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `auction_id` (`auction_id`),
  KEY `supplier_id` (`supplier_id`),
  KEY `product_id` (`product_id`),
  CONSTRAINT `purchase_orders_ibfk_1` FOREIGN KEY (`auction_id`) REFERENCES `reverse_auctions` (`id`),
  CONSTRAINT `purchase_orders_ibfk_2` FOREIGN KEY (`supplier_id`) REFERENCES `suppliers` (`id`),
  CONSTRAINT `purchase_orders_ibfk_3` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `purchase_orders`
--

LOCK TABLES `purchase_orders` WRITE;
/*!40000 ALTER TABLE `purchase_orders` DISABLE KEYS */;
INSERT INTO `purchase_orders` VALUES (1,3,1,2,'1','Unknown Supplier','vaibhavsuthar2711@gmail.com',NULL,NULL,'Copper Sheets',NULL,0,NULL,0,34570,0,34570,'SENT','2025-06-30 13:47:35',NULL,NULL,NULL,NULL,NULL,'Unknown Supplier','Copper Sheets',34570,NULL,NULL),(2,5,1,4,'2','Unknown Supplier','vaibhavsuthar2711@gmail.com',NULL,NULL,'Plastic Granules',NULL,20,NULL,400,8000,0,8000,'SENT','2025-07-02 09:49:30',NULL,NULL,NULL,NULL,NULL,'Unknown Supplier','Plastic Granules',8000,NULL,NULL),(3,6,1,3,'3','Unknown Supplier','vaibhavsuthar2711@gmail.com',NULL,NULL,'Aluminum Plates',NULL,90,NULL,575.3333333333334,51780,0,51780,'SENT','2025-07-03 14:15:20',NULL,NULL,NULL,NULL,NULL,'Unknown Supplier','Aluminum Plates',51780,NULL,NULL),(4,9,1,3,'4','Unknown Supplier','vaibhavsuthar2711@gmail.com',NULL,NULL,'Aluminum Plates',NULL,12,NULL,750,9000,0,9000,'SENT','2025-09-22 03:11:27',NULL,NULL,NULL,NULL,NULL,'Unknown Supplier','Aluminum Plates',9000,NULL,NULL),(5,8,1,3,'5','Vaibhav Suthar','vaibhavsuthar2711@gmail.com',NULL,NULL,'Aluminum Plates','Special grade product',20,'meters',500,10000,750,10750,'PENDING','2025-09-22 10:31:43',NULL,'2025-10-02','290 Example St, CityI, Country','FOB','Bulk commodity order','Vaibhav Suthar','Aluminum Plates',10000,'Shanghai','Advance'),(6,10,1,3,'6','Vaibhav Suthar','vaibhavsuthar2711@gmail.com',NULL,NULL,'Aluminum Plates','Special grade product',9,'liters',10000,90000,6750,96750,'PENDING','2025-09-23 07:26:03',NULL,'2025-10-06','719 Example St, CityF, Country','FOB','Bulk commodity order','Vaibhav Suthar','Aluminum Plates',90000,'Rotterdam','Net 45'),(7,2,1,1,'7','Demo Supplier','demo@supplier.com',NULL,NULL,'Steel Rods','Demo product description',0,'kg',9000,9000,675,9675,'PENDING','2025-09-23 08:29:21',NULL,'2025-09-30','123 Demo St','FOB','Demo notes','Demo Supplier','Steel Rods',9000,'Demo Port','Net 30'),(8,11,1,5,'8','Vaibhav Suthar','vaibhavsuthar2711@gmail.com',NULL,NULL,'Paint Buckets','Special grade product',11,'kg',101,1111,83.325,1194.325,'PENDING','2025-09-23 09:07:47',NULL,'2025-10-06','460 Example St, CityB, Country','FOB','High purity copper sheets','Vaibhav Suthar','Paint Buckets',1111,'Rotterdam','COD'),(9,12,1,5,'9','Vaibhav Suthar','vaibhavsuthar2711@gmail.com',NULL,NULL,'Paint Buckets','Special grade product',10,'meters',8900,89000,6675,95675,'PENDING','2025-09-23 09:44:12',NULL,'2025-09-26','253 Example St, CityZ, Country','CIF','Bulk commodity order','Vaibhav Suthar','Paint Buckets',89000,'Rotterdam','Net 45'),(10,13,1,2,'10','Vaibhav Suthar','vaibhavsuthar2711@gmail.com',NULL,NULL,'Copper Sheets','Bulk commodity order',11,'ton',809.0909090909091,8900,667.5,9567.5,'PENDING','2025-10-09 08:35:58',NULL,'2025-10-19','767 Example St, CityS, Country','CIF','High purity copper sheets','Vaibhav Suthar','Copper Sheets',8900,'Rotterdam','COD'),(11,14,1,1,'10','Vaibhav Suthar','vaibhavsuthar2711@gmail.com',NULL,NULL,'Steel Rods','Bulk commodity order',8,'meters',700,5600,420,6020,'SENT','2025-10-09 10:18:19',NULL,'2025-10-19','673 Example St, CityG, Country','DAP','Special grade product','Vaibhav Suthar','Steel Rods',5600,'Hamburg','COD'),(12,15,1,3,'10','Vaibhav Suthar','vaibhavsuthar2711@gmail.com',NULL,NULL,'Aluminum Plates','Special grade product',10,'meters',980,9800,735,10535,'SENT','2025-10-09 12:00:19',NULL,'2025-10-24','669 Example St, CityQ, Country','FOB','High purity copper sheets','Vaibhav Suthar','Aluminum Plates',9800,'Rotterdam','Advance'),(13,16,1,3,'10','Vaibhav Suthar','vaibhavsuthar2711@gmail.com',NULL,NULL,'Aluminum Plates','Standard industrial material',10,'meters',1000,10000,750,10750,'SENT','2025-10-09 12:12:02',NULL,'2025-10-12','982 Example St, CityZ, Country','DAP','Standard industrial material','Vaibhav Suthar','Aluminum Plates',10000,'Rotterdam','Net 30');
/*!40000 ALTER TABLE `purchase_orders` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `reverse_auctions`
--

DROP TABLE IF EXISTS `reverse_auctions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `reverse_auctions` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `product_id` bigint unsigned NOT NULL,
  `start_price` double NOT NULL,
  `current_price` double NOT NULL,
  `start_time` timestamp NOT NULL,
  `end_time` timestamp NOT NULL,
  `status` enum('PENDING','ACTIVE','COMPLETED','CANCELLED','SCHEDULED') DEFAULT 'PENDING',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `winning_supplier_id` bigint unsigned DEFAULT NULL,
  `required_quantity` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `product_id` (`product_id`),
  KEY `fk_winning_supplier` (`winning_supplier_id`),
  CONSTRAINT `fk_winning_supplier` FOREIGN KEY (`winning_supplier_id`) REFERENCES `suppliers` (`id`),
  CONSTRAINT `reverse_auctions_ibfk_1` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `reverse_auctions`
--

LOCK TABLES `reverse_auctions` WRITE;
/*!40000 ALTER TABLE `reverse_auctions` DISABLE KEYS */;
INSERT INTO `reverse_auctions` VALUES (1,5,300000,300000,'2025-06-27 12:24:00','2025-06-30 17:57:00','COMPLETED','2025-06-27 16:54:27',NULL,100),(2,1,90000,9000,'2025-06-30 04:08:00','2025-07-07 03:08:00','COMPLETED','2025-06-30 08:38:59',1,0),(3,2,35670,34570,'2025-06-30 05:51:00','2025-07-07 04:51:00','COMPLETED','2025-06-30 10:21:56',1,0),(4,5,60000,60000,'2025-07-02 04:57:00','2025-07-09 03:57:00','COMPLETED','2025-07-02 09:28:04',NULL,0),(5,4,9000,8000,'2025-07-02 05:18:00','2025-07-09 04:18:00','COMPLETED','2025-07-02 09:48:41',1,20),(6,3,56700,51780,'2025-07-03 09:42:00','2025-07-10 08:42:00','COMPLETED','2025-07-03 14:12:39',1,90),(7,3,56700,56700,'2025-07-03 09:42:00','2025-07-10 08:42:00','COMPLETED','2025-07-03 14:12:48',NULL,90),(8,3,20000,10000,'2025-09-21 00:44:00','2025-09-27 23:44:00','COMPLETED','2025-09-21 05:14:54',1,20),(9,3,12000,9000,'2025-09-21 02:02:00','2025-09-28 01:02:00','COMPLETED','2025-09-21 06:32:52',1,12),(10,3,100000,90000,'2025-09-23 02:54:00','2025-09-30 01:54:00','COMPLETED','2025-09-23 07:24:40',1,50),(11,5,111111,1111,'2025-09-23 04:36:00','2025-09-30 03:36:00','COMPLETED','2025-09-23 09:06:52',1,200),(12,5,90000,89000,'2025-09-23 05:13:00','2025-09-30 04:13:00','COMPLETED','2025-09-23 09:43:26',1,150),(13,2,90000,8900,'2025-10-09 04:04:00','2025-10-16 03:04:00','COMPLETED','2025-10-09 08:34:58',1,11),(14,1,7000,5600,'2025-10-09 04:55:00','2025-10-16 03:55:00','COMPLETED','2025-10-09 09:25:58',1,8),(15,3,12345,9800,'2025-10-09 07:28:00','2025-10-16 06:28:00','COMPLETED','2025-10-09 11:59:10',1,10),(16,3,12345,10000,'2025-10-09 07:28:00','2025-10-16 06:28:00','COMPLETED','2025-10-09 11:59:19',1,10),(17,3,12345,12345,'2025-10-09 07:28:00','2025-10-16 06:28:00','ACTIVE','2025-10-09 12:00:10',NULL,10),(18,3,12345,12345,'2025-10-09 07:28:00','2025-10-16 06:28:00','ACTIVE','2025-10-09 12:00:20',NULL,10);
/*!40000 ALTER TABLE `reverse_auctions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `settings`
--

DROP TABLE IF EXISTS `settings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `settings` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `email` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `notification_enabled` tinyint(1) DEFAULT '1',
  `theme` enum('light','dark','system') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'light',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `user_id` (`user_id`),
  UNIQUE KEY `email` (`email`),
  KEY `idx_email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=48772 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `settings`
--

LOCK TABLES `settings` WRITE;
/*!40000 ALTER TABLE `settings` DISABLE KEYS */;
INSERT INTO `settings` VALUES (1,1,'admin@example.com',1,'light','2025-05-13 08:35:53','2025-05-13 08:35:53');
/*!40000 ALTER TABLE `settings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `suppliers`
--

DROP TABLE IF EXISTS `suppliers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `suppliers` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `address` text,
  `password` varchar(255) NOT NULL DEFAULT 'changeme',
  `status` enum('ACTIVE','INACTIVE') DEFAULT 'ACTIVE',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=102 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `suppliers`
--

LOCK TABLES `suppliers` WRITE;
/*!40000 ALTER TABLE `suppliers` DISABLE KEYS */;
INSERT INTO `suppliers` VALUES (1,'Vaibhav Suthar','vaibhavsuthar2711@gmail.com','1234567890','','changeme','ACTIVE','2025-06-27 17:04:31'),(2,'Supplier 001','supplier001@test.com','1234567001','101 Market St','changeme','ACTIVE','2025-11-26 07:34:21'),(3,'Supplier 002','supplier002@test.com','1234567002','102 Market St','changeme','ACTIVE','2025-11-26 07:34:21'),(4,'Supplier 003','supplier003@test.com','1234567003','103 Market St','changeme','ACTIVE','2025-11-26 07:34:21'),(5,'Supplier 004','supplier004@test.com','1234567004','104 Market St','changeme','ACTIVE','2025-11-26 07:34:21'),(6,'Supplier 005','supplier005@test.com','1234567005','105 Market St','changeme','ACTIVE','2025-11-26 07:34:21'),(7,'Supplier 006','supplier006@test.com','1234567006','106 Market St','changeme','ACTIVE','2025-11-26 07:34:21'),(8,'Supplier 007','supplier007@test.com','1234567007','107 Market St','changeme','ACTIVE','2025-11-26 07:34:21'),(9,'Supplier 008','supplier008@test.com','1234567008','108 Market St','changeme','ACTIVE','2025-11-26 07:34:21'),(10,'Supplier 009','supplier009@test.com','1234567009','109 Market St','changeme','ACTIVE','2025-11-26 07:34:21'),(11,'Supplier 010','supplier010@test.com','1234567010','110 Market St','changeme','ACTIVE','2025-11-26 07:34:21'),(12,'Supplier 011','supplier011@test.com','1234567011','111 Market St','changeme','ACTIVE','2025-11-26 07:34:21'),(13,'Supplier 012','supplier012@test.com','1234567012','112 Market St','changeme','ACTIVE','2025-11-26 07:34:21'),(14,'Supplier 013','supplier013@test.com','1234567013','113 Market St','changeme','ACTIVE','2025-11-26 07:34:21'),(15,'Supplier 014','supplier014@test.com','1234567014','114 Market St','changeme','ACTIVE','2025-11-26 07:34:21'),(16,'Supplier 015','supplier015@test.com','1234567015','115 Market St','changeme','ACTIVE','2025-11-26 07:34:21'),(17,'Supplier 016','supplier016@test.com','1234567016','116 Market St','changeme','ACTIVE','2025-11-26 07:34:21'),(18,'Supplier 017','supplier017@test.com','1234567017','117 Market St','changeme','ACTIVE','2025-11-26 07:34:21'),(19,'Supplier 018','supplier018@test.com','1234567018','118 Market St','changeme','ACTIVE','2025-11-26 07:34:21'),(20,'Supplier 019','supplier019@test.com','1234567019','119 Market St','changeme','ACTIVE','2025-11-26 07:34:21'),(21,'Supplier 020','supplier020@test.com','1234567020','120 Market St','changeme','ACTIVE','2025-11-26 07:34:21'),(22,'Supplier 021','supplier021@test.com','1234567021','121 Market St','changeme','ACTIVE','2025-11-26 07:34:21'),(23,'Supplier 022','supplier022@test.com','1234567022','122 Market St','changeme','ACTIVE','2025-11-26 07:34:21'),(24,'Supplier 023','supplier023@test.com','1234567023','123 Market St','changeme','ACTIVE','2025-11-26 07:34:21'),(25,'Supplier 024','supplier024@test.com','1234567024','124 Market St','changeme','ACTIVE','2025-11-26 07:34:21'),(26,'Supplier 025','supplier025@test.com','1234567025','125 Market St','changeme','ACTIVE','2025-11-26 07:34:21'),(27,'Supplier 026','supplier026@test.com','1234567026','126 Market St','changeme','ACTIVE','2025-11-26 07:34:21'),(28,'Supplier 027','supplier027@test.com','1234567027','127 Market St','changeme','ACTIVE','2025-11-26 07:34:21'),(29,'Supplier 028','supplier028@test.com','1234567028','128 Market St','changeme','ACTIVE','2025-11-26 07:34:21'),(30,'Supplier 029','supplier029@test.com','1234567029','129 Market St','changeme','ACTIVE','2025-11-26 07:34:21'),(31,'Supplier 030','supplier030@test.com','1234567030','130 Market St','changeme','ACTIVE','2025-11-26 07:34:21'),(32,'Supplier 031','supplier031@test.com','1234567031','131 Market St','changeme','ACTIVE','2025-11-26 07:34:21'),(33,'Supplier 032','supplier032@test.com','1234567032','132 Market St','changeme','ACTIVE','2025-11-26 07:34:21'),(34,'Supplier 033','supplier033@test.com','1234567033','133 Market St','changeme','ACTIVE','2025-11-26 07:34:21'),(35,'Supplier 034','supplier034@test.com','1234567034','134 Market St','changeme','ACTIVE','2025-11-26 07:34:21'),(36,'Supplier 035','supplier035@test.com','1234567035','135 Market St','changeme','ACTIVE','2025-11-26 07:34:21'),(37,'Supplier 036','supplier036@test.com','1234567036','136 Market St','changeme','ACTIVE','2025-11-26 07:34:21'),(38,'Supplier 037','supplier037@test.com','1234567037','137 Market St','changeme','ACTIVE','2025-11-26 07:34:21'),(39,'Supplier 038','supplier038@test.com','1234567038','138 Market St','changeme','ACTIVE','2025-11-26 07:34:21'),(40,'Supplier 039','supplier039@test.com','1234567039','139 Market St','changeme','ACTIVE','2025-11-26 07:34:21'),(41,'Supplier 040','supplier040@test.com','1234567040','140 Market St','changeme','ACTIVE','2025-11-26 07:34:21'),(42,'Supplier 041','supplier041@test.com','1234567041','141 Market St','changeme','ACTIVE','2025-11-26 07:34:21'),(43,'Supplier 042','supplier042@test.com','1234567042','142 Market St','changeme','ACTIVE','2025-11-26 07:34:21'),(44,'Supplier 043','supplier043@test.com','1234567043','143 Market St','changeme','ACTIVE','2025-11-26 07:34:21'),(45,'Supplier 044','supplier044@test.com','1234567044','144 Market St','changeme','ACTIVE','2025-11-26 07:34:21'),(46,'Supplier 045','supplier045@test.com','1234567045','145 Market St','changeme','ACTIVE','2025-11-26 07:34:21'),(47,'Supplier 046','supplier046@test.com','1234567046','146 Market St','changeme','ACTIVE','2025-11-26 07:34:21'),(48,'Supplier 047','supplier047@test.com','1234567047','147 Market St','changeme','ACTIVE','2025-11-26 07:34:21'),(49,'Supplier 048','supplier048@test.com','1234567048','148 Market St','changeme','ACTIVE','2025-11-26 07:34:21'),(50,'Supplier 049','supplier049@test.com','1234567049','149 Market St','changeme','ACTIVE','2025-11-26 07:34:21'),(51,'Supplier 050','supplier050@test.com','1234567050','150 Market St','changeme','ACTIVE','2025-11-26 07:34:21'),(52,'Supplier 051','supplier051@test.com','1234567051','151 Market St','changeme','ACTIVE','2025-11-26 07:34:21'),(53,'Supplier 052','supplier052@test.com','1234567052','152 Market St','changeme','ACTIVE','2025-11-26 07:34:21'),(54,'Supplier 053','supplier053@test.com','1234567053','153 Market St','changeme','ACTIVE','2025-11-26 07:34:21'),(55,'Supplier 054','supplier054@test.com','1234567054','154 Market St','changeme','ACTIVE','2025-11-26 07:34:21'),(56,'Supplier 055','supplier055@test.com','1234567055','155 Market St','changeme','ACTIVE','2025-11-26 07:34:21'),(57,'Supplier 056','supplier056@test.com','1234567056','156 Market St','changeme','ACTIVE','2025-11-26 07:34:21'),(58,'Supplier 057','supplier057@test.com','1234567057','157 Market St','changeme','ACTIVE','2025-11-26 07:34:21'),(59,'Supplier 058','supplier058@test.com','1234567058','158 Market St','changeme','ACTIVE','2025-11-26 07:34:21'),(60,'Supplier 059','supplier059@test.com','1234567059','159 Market St','changeme','ACTIVE','2025-11-26 07:34:21'),(61,'Supplier 060','supplier060@test.com','1234567060','160 Market St','changeme','ACTIVE','2025-11-26 07:34:21'),(62,'Supplier 061','supplier061@test.com','1234567061','161 Market St','changeme','ACTIVE','2025-11-26 07:34:21'),(63,'Supplier 062','supplier062@test.com','1234567062','162 Market St','changeme','ACTIVE','2025-11-26 07:34:21'),(64,'Supplier 063','supplier063@test.com','1234567063','163 Market St','changeme','ACTIVE','2025-11-26 07:34:21'),(65,'Supplier 064','supplier064@test.com','1234567064','164 Market St','changeme','ACTIVE','2025-11-26 07:34:21'),(66,'Supplier 065','supplier065@test.com','1234567065','165 Market St','changeme','ACTIVE','2025-11-26 07:34:21'),(67,'Supplier 066','supplier066@test.com','1234567066','166 Market St','changeme','ACTIVE','2025-11-26 07:34:21'),(68,'Supplier 067','supplier067@test.com','1234567067','167 Market St','changeme','ACTIVE','2025-11-26 07:34:21'),(69,'Supplier 068','supplier068@test.com','1234567068','168 Market St','changeme','ACTIVE','2025-11-26 07:34:21'),(70,'Supplier 069','supplier069@test.com','1234567069','169 Market St','changeme','ACTIVE','2025-11-26 07:34:21'),(71,'Supplier 070','supplier070@test.com','1234567070','170 Market St','changeme','ACTIVE','2025-11-26 07:34:21'),(72,'Supplier 071','supplier071@test.com','1234567071','171 Market St','changeme','ACTIVE','2025-11-26 07:34:21'),(73,'Supplier 072','supplier072@test.com','1234567072','172 Market St','changeme','ACTIVE','2025-11-26 07:34:21'),(74,'Supplier 073','supplier073@test.com','1234567073','173 Market St','changeme','ACTIVE','2025-11-26 07:34:21'),(75,'Supplier 074','supplier074@test.com','1234567074','174 Market St','changeme','ACTIVE','2025-11-26 07:34:21'),(76,'Supplier 075','supplier075@test.com','1234567075','175 Market St','changeme','ACTIVE','2025-11-26 07:34:21'),(77,'Supplier 076','supplier076@test.com','1234567076','176 Market St','changeme','ACTIVE','2025-11-26 07:34:21'),(78,'Supplier 077','supplier077@test.com','1234567077','177 Market St','changeme','ACTIVE','2025-11-26 07:34:21'),(79,'Supplier 078','supplier078@test.com','1234567078','178 Market St','changeme','ACTIVE','2025-11-26 07:34:21'),(80,'Supplier 079','supplier079@test.com','1234567079','179 Market St','changeme','ACTIVE','2025-11-26 07:34:21'),(81,'Supplier 080','supplier080@test.com','1234567080','180 Market St','changeme','ACTIVE','2025-11-26 07:34:21'),(82,'Supplier 081','supplier081@test.com','1234567081','181 Market St','changeme','ACTIVE','2025-11-26 07:34:21'),(83,'Supplier 082','supplier082@test.com','1234567082','182 Market St','changeme','ACTIVE','2025-11-26 07:34:21'),(84,'Supplier 083','supplier083@test.com','1234567083','183 Market St','changeme','ACTIVE','2025-11-26 07:34:21'),(85,'Supplier 084','supplier084@test.com','1234567084','184 Market St','changeme','ACTIVE','2025-11-26 07:34:21'),(86,'Supplier 085','supplier085@test.com','1234567085','185 Market St','changeme','ACTIVE','2025-11-26 07:34:21'),(87,'Supplier 086','supplier086@test.com','1234567086','186 Market St','changeme','ACTIVE','2025-11-26 07:34:21'),(88,'Supplier 087','supplier087@test.com','1234567087','187 Market St','changeme','ACTIVE','2025-11-26 07:34:21'),(89,'Supplier 088','supplier088@test.com','1234567088','188 Market St','changeme','ACTIVE','2025-11-26 07:34:21'),(90,'Supplier 089','supplier089@test.com','1234567089','189 Market St','changeme','ACTIVE','2025-11-26 07:34:21'),(91,'Supplier 090','supplier090@test.com','1234567090','190 Market St','changeme','ACTIVE','2025-11-26 07:34:21'),(92,'Supplier 091','supplier091@test.com','1234567091','191 Market St','changeme','ACTIVE','2025-11-26 07:34:21'),(93,'Supplier 092','supplier092@test.com','1234567092','192 Market St','changeme','ACTIVE','2025-11-26 07:34:21'),(94,'Supplier 093','supplier093@test.com','1234567093','193 Market St','changeme','ACTIVE','2025-11-26 07:34:21'),(95,'Supplier 094','supplier094@test.com','1234567094','194 Market St','changeme','ACTIVE','2025-11-26 07:34:21'),(96,'Supplier 095','supplier095@test.com','1234567095','195 Market St','changeme','ACTIVE','2025-11-26 07:34:21'),(97,'Supplier 096','supplier096@test.com','1234567096','196 Market St','changeme','ACTIVE','2025-11-26 07:34:21'),(98,'Supplier 097','supplier097@test.com','1234567097','197 Market St','changeme','ACTIVE','2025-11-26 07:34:21'),(99,'Supplier 098','supplier098@test.com','1234567098','198 Market St','changeme','ACTIVE','2025-11-26 07:34:21'),(100,'Supplier 099','supplier099@test.com','1234567099','199 Market St','changeme','ACTIVE','2025-11-26 07:34:21'),(101,'Supplier 100','supplier100@test.com','1234567100','200 Market St','changeme','ACTIVE','2025-11-26 07:34:21');
/*!40000 ALTER TABLE `suppliers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `todos`
--

DROP TABLE IF EXISTS `todos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `todos` (
  `id` int NOT NULL AUTO_INCREMENT,
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `status` enum('PENDING','IN_PROGRESS','COMPLETED','CANCELLED') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'PENDING',
  `priority` enum('LOW','MEDIUM','HIGH','URGENT') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'MEDIUM',
  `assigned_to` int DEFAULT NULL,
  `due_date` date DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_status` (`status`),
  KEY `idx_priority` (`priority`),
  KEY `idx_due_date` (`due_date`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `todos`
--

LOCK TABLES `todos` WRITE;
/*!40000 ALTER TABLE `todos` DISABLE KEYS */;
INSERT INTO `todos` VALUES (1,'Review supplier contracts','Review and update contracts with key suppliers','COMPLETED','HIGH',NULL,'2025-05-20','2025-05-13 08:35:54','2025-05-22 14:22:46'),(2,'Prepare quarterly report','Compile Q2 sales and procurement data','COMPLETED','HIGH',NULL,'2025-05-16','2025-05-13 08:35:54','2025-05-13 08:51:55'),(3,'Update product catalog','Add new coating products to the catalog','PENDING','MEDIUM',NULL,'2025-05-27','2025-05-13 08:35:54','2025-05-13 08:35:54'),(5,'Inventory check','Perform monthly inventory audit','PENDING','LOW',NULL,'2025-05-23','2025-05-13 08:35:54','2025-05-13 08:35:54'),(6,'Final sumiision','Lagi padi hein','PENDING','HIGH',NULL,'2025-05-23','2025-05-22 14:23:15','2025-05-22 14:23:15');
/*!40000 ALTER TABLE `todos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `id` int NOT NULL AUTO_INCREMENT,
  `username` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `password_hash` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `role` enum('ADMIN','USER','SUPPLIER') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'USER',
  `status` enum('ACTIVE','INACTIVE','BLOCKED') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'ACTIVE',
  `email` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `last_login` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`),
  UNIQUE KEY `email` (`email`),
  KEY `idx_username` (`username`),
  KEY `idx_email` (`email`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'admin','$2a$10$CrOtY7cBJVMRXel/wGFMRg==$JpnaArTfsuWZKBq/fClio1iGronKFgoUEQBFZXeU96Q=','ADMIN','ACTIVE','admin@example.com','2025-05-19 08:40:05','2025-05-13 08:35:54','2025-05-19 08:40:54'),(4,'Vaibhav','123456','USER','ACTIVE','vaibhavsuthar2711@gmail.com','2025-11-26 07:27:44','2025-06-21 10:24:38','2025-11-26 07:27:44'),(5,'SAP','123456','SUPPLIER','ACTIVE','sap@gmail.com','2025-06-24 13:15:33','2025-06-24 12:54:27','2025-10-14 15:26:15');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-11-26 13:42:10
