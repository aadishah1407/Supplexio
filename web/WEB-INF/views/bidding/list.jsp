<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Supplier Bidding Portal - Axalta Coating Systems</title>
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.1/css/all.min.css">
    <style>
        :root {
            --axalta-blue: rgb(0, 51, 153);
            --axalta-red: rgb(204, 51, 51);
            --background-color: rgb(245, 245, 250);
            --accent-color: rgb(230, 230, 235);
        }
        
        body {
            background-color: var(--background-color);
            font-family: 'Segoe UI', Arial, sans-serif;
            padding-top: 20px;
        }
        
        .card {
            border: none;
            border-radius: 10px;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
            margin-bottom: 20px;
            transition: transform 0.3s ease;
        }
        
        .card:hover {
            transform: translateY(-5px);
        }
        
        .card-header {
            background-color: var(--axalta-blue);
            color: white;
            font-weight: 600;
            border-radius: 10px 10px 0 0 !important;
        }
        
        .btn-primary {
            background-color: var(--axalta-blue);
            border-color: var(--axalta-blue);
        }
        
        .btn-primary:hover {
            background-color: #00307a;
            border-color: #00307a;
        }
        
        .btn-danger {
            background-color: var(--axalta-red);
            border-color: var(--axalta-red);
        }
        
        .btn-danger:hover {
            background-color: #b32e2e;
            border-color: #b32e2e;
        }
        
        .alert {
            border-radius: 10px;
        }
        
        .supplier-info {
            background-color: var(--accent-color);
            padding: 15px;
            border-radius: 10px;
            margin-bottom: 20px;
        }
        
        .supplier-name {
            font-weight: 600;
            color: var(--axalta-blue);
        }
        
        .countdown {
            font-weight: bold;
            color: var(--axalta-red);
        }
        
        .no-auctions {
            text-align: center;
            padding: 50px 0;
            color: #666;
        }
        
        .no-auctions i {
            font-size: 3rem;
            color: var(--accent-color);
            margin-bottom: 20px;
        }
    </style>
</head>
<body>
   <div class="container">
<div class="d-flex justify-content-between align-items-center mb-4">
            <h2>Supplier Bidding Portal</h2>
            <div>
                <button id="showPOBtn" type="button" class="btn btn-warning font-weight-bold mr-2">
                    <i class="fas fa-file-invoice"></i> My Purchase Orders
                </button>
                <a href="${pageContext.request.contextPath}/bidding?action=logout" class="btn btn-outline-danger">
                    <i class="fas fa-sign-out-alt"></i> Logout
                </a>
            </div>
        </div>
        <!-- Supplier Purchase Orders Section -->
        <div id="purchaseOrdersSection" style="display:none; width:100%; max-width:1100px;">
            <c:if test="${not empty purchaseOrders}">
                <div class="card mb-4">
                    <div class="card-header bg-warning text-dark d-flex justify-content-between align-items-center">
                        <span><i class="fas fa-file-invoice"></i> My Purchase Orders</span>
                    </div>
                    <div class="card-body p-0">
                        <div class="table-responsive">
                            <table class="table table-striped mb-0">
                                <thead>
                                    <tr>
                                        <th>PO Number</th>
                                        <th>Date</th>
                                        <th>Status</th>
                                        <th>Quantity</th>
                                        <th>Amount</th>
                                        <th>GST (7.5%)</th>
                                        <th>Total (incl. GST)</th>
                                        <th>Supplier Name</th>
                                        <th>Action</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="po" items="${purchaseOrders}">
                                        <tr>
                                            <td>${po.poNumber}</td>
                                            <td><fmt:formatDate value="${po.date}" pattern="yyyy-MM-dd"/></td>
                                            <td>
                                                <span class="badge badge-${po.status eq 'CONFIRMED' ? 'success' : po.status eq 'PENDING' ? 'warning' : 'secondary'}">${po.status}</span>
                                            </td>
                                            <td>${po.quantity}</td>
                                            <td><fmt:formatNumber value="${po.amount}" type="currency" currencySymbol="₹"/></td>
                                            <td>
                                                <fmt:formatNumber value="${po.amount * 0.075}" type="currency" currencySymbol="₹"/>
                                            </td>
                                            <td>
                                                <fmt:formatNumber value="${po.amount * 1.075}" type="currency" currencySymbol="₹"/>
                                            </td>
                                            <td>
                                                <c:set var="foundName" value=""/>
                                                <c:forEach var="auction" items="${auctions}">
                                                    <c:if test="${auction.supplierId == po.supplierId}">
                                                        <c:set var="foundName" value="${auction.supplierName}"/>
                                                    </c:if>
                                                </c:forEach>
                                                <c:choose>
                                                    <c:when test="${not empty foundName}">
                                                        ${foundName}
                                                    </c:when>
                                                    <c:otherwise>
                                                        Unknown
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td>
                                                <c:if test="${po.status eq 'PENDING'}">
                                                    <form method="post" action="${pageContext.request.contextPath}/supplier-po-view" style="display:inline;">
                                                        <input type="hidden" name="action" value="confirm">
                                                        <input type="hidden" name="poNumber" value="${po.poNumber}">
                                                        <button type="submit" class="btn btn-success btn-sm">Confirm Order</button>
                                                    </form>
                                                </c:if>
                                                <a href="${pageContext.request.contextPath}/download-po-pdf?poId=${po.poNumber}" class="btn btn-outline-primary btn-sm ml-1">
                                                    <i class="fas fa-download"></i> PDF
                                                </a>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </c:if>
            <c:if test="${empty purchaseOrders}">
                <div class="alert alert-info text-center">
                    <i class="fas fa-info-circle"></i> You have no purchase orders yet.
                </div>
            </c:if>
        </div>
        
        <div class="supplier-info">
            <div class="row">
                <div class="col-md-6">
                    <p class="mb-1">Welcome, <span class="supplier-name">${supplier.name}</span></p>
                    <p class="mb-1"><strong>Address:</strong> ${supplier.address}</p>
                </div>
                <div class="col-md-6 text-md-right">
                    <p class="mb-1"><strong>Email:</strong> ${supplier.email}</p>
                    <p class="mb-1"><strong>Phone:</strong> ${supplier.phone}</p>
                </div>
            </div>
        </div>
        
        <c:if test="${not empty error}">
            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                ${error}
                <button type="button" class="close" data-dismiss="alert" aria-label="Close">
                    <span aria-hidden="true">&times;</span>
                </button>
            </div>
        </c:if>
        
        <h4 class="mb-3">Active Auctions</h4>
        
        <div class="row">
            <c:forEach var="auction" items="${auctions}">
                <div class="col-md-6 col-lg-4">
                    <div class="card h-100">
                        <div class="card-header">
                            <h5 class="mb-0">${auction.productName}</h5>
                        </div>
                        <div class="card-body d-flex flex-column">
                            <p><strong>Quantity:</strong> ${auction.requiredQuantity}</p>
                            <p><strong>Current Price:</strong> <fmt:formatNumber value="${auction.currentPrice}" type="currency" currencySymbol="₹" /></p>
                            <p><strong>End Time:</strong> <fmt:formatDate value="${auction.endTime}" pattern="yyyy-MM-dd HH:mm" /></p>
                            <p><strong>Time Left:</strong> <span class="countdown" data-end="${auction.endTime.time}">Loading...</span></p>
                            
                            <a href="${pageContext.request.contextPath}/bidding?action=view&id=${auction.id}" class="btn btn-primary mt-auto">
                                <i class="fas fa-gavel"></i> Place Bid
                            </a>
                        </div>
                    </div>
                </div>
            </c:forEach>
            
            <c:if test="${empty auctions}">
                <div class="col-12">
                    <div class="no-auctions">
                        <i class="fas fa-search"></i>
                        <h4>No Active Auctions</h4>
                        <p>You don't have any active auctions to participate in at the moment.</p>
                        <p>Please check back later or contact Axalta Coating Systems if you believe this is an error.</p>
                    </div>
                </div>
            </c:if>
        </div>
    </div>
    
    <script src="https://code.jquery.com/jquery-3.5.1.slim.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/popper.js@1.16.1/dist/umd/popper.min.js"></script>
    <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.min.js"></script>
    <script>
        // Update countdown timers
        function updateCountdowns() {
            const now = new Date().getTime();
            
            document.querySelectorAll('.countdown').forEach(function(element) {
                const endTime = parseInt(element.getAttribute('data-end'));
                const timeLeft = endTime - now;
                
                if (timeLeft <= 0) {
                    element.innerHTML = 'Auction ended';
                    element.classList.add('text-danger');
                } else {
                    const days = Math.floor(timeLeft / (1000 * 60 * 60 * 24));
                    const hours = Math.floor((timeLeft % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
                    const minutes = Math.floor((timeLeft % (1000 * 60 * 60)) / (1000 * 60));
                    const seconds = Math.floor((timeLeft % (1000 * 60)) / 1000);
                    
                    let countdownText = '';
                    if (days > 0) countdownText += days + 'd ';
                    countdownText += hours + 'h ' + minutes + 'm ' + seconds + 's';
                    
                    element.innerHTML = countdownText;
                }
            });
        }
        
        // Initial update and set interval
        updateCountdowns();
        setInterval(updateCountdowns, 1000);
        
        // Toggle purchase orders section
        document.getElementById('showPOBtn').addEventListener('click', function() {
            var section = document.getElementById('purchaseOrdersSection');
            if (section.style.display === 'none' || section.style.display === '') {
                section.style.display = 'block';
                this.classList.add('active');
            } else {
                section.style.display = 'none';
                this.classList.remove('active');
            }
        });
    </script>
</body>
</html>
