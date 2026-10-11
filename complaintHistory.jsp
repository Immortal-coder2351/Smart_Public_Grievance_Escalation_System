<%@ page import="com.grievance.model.User" %>
<%@ page import="java.util.List" %>
<%
    User user = (User) session.getAttribute("user");

    if (user == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    List<String[]> history =
            (List<String[]>) request.getAttribute("history");

    Integer complaintId = (Integer) request.getAttribute("complaintId");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Complaint History</title>
    <link rel="stylesheet" href="css/style.css">
    <script src="js/script.js" defer></script>
</head>
<body>

<header class="site-header">
    <div class="header-inner">
        <a class="brand" href="<%= "CITIZEN".equals(user.getRole()) ? "citizenDashboard" : "OFFICER".equals(user.getRole()) ? "officerDashboard.jsp" : "adminDashboard.jsp" %>">Grievance System</a>
        <nav class="nav-links">
            <a href="<%= "CITIZEN".equals(user.getRole()) ? "citizenDashboard" : "OFFICER".equals(user.getRole()) ? "officerDashboard.jsp" : "adminDashboard.jsp" %>">Dashboard</a>
            <a href="changePassword">Change Password</a>
            <a href="logout">Logout</a>
        </nav>
    </div>
</header>

<main class="dashboard-page complaints-page">
    <section class="dashboard-topbar">
        <div>
            <p class="eyebrow">Complaint tracking</p>
            <h1 class="page-title">Escalation History</h1>
            <p class="page-subtitle">
                Escalation events for complaint <strong>#<%= complaintId %></strong>.
            </p>
        </div>
    </section>

    <section class="table-panel">
        <div class="panel-heading">
            <div>
                <h2>Escalated Assignments</h2>
                <p class="complaints-table-caption">Only assignments that were escalated are shown here.</p>
            </div>
        </div>
<%
    if (history == null || history.isEmpty()) {
%>
        <div class="history-empty-state">
            <span class="history-empty-icon" aria-hidden="true">
                <svg viewBox="0 0 24 24"><path d="M12 3 22 20H2L12 3Z"/><path d="M12 9v5m0 3h.01"/></svg>
            </span>
            <strong>No escalation history</strong>
            <p>This complaint has no active escalation records. If an administrator reassigns it, its previous escalation is cleared from this view.</p>
        </div>
<%
    } else {
%>
        <div class="table-wrap">
            <table class="history-table">
                <thead>
                    <tr>
                        <th>Assignment</th>
                        <th>Officer</th>
                        <th>Officer Level</th>
                        <th>Escalation Level</th>
                        <th>Escalated At</th>
                        <th>Deadline</th>
                        <th>Remarks</th>
                    </tr>
                </thead>
                <tbody>
<%
        for (String[] record : history) {
%>
                <tr>
                    <td class="complaint-id">#<%= record[0] %></td>
                    <td><strong><%= record[1] %></strong></td>
                    <td><span class="history-level">Level <%= record[2] %></span></td>
                    <td><span class="history-level escalation-level">Level <%= record[3] %></span></td>
                    <td><%= record[7] %></td>
                    <td><%= record[5] %></td>
                    <td class="history-remarks"><%= record[8] == null || record[8].trim().isEmpty() ? "—" : record[8] %></td>
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
<%
    if ("CITIZEN".equals(user.getRole())) {
%>
        <a href="citizenDashboard">Back to Citizen Dashboard</a>
<%
    } else if ("OFFICER".equals(user.getRole())) {
%>
        <a href="officerDashboard.jsp">Back to Officer Dashboard</a>
<%
    } else if ("ADMIN".equals(user.getRole())) {
%>
        <a href="adminDashboard.jsp">Back to Admin Dashboard</a>
<%
    }
%>
    </div>
</main>

</body>
</html>
