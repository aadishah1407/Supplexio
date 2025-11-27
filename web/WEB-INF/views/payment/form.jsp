<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${payment.id == 0 ? 'Create' : 'Edit'} Payment - Supplexio</title>
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.1/css/all.min.css">
    <style>
        :root {
            --supplexio-primary: rgb(0, 123, 255);
            --supplexio-secondary: rgb(108, 117, 125);
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
        }
        
        .card-header {
            background-color: var(--supplexio-primary);
            color: white;
            font-weight: 600;
            border-radius: 10px 10px 0 0 !important;
        }
        
        .btn-primary {
            background-color: var(--supplexio-primary);
            border-color: var(--supplexio-primary);
        }
        
        .btn-primary:hover {
            background-color: #0056b3;
            border-color: #0056b3;
        }
        
        .btn-secondary {
            background-color: var(--supplexio-secondary);
            border-color: var(--supplexio-secondary);
        }
        
        .btn-secondary:hover {
            background-color: #5a6268;
            border-color: #545b62;
        }
        
        .form-control:focus {
            border-color: var(--supplexio-primary);
            box-shadow: 0 0 0 0.2rem rgba(0, 123, 255, 0.25);
        }
        
        .required-field::after {
            content: " *";
            color: #dc3545;
        }
    </style>
</head>
<body>
    <div class="container">
        <nav aria-label="breadcrumb">
            <ol class="breadcrumb">
                <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/">Home</a></li>
                <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/payment">Payment Management</a></li>
                <li class="breadcrumb-item active" aria-current="page">${payment.id == 0 ? 'Create' : 'Edit'} Payment</li>
            </ol>
        </nav>
        
        <div class="card">
            <div class="card-header">
                <h4 class="mb-0">${payment.id == 0 ? 'Create New' : 'Edit'} Payment</h4>
            </div>
            <div class="card-body">
                <c:if test="${not empty error}">
                    <div class="alert alert-danger alert-dismissible fade show" role="alert">
                        ${error}
                        <button type="button" class="close" data-dismiss="alert" aria-label="Close">
                            <span aria-hidden="true">&times;</span>
                        </button>
                    </div>
                </c:if>
                
                <form method="post" action="${pageContext.request.contextPath}/payment" id="paymentForm">
                    <input type="hidden" name="action" value="${payment.id == 0 ? 'create' : 'update'}">
                    <input type="hidden" name="id" value="${payment.id}">
                    
                    <div class="form-row">
                        <div class="form-group col-md-6">
                            <label for="auctionId" class="required-field">Auction</label>
                            <input type="hidden" name="auctionId" value="${auction.id}">
                            <input type="text" class="form-control" value="${auction.productName} (ID: ${auction.id})" readonly>
                        </div>
                        
                        <div class="form-group col-md-6">
                            <label for="supplierId" class="required-field">Supplier</label>
                            <input type="hidden" name="supplierId" value="${supplier.id}">
                            <input type="text" class="form-control" value="${supplier.name} (ID: ${supplier.id})" readonly>
                        </div>
                    </div>
                    
                    <div class="form-row">
                        <div class="form-group col-md-6">
                            <label for="amount" class="required-field">Amount (₹)</label>
                            <input type="number" class="form-control" id="amount" name="amount" 
                                   value="${payment.amount}" step="0.01" min="0" required readonly>
                        </div>
                        
                        <div class="form-group col-md-6">
                            <label for="paymentMethod" class="required-field">Payment Method</label>
                            <select class="form-control" id="paymentMethod" name="paymentMethod" required>
                                <option value="">-- Select Payment Method --</option>
                                <option value="BANK_TRANSFER" ${payment.paymentMethod == 'BANK_TRANSFER' ? 'selected' : ''}>Bank Transfer</option>
                                <option value="CREDIT_CARD" ${payment.paymentMethod == 'CREDIT_CARD' ? 'selected' : ''}>Credit Card</option>
                                <option value="CHEQUE" ${payment.paymentMethod == 'CHEQUE' ? 'selected' : ''}>Cheque</option>
                                <option value="CASH" ${payment.paymentMethod == 'CASH' ? 'selected' : ''}>Cash</option>
                            </select>
                        </div>
                    </div>
                    
                    <div class="form-row">
                        <div class="form-group col-md-6">
                            <label for="transactionId">Transaction ID</label>
                            <input type="text" class="form-control" id="transactionId" name="transactionId" 
                                   value="${payment.transactionId}" maxlength="50">
                            <small class="form-text text-muted">Leave blank for cash payments or if not available yet</small>
                        </div>
                        
                        <div class="form-group col-md-6">
                            <label for="paymentDate" class="required-field">Payment Date</label>
                            <input type="date" class="form-control" id="paymentDate" name="paymentDate" 
                                   value="<fmt:formatDate value="${payment.paymentDate}" pattern="yyyy-MM-dd" />" required>
                        </div>
                    </div>
                    
                    <div class="form-row">
                        <div class="form-group col-md-6">
                            <label for="status" class="required-field">Status</label>
                            <select class="form-control" id="status" name="status" required>
                                <option value="PENDING" ${payment.status == 'PENDING' ? 'selected' : ''}>Pending</option>
                                <option value="COMPLETED" ${payment.status == 'COMPLETED' ? 'selected' : ''}>Completed</option>
                                <option value="FAILED" ${payment.status == 'FAILED' ? 'selected' : ''}>Failed</option>
                            </select>
                        </div>
                        
                        <div class="form-group col-md-6">
                            <label for="remarks">Notes</label>
                            <textarea class="form-control" id="remarks" name="remarks" rows="3">${payment.remarks}</textarea>
                        </div>
                    </div>
                    
                    <div class="form-group text-right">
                        <a href="${pageContext.request.contextPath}/payment" class="btn btn-secondary">
                            <i class="fas fa-times"></i> Cancel
                        </a>
                        <button type="submit" class="btn btn-primary">
                            <i class="fas fa-save"></i> ${payment.id == 0 ? 'Create' : 'Update'} Payment
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>
    
    <script src="https://code.jquery.com/jquery-3.5.1.slim.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/popper.js@1.16.1/dist/umd/popper.min.js"></script>
    <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.min.js"></script>
    <script>
        // Using anonymous inner class instead of lambda for Java 8 compatibility
        $(document).ready(function() {
            $('#paymentMethod').change(function() {
                var method = $(this).val();
                if (method === 'CASH') {
                    $('#transactionId').attr('disabled', 'disabled').val('');
                } else {
                    $('#transactionId').removeAttr('disabled');
                }
            });
            
            // Trigger the change event to set initial state
            $('#paymentMethod').trigger('change');
        });
    </script>
</body>
</html>
