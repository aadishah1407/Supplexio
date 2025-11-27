package com.axaltacoating.util;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;
import java.util.logging.Level;
import java.util.logging.Logger;

public class DashboardCache {
    private static final Logger LOGGER = Logger.getLogger(DashboardCache.class.getName());
    private static final ConcurrentHashMap<String, Object> cache = new ConcurrentHashMap<>();
    private static final ScheduledExecutorService scheduler = Executors.newScheduledThreadPool(1);
    private static final int CACHE_UPDATE_INTERVAL = 5; // minutes

    static {
        scheduler.scheduleAtFixedRate(DashboardCache::updateCache, 0, CACHE_UPDATE_INTERVAL, TimeUnit.MINUTES);
    }

    public static Object get(String key) {
        return cache.get(key);
    }

    private static void updateCache() {
        try {
            updateActiveSuppliers();
            updateActiveAuctions();
            updateTotalTransactions();
            updateSuccessRate();
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error updating dashboard cache", e);
        }
    }

    private static void updateActiveSuppliers() throws SQLException {
        String query = "SELECT COUNT(*) as count FROM suppliers WHERE status = 'ACTIVE'";
        executeQuery(query, "activeSuppliers");
    }

    private static void updateActiveAuctions() throws SQLException {
        String query = "SELECT COUNT(*) as count FROM reverse_auctions WHERE status = 'ACTIVE'";
        executeQuery(query, "activeAuctions");
    }

    private static void updateTotalTransactions() throws SQLException {
        String query = "SELECT SUM(amount) as total FROM payments WHERE status = 'COMPLETED'";
        executeQuery(query, "totalTransactions");
    }

    private static void updateSuccessRate() throws SQLException {
        String query = "SELECT " +
                "(SELECT COUNT(*) FROM reverse_auctions WHERE status = 'COMPLETED') * 100.0 / " +
                "NULLIF((SELECT COUNT(*) FROM reverse_auctions WHERE status IN ('COMPLETED', 'FAILED')), 0) " +
                "as success_rate";
        executeQuery(query, "successRate");
    }

    private static void executeQuery(String query, String cacheKey) throws SQLException {
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query);
             ResultSet rs = stmt.executeQuery()) {
            if (rs.next()) {
                cache.put(cacheKey, rs.getObject(1));
            }
        }
    }
}