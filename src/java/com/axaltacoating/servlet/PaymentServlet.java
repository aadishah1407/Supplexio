package com.axaltacoating.servlet;

import com.axaltacoating.util.DatabaseConnection;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import org.json.simple.JSONObject;

/**
 * Simple Payment Servlet that marks payments as completed
 */
@WebServlet("/payment/*")
public class PaymentServlet extends HttpServlet {
    private static final Logger LOGGER = Logger.getLogger(PaymentServlet.class.getName());
    
    /**
     * Handles the HTTP GET method - retrieves payment information
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Check if this is a specific action request
        String action = request.getParameter("action");
        
        if (action != null) {
            // Handle specific actions
            if (action.equals("get")) {
                try {
                    long paymentId = Long.parseLong(request.getParameter("id"));
                    Map<String, Object> payment = getPaymentDetails(paymentId);
                    if (payment != null) {
                        response.setContentType("application/json");
                        JSONObject json = new JSONObject(payment);
                        response.getWriter().write(json.toString());
                    } else {
                        sendErrorResponse(response, "Payment not found");
                    }
                } catch (NumberFormatException e) {
                    sendErrorResponse(response, "Invalid payment ID");
                } catch (SQLException e) {
                    LOGGER.log(Level.SEVERE, "Database error getting payment details", e);
                    sendErrorResponse(response, "Database error: " + e.getMessage());
                }
                return;
            }
        }
        
        // Retrieve auction winners for the payment page
        List<Map<String, Object>> auctionWinners = getAuctionWinners();
        request.setAttribute("auctionWinners", auctionWinners);
        
        // Retrieve filter parameters
        String status = request.getParameter("status");
        String method = request.getParameter("method");
        String dateFrom = request.getParameter("dateFrom");
        String dateTo = request.getParameter("dateTo");

        // Retrieve payment history
        List<Map<String, Object>> payments = getPaymentHistory(status, method, dateFrom, dateTo);
        request.setAttribute("payments", payments);
        
        // Calculate statistics
        int completedPaymentsCount = 0;
        int pendingPaymentsCount = 0;
        double totalPaymentAmount = 0.0;
        for (Map<String, Object> payment : payments) {
            totalPaymentAmount += (double) payment.get("amount");
            if ("COMPLETED".equals(payment.get("status"))) {
                completedPaymentsCount++;
            } else if ("PENDING".equals(payment.get("status"))) {
                pendingPaymentsCount++;
            }
        }
        int totalPaymentsCount = payments.size();

        request.setAttribute("completedPaymentsCount", completedPaymentsCount);
        request.setAttribute("pendingPaymentsCount", pendingPaymentsCount);
        request.setAttribute("totalPaymentAmount", totalPaymentAmount);
        request.setAttribute("totalPaymentsCount", totalPaymentsCount);
        
        // For regular GET requests, forward to the payments page
        request.getRequestDispatcher("/payment.jsp").forward(request, response);
    }

    /**
     * Handles the HTTP POST method - processes payment requests
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");

        if ("complete".equals(action)) {
            try {
                long paymentId = Long.parseLong(request.getParameter("id"));
                boolean success = markPaymentAsCompletedById(paymentId);
                if (success) {
                    request.getSession().setAttribute("success", "Payment has been successfully marked as completed");
                } else {
                    request.getSession().setAttribute("error", "Failed to mark payment as completed");
                }
                response.sendRedirect(request.getContextPath() + "/payment");
            } catch (NumberFormatException e) {
                request.getSession().setAttribute("error", "Invalid payment ID");
                response.sendRedirect(request.getContextPath() + "/payment");
            } catch (SQLException e) {
                LOGGER.log(Level.SEVERE, "Database error while completing payment", e);
                request.getSession().setAttribute("error", "Database error: " + e.getMessage());
                response.sendRedirect(request.getContextPath() + "/payment");
            }
            return;
        }

        String auctionIdParam = request.getParameter("auctionId");
        String supplierIdParam = request.getParameter("supplierId");
        String amountParam = request.getParameter("amount");
        
        // Basic validation
        if (auctionIdParam == null || supplierIdParam == null || amountParam == null) {
            if (action != null && action.equals("create")) {
                // Form submission - redirect back to payment list with error
                request.getSession().setAttribute("error", "Missing required parameters");
                response.sendRedirect(request.getContextPath() + "/payment");
            } else {
                // API call - send JSON error
                sendErrorResponse(response, "Missing required parameters");
            }
            return;
        }
        
        try {
            long auctionId = Long.parseLong(auctionIdParam);
            long supplierId = Long.parseLong(supplierIdParam);
            double amount = Double.parseDouble(amountParam);
            
            // Process the payment
            boolean success = markPaymentAsCompleted(auctionId, supplierId, amount);
            
            if (success) {
                // Check if this is a form submission
                if (action != null && action.equals("create")) {
                    // Redirect to payment list with success message
                    request.getSession().setAttribute("success", "Payment has been successfully created");
                    response.sendRedirect(request.getContextPath() + "/payment");
                } else {
                    // Return JSON response for API calls
                    Map<String, Object> result = new HashMap<String, Object>();
                    result.put("success", true);
                    result.put("message", "Payment processed successfully");
                    result.put("auctionId", auctionId);
                    result.put("supplierId", supplierId);
                    result.put("amount", amount);
                    
                    JSONObject json = new JSONObject(result);
                    response.setContentType("application/json");
                    response.getWriter().write(json.toString());
                }
            } else {
                if (action != null && action.equals("create")) {
                    // Redirect to payment list with error message
                    request.getSession().setAttribute("error", "Failed to create payment");
                    response.sendRedirect(request.getContextPath() + "/payment");
                } else {
                    // Send JSON error for API calls
                    sendErrorResponse(response, "Failed to process payment");
                }
            }
        } catch (NumberFormatException e) {
            sendErrorResponse(response, "Invalid parameter format");
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Database error while processing payment", e);
            sendErrorResponse(response, "Database error: " + e.getMessage());
        }
    }
    
    /**
     * Simple method to mark a payment as completed in the database
     */
    /**
     * Creates a payment record and marks it as completed
     */
    private boolean markPaymentAsCompleted(long auctionId, long supplierId, double amount) throws SQLException {
        // helper to detect column existence
        java.sql.Connection tmpConn = null;
        try {
            tmpConn = DatabaseConnection.getConnection();
        } catch (SQLException e) {
            // ignore here; real method will open its own connection
        } finally {
            if (tmpConn != null) tmpConn.close();
        }
        Connection conn = null;
        PreparedStatement stmt = null;
        boolean success = false;

        try {
            conn = DatabaseConnection.getConnection();
            conn.setAutoCommit(false);
            
            // Insert the payment record. Be defensive if payments.auction_id doesn't exist.
            boolean paymentsHasAuctionId = false;
            try (PreparedStatement colStmt = conn.prepareStatement(
                    "SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'payments' AND COLUMN_NAME = 'auction_id'")) {
                try (ResultSet rsCol = colStmt.executeQuery()) {
                    if (rsCol.next()) paymentsHasAuctionId = rsCol.getInt(1) > 0;
                }
            }

            if (paymentsHasAuctionId) {
                String sql = "INSERT INTO payments (auction_id, supplier_id, amount, status, payment_date) " +
                             "VALUES (?, ?, ?, 'COMPLETED', NOW())";
                stmt = conn.prepareStatement(sql);
                stmt.setLong(1, auctionId);
                stmt.setLong(2, supplierId);
                stmt.setDouble(3, amount);
            } else {
                String sql = "INSERT INTO payments (supplier_id, amount, status, payment_date) VALUES (?, ?, 'COMPLETED', NOW())";
                stmt = conn.prepareStatement(sql);
                stmt.setLong(1, supplierId);
                stmt.setDouble(2, amount);
            }

            int result = stmt.executeUpdate();
            stmt.close();
            
            // If payment was inserted successfully, just commit the transaction
            if (result > 0) {
                conn.commit();
                success = true;
            } else {
                conn.rollback();
            }
            
            return success;
        } catch (SQLException e) {
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ex) {
                    // Ignore rollback error
                }
            }
            throw e;
        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                } catch (SQLException e) {
                    // Ignore
                }
            }
            DatabaseConnection.closeQuietly(null, stmt, conn);
        }
    }
    

    
    /**
     * Helper method to send error responses
     */
    private void sendErrorResponse(HttpServletResponse response, String message) throws IOException {
        Map<String, Object> errorResponse = new HashMap<String, Object>();
        errorResponse.put("success", false);
        errorResponse.put("message", message);
        
        JSONObject json = new JSONObject(errorResponse);
        response.setContentType("application/json");
        response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
        response.getWriter().write(json.toString());
    }
    
    /**
     * Retrieves the list of auction winners for the payment page
     */
    private List<Map<String, Object>> getAuctionWinners() {
        List<Map<String, Object>> winners = new ArrayList<>();
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        
        try {
            conn = DatabaseConnection.getConnection();
            boolean paymentsHasAuctionId = false;
            try (PreparedStatement colStmt = conn.prepareStatement(
                    "SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'payments' AND COLUMN_NAME = 'auction_id'")) {
                try (ResultSet rsCol = colStmt.executeQuery()) {
                    if (rsCol.next()) paymentsHasAuctionId = rsCol.getInt(1) > 0;
                }
            }

            String sql;
            if (paymentsHasAuctionId) {
                sql = "SELECT a.id as auction_id, p.name as product_name, a.end_time, " +
                      "a.current_price as winning_amount, " +
                      "COALESCE(b.supplier_id, b.user_id) as supplier_id, s.name as supplier_name, " +
                      "(SELECT COUNT(*) FROM payments WHERE auction_id = a.id) > 0 as has_payment " +
                      "FROM reverse_auctions a " +
                      "JOIN products p ON a.product_id = p.id " +
                      "JOIN bids b ON b.auction_id = a.id " +
                      "JOIN suppliers s ON COALESCE(b.supplier_id, b.user_id) = s.id " +
                      "WHERE a.status = 'COMPLETED' " +
                      "ORDER BY b.amount ASC, a.end_time DESC";
            } else {
                // payments table lacks auction_id — return winners but mark has_payment = false
                sql = "SELECT a.id as auction_id, p.name as product_name, a.end_time, " +
                      "a.current_price as winning_amount, " +
                      "COALESCE(b.supplier_id, b.user_id) as supplier_id, s.name as supplier_name, " +
                      "FALSE as has_payment " +
                      "FROM reverse_auctions a " +
                      "JOIN products p ON a.product_id = p.id " +
                      "JOIN bids b ON b.auction_id = a.id " +
                      "JOIN suppliers s ON COALESCE(b.supplier_id, b.user_id) = s.id " +
                      "WHERE a.status = 'COMPLETED' " +
                      "ORDER BY b.amount ASC, a.end_time DESC";
            }
            
            stmt = conn.prepareStatement(sql);
            rs = stmt.executeQuery();
            
            while (rs.next()) {
                Map<String, Object> winner = new HashMap<>();
                winner.put("auctionId", rs.getLong("auction_id"));
                winner.put("productName", rs.getString("product_name"));
                winner.put("endTime", rs.getTimestamp("end_time"));
                double winningAmt = rs.getDouble("winning_amount");
                winner.put("winningAmount", winningAmt);
                // Also provide an `amount` key for JSP compatibility
                winner.put("amount", winningAmt);
                winner.put("supplierId", rs.getLong("supplier_id"));
                String sName = rs.getString("supplier_name");
                if (sName == null || sName.trim().isEmpty()) sName = "Unknown Supplier";
                winner.put("supplierName", sName);
                winner.put("hasPayment", rs.getBoolean("has_payment"));
                winners.add(winner);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error retrieving auction winners", e);
        } finally {
            DatabaseConnection.closeQuietly(rs, stmt, conn);
        }
        
        LOGGER.log(Level.INFO, "Retrieved " + winners.size() + " auction winners");
        return winners;
    }
    
    /**
     * Retrieves auction details by ID
     */
    private Map<String, Object> getAuctionDetails(long auctionId) throws SQLException {
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        
        try {
            conn = DatabaseConnection.getConnection();
            String sql = "SELECT a.id, a.product_id, p.name as product_name, p.unit, " +
                         "a.current_price as winning_amount, a.end_time " +
                         "FROM reverse_auctions a " +
                         "JOIN products p ON a.product_id = p.id " +
                         "WHERE a.id = ?";
            
            stmt = conn.prepareStatement(sql);
            stmt.setLong(1, auctionId);
            rs = stmt.executeQuery();
            
            if (rs.next()) {
                Map<String, Object> auction = new HashMap<>();
                auction.put("id", rs.getLong("id"));
                auction.put("product_id", rs.getLong("product_id"));
                auction.put("product_name", rs.getString("product_name"));
                auction.put("unit", rs.getString("unit"));
                auction.put("winning_amount", rs.getDouble("winning_amount"));
                auction.put("end_time", rs.getTimestamp("end_time"));
                return auction;
            }
            
            return null;
        } finally {
            DatabaseConnection.closeQuietly(rs, stmt, conn);
        }
    }
    
    /**
     * Retrieves supplier details by ID
     */
    private Map<String, Object> getSupplierDetails(long supplierId) throws SQLException {
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        
        try {
            conn = DatabaseConnection.getConnection();
            String sql = "SELECT id, name, email, phone, status " +
                         "FROM suppliers " +
                         "WHERE id = ?";
            
            stmt = conn.prepareStatement(sql);
            stmt.setLong(1, supplierId);
            rs = stmt.executeQuery();
            
            if (rs.next()) {
                Map<String, Object> supplier = new HashMap<>();
                supplier.put("id", rs.getLong("id"));
                supplier.put("name", rs.getString("name"));
                supplier.put("email", rs.getString("email"));
                supplier.put("phone", rs.getString("phone"));
                supplier.put("status", rs.getString("status"));
                return supplier;
            }
            
            return null;
        } finally {
            DatabaseConnection.closeQuietly(rs, stmt, conn);
        }
    }

    private Map<String, Object> getPaymentDetails(long paymentId) throws SQLException {
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        
        try {
            conn = DatabaseConnection.getConnection();
            boolean paymentsHasAuctionId = false;
            try (PreparedStatement colStmt = conn.prepareStatement(
                    "SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'payments' AND COLUMN_NAME = 'auction_id'")) {
                try (ResultSet rsCol = colStmt.executeQuery()) {
                    if (rsCol.next()) paymentsHasAuctionId = rsCol.getInt(1) > 0;
                }
            }

            StringBuilder sqlBuilder;
            if (paymentsHasAuctionId) {
                sqlBuilder = new StringBuilder("SELECT p.id, p.supplier_id, p.amount, p.status, p.auction_id, ");
                sqlBuilder.append("p.transaction_id, p.payment_method, p.payment_date, p.created_at, p.remarks, ");
                sqlBuilder.append("s.name as supplier_name ");
                sqlBuilder.append("FROM payments p ");
                sqlBuilder.append("LEFT JOIN suppliers s ON p.supplier_id = s.id ");
                sqlBuilder.append("WHERE p.id = ?");
            } else {
                sqlBuilder = new StringBuilder("SELECT p.id, po.supplier_id, p.amount, p.status, po.auction_id, ");
                sqlBuilder.append("p.transaction_id, p.payment_method, p.payment_date, p.created_at, p.remarks, ");
                sqlBuilder.append("s.name as supplier_name ");
                sqlBuilder.append("FROM payments p ");
                sqlBuilder.append("JOIN purchase_orders po ON p.po_id = po.id ");
                sqlBuilder.append("LEFT JOIN suppliers s ON po.supplier_id = s.id ");
                sqlBuilder.append("WHERE p.id = ?");
            }
            
            stmt = conn.prepareStatement(sqlBuilder.toString());
            stmt.setLong(1, paymentId);
            rs = stmt.executeQuery();
            
            if (rs.next()) {
                Map<String, Object> payment = new HashMap<>();
                payment.put("id", rs.getLong("id"));
                payment.put("supplierId", rs.getLong("supplier_id"));
                payment.put("amount", rs.getDouble("amount"));
                payment.put("status", rs.getString("status"));
                payment.put("auctionId", rs.getLong("auction_id"));
                payment.put("transactionId", rs.getString("transaction_id"));
                payment.put("paymentMethod", rs.getString("payment_method"));
                payment.put("paymentDate", rs.getTimestamp("payment_date"));
                payment.put("createdAt", rs.getTimestamp("created_at"));
                payment.put("supplierName", rs.getString("supplier_name"));
                payment.put("remarks", rs.getString("remarks"));
                return payment;
            }
            
            return null;
        } finally {
            DatabaseConnection.closeQuietly(rs, stmt, conn);
        }
    }

    private boolean markPaymentAsCompletedById(long paymentId) throws SQLException {
        Connection conn = null;
        PreparedStatement stmt = null;
        boolean success = false;

        try {
            conn = DatabaseConnection.getConnection();
            String sql = "UPDATE payments SET status = 'COMPLETED', payment_date = NOW() WHERE id = ?";
            stmt = conn.prepareStatement(sql);
            stmt.setLong(1, paymentId);

            int result = stmt.executeUpdate();
            success = (result > 0);
        } finally {
            DatabaseConnection.closeQuietly(null, stmt, conn);
        }
        return success;
    }
    
    private String toTitleCase(String input) {
        if (input == null || input.isEmpty()) {
            return input;
        }
        StringBuilder titleCase = new StringBuilder();
        boolean nextTitleCase = true;
        for (char c : input.toLowerCase().toCharArray()) {
            if (Character.isSpaceChar(c)) {
                nextTitleCase = true;
            } else if (nextTitleCase) {
                c = Character.toTitleCase(c);
                nextTitleCase = false;
            }
            titleCase.append(c);
        }
        return titleCase.toString();
    }
    
    /**
     * Retrieves the payment history from the database
     */
    private List<Map<String, Object>> getPaymentHistory(String statusFilter, String methodFilter, String dateFromFilter, String dateToFilter) {
        List<Map<String, Object>> payments = new ArrayList<>();
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        
        try {
            conn = DatabaseConnection.getConnection();
            
            boolean paymentsHasAuctionId = false;
            try (PreparedStatement colStmt = conn.prepareStatement(
                    "SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'payments' AND COLUMN_NAME = 'auction_id'")) {
                try (ResultSet rsCol = colStmt.executeQuery()) {
                    if (rsCol.next()) paymentsHasAuctionId = rsCol.getInt(1) > 0;
                }
            }

            StringBuilder sqlBuilder;
            if (paymentsHasAuctionId) {
                sqlBuilder = new StringBuilder("SELECT p.id, p.supplier_id, p.amount, p.status, p.auction_id, ");
                sqlBuilder.append("p.transaction_id, p.payment_method, p.payment_date, p.created_at, ");
                sqlBuilder.append("s.name as supplier_name ");
                sqlBuilder.append("FROM payments p ");
                sqlBuilder.append("LEFT JOIN suppliers s ON p.supplier_id = s.id ");
            } else {
                sqlBuilder = new StringBuilder("SELECT p.id, po.supplier_id, p.amount, p.status, po.auction_id, ");
                sqlBuilder.append("p.transaction_id, p.payment_method, p.payment_date, p.created_at, ");
                sqlBuilder.append("s.name as supplier_name ");
                sqlBuilder.append("FROM payments p ");
                sqlBuilder.append("JOIN purchase_orders po ON p.po_id = po.id ");
                sqlBuilder.append("LEFT JOIN suppliers s ON po.supplier_id = s.id ");
            }
            
            List<Object> params = new ArrayList<>();
            StringBuilder whereClause = new StringBuilder();
            
            if (statusFilter != null && !statusFilter.isEmpty()) {
                whereClause.append("p.status = ? ");
                params.add(statusFilter);
            }
            
            if (methodFilter != null && !methodFilter.isEmpty()) {
                if (whereClause.length() > 0) whereClause.append("AND ");
                whereClause.append("p.payment_method = ? ");
                params.add(methodFilter);
            }
            
            if (dateFromFilter != null && !dateFromFilter.isEmpty()) {
                if (whereClause.length() > 0) whereClause.append("AND ");
                whereClause.append("p.payment_date >= ? ");
                params.add(dateFromFilter);
            }
            
            if (dateToFilter != null && !dateToFilter.isEmpty()) {
                if (whereClause.length() > 0) whereClause.append("AND ");
                whereClause.append("p.payment_date <= ? ");
                params.add(dateToFilter);
            }
            
            if (whereClause.length() > 0) {
                sqlBuilder.append("WHERE ").append(whereClause);
            }
            
            sqlBuilder.append("ORDER BY p.created_at DESC");
            
            stmt = conn.prepareStatement(sqlBuilder.toString());
            
            for (int i = 0; i < params.size(); i++) {
                stmt.setObject(i + 1, params.get(i));
            }
            
            rs = stmt.executeQuery();
            
            int recordCount = 0;
            while (rs.next()) {
                recordCount++;
                Map<String, Object> payment = new HashMap<>();
                payment.put("id", rs.getLong("id"));
                payment.put("supplierId", rs.getLong("supplier_id"));
                payment.put("amount", rs.getDouble("amount"));
                payment.put("status", rs.getString("status"));
                payment.put("auctionId", rs.getLong("auction_id"));
                payment.put("transactionId", rs.getString("transaction_id"));
                String paymentMethodRaw = rs.getString("payment_method");
                String paymentMethod = paymentMethodRaw != null ? toTitleCase(paymentMethodRaw.replace("_", " ")) : "N/A";
                payment.put("paymentMethod", paymentMethod);
                payment.put("paymentDate", rs.getTimestamp("payment_date"));
                payment.put("createdAt", rs.getTimestamp("created_at"));
                payment.put("supplierName", rs.getString("supplier_name"));
                payments.add(payment);
            }
            LOGGER.log(Level.INFO, "Retrieved " + recordCount + " payment records from history");
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error retrieving payment history: " + e.getMessage(), e);
        } finally {
            DatabaseConnection.closeQuietly(rs, stmt, conn);
        }
        
        return payments;
    }
}
