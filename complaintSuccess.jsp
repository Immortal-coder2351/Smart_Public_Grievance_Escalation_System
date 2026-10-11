<%@ page import="com.grievance.model.User" %>
<%
    User user = (User) session.getAttribute("user");

    if (user == null || !"CITIZEN".equals(user.getRole())) {
        response.sendRedirect("login.jsp");
        return;
    }

    String complaintId = request.getParameter("complaintId");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Complaint Submitted</title>
    <link rel="stylesheet" href="css/style.css">
    <script src="js/script.js" defer></script>
</head>
<body>

<header class="site-header">
    <div class="header-inner">
        <a class="brand" href="citizenDashboard">Grievance System</a>
        <nav class="nav-links">
            <a href="citizenDashboard">Dashboard</a>
            <a href="myComplaints">My Complaints</a>
            <a href="changePassword">Change Password</a>
            <a href="logout">Logout</a>
        </nav>
    </div>
</header>

<main class="page">
    <div class="form-card narrow center">
        <h1 class="page-title">Complaint Submitted</h1>
        <p>Your complaint has been registered successfully.</p>

        <%
            if (complaintId != null && !complaintId.trim().isEmpty()) {
        %>
        <div class="message success">
            Complaint ID: <strong><%= complaintId %></strong>
        </div>

        <p class="small">
            Please keep this Complaint ID for tracking your complaint.
        </p>
        <%
            }
        %>

        <p><a class="btn" href="myComplaints">View My Complaints</a></p>
        <p><a href="complaint.jsp">Register Another Complaint</a></p>
        <p><a href="citizenDashboard">Back to Citizen Dashboard</a></p>
    </div>
</main>

</body>
</html>
