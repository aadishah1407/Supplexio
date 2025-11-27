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
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet(name = "SupplierPOViewServlet", urlPatterns = {"/supplier-po-view"})
public class SupplierPOViewServlet extends HttpServlet {
    private static final Logger LOGGER = Logger.getLogger(SupplierPOViewServlet.class.getName());

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Try to obtain supplier id from several possible session attributes (robustness)
        Long supplierId = null;
        Object attr;
        String[] candidateKeys = new String[]{"supplierId", "supplier_id", "userId", "user_id", "id"};
        for (String key : candidateKeys) {
            attr = request.getSession().getAttribute(key);
            if (attr != null) {
                try {
                    if (attr instanceof Long) {
                        supplierId = (Long) attr;
                    } else if (attr instanceof Integer) {
                        supplierId = ((Integer) attr).longValue();
                    } else {
                        // Try parse string
                        supplierId = Long.parseLong(attr.toString());
                    }
                    LOGGER.info("Using session attribute '" + key + "' for supplierId: " + supplierId);
                    break;
                } catch (NumberFormatException nfe) {
                    LOGGER.warning("Session attribute '" + key + "' is not a valid number: " + attr);
                    supplierId = null; // continue
                }
            }
        }
        if (supplierId == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        List<PurchaseOrderBean> poList = new ArrayList<>();
        String supplierName = null;
        try (Connection conn = DatabaseConnection.getConnection()) {
            // Fetch supplier name for this supplierId
            try (PreparedStatement nameStmt = conn.prepareStatement("SELECT name FROM suppliers WHERE id = ?")) {
                nameStmt.setLong(1, supplierId);
                ResultSet nameRs = nameStmt.executeQuery();
                if (nameRs.next()) {
                    supplierName = nameRs.getString("name");
                }
                nameRs.close();
            }
            try (PreparedStatement stmt = conn.prepareStatement(
                    "SELECT * FROM purchase_orders WHERE supplier_id = ? ORDER BY created_at DESC")) {
                stmt.setLong(1, supplierId);
                ResultSet rs = stmt.executeQuery();
                while (rs.next()) {
                    PurchaseOrderBean po = new PurchaseOrderBean();
                    po.setId(rs.getLong("id"));
                    po.setAuctionId(rs.getLong("auction_id"));
                    po.setMaterial(rs.getString("material"));
                    po.setAmount(rs.getDouble("amount"));
                    po.setQuantity(rs.getInt("quantity"));
                    po.setStatus(rs.getString("status"));
                    po.setCreatedAt(rs.getTimestamp("created_at"));
                    po.setCompanyName(supplierName != null ? supplierName : "Unknown Supplier");
                    // Set supplierId for completeness (not used in JSP, but for consistency)
                    //po.SupplierId(rs.getLong("supplier_id"));
                    poList.add(po);
                }
                rs.close();
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error loading supplier POs", e);
        }
        request.setAttribute("poList", poList);
        request.getRequestDispatcher("supplier_po.jsp").forward(request, response);
    }

    // Simple bean for PO data
    public static class PurchaseOrderBean {
        private long id;
        private long auctionId;
        private String material;
        private double amount;
        private int quantity;
        private String status;
        private java.util.Date createdAt;
        private String companyName;
        public long getId() { return id; }
        public void setId(long id) { this.id = id; }
        public long getAuctionId() { return auctionId; }
        public void setAuctionId(long auctionId) { this.auctionId = auctionId; }
        public String getMaterial() { return material; }
        public void setMaterial(String material) { this.material = material; }
        public double getAmount() { return amount; }
        public void setAmount(double amount) { this.amount = amount; }
        public int getQuantity() { return quantity; }
        public void setQuantity(int quantity) { this.quantity = quantity; }
        public String getStatus() { return status; }
        public void setStatus(String status) { this.status = status; }
        public java.util.Date getCreatedAt() { return createdAt; }
        public void setCreatedAt(java.util.Date createdAt) { this.createdAt = createdAt; }
        public String getCompanyName() { return companyName; }
        public void setCompanyName(String companyName) { this.companyName = companyName; }
    }
}
