<%@ page import="com.grievance.model.User" %>
<%@ page import="com.grievance.model.Complaint" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.Locale" %>
<%
    User user = (User) session.getAttribute("user");

    if (user == null || !"CITIZEN".equals(user.getRole())) {
        response.sendRedirect("login.jsp");
        return;
    }

    List<Complaint> complaints =
            (List<Complaint>) request.getAttribute("complaints");
    SimpleDateFormat complaintDateFormat =
            new SimpleDateFormat("dd MMM yyyy", Locale.ENGLISH);
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Complaints</title>
    <link rel="stylesheet" href="css/style.css">
    <script src="js/script.js" defer></script>
</head>
<body>

<header class="site-header">
    <div class="header-inner">
        <a class="brand dashboard-brand" href="citizenDashboard">
            <span class="brand-logo" aria-hidden="true"><svg viewBox="0 0 48 48"><path d="M7 18 24 8l17 10M10 20h28M12 39h24M15 20v17m9-17v17m9-17v17M8 42h32"/><path d="m19 29 4 4 8-9"/></svg></span>
            Grievance System
        </a>
        <nav class="nav-links">
            <a href="citizenDashboard">Dashboard</a>
            <a href="complaint.jsp">Register Complaint</a>
            <a class="active" href="myComplaints">My Complaints</a>
            <a href="changePassword">Change Password</a>
            <a href="logout">Logout</a>
        </nav>
    </div>
</header>

<main class="dashboard-page complaints-page">
    <section class="dashboard-topbar">
        <div>
            <p class="eyebrow">Citizen portal</p>
            <h1 class="page-title">My Complaints</h1>
            <p class="page-subtitle">Track the progress and history of your submitted complaints.</p>
        </div>
        <div class="welcome-pill">Welcome, <strong><%= user.getName() %></strong></div>
    </section>

    <section class="table-panel">
        <div class="panel-heading">
            <div>
                <h2>Complaint Status</h2>
                <p class="complaints-table-caption">Your latest complaints are listed first.</p>
            </div>
            <a href="complaint.jsp" class="mini-btn">+ New Complaint</a>
        </div>
<%
    if (complaints == null || complaints.isEmpty()) {
%>
        <p class="empty-complaints">You have not registered any complaints yet.</p>
<%
    } else {
%>
        <div class="table-wrap">
            <table class="citizen-complaints-table">
                <thead>
                    <tr>
                        <th>Complaint ID</th>
                        <th>Category</th>
                        <th>Subject</th>
                        <th>Date</th>
                        <th>Status</th>
                        <th>Action</th>
                    </tr>
                </thead>
                <tbody>
<%
        for (Complaint complaint : complaints) {
            String rawStatus = complaint.getStatus() == null ||
                    complaint.getStatus().trim().isEmpty()
                    ? "PENDING"
                    : complaint.getStatus().trim().toUpperCase(Locale.ROOT);
            String statusClass = rawStatus.toLowerCase(Locale.ROOT)
                    .replace('_', '-');
            String statusLabel = rawStatus.replace('_', ' ')
                    .toLowerCase(Locale.ROOT);
            statusLabel = statusLabel.substring(0, 1).toUpperCase(Locale.ROOT)
                    + statusLabel.substring(1);
%>
                    <tr>
                        <td class="complaint-id">#<%= complaint.getComplaintId() %></td>
                        <td><%= complaint.getCategory() %></td>
                        <td class="complaint-title-cell"><%= complaint.getTitle() %></td>
                        <td><%= complaint.getCreatedAt() == null ? "—" : complaintDateFormat.format(complaint.getCreatedAt()) %></td>
                        <td><span class="status status-<%= statusClass %>"><%= statusLabel %></span></td>
                        <td><a class="table-link" href="complaintHistory?complaintId=<%= complaint.getComplaintId() %>">View</a></td>
                    </tr>
<%
        }
%>
                </tbody>
            </table>
        </div>
<%
    }
%>
    </section>

    <div class="page-footer">
        <a href="citizenDashboard">Back to Citizen Dashboard</a>
    </div>
</main>

</body>
</html>
