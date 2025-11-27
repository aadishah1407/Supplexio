<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Payment Management - Supplexio</title>
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.1/css/all.min.css">
    <link rel="stylesheet" href="https://cdn.datatables.net/1.10.22/css/dataTables.bootstrap4.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/animate.css/4.1.1/animate.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/common.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/payment.css">
</head>
<body>
    <!-- Include sidebar -->
    <jsp:include page="/WEB-INF/views/common/sidebar.jsp" />
    
    <!-- Main content -->
    <div class="main-content">
        <div class="header text-center animate__animated animate__fadeIn">
            <div class="container">
                <h1 class="animate__animated animate__fadeInDown">SUPPLEXIO</h1>
                <div class="divider">
                    <span class="divider-text">Supply Chain Excellence</span>
                </div>
                <p class="animate__animated animate__fadeInUp">Payment Management</p>
            </div>
        </div>
    
    <div class="container">
        <c:if test="${param.auctionId != null}">
            <!-- Payment Creation Form for Specific Auction -->
            <div class="row mb-4 animate__animated animate__fadeIn animate__delay-1s">
                <div class="col-md-12">
                    <div class="card">
                        <div class="card-header">
                            <span><i class="fas fa-file-invoice-dollar"></i> Create Payment for Auction #${param.auctionId}</span>
                            <a href="${pageContext.request.contextPath}/payment" class="btn btn-sm btn-outline-primary"><i class="fas fa-arrow-left"></i> Back to Payments</a>
                        </div>
                        <div class="card-body">
                            <form id="createPaymentForm" action="${pageContext.request.contextPath}/payment" method="post">
                                <input type="hidden" name="action" value="create">
                                <input type="hidden" name="auctionId" value="${param.auctionId}">
                                
                                <div class="row">
                                    <div class="col-md-6">
                                        <div class="form-group">
                                            <label for="supplierId"><i class="fas fa-building text-primary mr-1"></i> Winning Supplier</label>
                                            <select class="form-control" id="supplierId" name="supplierId" required>
                                                <option value="">Select Supplier</option>
                                                <c:forEach items="${winningSuppliers}" var="supplier">
                                                    <option value="${supplier.id}" data-amount="${supplier.bidAmount}">${supplier.name} - ${supplier.company}</option>
                                                </c:forEach>
                                            </select>
                                            <small class="form-text text-muted">Select the supplier who won this auction</small>
                                        </div>
                                    </div>
                                    <div class="col-md-6">
                                        <div class="form-group">
                                            <label for="amount"><i class="fas fa-dollar-sign text-success mr-1"></i> Amount</label>
                                            <div class="input-group">
                                                <div class="input-group-prepend">
                                                    <span class="input-group-text">$</span>
                                                </div>
                                                <input type="number" class="form-control" id="amount" name="amount" step="0.01" min="0" required>
                                            </div>
                                            <small class="form-text text-muted">This will be auto-filled based on the winning bid</small>
                                        </div>
                                    </div>
                                </div>
                                
                                <div class="row">
                                    <div class="col-md-6">
                                        <div class="form-group">
                                            <label for="paymentMethod"><i class="fas fa-credit-card text-primary mr-1"></i> Payment Method</label>
                                            <select class="form-control" id="paymentMethod" name="paymentMethod" required>
                                                <option value="">Select Payment Method</option>
                                                <option value="Credit Card">Credit Card</option>
                                                <option value="Bank Transfer">Bank Transfer</option>
                                                <option value="Check">Check</option>
                                                <option value="Cash">Cash</option>
                                                <option value="PayPal">PayPal</option>
                                            </select>
                                        </div>
                                    </div>
                                    <div class="col-md-6">
                                        <div class="form-group">
                                            <label for="transactionId"><i class="fas fa-hashtag text-primary mr-1"></i> Transaction ID</label>
                                            <input type="text" class="form-control" id="transactionId" name="transactionId" required>
                                            <small class="form-text text-muted">Unique identifier for this payment transaction</small>
                                        </div>
                                    </div>
                                </div>
                                
                                <div class="row">
                                    <div class="col-md-6">
                                        <div class="form-group">
                                            <label for="paymentDate"><i class="far fa-calendar-alt text-primary mr-1"></i> Payment Date</label>
                                            <input type="date" class="form-control" id="paymentDate" name="paymentDate" required>
                                            <small class="form-text text-muted">Today's date is set by default</small>
                                        </div>
                                    </div>
                                    <div class="col-md-6">
                                        <div class="form-group">
                                            <label for="status"><i class="fas fa-info-circle text-primary mr-1"></i> Status</label>
                                            <select class="form-control" id="status" name="status">
                                                <option value="Pending">Pending</option>
                                                <option value="Completed">Completed</option>
                                            </select>
                                            <small class="form-text text-muted">Initial status of this payment</small>
                                        </div>
                                    </div>
                                </div>
                                
                                <div class="form-group">
                                    <label for="remarks"><i class="fas fa-comment-alt text-primary mr-1"></i> Remarks</label>
                                    <textarea class="form-control" id="remarks" name="remarks" rows="3" placeholder="Enter any additional notes or comments about this payment..."></textarea>
                                </div>
                                
                                <div class="form-group d-flex justify-content-between align-items-center mt-4 pt-3 border-top">
                                    <a href="${pageContext.request.contextPath}/payment" class="btn btn-outline-secondary">
                                        <i class="fas fa-times mr-1"></i> Cancel
                                    </a>
                                    <button type="submit" class="btn btn-primary">
                                        <i class="fas fa-save mr-1"></i> Create Payment
                                    </button>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>
            </div>
        </c:if>
        
        <c:if test="${param.auctionId == null}">
            <!-- Payment List -->
            <div class="row mb-4 animate__animated animate__fadeIn animate__delay-1s">
                <div class="col-md-12">
                    <!-- Payment Statistics -->
                    <div class="row mb-4">
                        <div class="col-md-3">
                            <div class="stats-card success animate__animated animate__fadeInUp animate__delay-1s">
                                <div class="icon"><i class="fas fa-check-circle"></i></div>
                                <div class="number">${completedPaymentsCount != null ? completedPaymentsCount : 0}</div>
                                <div class="label">Completed Payments</div>
                            </div>
                        </div>
                        <div class="col-md-3">
                            <div class="stats-card warning animate__animated animate__fadeInUp animate__delay-1s">
                                <div class="icon"><i class="fas fa-clock"></i></div>
                                <div class="number">${pendingPaymentsCount != null ? pendingPaymentsCount : 0}</div>
                                <div class="label">Pending Payments</div>
                            </div>
                        </div>
                        <div class="col-md-3">
                            <div class="stats-card info animate__animated animate__fadeInUp animate__delay-1s">
                                <div class="icon"><i class="fas fa-dollar-sign"></i></div>
                                <div class="number">$<fmt:formatNumber value="${totalPaymentAmount != null ? totalPaymentAmount : 0}" pattern="#,##0.00"/></div>
                                <div class="label">Total Amount</div>
                            </div>
                        </div>
                        <div class="col-md-3">
                            <div class="stats-card animate__animated animate__fadeInUp animate__delay-1s">
                                <div class="icon"><i class="fas fa-calendar-check"></i></div>
                                <div class="number">${totalPaymentsCount != null ? totalPaymentsCount : 0}</div>
                                <div class="label">Total Payments</div>
                            </div>
                        </div>
                    </div>
                    
                    <div class="card animate__animated animate__fadeIn animate__delay-2s">
                        <div class="card-header">
                            <span><i class="fas fa-money-check-alt"></i> Payment Management</span>
                            <a href="${pageContext.request.contextPath}/auction" class="btn btn-primary">
                                <i class="fas fa-plus mr-1"></i> New Payment
                            </a>
                        </div>
                        <div class="card-body">
                            <!-- Filter Panel -->
                            <div class="filter-panel mb-4">
                                <form id="filterForm" action="${pageContext.request.contextPath}/payment" method="get">
                                    <div class="row">
                                        <div class="col-md-3">
                                            <div class="form-group">
                                                <label for="filterStatus"><i class="fas fa-filter text-primary mr-1"></i> Status</label>
                                                <select class="form-control" id="filterStatus" name="status">
                                                    <option value="">All Statuses</option>
                                                    <option value="COMPLETED" ${param.status == 'COMPLETED' ? 'selected' : ''}>Completed</option>
                                                    <option value="PENDING" ${param.status == 'PENDING' ? 'selected' : ''}>Pending</option>
                                                </select>
                                            </div>
                                        </div>
                                        <div class="col-md-3">
                                            <div class="form-group">
                                                <label for="filterMethod"><i class="fas fa-credit-card text-primary mr-1"></i> Payment Method</label>
                                                <select class="form-control" id="filterMethod" name="method">
                                                    <option value="">All Methods</option>
                                                    <option value="BANK_TRANSFER" ${param.method == 'BANK_TRANSFER' ? 'selected' : ''}>Bank Transfer</option>
                                                    <option value="CREDIT_CARD" ${param.method == 'CREDIT_CARD' ? 'selected' : ''}>Credit Card</option>
                                                    <option value="CHECK" ${param.method == 'CHECK' ? 'selected' : ''}>Check</option>
                                                    <option value="CASH" ${param.method == 'CASH' ? 'selected' : ''}>Cash</option>
                                                    <option value="PAYPAL" ${param.method == 'PAYPAL' ? 'selected' : ''}>PayPal</option>
                                                </select>
                                            </div>
                                        </div>
                                        <div class="col-md-3">
                                            <div class="form-group">
                                                <label for="filterDateFrom"><i class="fas fa-calendar-minus text-primary mr-1"></i> Date From</label>
                                                <input type="date" class="form-control" id="filterDateFrom" name="dateFrom" value="${param.dateFrom}">
                                            </div>
                                        </div>
                                        <div class="col-md-3">
                                            <div class="form-group">
                                                <label for="filterDateTo"><i class="fas fa-calendar-plus text-primary mr-1"></i> Date To</label>
                                                <input type="date" class="form-control" id="filterDateTo" name="dateTo" value="${param.dateTo}">
                                            </div>
                                        </div>
                                    </div>
                                    <div class="row">
                                        <div class="col-md-6">
                                            <div class="form-group">
                                                <label for="searchPayment"><i class="fas fa-search text-primary mr-1"></i> Search</label>
                                                <input type="text" class="form-control" id="searchPayment" placeholder="Search by ID, supplier, or transaction ID...">
                                            </div>
                                        </div>
                                        <div class="col-md-3">
                                            <div class="form-group">
                                                <label for="sortBy"><i class="fas fa-sort text-primary mr-1"></i> Sort By</label>
                                                <select class="form-control" id="sortBy">
                                                    <option value="date">Payment Date</option>
                                                    <option value="amount">Amount</option>
                                                    <option value="status">Status</option>
                                                    <option value="id">ID</option>
                                                </select>
                                            </div>
                                        </div>
                                        <div class="col-md-3 d-flex align-items-end">
                                            <div class="form-group w-100 mb-0">
                                                <div class="btn-group w-100">
                                                    <button type="submit" class="btn btn-primary">
                                                        <i class="fas fa-filter mr-1"></i> Apply Filters
                                                    </button>
                                                    <button type="button" id="clearFilters" class="btn btn-outline-secondary">
                                                        <i class="fas fa-undo mr-1"></i> Clear
                                                    </button>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </form>
                            </div>
                            
                            <!-- Payment Table -->
                            <div class="table-container">
                                <table id="paymentsTable" class="table table-hover">
                                    <thead>
                                        <tr>
                                            <th>ID</th>
                                            <th>Auction</th>
                                            <th>Supplier</th>
                                            <th>Amount</th>
                                            <th>Method</th>
                                            <th>Date</th>
                                            <th>Status</th>
                                            <th>Actions</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:if test="${not empty payments}">
                                            <c:forEach items="${payments}" var="payment" varStatus="status">
                                                <tr class="animate__animated animate__fadeIn" style="--animate-delay: ${status.index * 0.05}s;">
                                                    <td class="payment-id">#${payment.id}</td>
                                                    <td>
                                                        <a href="${pageContext.request.contextPath}/auction?action=view&id=${payment.auctionId}" class="text-primary" data-toggle="tooltip" title="View Auction Details">
                                                            <i class="fas fa-gavel mr-1"></i> ${payment.auctionId}
                                                        </a>
                                                    </td>
                                                    <td>
                                                        <div class="d-flex align-items-center">
                                                            <div class="supplier-avatar mr-2">
                                                                <i class="fas fa-building"></i>
                                                            </div>
                                                            <span>${payment.supplierName}</span>
                                                        </div>
                                                    </td>
                                                    <td class="payment-amount">$<fmt:formatNumber value="${payment.amount}" pattern="#,##0.00"/></td>
                                                    <td class="payment-method">
                                                        <c:choose>
                                                            <c:when test="${payment.paymentMethod == 'CREDIT_CARD'}"><i class="fas fa-credit-card text-info"></i></c:when>
                                                            <c:when test="${payment.paymentMethod == 'BANK_TRANSFER'}"><i class="fas fa-university text-primary"></i></c:when>
                                                            <c:when test="${payment.paymentMethod == 'CHECK'}"><i class="fas fa-money-check text-success"></i></c:when>
                                                            <c:when test="${payment.paymentMethod == 'CASH'}"><i class="fas fa-money-bill-wave text-success"></i></c:when>
                                                            <c:when test="${payment.paymentMethod == 'PAYPAL'}"><i class="fab fa-paypal text-info"></i></c:when>
                                                            <c:otherwise><i class="fas fa-money-bill-alt text-secondary"></i></c:otherwise>
                                                        </c:choose>
                                                        ${payment.paymentMethod}
                                                    </td>
                                                    <td class="payment-date"><fmt:formatDate value="${payment.paymentDate}" pattern="MMM dd, yyyy"/></td>
                                                    <td>
                                                        <c:choose>
                                                            <c:when test="${payment.status == 'COMPLETED'}">
                                                                <span class="badge badge-completed"><i class="fas fa-check"></i> Completed</span>
                                                            </c:when>
                                                            <c:when test="${payment.status == 'PENDING'}">
                                                                <span class="badge badge-pending"><i class="fas fa-clock"></i> Pending</span>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span class="badge badge-failed"><i class="fas fa-times"></i> Failed</span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                    <td>
                                                        <div class="btn-group">
                                                            <button class="btn btn-sm btn-action btn-info view-payment" data-id="${payment.id}" data-toggle="tooltip" title="View Details">
                                                                <i class="fas fa-eye"></i>
                                                            </button>
                                                            <c:if test="${payment.status == 'PENDING'}">
                                                                <button class="btn btn-sm btn-action btn-success complete-payment" data-id="${payment.id}" data-toggle="tooltip" title="Mark as Completed">
                                                                    <i class="fas fa-check"></i>
                                                                </button>
                                                            </c:if>
                                                            <c:if test="${payment.status == 'COMPLETED'}">
                                                                <button class="btn btn-sm btn-action btn-primary print-receipt" data-id="${payment.id}" data-toggle="tooltip" title="Print Receipt">
                                                                    <i class="fas fa-file-invoice"></i>
                                                                </button>
                                                            </c:if>
                                                        </div>
                                                    </td>
                                                </tr>
                                            </c:forEach>
                                        </c:if>
                                        <c:if test="${empty payments}">
                                            <tr>
                                                <td colspan="8">
                                                    <div class="empty-state">
                                                        <div class="icon"><i class="fas fa-file-invoice-dollar"></i></div>
                                                        <h3>No Payments Found</h3>
                                                        <p>There are no payments matching your current filters. Try clearing your filters or create a new payment.</p>
                                                        <a href="${pageContext.request.contextPath}/auction" class="btn btn-primary">
                                                            <i class="fas fa-plus mr-1"></i> Create New Payment
                                                        </a>
                                                    </div>
                                                </td>
                                            </tr>
                                        </c:if>
                                    </tbody>
                                </table>
                            </div>
                            
                            <c:if test="${not empty payments}">
                                <div class="d-flex justify-content-between align-items-center mt-3">
                                    <div>
                                        <select class="form-control form-control-sm" id="rowsPerPage">
                                            <option value="10">10 rows</option>
                                            <option value="25">25 rows</option>
                                            <option value="50">50 rows</option>
                                            <option value="100">100 rows</option>
                                        </select>
                                    </div>
                                    <nav aria-label="Payment pagination">
                                        <ul class="pagination pagination-sm">
                                            <li class="page-item disabled">
                                                <a class="page-link" href="#" tabindex="-1" aria-disabled="true">Previous</a>
                                            </li>
                                            <li class="page-item active"><a class="page-link" href="#">1</a></li>
                                            <li class="page-item"><a class="page-link" href="#">2</a></li>
                                            <li class="page-item"><a class="page-link" href="#">3</a></li>
                                            <li class="page-item">
                                                <a class="page-link" href="#">Next</a>
                                            </li>
                                        </ul>
                                    </nav>
                                </div>
                            </c:if>
            <div class="row mb-4">
                <div class="col-md-12">
                    <div class="card">
                        <div class="card-header">
                            <span>Payment Statistics</span>
                        </div>
                        <div class="card-body">
                            <div class="row">
                                <div class="col-md-3">
                                    <div class="stats-card">
                                        <div class="number">${totalPayments}</div>
                                        <div class="label">Total Payments</div>
                                    </div>
                                </div>
                                <div class="col-md-3">
                                    <div class="stats-card">
                                        <div class="number">$<fmt:formatNumber value="${totalAmount}" pattern="#,##0.00"/></div>
                                        <div class="label">Total Amount</div>
                                    </div>
                                </div>
                                <div class="col-md-3">
                                    <div class="stats-card">
                                        <div class="number">${completedCount}</div>
                                        <div class="label">Completed</div>
                                    </div>
                                </div>
                                <div class="col-md-3">
                                    <div class="stats-card">
                                        <div class="number">${pendingCount}</div>
                                        <div class="label">Pending</div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </c:if>
        
        <div class="row">
            <div class="col-md-12 text-center">
                <a href="${pageContext.request.contextPath}/" class="btn btn-primary">
                    <i class="fas fa-home"></i> Back to Dashboard
                </a>
            </div>
        </div>
    </div>
    
    <!-- View Payment Modal -->
    <div class="modal fade" id="viewPaymentModal" tabindex="-1" role="dialog" aria-labelledby="viewPaymentModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered" role="document">
            <div class="modal-content">
                <div class="modal-header bg-primary text-white">
                    <h5 class="modal-title" id="viewPaymentModalLabel"><i class="fas fa-file-invoice-dollar mr-2"></i> Payment Details</h5>
                    <button type="button" class="close text-white" data-dismiss="modal" aria-label="Close">
                        <span aria-hidden="true">&times;</span>
                    </button>
                </div>
                <div class="modal-body">
                    <div class="payment-details p-2">
                        <div class="payment-header mb-4 text-center">
                            <div class="payment-status-badge mb-2" id="payment-status-badge"></div>
                            <h4 class="payment-amount-large mb-0" id="payment-amount-large"></h4>
                            <p class="text-muted"><small id="payment-date-formatted"></small></p>
                        </div>
                        
                        <div class="row mb-4">
                            <div class="col-md-6">
                                <div class="detail-group">
                                    <label class="detail-label">Payment ID</label>
                                    <div class="detail-value" id="payment-id"></div>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div class="detail-group">
                                    <label class="detail-label">Auction ID</label>
                                    <div class="detail-value" id="payment-auction-id"></div>
                                </div>
                            </div>
                        </div>
                        
                        <div class="row mb-4">
                            <div class="col-md-6">
                                <div class="detail-group">
                                    <label class="detail-label">Supplier</label>
                                    <div class="detail-value" id="payment-supplier"></div>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div class="detail-group">
                                    <label class="detail-label">Transaction ID</label>
                                    <div class="detail-value" id="payment-transaction-id"></div>
                                </div>
                            </div>
                        </div>
                        
                        <div class="row mb-4">
                            <div class="col-md-6">
                                <div class="detail-group">
                                    <label class="detail-label">Payment Method</label>
                                    <div class="detail-value" id="payment-method"></div>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div class="detail-group">
                                    <label class="detail-label">Status</label>
                                    <div class="detail-value" id="payment-status"></div>
                                </div>
                            </div>
                        </div>
                        
                        <div class="row">
                            <div class="col-md-12">
                                <div class="detail-group">
                                    <label class="detail-label">Remarks</label>
                                    <div class="detail-value" id="payment-remarks"></div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-outline-secondary" data-dismiss="modal">
                        <i class="fas fa-times mr-1"></i> Close
                    </button>
                    <button type="button" class="btn btn-primary print-details">
                        <i class="fas fa-print mr-1"></i> Print Details
                    </button>
                </div>
            </div>
        </div>
    </div>
    
    <!-- Complete Payment Modal -->
    <div class="modal fade" id="completePaymentModal" tabindex="-1" role="dialog" aria-labelledby="completePaymentModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered" role="document">
            <div class="modal-content">
                <div class="modal-header bg-success text-white">
                    <h5 class="modal-title" id="completePaymentModalLabel"><i class="fas fa-check-circle mr-2"></i> Complete Payment</h5>
                    <button type="button" class="close text-white" data-dismiss="modal" aria-label="Close">
                        <span aria-hidden="true">&times;</span>
                    </button>
                </div>
                <div class="modal-body">
                    <div class="text-center mb-4">
                        <div class="complete-icon mb-3">
                            <i class="fas fa-check-circle text-success fa-4x"></i>
                        </div>
                        <h4>Mark Payment as Completed?</h4>
                        <p class="text-muted">This action will update the payment status to "Completed" and cannot be undone.</p>
                    </div>
                    <div class="alert alert-info">
                        <i class="fas fa-info-circle mr-2"></i> Completing a payment will automatically update the associated auction status.
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-outline-secondary" data-dismiss="modal">
                        <i class="fas fa-times mr-1"></i> Cancel
                    </button>
                    <form id="completePaymentForm" action="${pageContext.request.contextPath}/payment" method="post">
                        <input type="hidden" id="completePaymentId" name="id">
                        <input type="hidden" name="action" value="complete">
                        <button type="submit" class="btn btn-success">
                            <i class="fas fa-check mr-1"></i> Complete Payment
                        </button>
                    </form>
                </div>
            </div>
        </div>
    </div>
    
    </div> <!-- End of main-content -->
    
    <footer class="footer text-center">
        <div class="container">
            <p>&copy; <%= java.time.Year.now().getValue() %> Supplexio. All rights reserved.</p>
        </div>
    </footer>
    
    <script src="https://code.jquery.com/jquery-3.5.1.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/popper.js@1.16.1/dist/umd/popper.min.js"></script>
    <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.min.js"></script>
    <script src="https://cdn.datatables.net/1.10.22/js/jquery.dataTables.min.js"></script>
    <script src="https://cdn.datatables.net/1.10.22/js/dataTables.bootstrap4.min.js"></script>
    <script src="${pageContext.request.contextPath}/assets/js/payment-handler.js"></script>
    <script>
        $(document).ready(function() {
            // Initialize tooltips
            $('[data-toggle="tooltip"]').tooltip();
            
            // Initialize DataTable
            var table = $('#paymentsTable').DataTable({
                "paging": true,
                "ordering": true,
                "info": true,
                "searching": true,
                "lengthChange": false,
                "pageLength": 10,
                "language": {
                    "search": "",
                    "searchPlaceholder": "Search payments..."
                },
                "dom": '<"top"f>rt<"bottom"ip><"clear">'
            });
            
            // Connect search box
            $('#searchPayment').on('keyup', function() {
                table.search(this.value).draw();
            });
            
            // Connect status filter
            $('#filterStatus').on('change', function() {
                table.column(6).search(this.value).draw();
            });
            
            // Connect method filter
            $('#filterMethod').on('change', function() {
                table.column(4).search(this.value).draw();
            });
            
            // Connect sort by dropdown
            $('#sortBy').on('change', function() {
                var column = 0;
                switch($(this).val()) {
                    case 'date':
                        column = 5;
                        break;
                    case 'amount':
                        column = 3;
                        break;
                    case 'status':
                        column = 6;
                        break;
                    case 'id':
                        column = 0;
                        break;
                }
                table.order([column, 'asc']).draw();
            });
            
            // Connect rows per page selector
            $('#rowsPerPage').on('change', function() {
                table.page.len($(this).val()).draw();
            });
            
            // Clear filters button
            $('#clearFilters').on('click', function() {
                $('#searchPayment').val('');
                $('#filterStatus').val('');
                $('#filterMethod').val('');
                $('#filterDateFrom').val('');
                $('#filterDateTo').val('');
                $('#sortBy').val('date');
                table.search('').columns().search('').draw();
            });
            
            // Set today's date as default for payment date
            var today = new Date().toISOString().split('T')[0];
            $('#paymentDate').val(today);
            
            // Auto-fill amount when supplier is selected
            $('#supplierId').change(function() {
                var selectedOption = $(this).find('option:selected');
                var amount = selectedOption.data('amount');
                if (amount) {
                    $('#amount').val(amount);
                }
            });
            
            // View payment details
            $('.view-payment').click(function() {
                var paymentId = $(this).data('id');
                $.ajax({
                    url: '${pageContext.request.contextPath}/payment',
                    type: 'GET',
                    data: {
                        id: paymentId,
                        action: 'get'
                    },
                    success: function(response) {
                        var payment = JSON.parse(response);
                        
                        // Set payment status badge
                        var statusBadgeHtml = '';
                        if (payment.status === 'COMPLETED') {
                            statusBadgeHtml = '<span class="badge badge-completed"><i class="fas fa-check"></i> Completed</span>';
                        } else if (payment.status === 'PENDING') {
                            statusBadgeHtml = '<span class="badge badge-pending"><i class="fas fa-clock"></i> Pending</span>';
                        } else {
                            statusBadgeHtml = '<span class="badge badge-failed"><i class="fas fa-times"></i> Failed</span>';
                        }
                        $('#payment-status-badge').html(statusBadgeHtml);
                        
                        // Set payment amount in large format
                        $('#payment-amount-large').text('$' + payment.amount.toFixed(2));
                        
                        // Format date nicely
                        var paymentDate = new Date(payment.paymentDate);
                        var formattedDate = paymentDate.toLocaleDateString('en-US', { 
                            weekday: 'long', 
                            year: 'numeric', 
                            month: 'long', 
                            day: 'numeric' 
                        });
                        $('#payment-date-formatted').text(formattedDate);
                        
                        // Set other payment details
                        $('#payment-id').text('#' + payment.id);
                        $('#payment-auction-id').text('#' + payment.auctionId);
                        $('#payment-supplier').text(payment.supplierName);
                        
                        // Set payment method with icon
                        var methodIcon = '';
                        switch(payment.paymentMethod) {
                            case 'CREDIT_CARD':
                                methodIcon = '<i class="fas fa-credit-card text-info mr-2"></i>';
                                break;
                            case 'BANK_TRANSFER':
                                methodIcon = '<i class="fas fa-university text-primary mr-2"></i>';
                                break;
                            case 'CHECK':
                                methodIcon = '<i class="fas fa-money-check text-success mr-2"></i>';
                                break;
                            case 'CASH':
                                methodIcon = '<i class="fas fa-money-bill-wave text-success mr-2"></i>';
                                break;
                            case 'PAYPAL':
                                methodIcon = '<i class="fab fa-paypal text-info mr-2"></i>';
                                break;
                            default:
                                methodIcon = '<i class="fas fa-money-bill-alt text-secondary mr-2"></i>';
                        }
                        $('#payment-method').html(methodIcon + payment.paymentMethod);
                        
                        $('#payment-transaction-id').text(payment.transactionId);
                        $('#payment-status').text(payment.status);
                        $('#payment-remarks').text(payment.remarks || 'No remarks provided');
                        
                        $('#viewPaymentModal').modal('show');
                    },
                    error: function(xhr, status, error) {
                        alert('Error fetching payment details: ' + error);
                    }
                });
            });
            
            // Complete payment
            $('.complete-payment').click(function() {
                var paymentId = $(this).data('id');
                $('#completePaymentId').val(paymentId);
                $('#completePaymentModal').modal('show');
            });
            
            // Print receipt
            $('.print-receipt').click(function() {
                var paymentId = $(this).data('id');
                window.open('${pageContext.request.contextPath}/payment?action=receipt&id=' + paymentId, '_blank');
            });
            
            // Print payment details
            $('.print-details').click(function() {
                var printContents = $('.payment-details').html();
                var originalContents = document.body.innerHTML;
                
                document.body.innerHTML = '<div class="container mt-4">' + 
                    '<div class="text-center mb-4">' +
                    '<h2>Supplexio</h2>' +
                    '<h4>Payment Details</h4>' +
                    '</div>' + printContents + '</div>';
                
                window.print();
                document.body.innerHTML = originalContents;
                location.reload();
            });
            
            // Highlight row on hover
            $('#paymentsTable tbody').on('mouseenter', 'tr', function() {
                $(this).addClass('highlight');
            }).on('mouseleave', 'tr', function() {
                $(this).removeClass('highlight');
            });
        });
    </script>
</body>
</html>
