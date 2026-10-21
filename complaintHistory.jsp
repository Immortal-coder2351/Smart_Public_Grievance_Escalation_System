<%@ page import="com.grievance.model.User" %>
<%@ page import="java.util.List" %>
<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    User user = (User) session.getAttribute("user");

    if (user == null ||
            (!"CITIZEN".equals(user.getRole()) &&
             !"OFFICER".equals(user.getRole()) &&
             !"ADMIN".equals(user.getRole()))) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    List<String[]> history =
            (List<String[]>) request.getAttribute("history");

    Integer complaintId =
            (Integer) request.getAttribute("complaintId");

    String dashboardLink;

    if ("CITIZEN".equals(user.getRole())) {
        dashboardLink = "citizenDashboard";
    } else if ("OFFICER".equals(user.getRole())) {
        dashboardLink = "officerDashboard.jsp";
    } else {
        dashboardLink = "adminDashboard.jsp";
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Complaint History</title>
    <link rel="stylesheet" href="css/style.css">
    <script src="js/script.js" defer></script>
    <style>
        .history-table-wrap {
            width: 100%;
            max-width: 100%;
            overflow-x: auto;
            -webkit-overflow-scrolling: touch;
        }

        .history-table {
            width: 100%;
            min-width: 850px;
            border-collapse: collapse;
        }

        .history-table th,
        .history-table td {
            padding: 12px;
            text-align: left;
            vertical-align: top;
        }

        .history-table th {
            white-space: nowrap;
        }

        .history-table-wrap:focus-visible,
        .page-footer a:focus-visible {
            outline: 3px solid #1769aa;
            outline-offset: 3px;
        }

        .history-table caption {
            text-align: left;
            padding: 10px 0;
        }

        .history-table td {
            overflow-wrap: anywhere;
        }

        @media (max-width: 600px) {
            .history-table th,
            .history-table td {
                padding: 10px;
            }
        }
    </style>
</head>
<body>

<header class="site-header">
    <div class="header-inner">
        <a class="brand dashboard-brand" href="<%= dashboardLink %>">
            <span class="brand-logo" aria-hidden="true">
                <svg viewBox="0 0 48 48">
                    <path d="M7 18 24 8l17 10M10 20h28M12 39h24M15 20v17m9-17v17m9-17v17M8 42h32"/>
                    <path d="m19 29 4 4 8-9"/>
                </svg>
            </span>
            Grievance System
        </a>
        <nav class="nav-links" aria-label="Main navigation">
            <a href="<%= dashboardLink %>">Dashboard</a>
            <a href="logout">Logout</a>
        </nav>
    </div>
</header>

<main class="dashboard-page complaints-page">
    <section class="dashboard-topbar">
        <div>
            <p class="eyebrow">Grievance records</p>
            <h1 class="page-title">Complaint History</h1>
            <p class="page-subtitle">
                View the assignment and escalation history for this complaint.
            </p>
        </div>
        <% if (complaintId != null) { %>
        <div class="welcome-pill">
            Complaint ID: <strong>#<%= complaintId %></strong>
        </div>
        <% } %>
    </section>

    <section class="table-panel" aria-labelledby="history-heading">
        <div class="panel-heading">
            <div>
                <h2 id="history-heading">Escalation History</h2>
                <p class="complaints-table-caption">
                    Review officer assignments, escalation levels, deadlines, and remarks.
                </p>
            </div>
        </div>

        <% if (history == null || history.isEmpty()) { %>
            <p class="empty-complaints" role="status">
                No escalation history is available for this complaint.
            </p>
        <% } else { %>
            <p id="history-scroll-help" class="mobile-table-help">
                On a small screen, swipe horizontally to view all history details.
            </p>

            <div class="history-table-wrap"
                 role="region"
                 aria-label="Complaint escalation history records"
                 aria-describedby="history-scroll-help"
                 tabindex="0">
                <table class="history-table">
                    <caption>Assignment and escalation records for complaint #<%= complaintId %></caption>
                    <thead>
                        <tr>
                            <th scope="col">Assignment</th>
                            <th scope="col">Officer</th>
                            <th scope="col">Officer Level</th>
                            <th scope="col">Escalation Level</th>
                            <th scope="col">Escalated At</th>
                            <th scope="col">Deadline</th>
                            <th scope="col">Remarks</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% for (String[] row : history) { %>
                        <tr>
                            <th scope="row"><%= row[0] == null ? "—" : row[0] %></th>
                            <td><%= row[1] == null ? "—" : row[1] %></td>
                            <td><%= row[2] == null ? "—" : row[2] %></td>
                            <td><%= row[3] == null ? "—" : row[3] %></td>
                            <td><%= row[4] == null ? "—" : row[4] %></td>
                            <td><%= row[5] == null ? "—" : row[5] %></td>
                            <td><%= row[6] == null || row[6].trim().isEmpty() ? "—" : row[6] %></td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
        <% } %>
    </section>

    <div class="page-footer">
        <a href="<%= dashboardLink %>">Back to Dashboard</a>
    </div>
</main>

</body>
</html>