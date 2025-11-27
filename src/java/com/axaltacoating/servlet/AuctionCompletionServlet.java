package com.axaltacoating.servlet;

import com.axaltacoating.util.DatabaseConnection;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * Servlet for handling auction completion and inventory updates.
 */
@WebServlet(name = "AuctionCompletionServlet", urlPatterns = {"/auction-completion"})
public class AuctionCompletionServlet extends HttpServlet {
    
    private static final Logger LOGGER = Logger.getLogger(AuctionCompletionServlet.class.getName());

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String action = request.getParameter("action");
        
        switch (action) {
            case "completeAuction":
                completeAuction(request, response);
                break;
            case "markDelivered":
                markDelivered(request, response);
                break;
            case "checkCompletedAuctions":
                checkCompletedAuctions(request, response);
                break;
            default:
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid action");
                break;
        }
    }

    /**
     * Checks whether a table has the specified column.
     */
    private boolean columnExists(Connection conn, String tableName, String columnName) {
        try {
            java.sql.DatabaseMetaData md = conn.getMetaData();
            try (ResultSet cols = md.getColumns(null, null, tableName, columnName)) {
                return cols.next();
            }
        } catch (SQLException e) {
            LOGGER.log(Level.FINE, "Error checking column existence " + tableName + "." + columnName + ": " + e.getMessage());
            return false;
        }
    }

    /**
     * Checks whether an ENUM column contains a given value. Returns true if the value is allowed.
     */
    private boolean enumAllows(Connection conn, String tableName, String columnName, String value) {
        try (PreparedStatement s = conn.prepareStatement(
                "SELECT COLUMN_TYPE FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = ? AND COLUMN_NAME = ?")) {
            s.setString(1, tableName);
            s.setString(2, columnName);
            try (ResultSet rs = s.executeQuery()) {
                if (rs.next()) {
                    String columnType = rs.getString(1); // e.g. enum('PENDING','SENT')
                    if (columnType != null && columnType.toUpperCase().contains("ENUM")) {
                        // crude parse: look for 'VALUE' occurrences
                        String up = columnType.toUpperCase();
                        return up.contains("'" + value.toUpperCase() + "'") || up.contains("\"" + value.toUpperCase() + "\"");
                    }
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.FINE, "Error checking enum values for " + tableName + "." + columnName + ": " + e.getMessage());
        }
        return false;
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String action = request.getParameter("action");
        
        if ("checkCompletedAuctions".equals(action)) {
            checkCompletedAuctions(request, response);
        } else {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid action");
        }
    }

    /**
     * Completes an auction and determines the winning bid.
     */
    private void completeAuction(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String auctionIdParam = request.getParameter("auctionId");
        
        if (auctionIdParam == null || auctionIdParam.isEmpty()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"success\": false, \"message\": \"Auction ID is required\"}");
            return;
        }
        
        long auctionId = Long.parseLong(auctionIdParam);
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        
        try {
            conn = DatabaseConnection.getConnection();
            conn.setAutoCommit(false);
            LOGGER.info("Starting completeAuction for auctionId=" + auctionId);
            // Get the winning bid (lowest amount) — use COALESCE to handle both column naming schemes
            stmt = conn.prepareStatement(
                "SELECT b.*, s.name as supplier_name, s.email as supplier_email, " +
                "COALESCE(b.supplier_id, b.user_id) as winning_supplier_id, " +
                "b.amount as winning_amount " +
                "FROM bids b " +
                "JOIN suppliers s ON COALESCE(b.supplier_id, b.user_id) = s.id " +
                "WHERE b.auction_id = ? " +
                "ORDER BY b.amount ASC, b.bid_time ASC " +
                "LIMIT 1"
            );
            stmt.setLong(1, auctionId);
            rs = stmt.executeQuery();
            LOGGER.info("Executed winning bid query for auctionId=" + auctionId);
            if (rs.next()) {
                long winningSupplierId = rs.getLong("winning_supplier_id");
                double winningAmount = rs.getDouble("winning_amount");
                String supplierName = rs.getString("supplier_name");
                String supplierEmail = rs.getString("supplier_email");
                LOGGER.info("Winning supplier: " + winningSupplierId + ", amount: " + winningAmount);
                if (supplierName == null || supplierName.trim().isEmpty()) {
                    supplierName = "Unknown Supplier";
                    LOGGER.warning("Winning supplier name is null or empty for auction " + auctionId + ". Using 'Unknown Supplier'.");
                }
                if (supplierEmail == null || supplierEmail.trim().isEmpty()) {
                    supplierEmail = "unknown@example.com";
                    LOGGER.warning("Winning supplier email is null or empty for auction " + auctionId + ". Using 'unknown@example.com'.");
                }
                // No company name column, use supplierName for PO
                String supplierCompanyName = supplierName;
                // Get material (product) name, product_id, and quantity from auction
                String materialName = null;
                long productId = -1;
                int poQuantity = 1;
                String productUnit = null;
                stmt = conn.prepareStatement(
                    "SELECT p.id as product_id, p.name as product_name, p.unit as unit, ra.required_quantity as auction_quantity " +
                    "FROM reverse_auctions ra " +
                    "JOIN products p ON ra.product_id = p.id " +
                    "WHERE ra.id = ?"
                );
                stmt.setLong(1, auctionId);
                ResultSet rsProduct = stmt.executeQuery();
                if (rsProduct.next()) {
                    productId = rsProduct.getLong("product_id");
                    materialName = rsProduct.getString("product_name");
                    poQuantity = rsProduct.getInt("auction_quantity");
                    productUnit = rsProduct.getString("unit");
                    LOGGER.info("Product found: " + productId + ", name: " + materialName + ", quantity: " + poQuantity);
                } else {
                    materialName = "Unknown";
                    LOGGER.warning("No product found for auction " + auctionId);
                }
                rsProduct.close();
                // Safety: If poQuantity is zero or less, fetch from reverse_auctions directly
                if (poQuantity <= 0) {
                    stmt = conn.prepareStatement("SELECT required_quantity FROM reverse_auctions WHERE id = ?");
                    stmt.setLong(1, auctionId);
                    ResultSet rsQty = stmt.executeQuery();
                    if (rsQty.next()) {
                        poQuantity = rsQty.getInt("required_quantity");
                        LOGGER.info("Fetched required_quantity from reverse_auctions: " + poQuantity);
                    }
                    rsQty.close();
                }
                // Update auction status to COMPLETED and set winning details
                stmt = conn.prepareStatement(
                    "UPDATE reverse_auctions " +
                    "SET status = 'COMPLETED', current_price = ?, winning_supplier_id = ? " +
                    "WHERE id = ?"
                );
                stmt.setDouble(1, winningAmount);
                stmt.setLong(2, winningSupplierId);
                stmt.setLong(3, auctionId);
                stmt.executeUpdate();
                LOGGER.info("Updated reverse_auctions status to COMPLETED for auctionId=" + auctionId);
                // Create a delivery record
                stmt = conn.prepareStatement(
                    "INSERT INTO auction_deliveries (auction_id, supplier_id, winning_amount, status, created_at) " +
                    "VALUES (?, ?, ?, 'PENDING', NOW())"
                );
                stmt.setLong(1, auctionId);
                stmt.setLong(2, winningSupplierId);
                stmt.setDouble(3, winningAmount);
                stmt.executeUpdate();
                LOGGER.info("Inserted auction_deliveries record for auctionId=" + auctionId);
                // Generate next PO number
                long nextPONumber = 1;
                PreparedStatement poNumStmt = conn.prepareStatement("SELECT MAX(po_number) FROM purchase_orders");
                ResultSet poNumRs = poNumStmt.executeQuery();
                if (poNumRs.next()) {
                    long maxPONum = poNumRs.getLong(1);
                    if (!poNumRs.wasNull()) {
                        nextPONumber = maxPONum + 1;
                    }
                }
                poNumRs.close();
                poNumStmt.close();
                LOGGER.info("Next PO number: " + nextPONumber);
                // Get supplier email
                stmt = conn.prepareStatement("SELECT email FROM suppliers WHERE id = ?");
                stmt.setLong(1, winningSupplierId);
                ResultSet rsEmail = stmt.executeQuery();
                if (rsEmail.next()) {
                    supplierEmail = rsEmail.getString("email");
                }
                rsEmail.close();
                if (supplierEmail == null || supplierEmail.trim().isEmpty()) {
                    supplierEmail = "unknown@example.com";
                    LOGGER.warning("Winning supplier email is null or empty for auction " + auctionId + ". Using 'unknown@example.com'.");
                }
                // Calculate unit price
                // double unitPrice = (poQuantity > 0) ? (winningAmount / poQuantity) : 0.0;
                // Calculate total_amount (for clarity, use winningAmount)
                // double totalAmount = winningAmount;
                // Insert a purchase order for the winning supplier
                // Provide required NOT NULL fields in purchase_orders schema
                // Prepare PO values
                String poNumberStr = String.valueOf(nextPONumber);
                int quantity = (poQuantity > 0) ? poQuantity : 1;
                double unitPrice = (quantity > 0) ? (winningAmount / quantity) : winningAmount;
                double totalAmount = unitPrice * quantity;
                double taxAmount = 0.0;
                double grandTotal = totalAmount + taxAmount;

                stmt = conn.prepareStatement(
                    "INSERT INTO purchase_orders (auction_id, supplier_id, product_id, po_number, supplier_name, supplier_email, product_name, quantity, unit, unit_price, total_amount, tax_amount, grand_total, status, created_at, company_name, material, amount) " +
                    "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'PENDING', NOW(), ?, ?, ?)"
                );
                stmt.setLong(1, auctionId);
                stmt.setLong(2, winningSupplierId);
                stmt.setLong(3, productId);
                stmt.setString(4, poNumberStr);
                stmt.setString(5, supplierCompanyName);
                stmt.setString(6, supplierEmail != null ? supplierEmail : "");
                stmt.setString(7, materialName);
                stmt.setInt(8, quantity);
                // set unit (may be null)
                stmt.setString(9, productUnit);
                stmt.setDouble(10, unitPrice);
                stmt.setDouble(11, totalAmount);
                stmt.setDouble(12, taxAmount);
                stmt.setDouble(13, grandTotal);
                stmt.setString(14, supplierCompanyName);
                stmt.setString(15, materialName);
                stmt.setDouble(16, winningAmount);
                stmt.executeUpdate();
                LOGGER.info("Inserted purchase_order for auctionId=" + auctionId);
                conn.commit();
                LOGGER.info("Transaction committed for auctionId=" + auctionId);
                LOGGER.log(Level.INFO, "Auction {0} completed. Winner: {1} with amount: {2}", 
                    new Object[]{auctionId, supplierName, winningAmount});
                response.setContentType("application/json");
                response.getWriter().write(String.format(
                    "{\"success\": true, \"message\": \"Auction completed successfully. Winner: %s with amount: %.2f\", \"winnerId\": %d, \"winningAmount\": %.2f}",
                    supplierName, winningAmount, winningSupplierId, winningAmount
                ));
            } else {
                LOGGER.warning("No bids found for auction " + auctionId);
                conn.rollback();
                response.setContentType("application/json");
                response.getWriter().write("{\"success\": false, \"message\": \"No bids found for this auction\"}");
            }
        } catch (SQLException e) {
            try {
                if (conn != null) conn.rollback();
            } catch (SQLException ex) {
                LOGGER.log(Level.SEVERE, "Error rolling back transaction", ex);
            }
            LOGGER.log(Level.SEVERE, "Error completing auction", e);
            response.setContentType("application/json");
            response.getWriter().write("{\"success\": false, \"message\": \"Error completing auction: " + e.getMessage() + "\"}");
        } catch (Exception e) {
            try {
                if (conn != null) conn.rollback();
            } catch (SQLException ex) {
                LOGGER.log(Level.SEVERE, "Error rolling back transaction", ex);
            }
            LOGGER.log(Level.SEVERE, "Unexpected error in completeAuction", e);
            response.setContentType("application/json");
            response.getWriter().write("{\"success\": false, \"message\": \"Unexpected error: " + e.getMessage() + "\"}");
        } finally {
            try {
                if (rs != null) rs.close();
                if (stmt != null) stmt.close();
                if (conn != null) {
                    conn.setAutoCommit(true);
                    conn.close();
                }
            } catch (SQLException e) {
                LOGGER.log(Level.SEVERE, "Error closing database resources", e);
            }
        }
    }

    /**
     * Marks an auction delivery as completed and updates inventory.
     */
    private void markDelivered(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String auctionIdParam = request.getParameter("auctionId");
        String quantityParam = request.getParameter("quantity");
        
        if (auctionIdParam == null || auctionIdParam.isEmpty() || 
            quantityParam == null || quantityParam.isEmpty()) {
            response.setContentType("application/json");
            response.getWriter().write("{\"success\": false, \"message\": \"Auction ID and quantity are required\"}");
            return;
        }
        
        long auctionId = Long.parseLong(auctionIdParam);
        int deliveredQuantity = Integer.parseInt(quantityParam);
        
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        
        try {
            conn = DatabaseConnection.getConnection();
            conn.setAutoCommit(false);
            
            // Get auction and product details. Be defensive: some DBs may not have auction_id on auction_deliveries.
            boolean adHasAuctionId = columnExists(conn, "auction_deliveries", "auction_id");
            long supplierId = -1;
            long productId = -1;
            String productName = "Unknown";
            Long inventoryId = null;
            boolean pendingFound = false;

            if (adHasAuctionId) {
                stmt = conn.prepareStatement(
                    "SELECT ra.product_id, p.name as product_name, p.inventory_id, ad.supplier_id " +
                    "FROM reverse_auctions ra " +
                    "JOIN products p ON ra.product_id = p.id " +
                    "JOIN auction_deliveries ad ON ra.id = ad.auction_id " +
                    "WHERE ra.id = ? AND ad.status = 'PENDING'"
                );
                stmt.setLong(1, auctionId);
                rs = stmt.executeQuery();
                if (rs.next()) {
                    productId = rs.getLong("product_id");
                    productName = rs.getString("product_name");
                    inventoryId = rs.getLong("inventory_id");
                    supplierId = rs.getLong("supplier_id");
                    pendingFound = true;
                }
                if (rs != null) { rs.close(); }
                if (stmt != null) { stmt.close(); }
            } else {
                // Fallback: fetch product info from reverse_auctions joined to products only
                LOGGER.log(Level.WARNING, "Table auction_deliveries has no column auction_id; skipping JOIN with auction_deliveries.");
                stmt = conn.prepareStatement(
                    "SELECT ra.product_id, p.name as product_name, p.inventory_id " +
                    "FROM reverse_auctions ra " +
                    "JOIN products p ON ra.product_id = p.id " +
                    "WHERE ra.id = ?"
                );
                stmt.setLong(1, auctionId);
                rs = stmt.executeQuery();
                if (rs.next()) {
                    productId = rs.getLong("product_id");
                    productName = rs.getString("product_name");
                    inventoryId = rs.getLong("inventory_id");
                    pendingFound = true;
                }
                if (rs != null) { rs.close(); }
                if (stmt != null) { stmt.close(); }
            }
            
            // Only proceed if we found a pending delivery/auction row
            if (pendingFound) {
                // Update inventory if inventory_id exists
                if (inventoryId != null && inventoryId > 0) {
                    String sqlUpdateInventory = "UPDATE inventory SET quantity = quantity + ?, updated_at = NOW() WHERE id = ?";
                    try {
                        stmt = conn.prepareStatement(sqlUpdateInventory);
                        stmt.setInt(1, deliveredQuantity);
                        stmt.setLong(2, inventoryId);
                        int inventoryUpdated = stmt.executeUpdate();
                        stmt.close();

                        if (inventoryUpdated > 0) {
                            // Update kanban status based on new quantity
                            String sqlUpdateKanban =
                                "UPDATE inventory " +
                                "SET kanban_status = CASE " +
                                "    WHEN quantity <= min_threshold THEN 'Low' " +
                                "    WHEN quantity >= max_threshold THEN 'High' " +
                                "    ELSE 'Medium' " +
                                "END, " +
                                "needs_auction = (quantity <= min_threshold), " +
                                "auction_started = FALSE " +
                                "WHERE id = ?";
                            try {
                                stmt = conn.prepareStatement(sqlUpdateKanban);
                                stmt.setLong(1, inventoryId);
                                stmt.executeUpdate();
                                stmt.close();
                            } catch (SQLException kanEx) {
                                LOGGER.log(Level.WARNING, "Failed kanban update (sql=" + sqlUpdateKanban + "): " + kanEx.getMessage());
                            }
                        }
                    } catch (SQLException invEx) {
                        LOGGER.log(Level.WARNING, "Failed inventory update (sql=" + sqlUpdateInventory + "): " + invEx.getMessage());
                    }
                }
                
                // Update product stock quantity
                String sqlUpdateProduct = "UPDATE products SET stock_quantity = COALESCE(stock_quantity,0) + ? WHERE id = ?";
                try {
                    stmt = conn.prepareStatement(sqlUpdateProduct);
                    stmt.setInt(1, deliveredQuantity);
                    stmt.setLong(2, productId);
                    stmt.executeUpdate();
                    stmt.close();
                } catch (SQLException prodEx) {
                    LOGGER.log(Level.WARNING, "Failed product stock update (sql=" + sqlUpdateProduct + "): " + prodEx.getMessage());
                }
                
                // Mark delivery as completed in auction_deliveries (only if column exists)
                if (columnExists(conn, "auction_deliveries", "auction_id")) {
                    String sqlUpdateDelivery = "UPDATE auction_deliveries SET status = 'DELIVERED', delivered_quantity = ?, delivery_date = NOW() WHERE auction_id = ?";
                    try {
                        stmt = conn.prepareStatement(sqlUpdateDelivery);
                        stmt.setInt(1, deliveredQuantity);
                        stmt.setLong(2, auctionId);
                        stmt.executeUpdate();
                        stmt.close();
                    } catch (SQLException updAdEx) {
                        LOGGER.log(Level.WARNING, "Failed to update auction_deliveries (sql=" + sqlUpdateDelivery + "): " + updAdEx.getMessage());
                    }
                } else {
                    LOGGER.log(Level.WARNING, "Skipping update of auction_deliveries: column auction_id not present");
                }

                // Update auction status to DELIVERED if the column allows that enum value
                if (enumAllows(conn, "reverse_auctions", "status", "DELIVERED")) {
                    String sqlUpdateAuction = "UPDATE reverse_auctions SET status = 'DELIVERED' WHERE id = ?";
                    try {
                        stmt = conn.prepareStatement(sqlUpdateAuction);
                        stmt.setLong(1, auctionId);
                        stmt.executeUpdate();
                        stmt.close();
                    } catch (SQLException updRaEx) {
                        LOGGER.log(Level.WARNING, "Failed to update reverse_auctions (sql=" + sqlUpdateAuction + "): " + updRaEx.getMessage());
                    }
                } else {
                    LOGGER.log(Level.WARNING, "Skipping update of reverse_auctions.status to 'DELIVERED' because the enum does not allow it");
                }

                // Create a payment record for this auction if one does not already exist
                boolean paymentsHasAuctionId = columnExists(conn, "payments", "auction_id");
                boolean hasPayment = false;
                if (paymentsHasAuctionId) {
                    PreparedStatement checkPaymentStmt = conn.prepareStatement(
                        "SELECT COUNT(*) FROM payments WHERE auction_id = ?"
                    );
                    checkPaymentStmt.setLong(1, auctionId);
                    ResultSet paymentRs = checkPaymentStmt.executeQuery();
                    if (paymentRs.next()) {
                        hasPayment = paymentRs.getInt(1) > 0;
                    }
                    paymentRs.close();
                    checkPaymentStmt.close();
                } else {
                    LOGGER.log(Level.WARNING, "payments.auction_id column missing; will attempt fallback payment insert without auction_id");
                }

                if (!hasPayment && paymentsHasAuctionId) {
                    // Determine payment amount: prefer purchase_orders.grand_total if available, else use auction current price
                    double paymentAmount = 0.0;
                    if (columnExists(conn, "purchase_orders", "auction_id")) {
                        PreparedStatement poStmt = conn.prepareStatement(
                            "SELECT grand_total, total_amount, amount FROM purchase_orders WHERE auction_id = ? ORDER BY created_at DESC LIMIT 1"
                        );
                        poStmt.setLong(1, auctionId);
                        ResultSet poRs = poStmt.executeQuery();
                        if (poRs.next()) {
                            paymentAmount = poRs.getDouble("grand_total");
                            if (poRs.wasNull() || paymentAmount == 0.0) {
                                paymentAmount = poRs.getDouble("total_amount");
                            }
                            if (poRs.wasNull() || paymentAmount == 0.0) {
                                paymentAmount = poRs.getDouble("amount");
                            }
                        }
                        poRs.close();
                        poStmt.close();
                    }

                    // If we still don't have an amount, fall back to auction current_price
                    if (paymentAmount <= 0.0) {
                        PreparedStatement auctionPriceStmt = conn.prepareStatement(
                            "SELECT current_price FROM reverse_auctions WHERE id = ?"
                        );
                        auctionPriceStmt.setLong(1, auctionId);
                        ResultSet apRs = auctionPriceStmt.executeQuery();
                        if (apRs.next()) {
                            paymentAmount = apRs.getDouble("current_price");
                        }
                        apRs.close();
                        auctionPriceStmt.close();
                    }

                    try {
                        PreparedStatement insertPaymentStmt = conn.prepareStatement(
                            "INSERT INTO payments (auction_id, supplier_id, amount, status, payment_method, created_at) VALUES (?, ?, ?, 'PENDING', 'NOT_SELECTED', NOW())"
                        );
                        insertPaymentStmt.setLong(1, auctionId);
                        insertPaymentStmt.setLong(2, supplierId);
                        insertPaymentStmt.setDouble(3, paymentAmount);
                        insertPaymentStmt.executeUpdate();
                        insertPaymentStmt.close();
                    } catch (SQLException payEx) {
                        // Don't fail the entire delivery flow if payments table/schema is missing or INSERT fails
                        LOGGER.log(Level.WARNING, "Failed to insert payment for auction " + auctionId + ": " + payEx.getMessage());
                    }
                } else if (!hasPayment && !paymentsHasAuctionId) {
                    // Fallback: insert a payment without auction_id column if table schema is older
                    double paymentAmount = 0.0;
                    if (columnExists(conn, "purchase_orders", "auction_id")) {
                        PreparedStatement poStmt = conn.prepareStatement(
                            "SELECT grand_total, total_amount, amount FROM purchase_orders WHERE auction_id = ? ORDER BY created_at DESC LIMIT 1"
                        );
                        poStmt.setLong(1, auctionId);
                        ResultSet poRs = poStmt.executeQuery();
                        if (poRs.next()) {
                            paymentAmount = poRs.getDouble("grand_total");
                            if (poRs.wasNull() || paymentAmount == 0.0) {
                                paymentAmount = poRs.getDouble("total_amount");
                            }
                            if (poRs.wasNull() || paymentAmount == 0.0) {
                                paymentAmount = poRs.getDouble("amount");
                            }
                        }
                        poRs.close();
                        poStmt.close();
                    }

                    if (paymentAmount <= 0.0) {
                        PreparedStatement auctionPriceStmt = conn.prepareStatement(
                            "SELECT current_price FROM reverse_auctions WHERE id = ?"
                        );
                        auctionPriceStmt.setLong(1, auctionId);
                        ResultSet apRs = auctionPriceStmt.executeQuery();
                        if (apRs.next()) {
                            paymentAmount = apRs.getDouble("current_price");
                        }
                        apRs.close();
                        auctionPriceStmt.close();
                    }

                    try {
                        // Insert without auction_id column (older schema)
                        PreparedStatement insertPaymentFallback = conn.prepareStatement(
                            "INSERT INTO payments (supplier_id, amount, status, payment_method, created_at) VALUES (?, ?, 'PENDING', 'NOT_SELECTED', NOW())"
                        );
                        insertPaymentFallback.setLong(1, supplierId);
                        insertPaymentFallback.setDouble(2, paymentAmount);
                        insertPaymentFallback.executeUpdate();
                        insertPaymentFallback.close();
                    } catch (SQLException payEx) {
                        LOGGER.log(Level.WARNING, "Fallback insert into payments failed for auction " + auctionId + ": " + payEx.getMessage());
                    }
                }

                // Update related purchase order status to DELIVERED if present
                // Wrapped in try-catch to avoid failing the entire delivery if PO table schema differs
                try {
                    PreparedStatement updatePOStatus = conn.prepareStatement(
                        "UPDATE purchase_orders SET status = 'DELIVERED' WHERE auction_id = ?"
                    );
                    updatePOStatus.setLong(1, auctionId);
                    updatePOStatus.executeUpdate();
                    updatePOStatus.close();
                } catch (SQLException poEx) {
                    // Log but don't fail the entire delivery flow if purchase order update fails
                    LOGGER.log(Level.WARNING, "Could not update purchase_orders for auction " + auctionId + ": " + poEx.getMessage());
                }

                conn.commit();
                
                LOGGER.log(Level.INFO, "Delivery completed for auction {0}. Added {1} units of {2} to inventory", 
                    new Object[]{auctionId, deliveredQuantity, productName});
                
                response.setContentType("application/json");
                response.getWriter().write(String.format(
                    "{\"success\": true, \"message\": \"Delivery marked as completed. Added %d units of %s to inventory\"}",
                    deliveredQuantity, productName
                ));
            } else {
                conn.rollback();
                response.setContentType("application/json");
                response.getWriter().write("{\"success\": false, \"message\": \"No pending delivery found for this auction\"}");
            }
            
        } catch (SQLException e) {
            try {
                if (conn != null) conn.rollback();
            } catch (SQLException ex) {
                LOGGER.log(Level.SEVERE, "Error rolling back transaction", ex);
            }
            
            LOGGER.log(Level.SEVERE, "Error marking delivery as completed", e);
            response.setContentType("application/json");
            response.getWriter().write("{\"success\": false, \"message\": \"Error updating delivery: " + e.getMessage() + "\"}");
            
        } finally {
            try {
                if (rs != null) rs.close();
                if (stmt != null) stmt.close();
                if (conn != null) {
                    conn.setAutoCommit(true);
                    conn.close();
                }
            } catch (SQLException e) {
                LOGGER.log(Level.SEVERE, "Error closing database resources", e);
            }
        }
    }

    /**
     * Checks for auctions that have ended and automatically completes them.
     */
    private void checkCompletedAuctions(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        
        try {
            conn = DatabaseConnection.getConnection();
            
            // Find auctions that have ended but are still marked as ACTIVE
            stmt = conn.prepareStatement(
                "SELECT id FROM reverse_auctions " +
                "WHERE status = 'ACTIVE' AND end_time < NOW()"
            );
            rs = stmt.executeQuery();
            
            int completedCount = 0;
            while (rs.next()) {
                long auctionId = rs.getLong("id");
                
                // Complete each auction
                MockHttpServletRequest mockRequest = new MockHttpServletRequest();
                mockRequest.setParameter("auctionId", String.valueOf(auctionId));
                
                MockHttpServletResponse mockResponse = new MockHttpServletResponse();
                completeAuction(mockRequest, mockResponse);
                
                completedCount++;
            }
            
            response.setContentType("application/json");
            response.getWriter().write(String.format(
                "{\"success\": true, \"message\": \"Checked and completed %d auctions\", \"completedCount\": %d}",
                completedCount, completedCount
            ));
            
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error checking completed auctions", e);
            response.setContentType("application/json");
            response.getWriter().write("{\"success\": false, \"message\": \"Error checking auctions: " + e.getMessage() + "\"}");
            
        } finally {
            try {
                if (rs != null) rs.close();
                if (stmt != null) stmt.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                LOGGER.log(Level.SEVERE, "Error closing database resources", e);
            }
        }
    }

    // Mock classes for internal method calls
    private static class MockHttpServletRequest implements HttpServletRequest {
        private java.util.Map<String, String> parameters = new java.util.HashMap<>();
        
        public void setParameter(String name, String value) {
            parameters.put(name, value);
        }
        
        @Override
        public String getParameter(String name) {
            return parameters.get(name);
        }
        
        // Implement other required methods with default/empty implementations
        @Override public String getAuthType() { return null; }
        @Override public javax.servlet.http.Cookie[] getCookies() { return null; }
        @Override public long getDateHeader(String name) { return 0; }
        @Override public String getHeader(String name) { return null; }
        @Override public java.util.Enumeration<String> getHeaders(String name) { return null; }
        @Override public java.util.Enumeration<String> getHeaderNames() { return null; }
        @Override public int getIntHeader(String name) { return 0; }
        @Override public String getMethod() { return null; }
        @Override public String getPathInfo() { return null; }
        @Override public String getPathTranslated() { return null; }
        @Override public String getContextPath() { return null; }
        @Override public String getQueryString() { return null; }
        @Override public String getRemoteUser() { return null; }
        @Override public boolean isUserInRole(String role) { return false; }
        @Override public java.security.Principal getUserPrincipal() { return null; }
        @Override public String getRequestedSessionId() { return null; }
        @Override public String getRequestURI() { return null; }
        @Override public StringBuffer getRequestURL() { return null; }
        @Override public String getServletPath() { return null; }
        @Override public javax.servlet.http.HttpSession getSession(boolean create) { return null; }
        @Override public javax.servlet.http.HttpSession getSession() { return null; }
        @Override public String changeSessionId() { return null; }
        @Override public boolean isRequestedSessionIdValid() { return false; }
        @Override public boolean isRequestedSessionIdFromCookie() { return false; }
        @Override public boolean isRequestedSessionIdFromURL() { return false; }
        @Override public boolean isRequestedSessionIdFromUrl() { return false; }
        @Override public boolean authenticate(HttpServletResponse response) { return false; }
        @Override public void login(String username, String password) {}
        @Override public void logout() {}
        @Override public java.util.Collection<javax.servlet.http.Part> getParts() { return null; }
        @Override public javax.servlet.http.Part getPart(String name) { return null; }
        @Override public <T extends javax.servlet.http.HttpUpgradeHandler> T upgrade(Class<T> handlerClass) { return null; }
        @Override public Object getAttribute(String name) { return null; }
        @Override public java.util.Enumeration<String> getAttributeNames() { return null; }
        @Override public String getCharacterEncoding() { return null; }
        @Override public void setCharacterEncoding(String env) {}
        @Override public int getContentLength() { return 0; }
        @Override public long getContentLengthLong() { return 0; }
        @Override public String getContentType() { return null; }
        @Override public javax.servlet.ServletInputStream getInputStream() { return null; }
        @Override public String[] getParameterValues(String name) { return null; }
        @Override public java.util.Map<String, String[]> getParameterMap() { return null; }
        @Override public java.util.Enumeration<String> getParameterNames() { return null; }
        @Override public String getProtocol() { return null; }
        @Override public String getScheme() { return null; }
        @Override public String getServerName() { return null; }
        @Override public int getServerPort() { return 0; }
        @Override public java.io.BufferedReader getReader() { return null; }
        @Override public String getRemoteAddr() { return null; }
        @Override public String getRemoteHost() { return null; }
        @Override public void setAttribute(String name, Object o) {}
        @Override public void removeAttribute(String name) {}
        @Override public java.util.Locale getLocale() { return null; }
        @Override public java.util.Enumeration<java.util.Locale> getLocales() { return null; }
        @Override public boolean isSecure() { return false; }
        @Override public javax.servlet.RequestDispatcher getRequestDispatcher(String path) { return null; }
        @Override public String getRealPath(String path) { return null; }
        @Override public int getRemotePort() { return 0; }
        @Override public String getLocalName() { return null; }
        @Override public String getLocalAddr() { return null; }
        @Override public int getLocalPort() { return 0; }
        @Override public javax.servlet.ServletContext getServletContext() { return null; }
        @Override public javax.servlet.AsyncContext startAsync() { return null; }
        @Override public javax.servlet.AsyncContext startAsync(javax.servlet.ServletRequest servletRequest, javax.servlet.ServletResponse servletResponse) { return null; }
        @Override public boolean isAsyncStarted() { return false; }
        @Override public boolean isAsyncSupported() { return false; }
        @Override public javax.servlet.AsyncContext getAsyncContext() { return null; }
        @Override public javax.servlet.DispatcherType getDispatcherType() { return null; }
    }

    private static class MockHttpServletResponse implements HttpServletResponse {
        private java.io.StringWriter writer = new java.io.StringWriter();
        
        @Override public java.io.PrintWriter getWriter() { return new java.io.PrintWriter(writer); }
        @Override public void setContentType(String type) {}
        
        // Implement other required methods with default/empty implementations
        @Override public void addCookie(javax.servlet.http.Cookie cookie) {}
        @Override public boolean containsHeader(String name) { return false; }
        @Override public String encodeURL(String url) { return null; }
        @Override public String encodeRedirectURL(String url) { return null; }
        @Override public String encodeUrl(String url) { return null; }
        @Override public String encodeRedirectUrl(String url) { return null; }
        @Override public void sendError(int sc, String msg) {}
        @Override public void sendError(int sc) {}
        @Override public void sendRedirect(String location) {}
        @Override public void setDateHeader(String name, long date) {}
        @Override public void addDateHeader(String name, long date) {}
        @Override public void setHeader(String name, String value) {}
        @Override public void addHeader(String name, String value) {}
        @Override public void setIntHeader(String name, int value) {}
        @Override public void addIntHeader(String name, int value) {}
        @Override public void setStatus(int sc) {}
        @Override public void setStatus(int sc, String sm) {}
        @Override public int getStatus() { return 0; }
        @Override public String getHeader(String name) { return null; }
        @Override public java.util.Collection<String> getHeaders(String name) { return null; }
        @Override public java.util.Collection<String> getHeaderNames() { return null; }
        @Override public String getCharacterEncoding() { return null; }
        @Override public String getContentType() { return null; }
        @Override public javax.servlet.ServletOutputStream getOutputStream() { return null; }
        @Override public void setCharacterEncoding(String charset) {}
        @Override public void setContentLength(int len) {}
        @Override public void setContentLengthLong(long len) {}
        @Override public void setBufferSize(int size) {}
        @Override public int getBufferSize() { return 0; }
        @Override public void flushBuffer() {}
        @Override public void resetBuffer() {}
        @Override public boolean isCommitted() { return false; }
        @Override public void reset() {}
        @Override public void setLocale(java.util.Locale loc) {}
        @Override public java.util.Locale getLocale() { return null; }
    }
}