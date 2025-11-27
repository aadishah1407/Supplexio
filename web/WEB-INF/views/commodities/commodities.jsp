<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Commodities Price Trends - Axalta Coating Systems</title>
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.1/css/all.min.css">
    <link href="${pageContext.request.contextPath}/assets/css/common.css" rel="stylesheet" type="text/css"/>
    <link href="${pageContext.request.contextPath}/resources/css/style.css" rel="stylesheet" type="text/css"/>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>
        .page-header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 1rem;
            margin-bottom: 1rem;
            border-radius: 10px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.1);
        }
        .commodities-table {
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            border: none;
        }
        .table th {
            background-color: #f8f9fa;
            border-top: none;
            font-weight: 600;
            color: #495057;
            padding: 0.5rem;
        }
        .table td {
            padding: 0.5rem;
        }
        .card {
            border: none;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        .card-body {
            padding: 1rem;
        }
        #timeRange {
            border-radius: 5px;
            border: 1px solid rgba(255,255,255,0.3);
            background-color: rgba(255,255,255,0.1);
            color: white;
            padding: 0.5rem 1rem;
        }
        #timeRange option {
            background-color: #495057;
            color: white;
        }
        .page-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
        }
        .price-positive {
            color: #28a745;
        }
        .price-negative {
            color: #dc3545;
        }
        .commodity-row {
            cursor: pointer;
            transition: background-color 0.2s;
        }
        .commodity-row:hover {
            background-color: #f8f9fa;
        }
        .trend-icon {
            font-size: 1.2em;
        }
        .chart-container {
            position: relative;
            height: 400px;
        }
        .loading-spinner {
            display: none;
            text-align: center;
            padding: 2rem;
        }
        .category-badge {
            font-size: 0.75em;
            padding: 0.25em 0.5em;
        }
        /* Reduce overall spacing */
        .main-content {
            padding: 0.5rem;
        }
        .row {
            margin-left: -0.5rem;
            margin-right: -0.5rem;
        }
        .row > [class*="col-"] {
            padding-left: 0.5rem;
            padding-right: 0.5rem;
        }
        .mb-4 {
            margin-bottom: 1rem !important;
        }
        .card-header {
            padding: 0.75rem 1rem;
        }
    </style>
</head>
<body class="commodities-page">
    <!-- Include sidebar -->
    <jsp:include page="/WEB-INF/views/common/sidebar.jsp" />
    
    <!-- Main content -->
    <div class="main-content">
        <!-- Page header -->
        <div class="page-header">
            <div>
                <h1 style="font-size:2.2rem; font-weight:700; margin-bottom:0.5rem;">Commodities Price Trends</h1>
                <p style="opacity:0.85; font-size:1.1rem; margin-bottom:0;">Track and analyze commodity price movements in real time</p>
            </div>
            <div>
                <select id="timeRange" class="form-control" style="min-width:160px;">
                    <option value="7">Last 7 Days</option>
                    <option value="30">Last 30 Days</option>
                    <option value="90">Last 90 Days</option>
                    <option value="365">Last Year</option>
                </select>
            </div>
        </div>
        
        <!-- Search and Filter Section -->
        <div class="row mb-4">
            <div class="col-12">
                <div class="card">
                    <div class="card-body">
                        <div class="row">
                            <div class="col-md-6">
                                <div class="input-group">
                                    <div class="input-group-prepend">
                                        <span class="input-group-text"><i class="fas fa-search"></i></span>
                                    </div>
                                    <input type="text" id="commoditySearch" class="form-control" placeholder="Search commodities (e.g., Gold, Silver, Copper...)">
                                </div>
                            </div>
                            <div class="col-md-3">
                                <select id="categoryFilter" class="form-control">
                                    <option value="">All Categories</option>
                                    <option value="metals">Precious Metals</option>
                                    <option value="energy">Energy</option>
                                    <option value="agriculture">Agriculture</option>
                                    <option value="livestock">Livestock</option>
                                </select>
                            </div>
                            <div class="col-md-3">
                                <button id="clearFilters" class="btn btn-outline-secondary btn-block">
                                    <i class="fas fa-undo mr-1"></i> Clear Filters
                                </button>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        
        <!-- Price Chart Section -->
        <div class="row mb-4" id="chartSection" style="display: none;">
            <div class="col-12">
                <div class="card">
                    <div class="card-header bg-primary text-white">
                        <h5 class="mb-0">
                            <i class="fas fa-chart-line mr-2"></i>
                            <span id="selectedCommodityName">Price Trend</span>
                        </h5>
                        <button type="button" class="close text-white" onclick="hideChart()">
                            <span>&times;</span>
                        </button>
                    </div>
                    <div class="card-body">
                        <canvas id="priceChart" width="400" height="100"></canvas>
                    </div>
                </div>
            </div>
        </div>
        
        <!-- Commodities Table -->
        <div class="card commodities-table">
            <div class="card-header bg-white">
                <div class="d-flex justify-content-between align-items-center">
                    <h5 class="mb-0">
                        <i class="fas fa-list mr-2"></i>Live Commodities Prices
                    </h5>
                    <span class="badge badge-success" id="lastUpdated">Live Data</span>
                </div>
            </div>
            <div class="card-body">
                <div class="table-responsive">
                    <table class="table table-hover" id="commoditiesTable">
                        <thead class="thead-light">
                            <tr>
                                <th>Commodity</th>
                                <th>Current Price</th>
                                <th>High</th>
                                <th>Low</th>
                                <th>Change</th>
                                <th>Change %</th>
                                <th>Last Updated</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody id="commoditiesTableBody">
                            <!-- Data will be populated by JavaScript -->
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div> <!-- End of main-content -->
    
    <!-- Required JavaScript -->
    <script src="https://code.jquery.com/jquery-3.5.1.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/popper.js@1.16.1/dist/umd/popper.min.js"></script>
    <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.min.js"></script>
    
    <script>
        // Pass data from server to JavaScript
        var commoditiesData = [
            <c:forEach var="row" items="${commoditiesTable}" varStatus="status">
                <c:if test="${!status.first && fn:length(row) >= 8}">
                    {
                        name: "${fn:escapeXml(row[1])}",
                        month: "${fn:escapeXml(row[2])}",
                        last: "${fn:escapeXml(row[3])}",
                        high: "${fn:escapeXml(row[4])}",
                        low: "${fn:escapeXml(row[5])}",
                        change: "${fn:escapeXml(row[6])}",
                        changePercent: "${fn:escapeXml(row[7])}",
                        time: "${fn:escapeXml(row[8])}"
                    }<c:if test="${!status.last}">,</c:if>
                </c:if>
            </c:forEach>
        ];
        
        var copperLabels = <c:out value='${copperLabelsJson}' escapeXml="false"/>;
        var copperHistory = <c:out value='${copperHistoryJson}' escapeXml="false"/>;
    </script>
    <script src="${pageContext.request.contextPath}/assets/js/commodities.js"></script>
</body>
</html>
