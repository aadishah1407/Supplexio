<%@ page import="java.sql.*, java.util.*" %>
<!DOCTYPE html>
<html>
<head>
    <title>Suppliers List</title>
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
</head>
<body>
    <div class="container">
        <h1 class="mt-4">Suppliers</h1>
        <table class="table table-striped mt-4">
            <thead class="thead-dark">
                <tr>
                    <th>ID</th>
                    <th>Name</th>
                    <th>Email</th>
                    <th>Phone</th>
                    <th>Address</th>
                </tr>
            </thead>
            <tbody>
            <%
                Connection conn = null;
                Statement stmt = null;
                ResultSet rs = null;
                try {
                    // NOTE: This is a direct JDBC connection.
                    // The application seems to use a JNDI data source, but for this simple page,
                    // we are connecting directly.
                    // This requires the MySQL JDBC driver to be in the classpath.
                    // Credentials are hardcoded based on project configuration.
                    Class.forName("com.mysql.cj.jdbc.Driver");
                    conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/supplexio", "root", "root");
                    stmt = conn.createStatement();
                    rs = stmt.executeQuery("SELECT id, name, email, phone, address FROM suppliers ORDER BY id DESC");
                    while (rs.next()) {
            %>
            <tr>
                <td><%= rs.getInt("id") %></td>
                <td><%= rs.getString("name") %></td>
                <td><%= rs.getString("email") %></td>
                <td><%= rs.getString("phone") %></td>
                <td><%= rs.getString("address") %></td>
            </tr>
            <%
                    }
                } catch (Exception e) {
            %>
                <tr>
                    <td colspan="5" class="text-danger">Error fetching data: <%= e.getMessage() %></td>
                </tr>
            <%
                    e.printStackTrace();
                } finally {
                    if (rs != null) try { rs.close(); } catch (SQLException e) {}
                    if (stmt != null) try { stmt.close(); } catch (SQLException e) {}
                    if (conn != null) try { conn.close(); } catch (SQLException e) {}
                }
            %>
            </tbody>
        </table>
    </div>
</body>
</html>
