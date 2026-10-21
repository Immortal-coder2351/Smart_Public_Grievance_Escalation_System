<%@ page import="com.grievance.model.User" %>
<%@ page import="com.grievance.model.Complaint" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.Locale" %>
<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    User user = (User) session.getAttribute("user");

    if (user == null || !"CITIZEN".equals(user.getRole())) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    List<Complaint> complaints =
            (List<Complaint>) request.getAttribute("complaints");

    SimpleDateFormat complaintDateFormat =
            new SimpleDateFormat("dd MMM yyyy", Locale.ENGLISH);
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Complaints</title>
    <link rel="stylesheet" href="css/style.css">
    <script src="js/script.js" defer></script>
    <style>
        .mobile-table-help {
            margin: 0 0 12px;
            font-size: 0.9rem;
            color: #555;
        }

        .accessible-table-wrap {
            width: 100%;
            max-width: 100%;
            overflow-x: auto;
            -webkit-overflow-scrolling: touch;
            border-radius: 8px;
        }

        .citizen-complaints-table {
            width: 100%;
            min-width: 680px;
            border-collapse: collapse;
        }

        .citizen-complaints-table th,
        .citizen-complaints-table td {
            padding: 12px;
            text-align: left;
            vertical-align: middle;
        }

        .citizen-complaints-table th {
            white-space: nowrap;
        }

        .citizen-complaints-table a:focus-visible,
        .nav-links a:focus-visible,
        .brand:focus-visible,
        .mini-btn:focus-visible,
        .page-footer a:focus-visible {
            outline: 3px solid #1769aa;
            outline-offset: 3px;
        }

        .table-link {
            display: inline-block;
            padding: 6px 8px;
            min-width: 44px;
            min-height: 44px;
            line-height: 32px;
            text-align: center;
        }

        @media (max-width: 600px) {
            .accessible-table-wrap {
                border: 1px solid #ddd;
            }

            .citizen-complaints-table th,
            .citizen-complaints-table td {
                padding: 10px;
            }

            .mobile-table-help {
                line-height: 1.5;
            }
        }

        @media (prefers-reduced-motion: reduce) {
            .accessible-table-wrap {
                scroll-behavior: auto;
            }
        }
    </style>
</head>
<body>

<header class="site-header">
    <div class="header-inner">
        <a class="brand dashboard-brand" href="citizenDashboard">
            <span class="brand-logo" aria-hidden="true">
                <svg viewBox="0 0 48 48">
                    <path d="M7 18 24 8l17 10M10 20h28M12 39h24M15 20v17m9-17v17m9-17v17M8 42h32"/>
                    <path d="m19 29 4 4 8-9"/>
                </svg>
            </span>
            Grievance System
        </a>
        <nav class="nav-links" aria-label="Citizen navigation">
            <a href="citizenDashboard">Dashboard</a>
            <a href="complaint.jsp">Register Complaint</a>
            <a class="active" href="myComplaints" aria-current="page">My Complaints</a>
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
        <div class="welcome-pill">
            Welcome, <strong><%= user.getName() %></strong>
        </div>
    </section>

    <section class="table-panel" aria-labelledby="complaint-status-heading">
        <div class="panel-heading">
            <div>
                <h2 id="complaint-status-heading">Complaint Status</h2>
                <p class="complaints-table-caption">Your latest complaints are listed first.</p>
            </div>
            <a href="complaint.jsp" class="mini-btn">+ New Complaint</a>
        </div>

<%
    if (complaints == null || complaints.isEmpty()) {
%>
        <p class="empty-complaints" role="status">You have not registered any complaints yet.</p>
<%
    } else {
%>
        <p class="mobile-table-help" id="table-scroll-help">
            On a small screen, swipe horizontally to view all complaint details.
        </p>

        <div class="accessible-table-wrap"
             role="region"
             aria-label="Your complaint records"
             aria-describedby="table-scroll-help"
             tabindex="0">
            <table class="citizen-complaints-table">
                <caption class="sr-only">Your registered complaints, their dates, current statuses, and history links.</caption>
                <thead>
                    <tr>
                        <th scope="col">Complaint ID</th>
                        <th scope="col">Category</th>
                        <th scope="col">Subject</th>
                        <th scope="col">Date</th>
                        <th scope="col">Status</th>
                        <th scope="col">Action</th>
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
                        <th scope="row" class="complaint-id">#<%= complaint.getComplaintId() %></th>
                        <td><%= complaint.getCategory() %></td>
                        <td class="complaint-title-cell"><%= complaint.getTitle() %></td>
                        <td><%= complaint.getCreatedAt() == null ? "—" : complaintDateFormat.format(complaint.getCreatedAt()) %></td>
                        <td>
                            <span class="status status-<%= statusClass %>">
                                <%= statusLabel %>
                            </span>
                        </td>
                        <td>
                            <a class="table-link"
                               href="complaintHistory?complaintId=<%= complaint.getComplaintId() %>"
                               aria-label="View history for complaint <%= complaint.getComplaintId() %>">View</a>
                        </td>
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