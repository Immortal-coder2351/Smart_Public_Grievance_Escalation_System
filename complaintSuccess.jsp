<%@ page import="com.grievance.model.User" %>
<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    User user = (User) session.getAttribute("user");

    if (user == null || !"CITIZEN".equals(user.getRole())) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    String complaintId = request.getParameter("complaintId");
    boolean validComplaintId = false;

    if (complaintId != null && !complaintId.trim().isEmpty()) {
        try {
            validComplaintId = Integer.parseInt(complaintId.trim()) > 0;
        } catch (NumberFormatException e) {
            validComplaintId = false;
        }
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate">
    <meta http-equiv="Pragma" content="no-cache">
    <meta http-equiv="Expires" content="0">
    <title>Complaint Submitted</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
    <script src="<%= request.getContextPath() %>/js/script.js" defer></script>
</head>
<body>

<header class="site-header">
    <div class="header-inner">
        <a class="brand" href="<%= request.getContextPath() %>/citizenDashboard">Grievance System</a>
        <nav class="nav-links">
            <a href="<%= request.getContextPath() %>/citizenDashboard">Dashboard</a>
            <a href="<%= request.getContextPath() %>/myComplaints">My Complaints</a>
            <a href="<%= request.getContextPath() %>/changePassword">Change Password</a>
            <a href="<%= request.getContextPath() %>/logout">Logout</a>
        </nav>
    </div>
</header>

<main class="page">
    <div class="form-card narrow center">
        <h1 class="page-title">Complaint Submitted</h1>
        <p>Your complaint has been registered successfully.</p>

        <% if (validComplaintId) { %>
        <div class="message success">
            Complaint ID: <strong><%= complaintId.trim() %></strong>
        </div>

        <p class="small">
            Please keep this Complaint ID for tracking your complaint.
        </p>
        <% } %>

        <p><a class="btn" href="<%= request.getContextPath() %>/myComplaints">View My Complaints</a></p>
        <p><a href="<%= request.getContextPath() %>/complaint.jsp">Register Another Complaint</a></p>
        <p><a href="<%= request.getContextPath() %>/citizenDashboard">Back to Citizen Dashboard</a></p>
    </div>
</main>

</body>
</html>