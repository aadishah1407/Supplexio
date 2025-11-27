package com.axaltacoating.servlet;

import com.google.gson.Gson;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.*;
import java.nio.charset.StandardCharsets;
import java.util.*;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet("/commodities")
public class CommoditiesServlet extends HttpServlet {
    private static final Logger LOGGER = Logger.getLogger(CommoditiesServlet.class.getName());
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");
        
        if ("getHistoricalData".equals(action)) {
            handleHistoricalDataRequest(request, response);
            return;
        }
        
        // Default: show commodities page
        loadCommoditiesData(request, response);
    }
    
    private void loadCommoditiesData(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String csvPath = getServletContext().getRealPath("/WEB-INF/data/commodities_live.csv");
        List<List<String>> table = new ArrayList<>();
        
        try (BufferedReader br = new BufferedReader(new InputStreamReader(new FileInputStream(csvPath), StandardCharsets.UTF_8))) {
            String line;
            while ((line = br.readLine()) != null) {
                List<String> row = parseCsvLine(line);
                table.add(row);
            }
        } catch (Exception e) {
            LOGGER.log(Level.WARNING, "Error reading commodities CSV file", e);
            // Create sample data if file not found
            table = createSampleData();
        }
        
        request.setAttribute("commoditiesTable", table);
        
        // Generate sample historical data for charts
        generateSampleHistoricalData(request);
        
        request.getRequestDispatcher("/WEB-INF/views/commodities/commodities.jsp").forward(request, response);
    }
    
    private void handleHistoricalDataRequest(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String commodity = request.getParameter("commodity");
        String timeRange = request.getParameter("timeRange");
        
        if (commodity == null || timeRange == null) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }
        
        int days = Integer.parseInt(timeRange);
        Map<String, Object> historicalData = generateHistoricalDataForCommodity(commodity, days);
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        Gson gson = new Gson();
        response.getWriter().write(gson.toJson(historicalData));
    }
    
    private List<String> parseCsvLine(String line) {
        List<String> row = new ArrayList<>();
        StringBuilder sb = new StringBuilder();
        boolean inQuotes = false;
        
        for (char c : line.toCharArray()) {
            if (c == '"') {
                inQuotes = !inQuotes;
            } else if (c == ',' && !inQuotes) {
                row.add(sb.toString().trim());
                sb.setLength(0);
            } else {
                sb.append(c);
            }
        }
        row.add(sb.toString().trim());
        return row;
    }
    
    private List<List<String>> createSampleData() {
        List<List<String>> sampleData = new ArrayList<>();
        
        // Header row
        sampleData.add(Arrays.asList("", "Name", "Month", "Last", "High", "Low", "Chg.", "Chg. %", "Time"));
        
        // Sample commodity data
        sampleData.add(Arrays.asList("", "Gold derived", "Aug 25", "3,403.30", "3,411.55", "3,362.17", "+17.60", "+0.52%", "11:14:44"));
        sampleData.add(Arrays.asList("", "Silver derived", "Jul 25", "36.288", "36.305", "35.793", "+0.270", "+0.75%", "11:14:40"));
        sampleData.add(Arrays.asList("", "Copper derived", "Jul 25", "4.8445", "4.8513", "4.7705", "+0.0110", "+0.23%", "11:14:24"));
        sampleData.add(Arrays.asList("", "Platinum derived", "Jul 25", "1,297.80", "1,302.10", "1,241.05", "+33.30", "+2.63%", "11:14:57"));
        sampleData.add(Arrays.asList("", "Crude Oil WTI derived", "Aug 25", "72.94", "77.13", "72.61", "-0.90", "-1.22%", "11:14:39"));
        sampleData.add(Arrays.asList("", "Brent Oil derived", "Sep 25", "74.86", "77.66", "74.51", "-0.62", "-0.82%", "11:14:49"));
        sampleData.add(Arrays.asList("", "Natural Gas derived", "Aug 25", "3.828", "4.014", "3.816", "-0.121", "-3.06%", "11:14:57"));
        sampleData.add(Arrays.asList("", "Aluminium derived", "", "2,585.65", "2,595.15", "2,550.25", "+29.15", "+1.14%", "11:13:49"));
        sampleData.add(Arrays.asList("", "US Wheat derived", "Jul 25", "550.13", "569.50", "549.38", "-16.88", "-2.98%", "11:15:22"));
        sampleData.add(Arrays.asList("", "US Corn derived", "Jul 25", "418.90", "430.00", "418.40", "-9.10", "-2.13%", "11:15:03"));
        
        return sampleData;
    }
    
    private void generateSampleHistoricalData(HttpServletRequest request) {
        // Generate sample data for charts
        List<String> dateLabels = new ArrayList<>();
        List<Double> priceHistory = new ArrayList<>();
        
        // Generate last 7 days of data
        Calendar cal = Calendar.getInstance();
        double basePrice = 4.8445; // Copper base price
        
        for (int i = 6; i >= 0; i--) {
            cal.setTime(new Date());
            cal.add(Calendar.DAY_OF_MONTH, -i);
            dateLabels.add(String.format("%02d/%02d", cal.get(Calendar.MONTH) + 1, cal.get(Calendar.DAY_OF_MONTH)));
            
            // Add some realistic price variation
            double variation = (Math.random() - 0.5) * 0.1; // ±5% variation
            priceHistory.add(basePrice + variation);
        }
        
        Gson gson = new Gson();
        request.setAttribute("copperLabelsJson", gson.toJson(dateLabels));
        request.setAttribute("copperHistoryJson", gson.toJson(priceHistory));
    }
    
    private Map<String, Object> generateHistoricalDataForCommodity(String commodity, int days) {
        List<String> labels = new ArrayList<>();
        List<Double> data = new ArrayList<>();
        
        // Get base price for the commodity (simplified)
        double basePrice = getBasePriceForCommodity(commodity);
        
        Calendar cal = Calendar.getInstance();
        for (int i = days - 1; i >= 0; i--) {
            cal.setTime(new Date());
            cal.add(Calendar.DAY_OF_MONTH, -i);
            
            if (days <= 7) {
                labels.add(String.format("%02d/%02d", cal.get(Calendar.MONTH) + 1, cal.get(Calendar.DAY_OF_MONTH)));
            } else if (days <= 30) {
                if (i % 2 == 0) { // Show every other day for 30 days
                    labels.add(String.format("%02d/%02d", cal.get(Calendar.MONTH) + 1, cal.get(Calendar.DAY_OF_MONTH)));
                } else {
                    labels.add("");
                }
            } else {
                if (i % 7 == 0) { // Show weekly for longer periods
                    labels.add(String.format("%02d/%02d", cal.get(Calendar.MONTH) + 1, cal.get(Calendar.DAY_OF_MONTH)));
                } else {
                    labels.add("");
                }
            }
            
            // Generate realistic price variation
            double variation = (Math.random() - 0.5) * 0.08; // ±4% variation
            double trendFactor = Math.sin(i * 0.1) * 0.02; // Add some trend
            data.add(basePrice * (1 + variation + trendFactor));
        }
        
        Map<String, Object> result = new HashMap<>();
        result.put("labels", labels);
        result.put("data", data);
        result.put("commodity", commodity);
        
        return result;
    }
    
    private double getBasePriceForCommodity(String commodity) {
        // Simplified price mapping
        switch (commodity.toLowerCase()) {
            case "gold derived": return 3403.30;
            case "silver derived": return 36.288;
            case "copper derived": return 4.8445;
            case "platinum derived": return 1297.80;
            case "crude oil wti derived": return 72.94;
            case "brent oil derived": return 74.86;
            case "natural gas derived": return 3.828;
            case "aluminium derived": return 2585.65;
            default: return 100.0; // Default price
        }
    }
}
