<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>

<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Supplexio - Procurement Portal</title>
    
    <!-- Common CSS -->
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.1/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/common.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/home.css">
</head>
<body>
        <!-- Include sidebar -->
    <jsp:include page="/WEB-INF/views/common/sidebar.jsp" />
    
    <!-- Main content -->
    <div class="main-content">
        <section class="main-hero">
            <div class="container">
                <h1 class="main-title">SUPPLEXIO</h1>
                <p class="main-subtitle">Next-Generation Procurement and Reverse Auction Platform</p>
                
                <div class="stats-horizontal">
                    <div class="stat-column">
                        <div class="stat-number">150+</div>
                        <div class="stat-label">Active Suppliers</div>
                    </div>
                    <div class="stat-column">
                        <div class="stat-number">75</div>
                        <div class="stat-label">Active Auctions</div>
                    </div>
                    <div class="stat-column">
                        <div class="stat-number">2.5Cr</div>
                        <div class="stat-label">Total Transactions</div>
                    </div>
                    <div class="stat-column">
                        <div class="stat-number">95</div>
                        <div class="stat-label">Success Rate</div>
                    </div>
                </div>
            </div>
        
        <div class="row mt-5">
            <div class="col-md-3">
                <div class="card h-100">
                    <div class="card-header">
                        <i class="fas fa-box"></i>
                        Products
                    </div>
                    <div class="card-body d-flex flex-column">
                        <p>Manage your product catalog for reverse auctions. Add, edit, and track product specifications.</p>
                        <a href="product" class="btn btn-primary mt-auto">
                            <i class="fas fa-arrow-right"></i> Manage Products
                        </a>
                    </div>
                </div>
            </div>
            
            <div class="col-md-3">
                <div class="card h-100">
                    <div class="card-header">
                        <i class="fas fa-users"></i>
                        Suppliers
                    </div>
                    <div class="card-body d-flex flex-column">
                        <p>Manage your supplier database, track performance, and maintain supplier relationships.</p>
                        <a href="supplier" class="btn btn-primary mt-auto">
                            <i class="fas fa-arrow-right"></i> Manage Suppliers
                        </a>
                    </div>
                </div>
            </div>
            
            <div class="col-md-3">
                <div class="card h-100">
                    <div class="card-header">
                        <i class="fas fa-gavel"></i>
                        Reverse Auctions
                    </div>
                    <div class="card-body d-flex flex-column">
                        <p>Create and manage reverse auctions. Monitor bidding activity and award contracts.</p>
                        <a href="auction" class="btn btn-primary mt-auto">
                            <i class="fas fa-arrow-right"></i> Manage Auctions
                        </a>
                    </div>
                </div>
            </div>
            
            <div class="col-md-3">
                <div class="card h-100">
                    <div class="card-header">
                        <i class="fas fa-money-check-alt"></i>
                        Payments
                    </div>
                    <div class="card-body d-flex flex-column">
                        <p>Track payments, generate invoices, and manage financial transactions with suppliers.</p>
                        <a href="payment" class="btn btn-primary mt-auto">
                            <i class="fas fa-arrow-right"></i> Manage Payments
                        </a>
                    </div>
                </div>
            </div>
        </div>
        
        <div class="row mt-4">
            <div class="col-md-3">
                <div class="card h-100 ${hasLowStockAlert ? 'border-warning' : ''}">
                    <div class="card-header ${hasLowStockAlert ? 'bg-warning text-dark' : ''}">
                        <i class="fas fa-warehouse"></i>
                        Inventory Management
                        <c:if test="${hasLowStockAlert}">
                            <span class="badge badge-danger ml-2">Alert!</span>
                        </c:if>
                    </div>
                    <div class="card-body d-flex flex-column">
                        <c:choose>
                            <c:when test="${hasLowStockAlert}">
                                <p class="text-warning"><strong>⚠️ Low stock items detected!</strong></p>
                                <p>Monitor stock levels and manage inventory with Kanban system. Some items need immediate attention.</p>
                                <a href="inventory" class="btn btn-warning mt-auto">
                                    <i class="fas fa-exclamation-triangle"></i> Manage Inventory
                                </a>
                            </c:when>
                            <c:otherwise>
                                <p>Monitor stock levels and manage inventory with Kanban system. All items are well-stocked.</p>
                                <a href="inventory" class="btn btn-primary mt-auto">
                                    <i class="fas fa-arrow-right"></i> Manage Inventory
                                </a>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </div>
            
            <div class="col-md-9">
                <div class="card h-100">
                    <div class="card-header">
                        <i class="fas fa-chart-line"></i>
                        System Status & Quick Actions
                    </div>
                    <div class="card-body">
                        <div class="row">
                            <div class="col-md-6">
                                <h6>Quick Actions</h6>
                                <a href="auction?action=new" class="quick-action-btn">
                                    <i class="fas fa-plus-circle"></i>
                                    Create New Auction
                                </a>
                                <a href="supplier?action=new" class="quick-action-btn">
                                    <i class="fas fa-user-plus"></i>
                                    Add New Supplier
                                </a>
                                <a href="product?action=new" class="quick-action-btn">
                                    <i class="fas fa-cube"></i>
                                    Add New Product
                                </a>
                            </div>
                            <div class="col-md-6">
                                <h6>System Overview</h6>
                                <c:if test="${hasLowStockAlert}">
                                    <div class="alert alert-warning alert-sm">
                                        <i class="fas fa-exclamation-triangle"></i>
                                        <strong>${fn:length(lowStockItems)}</strong> items need attention
                                    </div>
                                </c:if>
                                <a href="auction?action=active" class="quick-action-btn">
                                    <i class="fas fa-clock"></i>
                                    View Active Auctions
                                </a>
                                <a href="payment?action=statistics" class="quick-action-btn">
                                    <i class="fas fa-chart-bar"></i>
                                    View Payment Statistics
                                </a>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        
        <div class="row mt-4">
            <div class="col-md-12">
                <div class="card h-100">
                    <div class="card-header">
                        <i class="fas fa-sign-in-alt"></i>
                        Supplier Portal
                    </div>
                    <div class="card-body text-center">
                        <p class="mb-4">Access the supplier bidding portal to participate in active reverse auctions.</p>
                        <a href="bidding" class="btn btn-danger btn-lg">
                            <i class="fas fa-external-link-alt"></i> Enter Bidding Portal
                        </a>
                    </div>
                </div>
            </div>
        </div>
        </div>
    </div>
    
    <!-- Footer -->
    <footer class="footer mt-5">
        <div class="container">
            <div class="row">
                <div class="col-md-4">
                    <h5>SUPPLEXIO</h5>
                    <p><i class="fas fa-map-marker-alt"></i> Global Headquarters<br>2001 Market Street, Suite 3600<br>Philadelphia, PA 19103</p>
                </div>
                <div class="col-md-4">
                    <h5>Quick Links</h5>
                    <ul class="footer-links">
                        <li><a href="product"><i class="fas fa-box"></i> Products</a></li>
                        <li><a href="supplier"><i class="fas fa-users"></i> Suppliers</a></li>
                        <li><a href="auction"><i class="fas fa-gavel"></i> Reverse Auctions</a></li>
                        <li><a href="payment"><i class="fas fa-money-check-alt"></i> Payments</a></li>
                    </ul>
                </div>
                <div class="col-md-4">
                    <h5>Contact Us</h5>
                    <p><i class="fas fa-phone"></i> +1 (855) 547-1461</p>
                    <p><i class="fas fa-envelope"></i> procurement@supplexio.com</p>
                    <div class="social-icons">
                        <a href="#" class="social-icon"><i class="fab fa-facebook-f"></i></a>
                        <a href="#" class="social-icon"><i class="fab fa-twitter"></i></a>
                        <a href="#" class="social-icon"><i class="fab fa-linkedin-in"></i></a>
                        <a href="#" class="social-icon"><i class="fab fa-youtube"></i></a>
                    </div>
                </div>
            </div>
            <div class="row mt-3">
                <div class="col-md-12 text-center">
                    <p class="copyright">© <%= java.time.Year.now().getValue() %> Supplexio. All Rights Reserved.</p>
                </div>
            </div>
        </div>
    </footer>
    
    <!-- Common JavaScript -->
    <script src="https://code.jquery.com/jquery-3.5.1.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/popper.js@1.16.1/dist/umd/popper.min.js"></script>
    <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.min.js"></script>
    <script src="${pageContext.request.contextPath}/assets/js/home.js"></script>
</body>
</html>
