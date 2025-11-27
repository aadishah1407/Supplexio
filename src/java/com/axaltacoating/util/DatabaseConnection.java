package com.axaltacoating.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.TimeUnit;
import java.util.logging.Level;
import java.util.logging.Logger;

public class DatabaseConnection {
    private static final Logger LOGGER = Logger.getLogger(DatabaseConnection.class.getName());
    private static final String DB_URL = "jdbc:mysql://localhost:3306/axalta?useSSL=false&allowPublicKeyRetrieval=true";
    private static final String DB_USER = "root";
    private static final String DB_PASSWORD = "root";
    private static final CountDownLatch initLatch = new CountDownLatch(1);
    private static volatile boolean tablesInitialized = false;

    static {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            LOGGER.log(Level.SEVERE, "MySQL JDBC Driver not found", e);
        }
    }

    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
    }

    public static void initializeTables() throws SQLException {
        if (tablesInitialized) {
            return;
        }

        Connection conn = null;
        Statement stmt = null;

        try {
            conn = getConnection();
            stmt = conn.createStatement();

            // Create inventory table
            stmt.executeUpdate(
                "CREATE TABLE IF NOT EXISTS inventory (" +
                "id INT PRIMARY KEY AUTO_INCREMENT, " +
                "item_name VARCHAR(255) NOT NULL, " +
                "quantity INT NOT NULL, " +
                "min_threshold INT NOT NULL, " +
                "max_threshold INT NOT NULL, " +
                "kanban_status ENUM('Low', 'Medium', 'High') DEFAULT 'Medium', " +
                "needs_auction BOOLEAN DEFAULT FALSE, " +
                "auction_started BOOLEAN DEFAULT FALSE, " +
                "created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, " +
                "updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP" +
                ")"
            );

            // Create products table
            stmt.executeUpdate(
                "CREATE TABLE IF NOT EXISTS products (" +
                "id BIGINT PRIMARY KEY AUTO_INCREMENT, " +
                "name VARCHAR(255) NOT NULL, " +
                "description TEXT, " +
                "category VARCHAR(100) DEFAULT 'General', " +
                "base_price DECIMAL(10,2) DEFAULT 0.00, " +
                "unit VARCHAR(50) DEFAULT 'pcs', " +
                "stock_quantity INT DEFAULT 0, " +
                "inventory_id BIGINT NULL, " +
                "created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP" +
                ")"
            );

            // Create suppliers table
            stmt.executeUpdate(
                "CREATE TABLE IF NOT EXISTS suppliers (" +
                "id BIGINT PRIMARY KEY AUTO_INCREMENT, " +
                "name VARCHAR(255) NOT NULL, " +
                "email VARCHAR(255) NOT NULL UNIQUE, " +
                "phone VARCHAR(20), " +
                "address TEXT, " +
                "password VARCHAR(255) NOT NULL, " +
                "status ENUM('ACTIVE', 'INACTIVE') DEFAULT 'ACTIVE', " +
                "created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP" +
                ")"
            );

            // Create reverse auctions table
            stmt.executeUpdate(
                "CREATE TABLE IF NOT EXISTS reverse_auctions (" +
                "id BIGINT PRIMARY KEY AUTO_INCREMENT, " +
                "product_id BIGINT NOT NULL, " +
                "start_price DOUBLE NOT NULL, " +
                "current_price DOUBLE NOT NULL, " +
                "start_time TIMESTAMP NOT NULL, " +
                "end_time TIMESTAMP NOT NULL, " +
                "status ENUM('PENDING', 'ACTIVE', 'COMPLETED', 'CANCELLED', 'SCHEDULED') DEFAULT 'PENDING', " +
                "created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, " +
                "FOREIGN KEY (product_id) REFERENCES products(id)" +
                ")"
            );

            // Create bids table
            stmt.executeUpdate(
                "CREATE TABLE IF NOT EXISTS bids (" +
                "id BIGINT PRIMARY KEY AUTO_INCREMENT, " +
                "auction_id BIGINT NOT NULL, " +
                "user_id BIGINT NOT NULL, " +
                "bid_amount DOUBLE NOT NULL, " +
                "bid_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, " +
                "FOREIGN KEY (auction_id) REFERENCES reverse_auctions(id)" +
                ")"
            );

            // Create auction invitations table
            stmt.executeUpdate(
                "CREATE TABLE IF NOT EXISTS auction_invitations (" +
                "auction_id BIGINT NOT NULL, " +
                "supplier_id BIGINT NOT NULL, " +
                "status ENUM('PENDING', 'ACCEPTED', 'DECLINED') DEFAULT 'PENDING', " +
                "created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, " +
                "PRIMARY KEY (auction_id, supplier_id), " +
                "FOREIGN KEY (auction_id) REFERENCES reverse_auctions(id), " +
                "FOREIGN KEY (supplier_id) REFERENCES suppliers(id)" +
                ")"
            );

            // Create payments table
            stmt.executeUpdate(
                "CREATE TABLE IF NOT EXISTS payments (" +
                "id BIGINT PRIMARY KEY AUTO_INCREMENT, " +
                "auction_id BIGINT NOT NULL, " +
                "supplier_id BIGINT NOT NULL, " +
                "amount DOUBLE NOT NULL, " +
                "status VARCHAR(20) NOT NULL DEFAULT 'PENDING', " +
                "payment_method VARCHAR(20), " +
                "transaction_id VARCHAR(100), " +
                "payment_date TIMESTAMP NULL, " +
                "created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, " +
                "remarks TEXT, " +
                "FOREIGN KEY (auction_id) REFERENCES reverse_auctions(id), " +
                "FOREIGN KEY (supplier_id) REFERENCES suppliers(id)" +
                ")"
            );

            // Defensive migration: ensure commonly referenced columns exist so runtime SQL won't fail
            // Add auction_id to auction_deliveries if missing
            try {
                stmt.executeUpdate("ALTER TABLE auction_deliveries ADD COLUMN IF NOT EXISTS auction_id BIGINT");
            } catch (SQLException e) {
                LOGGER.log(Level.FINE, "Could not add auction_id to auction_deliveries (may already exist or DB does not support IF NOT EXISTS): " + e.getMessage());
                try {
                    // Fallback: attempt add without IF NOT EXISTS to support older MySQL versions, but ignore errors
                    stmt.executeUpdate("ALTER TABLE auction_deliveries ADD COLUMN auction_id BIGINT");
                } catch (SQLException ex) {
                    LOGGER.log(Level.FINE, "Fallback add auction_id failed (likely already exists): " + ex.getMessage());
                }
            }

            // Add auction_id to purchase_orders if missing
            try {
                stmt.executeUpdate("ALTER TABLE purchase_orders ADD COLUMN IF NOT EXISTS auction_id BIGINT");
            } catch (SQLException e) {
                LOGGER.log(Level.FINE, "Could not add auction_id to purchase_orders (may already exist or DB does not support IF NOT EXISTS): " + e.getMessage());
                try {
                    stmt.executeUpdate("ALTER TABLE purchase_orders ADD COLUMN auction_id BIGINT");
                } catch (SQLException ex) {
                    LOGGER.log(Level.FINE, "Fallback add auction_id to purchase_orders failed (likely already exists): " + ex.getMessage());
                }
            }

            tablesInitialized = true;
            LOGGER.info("All tables created successfully");
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error initializing database tables", e);
            throw e; // Rethrow the exception to signal initialization failure
        } finally {
            closeQuietly(null, stmt, conn);
            initLatch.countDown(); // Signal that initialization attempt is complete
        }
    }

    public static boolean waitForInitialization(long timeout, TimeUnit unit) throws InterruptedException {
        return initLatch.await(timeout, unit);
    }

    public static boolean isInitialized() {
        return tablesInitialized;
    }

    public static void closeQuietly(ResultSet rs, Statement stmt, Connection conn) {
        if (rs != null) {
            try {
                rs.close();
            } catch (SQLException e) {
                LOGGER.log(Level.WARNING, "Error closing ResultSet", e);
            }
        }
        if (stmt != null) {
            try {
                stmt.close();
            } catch (SQLException e) {
                LOGGER.log(Level.WARNING, "Error closing Statement", e);
            }
        }
        if (conn != null) {
            try {
                conn.close();
            } catch (SQLException e) {
                LOGGER.log(Level.WARNING, "Error closing Connection", e);
            }
        }
    }
}
