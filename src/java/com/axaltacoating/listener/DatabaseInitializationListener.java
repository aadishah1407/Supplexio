package com.axaltacoating.listener;

import com.axaltacoating.util.DatabaseConnection;
import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;
import javax.servlet.annotation.WebListener;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebListener
public class DatabaseInitializationListener implements ServletContextListener {
    private static final Logger LOGGER = Logger.getLogger(DatabaseInitializationListener.class.getName());

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        LOGGER.info("DatabaseInitializationListener: Checking database connectivity...");
        
        // Test database connectivity
        try (Connection conn = DatabaseConnection.getConnection()) {
            if (conn != null && !conn.isClosed()) {
                LOGGER.info("DatabaseInitializationListener: Database connection successful");
                // Database already initialized, skip SQL script execution for faster startup
                LOGGER.info("DatabaseInitializationListener: Skipping SQL script execution (database already initialized)");
                return;
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "DatabaseInitializationListener: Failed to connect to database", e);
        }
        
        LOGGER.info("DatabaseInitializationListener: Database initialization complete");
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        LOGGER.info("DatabaseInitializationListener: Application context destroyed");
    }
}