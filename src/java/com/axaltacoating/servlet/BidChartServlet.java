package com.axaltacoating.servlet;

import com.axaltacoating.util.DatabaseConnection;
import java.io.IOException;
import java.io.PrintWriter;
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
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import org.json.simple.JSONArray;
import org.json.simple.JSONObject;

/**
 * Servlet for handling bid chart data API requests.
 */
@SuppressWarnings("unchecked")
public class BidChartServlet extends HttpServlet {
    private static final Logger LOGGER = Logger.getLogger(BidChartServlet.class.getName());
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String auctionIdParam = request.getParameter("auctionId");
        
        if (auctionIdParam == null || auctionIdParam.trim().isEmpty()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("Missing required parameter: auctionId");
            return;
        }
        
        int auctionId;
        try {
            auctionId = Integer.parseInt(auctionIdParam);
        } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("Invalid auction ID format");
            return;
        }
        
        List<Map<String, Object>> chartData = getBidChartData(auctionId);
        
        // Convert to JSON and send response
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        JSONArray jsonArray = new JSONArray();
        
        for (Map<String, Object> dataPoint : chartData) {
            JSONObject jsonObject = new JSONObject();
            jsonObject.put("bidTime", dataPoint.get("bidTime"));
            jsonObject.put("bidAmount", dataPoint.get("bidAmount"));
            jsonObject.put("supplierName", dataPoint.get("supplierName"));
            jsonArray.add(jsonObject);
        }
        
        PrintWriter out = response.getWriter();
        out.print(jsonArray.toJSONString());
        out.flush();
    }
    
    /**
     * Retrieves bid chart data for a specific auction.
     * 
     * @param auctionId The auction ID
     * @return A list of data points for the chart
     */
    private List<Map<String, Object>> getBidChartData(int auctionId) {
        List<Map<String, Object>> chartData = new ArrayList<Map<String, Object>>();
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        
        try {
            conn = DatabaseConnection.getConnection();
            
            // First, check if we have data in the bid_chart_data table
            String sql = "SELECT * FROM bid_chart_data WHERE auction_id = ? ORDER BY bid_time ASC";
            stmt = conn.prepareStatement(sql);
            stmt.setInt(1, auctionId);
            rs = stmt.executeQuery();
            
            boolean hasData = false;
            while (rs.next()) {
                hasData = true;
                Map<String, Object> dataPoint = new HashMap<String, Object>();
                dataPoint.put("bidTime", rs.getTimestamp("bid_time").toString());
                dataPoint.put("bidAmount", rs.getDouble("bid_amount"));
                dataPoint.put("supplierName", rs.getString("supplier_name"));
                chartData.add(dataPoint);
            }
            
            // If no data in the bid_chart_data table, try to get it directly from bids table
            if (!hasData) {
                DatabaseConnection.closeQuietly(rs, stmt, null);
                
                // Run the SQL from setup_bid_charts.sql to populate the table
                String insertSql = "INSERT INTO bid_chart_data (auction_id, bid_time, bid_amount, supplier_id, supplier_name, bid_id) " +
                                 "SELECT b.auction_id, b.bid_time, b.bid_amount, b.user_id, s.name, b.id " +
                                 "FROM bids b " +
                                 "JOIN suppliers s ON b.user_id = s.id " +
                                 "WHERE b.auction_id = ? " +
                                 "AND NOT EXISTS (" +
                                 "    SELECT 1 FROM bid_chart_data bcd " +
                                 "    WHERE bcd.auction_id = b.auction_id " +
                                 "    AND bcd.bid_time = b.bid_time " +
                                 "    AND bcd.supplier_id = b.user_id" +
                                 "    AND bcd.bid_id = b.id" +
                                 ")";
                
                stmt = conn.prepareStatement(insertSql);
                stmt.setInt(1, auctionId);
                stmt.executeUpdate();
                
                // Now query the data again
                DatabaseConnection.closeQuietly(null, stmt, null);
                stmt = conn.prepareStatement(sql);
                stmt.setInt(1, auctionId);
                rs = stmt.executeQuery();
                
                boolean foundData = false;
                while (rs.next()) {
                    foundData = true;
                    Map<String, Object> dataPoint = new HashMap<String, Object>();
                    dataPoint.put("bidTime", rs.getTimestamp("bid_time").toString());
                    dataPoint.put("bidAmount", rs.getDouble("bid_amount"));
                    dataPoint.put("supplierName", rs.getString("supplier_name"));
                    chartData.add(dataPoint);
                }
                
                // If still no data, generate sample data for testing purposes
                if (!foundData) {
                    LOGGER.info("No bid data found for auction ID " + auctionId + ", generating sample data");
                    generateSampleBidData(chartData, auctionId);
                }
            }
            
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error retrieving bid chart data", e);
        } finally {
            DatabaseConnection.closeQuietly(rs, stmt, conn);
        }
        
        return chartData;
    }
    
    /**
     * Generates sample bid data for testing purposes when no actual data is available.
     * This ensures the bid graph always has something to display during development and testing.
     * 
     * @param chartData The list to populate with sample data points
     * @param auctionId The auction ID to generate data for
     */
    private void generateSampleBidData(List<Map<String, Object>> chartData, int auctionId) {
        // Start with a high bid amount and decrease it over time
        double startAmount = 10000.00;
        double decrementAmount = 500.00;
        
        // Get current time and go back 20 minutes
        long now = System.currentTimeMillis();
        long startTime = now - (20 * 60 * 1000); // 20 minutes ago
        
        // Generate 20 data points, one per minute
        for (int i = 0; i < 20; i++) {
            Map<String, Object> dataPoint = new HashMap<String, Object>();
            
            // Calculate time for this data point (starting from 20 minutes ago)
            long pointTime = startTime + (i * 60 * 1000); // Add i minutes
            java.sql.Timestamp timestamp = new java.sql.Timestamp(pointTime);
            
            // Calculate bid amount (decreasing over time)
            double bidAmount = startAmount - (i * decrementAmount);
            if (bidAmount < 500) bidAmount = 500; // Don't go below 500
            
            dataPoint.put("bidTime", timestamp.toString());
            dataPoint.put("bidAmount", bidAmount);
            dataPoint.put("supplierName", "Sample Supplier");
            
            chartData.add(dataPoint);
        }
        
        // Add a final bid that's very recent
        Map<String, Object> finalBid = new HashMap<String, Object>();
        finalBid.put("bidTime", new java.sql.Timestamp(now - 30000).toString()); // 30 seconds ago
        finalBid.put("bidAmount", 500.00); // Final low bid
        finalBid.put("supplierName", "Sample Supplier");
        chartData.add(finalBid);
        
        LOGGER.info("Generated " + chartData.size() + " sample data points for auction ID " + auctionId);
    }
}
