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

@WebServlet(name = "UserPOViewServlet", urlPatterns = {"/user-po-view"})
public class UserPOViewServlet extends HttpServlet {
    private static final Logger LOGGER = Logger.getLogger(UserPOViewServlet.class.getName());

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        List<PurchaseOrderBean> poList = new ArrayList<>();
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(
                     "SELECT po.*, s.name as supplier_name FROM purchase_orders po LEFT JOIN suppliers s ON po.supplier_id = s.id ORDER BY po.created_at DESC")) {
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                PurchaseOrderBean po = new PurchaseOrderBean();
                po.setId(rs.getLong("id"));
                String supplierName = rs.getString("supplier_name");
                // Use supplier name for both Supplier and Company columns
                po.setSupplierName(supplierName != null && !supplierName.trim().isEmpty() ? supplierName : "Unknown Supplier");
                po.setCompanyName(po.getSupplierName());
                po.setMaterial(rs.getString("material"));
                po.setAmount(rs.getDouble("amount"));
                po.setStatus(rs.getString("status"));
                po.setCreatedAt(rs.getTimestamp("created_at"));
                po.setSupplierId(rs.getLong("supplier_id")); // Set supplier ID
                po.setQuantity(rs.getInt("quantity")); // Set quantity
                poList.add(po);
            }
            rs.close();
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error loading user POs", e);
        }
        request.setAttribute("poList", poList);
        request.getRequestDispatcher("user_po.jsp").forward(request, response);
    }

    // Simple bean for PO data
    public static class PurchaseOrderBean {
        private long id;
        private String supplierName;
        private String companyName;
        private String material;
        private double amount;
        private String status;
        private java.util.Date createdAt;
        private long supplierId; // Add supplierId property
        private int quantity;

        public long getId() { return id; }
        public void setId(long id) { this.id = id; }
        public String getSupplierName() { return supplierName; }
        public void setSupplierName(String supplierName) { this.supplierName = supplierName; }
        public String getCompanyName() { return companyName; }
        public void setCompanyName(String companyName) { this.companyName = companyName; }
        public String getMaterial() { return material; }
        public void setMaterial(String material) { this.material = material; }
        public double getAmount() { return amount; }
        public void setAmount(double amount) { this.amount = amount; }
        public String getStatus() { return status; }
        public void setStatus(String status) { this.status = status; }
        public java.util.Date getCreatedAt() { return createdAt; }
        public void setCreatedAt(java.util.Date createdAt) { this.createdAt = createdAt; }
        public long getSupplierId() { return supplierId; } // Getter for supplierId
        public void setSupplierId(long supplierId) { this.supplierId = supplierId; } // Setter for supplierId
        public int getQuantity() { return quantity; }
        public void setQuantity(int quantity) { this.quantity = quantity; }
    }
}
