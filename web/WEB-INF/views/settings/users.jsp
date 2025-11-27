<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>User Management - Supplexio</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/bootstrap.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/supplexio-theme.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/settings.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.3/css/all.min.css">
</head>
<body>
    <!-- Left Menu -->
    <div class="left-menu">
        <div class="logo-container">
            <a href="${pageContext.request.contextPath}/">
                <div class="logo-container">
                    <img src="${pageContext.request.contextPath}/assets/img/supplexio-logo.png" alt="Supplexio Logo" class="logo-img">
                </div>
            </a>
        </div>
        <ul>
            <li><a href="${pageContext.request.contextPath}/"><i class="fas fa-home"></i> Home</a></li>
            <li><a href="${pageContext.request.contextPath}/product"><i class="fas fa-box"></i> Products</a></li>
            <li><a href="${pageContext.request.contextPath}/auction"><i class="fas fa-gavel"></i> Reverse Auctions</a></li>
            <li><a href="${pageContext.request.contextPath}/supplier"><i class="fas fa-truck"></i> Suppliers</a></li>
            <li><a href="${pageContext.request.contextPath}/payment"><i class="fas fa-credit-card"></i> Payments</a></li>
            <li><a href="${pageContext.request.contextPath}/todo"><i class="fas fa-tasks"></i> To-Do List</a></li>
            <li class="active"><a href="${pageContext.request.contextPath}/settings?action=users"><i class="fas fa-cog"></i> Settings</a></li>
        </ul>
        <div class="tagline-container">
            <p class="tagline">WE LIVE COATINGS</p>
        </div>
    </div>
    
    <!-- Main Content -->
    <div class="content-wrapper">
        <div class="page-header">
            <h1 class="page-title">User Management</h1>
            <a href="${pageContext.request.contextPath}/settings?action=newUser" class="btn-supplexio">
                <i class="fas fa-plus-circle"></i> Add New User
            </a>
        </div>
        
        <c:if test="${not empty sessionScope.successMessage}">
            <div class="alert alert-success alert-dismissible fade show" role="alert">
                ${sessionScope.successMessage}
                <button type="button" class="close" data-dismiss="alert" aria-label="Close">
                    <span aria-hidden="true">&times;</span>
                </button>
            </div>
            <c:remove var="successMessage" scope="session" />
        </c:if>
        
        <c:if test="${not empty sessionScope.errorMessage}">
            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                ${sessionScope.errorMessage}
                <button type="button" class="close" data-dismiss="alert" aria-label="Close">
                    <span aria-hidden="true">&times;</span>
                </button>
            </div>
            <c:remove var="errorMessage" scope="session" />
        </c:if>
        
        <div class="users-table">
            <table>
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Username</th>
                        <th>Email</th>
                        <th>Role</th>
                        <th>Status</th>
                        <th>Last Login</th>
                        <th>Created</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach items="${users}" var="user">
                        <tr>
                            <td>${user.id}</td>
                            <td>${user.username}</td>
                            <td>${user.email}</td>
                            <td>${user.role}</td>
                            <td>
                                <span class="status-badge status-${user.status.toLowerCase()}">
                                    ${user.status}
                                </span>
                            </td>
                            <td>
                                <fmt:formatDate value="${user.lastLogin}" pattern="yyyy-MM-dd HH:mm" />
                            </td>
                            <td>
                                <fmt:formatDate value="${user.createdAt}" pattern="yyyy-MM-dd" />
                            </td>
                            <td>
                                <a href="${pageContext.request.contextPath}/settings?action=editUser&id=${user.id}" 
                                   class="action-btn edit">
                                    Edit
                                </a>
                            </td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
        </div>
        
        <div class="footer-text">
            <p>Global leader in coatings providing customers with innovative, colorful, beautiful and sustainable solutions.</p>
            <p>© ${java.time.Year.now().getValue()} Supplexio. All rights reserved.</p>
        </div>
    </div>
    
    <script src="https://code.jquery.com/jquery-3.5.1.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@4.5.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
