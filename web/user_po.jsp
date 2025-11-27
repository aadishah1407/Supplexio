<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    List poList = (List) request.getAttribute("poList");
    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm");
%>
<!DOCTYPE html>
<html>
<head>
    <title>All Purchase Orders</title>
    <link rel="stylesheet" href="assets/css/common.css">
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.1/css/all.min.css">
    <style>
        .main-content { margin-left: 250px; padding: 2rem; }
        @media (max-width: 991px) {
            .sidebar { display: none; }
            .main-content { margin-left: 0; }
        }
    </style>
</head>
<body>
<!-- <jsp:include page="WEB-INF/views/includes/header.jsp" /> -->
<jsp:include page="WEB-INF/views/common/sidebar.jsp" />
<div class="main-content">
    <h2 class="mb-4">All Purchase Orders</h2>
    <div class="table-responsive">
        <table class="table table-striped table-bordered align-middle">
            <thead class="table-dark">
                <tr>
                    <th>PO ID</th>
                    <th>Supplier Name</th>
                    <th>Material</th>
                    <th>Amount</th>
                    <th>GST (7.5%)</th>
                    <th>Total (incl. GST)</th>
                    <th>Status</th>
                    <th>Created At</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
            <% if (poList != null && !poList.isEmpty()) {
                for (Object obj : poList) {
                    // Use reflection to access bean properties
                    Class<?> beanClass = obj.getClass();
                    double amount = Double.parseDouble(beanClass.getMethod("getAmount").invoke(obj).toString());
                    double gst = amount * 0.075;
                    double total = amount * 1.075;
            %>
                <tr>
                    <td><%= beanClass.getMethod("getId").invoke(obj) %></td>
                    <td><%= beanClass.getMethod("getCompanyName").invoke(obj) %></td>
                    <td><%= beanClass.getMethod("getMaterial").invoke(obj) %></td>
                    <td>Rs<%= String.format("%.2f", amount) %></td>
                    <td>Rs<%= String.format("%.2f", gst) %></td>
                    <td>Rs<%= String.format("%.2f", total) %></td>
                    <td><span class="badge bg-info"><%= beanClass.getMethod("getStatus").invoke(obj) %></span></td>
                    <td><%= sdf.format(beanClass.getMethod("getCreatedAt").invoke(obj)) %></td>
                    <td>
                        <form method="post" action="send-po-to-supplier" style="display:inline;">
                            <input type="hidden" name="poId" value="<%= beanClass.getMethod("getId").invoke(obj) %>" />
                            <input type="hidden" name="supplierId" value="<%= beanClass.getMethod("getSupplierId").invoke(obj) %>" />
                            <input type="hidden" name="material" value="<%= beanClass.getMethod("getMaterial").invoke(obj) %>" />
                            <input type="hidden" name="amount" value="<%= beanClass.getMethod("getAmount").invoke(obj) %>" />
                            <input type="hidden" name="quantity" value="<%= beanClass.getMethod("getQuantity").invoke(obj) %>" />
                            <button type="submit" class="btn btn-sm btn-primary">Send PO to Supplier</button>
                        </form>
                        <form method="get" action="download-po-pdf" style="display:inline;">
                            <input type="hidden" name="poId" value="<%= beanClass.getMethod("getId").invoke(obj) %>" />
                            <button type="submit" class="btn btn-sm btn-success">Download as PDF</button>
                        </form>
                    </td>
                </tr>
            <%  } 
            } else { %>
                <tr><td colspan="9" class="text-center">No purchase orders found.</td></tr>
            <% } %>
            </tbody>
        </table>
    </div>
</div>
<jsp:include page="WEB-INF/views/includes/footer.jsp" />
</body>
</html>
