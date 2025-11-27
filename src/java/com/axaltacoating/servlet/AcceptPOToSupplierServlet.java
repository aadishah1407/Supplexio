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
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet(name = "AcceptPOToSupplierServlet", urlPatterns = {"/accept-po"})
public class AcceptPOToSupplierServlet extends HttpServlet {
    private static final Logger LOGGER = Logger.getLogger(AcceptPOToSupplierServlet.class.getName());

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String poIdParam = request.getParameter("poId");
        if (poIdParam == null || poIdParam.isEmpty()) {
            response.sendRedirect("supplier-po-view?error=Missing+PO+ID");
            return;
        }
        long poId = Long.parseLong(poIdParam);
           try (Connection conn = DatabaseConnection.getConnection();
               PreparedStatement stmt = conn.prepareStatement("UPDATE purchase_orders SET status = 'SENT' WHERE id = ?")) {
            stmt.setLong(1, poId);
            int updated = stmt.executeUpdate();
            if (updated > 0) {
                response.sendRedirect("supplier-po-view?success=PO+accepted");
            } else {
                response.sendRedirect("supplier-po-view?error=PO+not+found");
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error accepting PO", e);
            response.sendRedirect("supplier-po-view?error=Database+error");
        }
    }
}
