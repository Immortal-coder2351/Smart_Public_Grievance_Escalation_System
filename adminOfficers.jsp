<%@ page import="com.grievance.model.User" %>
<%@ page import="com.grievance.dao.OfficerDAO" %>
<%@ page import="java.util.List" %>
<%
    User user = (User) session.getAttribute("user");

    if (user == null || !"ADMIN".equals(user.getRole())) {
        response.sendRedirect("login.jsp");
        return;
    }

    OfficerDAO officerDAO = new OfficerDAO();
    List<User> officers = officerDAO.getAllOfficers();

    String error = request.getParameter("error");
    String success = request.getParameter("success");

    String[] departmentNames = {
        "",
        "Roads",
        "Water Supply",
        "Electricity",
        "Sanitation",
        "Drainage",
        "Garbage Collection",
        "Street Lighting"
    };
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Manage Officers</title>
    <link rel="stylesheet" href="css/style.css">
    <script src="js/script.js" defer></script>
</head>
<body>

<header class="site-header">
    <div class="header-inner">
        <a class="brand" href="adminDashboard.jsp">Grievance System</a>
        <nav class="nav-links">
            <a href="adminDashboard.jsp">Dashboard</a>
            <a href="adminComplaints">Complaints</a>
            <a class="active" href="adminOfficers.jsp">Officers</a>
            <a href="changePassword">Change Password</a>
            <a href="logout">Logout</a>
        </nav>
    </div>
</header>

<main class="page">
    <h1 class="page-title">Officer Management</h1>
    <p class="page-subtitle">Welcome, <strong><%= user.getName() %></strong>.</p>

<%
    if ("officerAdded".equals(success)) {
%>
    <div class="message success">Officer added successfully.</div>
<%
    }

    if ("missing".equals(error)) {
%>
    <div class="message error">Please enter all required details.</div>
<%
    } else if ("username".equals(error)) {
%>
    <div class="message error">Username already exists.</div>
<%
    } else if ("email".equals(error)) {
%>
    <div class="message error">Email already exists.</div>
<%
    } else if ("invalidData".equals(error)) {
%>
    <div class="message error">Please enter valid officer details.</div>
<%
    } else if ("failed".equals(error)) {
%>
    <div class="message error">Officer could not be added.</div>
<%
    } else if ("server".equals(error)) {
%>
    <div class="message error">A server error occurred.</div>
<%
    }
%>

    <div class="two-column">
        <div class="content-card">
            <h2>Add Officer</h2>

            <form class="inline-form" action="addOfficer" method="post">
                <div class="form-field">
                    <label for="name">Name</label>
                    <input type="text" id="name" name="name" required>
                </div>

                <div class="form-field">
                    <label for="email">Email</label>
                    <input type="email" id="email" name="email" required>
                </div>

                <div class="form-field">
                    <label for="phone">Phone</label>
                    <input type="text" id="phone" name="phone">
                </div>

                <div class="form-field">
                    <label for="username">Username</label>
                    <input type="text" id="username" name="username" required>
                </div>

                <div class="form-field">
                    <label for="password">Password</label>
                    <input type="password" id="password" name="password" required>
                </div>

                <div class="form-field">
                    <label for="departmentId">Department</label>
                    <select id="departmentId" name="departmentId" required>
                        <option value="">Select Department</option>
                        <option value="1">Roads</option>
                        <option value="2">Water Supply</option>
                        <option value="3">Electricity</option>
                        <option value="4">Sanitation</option>
                        <option value="5">Drainage</option>
                        <option value="6">Garbage Collection</option>
                        <option value="7">Street Lighting</option>
                    </select>
                </div>

                <div class="form-field">
                    <label for="officerLevel">Officer Level</label>
                    <select id="officerLevel" name="officerLevel" required>
                        <option value="">Select Level</option>
                        <option value="1">Level 1</option>
                        <option value="2">Level 2</option>
                        <option value="3">Level 3</option>
                    </select>
                </div>

                <div class="form-actions">
                    <input type="submit" value="Add Officer">
                </div>
            </form>
        </div>

        <div class="content-card">
            <h2>Officer Structure</h2>
            <p class="small">Each department uses three escalation levels.</p>
            <ul class="action-list">
                <li><div class="quick-link"><strong>Level 1</strong> First assigned officer</div></li>
                <li><div class="quick-link"><strong>Level 2</strong> First escalation</div></li>
                <li><div class="quick-link"><strong>Level 3</strong> Final escalation level</div></li>
            </ul>
        </div>
    </div>

    <div class="content-card">
        <h2>Existing Officers</h2>
<%
    if (officers == null || officers.isEmpty()) {
%>
        <p>No officers found.</p>
<%
    } else {
%>
        <div class="table-wrap">
            <table>
                <tr>
                    <th>ID</th>
                    <th>Name</th>
                    <th>Email</th>
                    <th>Username</th>
                    <th>Department</th>
                    <th>Level</th>
                </tr>
<%
        for (User officer : officers) {
            int deptId = officer.getDepartmentId() == null ? 0 : officer.getDepartmentId();
            String deptName =
                    deptId >= 1 && deptId < departmentNames.length
                    ? departmentNames[deptId]
                    : String.valueOf(deptId);
%>
                <tr>
                    <td><%= officer.getUserId() %></td>
                    <td><%= officer.getName() %></td>
                    <td><%= officer.getEmail() %></td>
                    <td><%= officer.getUsername() %></td>
                    <td><%= deptName %></td>
                    <td>Level <%= officer.getOfficerLevel() %></td>
                </tr>
<%
        }
%>
            </table>
        </div>
<%
    }
%>
    </div>

    <div class="page-footer">
        <a href="adminDashboard.jsp">Back to Admin Dashboard</a>
    </div>
</main>

</body>
</html>
