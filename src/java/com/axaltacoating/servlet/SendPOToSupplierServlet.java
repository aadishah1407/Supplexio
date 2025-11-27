package com.axaltacoating.servlet;

import com.axaltacoating.util.DatabaseConnection;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet(name = "SendPOToSupplierServlet", urlPatterns = {"/send-po-to-supplier"})
public class SendPOToSupplierServlet extends HttpServlet {
    private static final Logger LOGGER = Logger.getLogger(SendPOToSupplierServlet.class.getName());

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String poIdParam = request.getParameter("poId");
        if (poIdParam == null || poIdParam.isEmpty()) {
            // Redirect to the supplier view servlet so it will populate the PO list (not directly to the JSP)
            response.sendRedirect("supplier-po-view?error=Missing+PO+ID");
            return;
        }
        long poId = Long.parseLong(poIdParam);
        try (Connection conn = DatabaseConnection.getConnection()) {
            // Check if PO exists
            boolean exists = false;
            try (PreparedStatement checkStmt = conn.prepareStatement(
                    "SELECT COUNT(*) FROM purchase_orders WHERE id = ?")) {
                checkStmt.setLong(1, poId);
                ResultSet rs = checkStmt.executeQuery();
                if (rs.next() && rs.getInt(1) > 0) {
                    exists = true;
                }
                rs.close();
            }
            if (exists) {
                // Update status to SENT. If supplierId provided, also set supplier_id so supplier will see it.
                String supplierIdParam = request.getParameter("supplierId");
                if (supplierIdParam != null && !supplierIdParam.isEmpty()) {
                    try (PreparedStatement stmt = conn.prepareStatement(
                            "UPDATE purchase_orders SET status = 'SENT', supplier_id = ? WHERE id = ?")) {
                        stmt.setLong(1, Long.parseLong(supplierIdParam));
                        stmt.setLong(2, poId);
                        int updated = stmt.executeUpdate();
                        if (updated > 0) {
                            // Redirect back to user PO view (buyer) so buyer remains logged in
                            response.sendRedirect("user-po-view?success=PO+sent+to+supplier");
                        } else {
                            response.sendRedirect("user-po-view?error=PO+not+found");
                        }
                    }
                } else {
                    try (PreparedStatement stmt = conn.prepareStatement(
                            "UPDATE purchase_orders SET status = 'SENT' WHERE id = ?")) {
                        stmt.setLong(1, poId);
                        int updated = stmt.executeUpdate();
                        if (updated > 0) {
                            response.sendRedirect("user-po-view?success=PO+sent+to+supplier");
                        } else {
                            response.sendRedirect("user-po-view?error=PO+not+found");
                        }
                    }
                }
            } else {
                // If PO does not exist, collect all required fields from the request and insert it
                String supplierIdParam = request.getParameter("supplierId");
                String material = request.getParameter("material");
                double amount = Double.parseDouble(request.getParameter("amount"));
                int quantity = Integer.parseInt(request.getParameter("quantity"));
                // Provide required NOT NULL fields for purchase_orders insert
                String poNumberStr = String.valueOf(poId);
                double unitPrice = (quantity > 0) ? (amount / quantity) : amount;
                double totalAmount = amount;
                double taxAmount = 0.0;
                double grandTotal = totalAmount + taxAmount;
                String supplierName = request.getParameter("supplierName");
                if (supplierName == null || supplierName.isEmpty()) supplierName = "Unknown Supplier";
                
                try (PreparedStatement insertStmt = conn.prepareStatement(
                        "INSERT INTO purchase_orders (id, supplier_id, product_id, po_number, supplier_name, material, amount, quantity, unit_price, total_amount, tax_amount, grand_total, status, created_at) " +
                        "VALUES (?, ?, 0, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'SENT', NOW())")) {
                    insertStmt.setLong(1, poId);
                    insertStmt.setLong(2, Long.parseLong(supplierIdParam));
                    insertStmt.setString(3, poNumberStr);
                    insertStmt.setString(4, supplierName);
                    insertStmt.setString(5, material);
                    insertStmt.setDouble(6, amount);
                    insertStmt.setInt(7, quantity);
                    insertStmt.setDouble(8, unitPrice);
                    insertStmt.setDouble(9, totalAmount);
                    insertStmt.setDouble(10, taxAmount);
                    insertStmt.setDouble(11, grandTotal);
                    int inserted = insertStmt.executeUpdate();
                    if (inserted > 0) {
                        response.sendRedirect("user-po-view?success=PO+created+and+sent+to+supplier");
                    } else {
                        response.sendRedirect("user-po-view?error=Failed+to+create+PO");
                    }
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error sending PO to supplier", e);
            response.sendRedirect("supplier-po-view?error=Database+error");
        }
    }
}
