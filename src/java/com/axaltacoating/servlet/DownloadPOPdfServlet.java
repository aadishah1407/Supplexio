package com.axaltacoating.servlet;

import com.axaltacoating.util.DatabaseConnection;
import com.itextpdf.text.*;
import com.itextpdf.text.pdf.PdfPCell;
import com.itextpdf.text.pdf.PdfPTable;
import com.itextpdf.text.pdf.PdfWriter;

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

@WebServlet(name = "DownloadPOPdfServlet", urlPatterns = {"/download-po-pdf"})
public class DownloadPOPdfServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String poIdParam = request.getParameter("poId");
        if (poIdParam == null || poIdParam.isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Missing PO ID");
            return;
        }
        long poId = Long.parseLong(poIdParam);
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(
                     "SELECT po.*, s.name as supplier_name, s.email as supplier_email FROM purchase_orders po LEFT JOIN suppliers s ON po.supplier_id = s.id WHERE po.id = ?")) {
            stmt.setLong(1, poId);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                response.setContentType("application/pdf");
                response.setHeader("Content-Disposition", "attachment; filename=PO-" + poId + ".pdf");
                Document document = new Document();
                PdfWriter.getInstance(document, response.getOutputStream());
                document.open();
                // --- HEADER ---
                Font titleFont = new Font(Font.FontFamily.HELVETICA, 22, Font.BOLD, BaseColor.BLUE);
                Paragraph title = new Paragraph("SUPPLEXIO", titleFont);
                title.setAlignment(Element.ALIGN_LEFT);
                document.add(title);
                document.add(new Paragraph("\n"));
                // --- PO Info ---
                PdfPTable infoTable = new PdfPTable(2);
                infoTable.setWidthPercentage(100);
                infoTable.addCell(getCell("Purchase Order", PdfPCell.ALIGN_LEFT, Font.BOLD));
                infoTable.addCell(getCell("PO No: " + rs.getLong("po_number") + "\n" + rs.getTimestamp("created_at"), PdfPCell.ALIGN_RIGHT, Font.NORMAL));
                document.add(infoTable);
                document.add(new Paragraph("\n"));
                // --- Supplier/Delivery ---
                PdfPTable supTable = new PdfPTable(2);
                supTable.setWidthPercentage(100);
                supTable.addCell(getCell("SUPPLIER", PdfPCell.ALIGN_CENTER, Font.BOLD));
                supTable.addCell(getCell("DELIVERY ADDRESS", PdfPCell.ALIGN_CENTER, Font.BOLD));
                String supplierBlock = rs.getString("supplier_name") + "\n" + rs.getString("company_name") + "\nEmail: " + rs.getString("supplier_email");
                String deliveryBlock = "Supplexio HQ\n2001 Market Street, Suite 3600\nPhiladelphia, PA 19103";
                supTable.addCell(getCell(supplierBlock, PdfPCell.ALIGN_LEFT, Font.NORMAL));
                supTable.addCell(getCell(deliveryBlock, PdfPCell.ALIGN_LEFT, Font.NORMAL));
                document.add(supTable);
                document.add(new Paragraph("\n"));
                // --- Items Table ---
                PdfPTable itemTable = new PdfPTable(5);
                itemTable.setWidthPercentage(100);
                itemTable.addCell(getCell("ITEM NAME", PdfPCell.ALIGN_CENTER, Font.BOLD));
                itemTable.addCell(getCell("QTY", PdfPCell.ALIGN_CENTER, Font.BOLD));
                itemTable.addCell(getCell("ITEM PRICE", PdfPCell.ALIGN_CENTER, Font.BOLD));
                itemTable.addCell(getCell("GST (7.5%)", PdfPCell.ALIGN_CENTER, Font.BOLD));
                itemTable.addCell(getCell("TOTAL", PdfPCell.ALIGN_CENTER, Font.BOLD));
                itemTable.addCell(getCell(rs.getString("material"), PdfPCell.ALIGN_LEFT, Font.NORMAL));
                // Always use correct field names for quantity and unit price
                int qty = rs.getInt("quantity");
                double unitPrice = rs.getDouble("unit_price");
                if (qty == 0) {
                    try { qty = rs.getInt("auction_quantity"); } catch (Exception e) { qty = 0; }
                }
                // Fallback: If qty is still zero, fetch from reverse_auctions using auction_id
                if (qty == 0) {
                    try {
                        long auctionId = rs.getLong("auction_id");
                        try (Connection conn2 = DatabaseConnection.getConnection();
                             PreparedStatement stmt2 = conn2.prepareStatement("SELECT required_quantity FROM reverse_auctions WHERE id = ?")) {
                            stmt2.setLong(1, auctionId);
                            ResultSet rs2 = stmt2.executeQuery();
                            if (rs2.next()) {
                                qty = rs2.getInt("required_quantity");
                            }
                            rs2.close();
                        }
                    } catch (Exception e) { qty = 0; }
                }
                if (unitPrice == 0.0) {
                    try { unitPrice = rs.getDouble("price"); } catch (Exception e) { unitPrice = 0.0; }
                }
                double amount = unitPrice * qty;
                if (amount == 0.0) {
                    try { amount = rs.getDouble("amount"); } catch (Exception e) { amount = 0.0; }
                }
                double gst = amount * 0.075;
                double total = amount + gst;
                itemTable.addCell(getCell(String.valueOf(qty), PdfPCell.ALIGN_CENTER, Font.NORMAL));
                itemTable.addCell(getCell(String.format("Rs%.2f", unitPrice), PdfPCell.ALIGN_RIGHT, Font.NORMAL));
                itemTable.addCell(getCell(String.format("Rs%.2f", gst), PdfPCell.ALIGN_RIGHT, Font.NORMAL));
                itemTable.addCell(getCell(String.format("Rs%.2f", total), PdfPCell.ALIGN_RIGHT, Font.NORMAL));
                document.add(itemTable);
                document.add(new Paragraph("\n"));
                // --- Order Total ---
                Paragraph totalPara = new Paragraph("ORDER TOTAL: Rs" + String.format("%.2f", total), new Font(Font.FontFamily.HELVETICA, 14, Font.BOLD, BaseColor.BLUE));
                totalPara.setAlignment(Element.ALIGN_RIGHT);
                document.add(totalPara);
                document.close();
            } else {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "PO not found");
            }
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }
    private PdfPCell getCell(String text, int alignment, int style) {
        Font font = new Font(Font.FontFamily.HELVETICA, 10, style);
        PdfPCell cell = new PdfPCell(new Phrase(text, font));
        cell.setPadding(5);
        cell.setHorizontalAlignment(alignment);
        return cell;
    }
}
