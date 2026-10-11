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
    if (complaints == null) {
        response.sendRedirect("citizenDashboard");
        return;
    }

    int totalComplaints = complaints.size();
    int resolvedComplaints = 0;
    int pendingComplaints = 0;
    int escalatedComplaints = 0;
    for (Complaint complaint : complaints) {
        String status = complaint.getStatus() == null
                ? ""
                : complaint.getStatus().trim().toUpperCase(Locale.ROOT);
        if ("RESOLVED".equals(status)) {
            resolvedComplaints++;
        } else if ("PENDING".equals(status)) {
            pendingComplaints++;
        } else if ("ESCALATED".equals(status) ||
                "ESCALATION_PENDING".equals(status)) {
            escalatedComplaints++;
        }
    }

    SimpleDateFormat complaintDateFormat =
            new SimpleDateFormat("dd MMM yyyy", Locale.ENGLISH);
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Citizen Dashboard</title>
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
            <a class="active" href="citizenDashboard">Home</a>
            <a href="complaint.jsp">Register Complaint</a>
            <a href="myComplaints">My Complaints</a>
            <a href="changePassword">Change Password</a>
            <a href="logout">Logout</a>
        </nav>
    </div>
</header>

<main class="dashboard-page">
    <section class="dashboard-topbar">
        <div>
            <p class="eyebrow">Citizen portal</p>
            <h1 class="page-title">Citizen Dashboard</h1>
        </div>
        <div class="welcome-pill">Welcome, <strong><%= user.getName() %></strong></div>
    </section>

    <section class="summary-grid">
        <article class="summary-card card-blue">
            <div class="summary-icon" aria-hidden="true"><svg viewBox="0 0 24 24"><path d="M7 3h7l5 5v13H7a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2Z"/><path d="M14 3v6h5M9 13h6m-6 4h6"/></svg></div>
            <div>
                <span>Total Complaints</span>
                <strong><%= totalComplaints %></strong>
            </div>
        </article>

        <article class="summary-card card-green">
            <div class="summary-icon" aria-hidden="true"><svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="9"/><path d="m8 12 2.5 2.5L16 9"/></svg></div>
            <div>
                <span>Resolved</span>
                <strong><%= resolvedComplaints %></strong>
            </div>
        </article>

        <article class="summary-card card-orange">
            <div class="summary-icon" aria-hidden="true"><svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="9"/><path d="M12 7v5l3 2"/></svg></div>
            <div>
                <span>Pending</span>
                <strong><%= pendingComplaints %></strong>
            </div>
        </article>

        <article class="summary-card card-red">
            <div class="summary-icon" aria-hidden="true"><svg viewBox="0 0 24 24"><path d="M4 19V5m0 14h16"/><path d="m7 15 4-4 3 2 5-6"/><path d="M15 7h4v4"/></svg></div>
            <div>
                <span>Escalated</span>
                <strong><%= escalatedComplaints %></strong>
            </div>
        </article>
    </section>

    <section class="action-grid">
        <a class="action-card" href="complaint.jsp">
            <span class="action-icon" aria-hidden="true"><svg viewBox="0 0 24 24"><path d="M12 20h9"/><path d="m16.5 3.5 4 4L9 19l-5 1 1-5 11.5-11.5Z"/></svg></span>
            <strong>Raise Complaint</strong>
            <small>Register a new public grievance.</small>
        </a>

        <a class="action-card" href="myComplaints">
            <span class="action-icon" aria-hidden="true"><svg viewBox="0 0 24 24"><rect x="5" y="4" width="14" height="17" rx="2"/><path d="M9 4.5h6M9 10h6m-6 4h6m-6 4h4"/></svg></span>
            <strong>View Complaints</strong>
            <small>Check all submitted issues.</small>
        </a>

        <a class="action-card" href="myComplaints">
            <span class="action-icon" aria-hidden="true"><svg viewBox="0 0 24 24"><path d="M20 10c0 5-8 11-8 11S4 15 4 10a8 8 0 1 1 16 0Z"/><circle cx="12" cy="10" r="2.5"/></svg></span>
            <strong>Track Complaint Status</strong>
            <small>Monitor current progress and updates.</small>
        </a>

        <a class="action-card action-card-alt" href="logout">
            <span class="action-icon" aria-hidden="true"><svg viewBox="0 0 24 24"><path d="M10 17l5-5-5-5m5 5H3"/><path d="M12 3h7a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2h-7"/></svg></span>
            <strong>Logout</strong>
            <small>End your session securely.</small>
        </a>
    </section>

    <section class="table-panel">
        <div class="panel-heading">
            <h2>My Complaints</h2>
            <a href="myComplaints" class="table-link">View all complaints</a>
        </div>

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
                    if (complaints.isEmpty()) {
%>
                    <tr>
                        <td colspan="6" class="empty-complaints">
                            You have not registered any complaints yet.
                        </td>
                    </tr>
<%
                    } else {
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
                        <td><a href="complaintHistory?complaintId=<%= complaint.getComplaintId() %>" class="table-link">View</a></td>
                    </tr>
<%
                        }
                    }
%>
                </tbody>
            </table>
        </div>
    </section>
</main>

</body>
</html>
