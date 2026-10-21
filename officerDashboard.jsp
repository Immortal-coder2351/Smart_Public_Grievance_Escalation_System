<%@ page import="com.grievance.model.User" %>
<%@ page import="com.grievance.model.Complaint" %>
<%@ page import="com.grievance.dao.OfficerComplaintDAO" %>
<%@ page import="com.grievance.dao.DBConnection" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Locale" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%!
    private String escapeHtml(Object value) {
        if (value == null) {
            return "";
        }

        String text = String.valueOf(value);
        return text.replace("&", "&amp;")
                   .replace("<", "&lt;")
                   .replace(">", "&gt;")
                   .replace("\"", "&quot;")
                   .replace("'", "&#39;");
    }
%>
<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    String contextPath = request.getContextPath();
    User user = (User) session.getAttribute("user");

    if (user == null || !"OFFICER".equals(user.getRole())) {
        response.sendRedirect(contextPath + "/login.jsp");
        return;
    }

    List<Complaint> recentComplaints =
            new OfficerComplaintDAO().getRecentOfficerComplaints(user.getUserId());

    SimpleDateFormat complaintDateFormat =
            new SimpleDateFormat("dd MMM yyyy", Locale.ENGLISH);

    int pending = 0;
    int inProgress = 0;
    int resolved = 0;
    int escalated = 0;
    int highPriority = 0;
    String statsError = null;
    String priorityError = null;

    String statsSql =
        "SELECT " +
        "COALESCE(SUM(CASE " +
        "WHEN UPPER(TRIM(COALESCE(ca.status, ''))) = 'PENDING' " +
        "AND UPPER(REPLACE(TRIM(COALESCE(c.status, 'PENDING')), ' ', '_')) NOT IN ('IN_PROGRESS', 'RESOLVED') " +
        "THEN 1 ELSE 0 END), 0) AS pending, " +
        "COALESCE(SUM(CASE " +
        "WHEN UPPER(TRIM(COALESCE(ca.status, ''))) = 'PENDING' " +
        "AND UPPER(REPLACE(TRIM(COALESCE(c.status, '')), ' ', '_')) = 'IN_PROGRESS' " +
        "THEN 1 ELSE 0 END), 0) AS in_progress, " +
        "COALESCE(SUM(CASE " +
        "WHEN UPPER(TRIM(COALESCE(ca.status, ''))) = 'RESOLVED' " +
        "OR UPPER(TRIM(COALESCE(c.status, ''))) = 'RESOLVED' " +
        "THEN 1 ELSE 0 END), 0) AS resolved, " +
        "COALESCE(SUM(CASE " +
        "WHEN UPPER(TRIM(COALESCE(ca.status, ''))) = 'ESCALATED' " +
        "AND UPPER(TRIM(COALESCE(c.status, ''))) <> 'RESOLVED' " +
        "THEN 1 ELSE 0 END), 0) AS escalated " +
        "FROM complaint_assignments ca " +
        "JOIN complaints c ON c.complaint_id = ca.complaint_id " +
        "WHERE ca.officer_id = ?";

    try (Connection connection = DBConnection.getConnection();
         PreparedStatement statement = connection.prepareStatement(statsSql)) {

        statement.setInt(1, user.getUserId());

        try (ResultSet resultSet = statement.executeQuery()) {
            if (resultSet.next()) {
                pending = resultSet.getInt("pending");
                inProgress = resultSet.getInt("in_progress");
                resolved = resultSet.getInt("resolved");
                escalated = resultSet.getInt("escalated");
            }
        }
    } catch (Exception e) {
        statsError = "Officer statistics could not be loaded. Check the Tomcat console and database connection.";
        application.log("Unable to load officer dashboard statistics.", e);
    }

    String prioritySql =
        "SELECT COUNT(DISTINCT c.complaint_id) AS high_priority_count " +
        "FROM complaint_assignments ca " +
        "JOIN complaints c ON c.complaint_id = ca.complaint_id " +
        "WHERE ca.officer_id = ? " +
        "AND UPPER(TRIM(COALESCE(ca.status, ''))) = 'PENDING' " +
        "AND UPPER(TRIM(COALESCE(c.priority, ''))) = 'HIGH' " +
        "AND UPPER(TRIM(COALESCE(c.status, ''))) <> 'RESOLVED'";

    try (Connection connection = DBConnection.getConnection();
         PreparedStatement statement = connection.prepareStatement(prioritySql)) {

        statement.setInt(1, user.getUserId());

        try (ResultSet resultSet = statement.executeQuery()) {
            if (resultSet.next()) {
                highPriority = resultSet.getInt("high_priority_count");
            }
        }
    } catch (Exception e) {
        priorityError = "Priority count is unavailable. Confirm that complaints.priority exists in smart_grievance.";
        application.log("Unable to load officer high-priority count.", e);
    }

    int total = pending + inProgress + resolved + escalated;
    int chartTotal = total > 0 ? total : 1;
    int pendingEnd = Math.round((pending * 360f) / chartTotal);
    int inProgressEnd = Math.round(((pending + inProgress) * 360f) / chartTotal);
    int resolvedEnd = Math.round(((pending + inProgress + resolved) * 360f) / chartTotal);

    String pieStyle;

    if (total == 0) {
        pieStyle = "background: conic-gradient(#d1d5db 0deg 360deg);";
    } else {
        pieStyle = "background: conic-gradient(" +
            "#ffb703 0deg " + pendingEnd + "deg, " +
            "#3a86ff " + pendingEnd + "deg " + inProgressEnd + "deg, " +
            "#2ec4b6 " + inProgressEnd + "deg " + resolvedEnd + "deg, " +
            "#ef476f " + resolvedEnd + "deg 360deg);";
    }

    int pendingHeight = pending == 0 ? 8 : Math.max(12, Math.min(100, Math.round((pending * 100f) / chartTotal)));
    int progressHeight = inProgress == 0 ? 8 : Math.max(12, Math.min(100, Math.round((inProgress * 100f) / chartTotal)));
    int resolvedHeight = resolved == 0 ? 8 : Math.max(12, Math.min(100, Math.round((resolved * 100f) / chartTotal)));
    int escalatedHeight = escalated == 0 ? 8 : Math.max(12, Math.min(100, Math.round((escalated * 100f) / chartTotal)));
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate">
    <meta http-equiv="Pragma" content="no-cache">
    <meta http-equiv="Expires" content="0">
    <title>Officer Dashboard - Smart Grievance System</title>
    <link rel="stylesheet" href="<%= contextPath %>/css/style.css">
    <script src="<%= contextPath %>/js/script.js" defer></script>
    <style>
        .officer-dashboard-page{min-height:100vh;background:linear-gradient(135deg,#eef6ff 0%,#f7f4ff 50%,#fff6f0 100%)}
        .officer-dashboard-main{max-width:1250px;margin:0 auto;padding:28px 24px 50px}
        .officer-hero-box{background:linear-gradient(110deg,#0077b6,#3a86ff 55%,#6c63ff);border-radius:24px;padding:32px;color:white;display:flex;justify-content:space-between;align-items:center;gap:20px;box-shadow:0 15px 35px rgba(45,90,180,.20)}
        .officer-hero-box h1{margin:5px 0 8px;color:white;font-size:32px}
        .officer-hero-box p{margin:0;color:rgba(255,255,255,.95)}
        .officer-dashboard-btn{display:inline-block;background:white;color:#27346d;padding:13px 19px;border-radius:12px;text-decoration:none;font-weight:bold;box-shadow:0 8px 18px rgba(0,0,0,.12)}
        .officer-dashboard-btn:hover{text-decoration:none;transform:translateY(-1px)}
        .officer-stat-grid{display:grid;grid-template-columns:repeat(5,minmax(0,1fr));gap:16px;margin-top:20px}
        .officer-stat-card{min-height:125px;border-radius:18px;color:white;padding:20px;display:flex;align-items:center;gap:14px;box-shadow:0 10px 25px rgba(31,41,55,.12)}
        .officer-stat-icon{width:52px;height:52px;border-radius:15px;background:rgba(255,255,255,.22);display:grid;place-items:center;font-size:23px;font-weight:bold;flex-shrink:0}
        .officer-stat-icon svg{width:25px;height:25px;fill:none;stroke:currentColor;stroke-width:1.8;stroke-linecap:round;stroke-linejoin:round}
        .officer-stat-label{display:block;font-size:14px;font-weight:bold;opacity:.92}
        .officer-stat-number{display:block;font-size:34px;line-height:1.1;font-weight:bold;margin-top:4px}
        .officer-card-orange{background:linear-gradient(135deg,#f59e0b,#ffb703)}
        .officer-card-purple{background:linear-gradient(135deg,#7b2cbf,#9d4edd)}
        .officer-card-blue{background:linear-gradient(135deg,#3a86ff,#4361ee)}
        .officer-card-green{background:linear-gradient(135deg,#06b48a,#2ec4b6)}
        .officer-card-red{background:linear-gradient(135deg,#ef476f,#d90429)}
        .officer-chart-grid{display:grid;grid-template-columns:repeat(2,minmax(0,1fr));gap:20px;margin-top:20px}
        .officer-chart-box{background:white;border-radius:20px;padding:24px;box-shadow:0 10px 25px rgba(31,41,55,.09);min-width:0}
        .officer-chart-title{margin:0 0 5px;color:#27346d;font-size:22px}
        .officer-chart-subtitle{margin:0 0 20px;color:#64748b;font-size:13px}
        .officer-pie-area{min-height:300px;display:flex;justify-content:center;align-items:center;gap:30px;flex-wrap:wrap}
        .officer-pie-chart{width:210px;height:210px;min-width:210px;border-radius:50%;position:relative;box-shadow:inset 0 0 0 2px rgba(255,255,255,.8),0 10px 22px rgba(31,41,55,.10)}
        .officer-pie-hole{position:absolute;inset:38px;background:white;border-radius:50%;display:flex;flex-direction:column;align-items:center;justify-content:center;box-shadow:0 5px 18px rgba(31,41,55,.10)}
        .officer-pie-hole strong{color:#27346d;font-size:31px}
        .officer-pie-hole span{color:#64748b;font-size:13px}
        .officer-legend{min-width:210px}
        .officer-legend-row{display:grid;grid-template-columns:14px 1fr auto;align-items:center;gap:9px;padding:11px 0;border-bottom:1px dashed #e2e8f0}
        .officer-legend-row:last-child{border-bottom:0}
        .officer-legend-dot{width:11px;height:11px;border-radius:50%}
        .dot-yellow{background:#ffb703}.dot-blue{background:#3a86ff}.dot-green{background:#2ec4b6}.dot-red{background:#ef476f}
        .officer-legend-label{color:#475569}.officer-legend-number{color:#1e293b;font-weight:bold}
        .officer-bar-chart{height:300px;display:flex;align-items:flex-end;justify-content:space-around;gap:18px;padding:15px 10px 5px;border-bottom:1px solid #dbe4ee;background:linear-gradient(to top,#f7fbff,#fff);border-radius:15px}
        .officer-bar-item{flex:1;height:100%;display:flex;flex-direction:column;justify-content:flex-end;align-items:center;gap:8px;min-width:55px}
        .officer-bar-track{width:52px;height:205px;padding:4px;background:#edf2f7;border-radius:13px 13px 7px 7px;display:flex;align-items:flex-end}
        .officer-bar{width:100%;min-height:8px;border-radius:9px 9px 5px 5px}
        .bar-yellow{background:linear-gradient(180deg,#ffd166,#ffb703)}.bar-blue{background:linear-gradient(180deg,#60a5fa,#3a86ff)}.bar-green{background:linear-gradient(180deg,#55d6be,#2ec4b6)}.bar-red{background:linear-gradient(180deg,#ff7b9b,#ef476f)}
        .officer-bar-value{color:#27346d;font-weight:bold;font-size:15px}.officer-bar-label{color:#64748b;font-size:12px;text-align:center}
        .officer-actions{margin-top:20px;background:white;border-radius:20px;padding:24px;box-shadow:0 10px 25px rgba(31,41,55,.09)}
        .officer-action-grid{display:grid;grid-template-columns:repeat(2,minmax(0,1fr));gap:14px}
        .officer-action{display:block;color:white;text-decoration:none;padding:20px;border-radius:16px;min-height:100px;box-shadow:0 8px 18px rgba(31,41,55,.10)}
        .officer-action:hover{color:white;text-decoration:none;transform:translateY(-2px)}
        .action-blue{background:linear-gradient(135deg,#3a86ff,#4361ee)}.action-purple{background:linear-gradient(135deg,#7b2cbf,#9d4edd)}
        .officer-action strong{display:block;font-size:17px;margin-bottom:6px}.officer-action small{opacity:.92}
        .officer-table-region{overflow-x:auto;max-width:100%}
        .sr-only{position:absolute;width:1px;height:1px;padding:0;margin:-1px;overflow:hidden;clip:rect(0,0,0,0);white-space:nowrap;border:0}
        a:focus-visible{outline:3px solid #111827;outline-offset:3px}
        @media(max-width:1050px){.officer-stat-grid{grid-template-columns:repeat(3,minmax(0,1fr))}.officer-chart-grid{grid-template-columns:1fr}}
        @media(max-width:700px){.officer-hero-box{flex-direction:column;align-items:flex-start}.officer-stat-grid{grid-template-columns:1fr 1fr}.officer-action-grid{grid-template-columns:1fr}.officer-pie-chart{width:180px;height:180px;min-width:180px}.officer-dashboard-main{padding-left:16px;padding-right:16px}}
        @media(max-width:480px){.officer-dashboard-main{padding:18px 10px 35px}.officer-hero-box{padding:22px}.officer-stat-grid{grid-template-columns:1fr}.officer-bar-track{width:38px}.officer-bar-chart{gap:8px}.officer-chart-box,.officer-actions{padding:16px}}
    </style>
</head>
<body class="officer-dashboard-page">

<header class="site-header dashboard-header">
    <div class="header-inner">
        <a class="brand dashboard-brand" href="<%= contextPath %>/officerDashboard.jsp">
            <span class="brand-logo" aria-hidden="true">
                <svg viewBox="0 0 48 48" focusable="false">
                    <path d="M7 18 24 8l17 10M10 20h28M12 39h24M15 20v17m9-17v17m9-17v17M8 42h32"/>
                    <path d="m19 29 4 4 8-9"/>
                </svg>
            </span>
            Smart Grievance System
        </a>
        <nav class="nav-links" aria-label="Officer navigation">
            <a class="active" href="<%= contextPath %>/officerDashboard.jsp" aria-current="page">Dashboard</a>
            <a href="<%= contextPath %>/officerComplaints">Assigned Complaints</a>
            <a href="<%= contextPath %>/changePassword">Change Password</a>
            <a href="<%= contextPath %>/logout">Logout</a>
        </nav>
    </div>
</header>

<main class="officer-dashboard-main">
    <section class="officer-hero-box" aria-labelledby="officer-dashboard-title">
        <div>
            <span class="eyebrow">OFFICER PANEL</span>
            <h1 id="officer-dashboard-title">Officer Dashboard</h1>
            <p>Welcome, <strong><%= escapeHtml(user.getName()) %></strong> &nbsp; • &nbsp; Level <strong><%= user.getOfficerLevel() %></strong></p>
        </div>
        <a class="officer-dashboard-btn" href="<%= contextPath %>/officerComplaints">View Assigned Complaints</a>
    </section>

    <% if (statsError != null || priorityError != null) { %>
        <div role="alert" style="margin-top:16px;padding:14px 18px;border-radius:12px;background:#fff1f2;border:1px solid #fecdd3;color:#9f1239;">
            <% if (statsError != null) { %><div><strong>Dashboard stats:</strong> <%= statsError %></div><% } %>
            <% if (priorityError != null) { %><div style="margin-top:4px;"><strong>Priority:</strong> <%= priorityError %></div><% } %>
        </div>
    <% } %>

    <section class="officer-stat-grid" aria-label="Complaint statistics">
        <div class="officer-stat-card officer-card-orange"><div class="officer-stat-icon" aria-hidden="true">◷</div><div><span class="officer-stat-label">Pending</span><span class="officer-stat-number"><%= pending %></span></div></div>
        <div class="officer-stat-card officer-card-purple"><div class="officer-stat-icon" aria-hidden="true">★</div><div><span class="officer-stat-label">High Priority</span><span class="officer-stat-number"><%= highPriority %></span></div></div>
        <div class="officer-stat-card officer-card-blue"><div class="officer-stat-icon" aria-hidden="true">↻</div><div><span class="officer-stat-label">In Progress</span><span class="officer-stat-number"><%= inProgress %></span></div></div>
        <div class="officer-stat-card officer-card-green"><div class="officer-stat-icon" aria-hidden="true">✓</div><div><span class="officer-stat-label">Resolved</span><span class="officer-stat-number"><%= resolved %></span></div></div>
        <div class="officer-stat-card officer-card-red"><div class="officer-stat-icon" aria-hidden="true">!</div><div><span class="officer-stat-label">Escalated</span><span class="officer-stat-number"><%= escalated %></span></div></div>
    </section>

    <section class="table-panel dashboard-complaints-panel" aria-labelledby="recent-complaints-title">
        <div class="panel-heading">
            <div>
                <h2 id="recent-complaints-title">Recent Assigned Complaints</h2>
                <p class="complaints-table-caption">The latest complaints assigned to you.</p>
            </div>
            <a href="<%= contextPath %>/officerComplaints" class="mini-btn">View assigned complaints</a>
        </div>

        <% if (recentComplaints == null || recentComplaints.isEmpty()) { %>
            <p class="empty-complaints">No complaints are assigned to you yet.</p>
        <% } else { %>
            <div class="table-wrap officer-table-region" role="region" aria-label="Recent assigned complaints table" tabindex="0">
                <table class="citizen-complaints-table">
                    <caption class="sr-only">Recent complaints assigned to this officer</caption>
                    <thead>
                        <tr><th scope="col">Complaint ID</th><th scope="col">Category</th><th scope="col">Subject</th><th scope="col">Date</th><th scope="col">Status</th><th scope="col">Action</th></tr>
                    </thead>
                    <tbody>
                    <% for (Complaint complaint : recentComplaints) {
                        String rawStatus = complaint.getStatus() == null || complaint.getStatus().trim().isEmpty()
                                ? "PENDING" : complaint.getStatus().trim().toUpperCase(Locale.ROOT);
                        String statusClass = rawStatus.toLowerCase(Locale.ROOT).replace('_', '-');
                        String statusLabel = rawStatus.replace('_', ' ').toLowerCase(Locale.ROOT);
                        statusLabel = statusLabel.substring(0, 1).toUpperCase(Locale.ROOT) + statusLabel.substring(1);
                    %>
                        <tr>
                            <td class="complaint-id">#<%= complaint.getComplaintId() %></td>
                            <td><%= escapeHtml(complaint.getCategory()) %></td>
                            <td class="complaint-title-cell"><%= escapeHtml(complaint.getTitle()) %></td>
                            <td><%= complaint.getCreatedAt() == null ? "—" : complaintDateFormat.format(complaint.getCreatedAt()) %></td>
                            <td><span class="status status-<%= escapeHtml(statusClass) %>"><%= escapeHtml(statusLabel) %></span></td>
                            <td><a class="table-link" href="<%= contextPath %>/complaintHistory?complaintId=<%= complaint.getComplaintId() %>">View</a></td>
                        </tr>
                    <% } %>
                    </tbody>
                </table>
            </div>
        <% } %>
    </section>

    <section class="officer-chart-grid" aria-label="Complaint charts">
        <div class="officer-chart-box">
            <h2 class="officer-chart-title">Complaint Status</h2>
            <p class="officer-chart-subtitle">Current officer assignments</p>
            <div class="officer-pie-area">
                <div class="officer-pie-chart" style="<%= pieStyle %>" role="img" aria-label="Complaint status distribution">
                    <div class="officer-pie-hole"><strong><%= total %></strong><span>Total Cases</span></div>
                </div>
                <div class="officer-legend" aria-label="Chart legend">
                    <div class="officer-legend-row"><span class="officer-legend-dot dot-yellow" aria-hidden="true"></span><span class="officer-legend-label">Pending</span><span class="officer-legend-number"><%= pending %></span></div>
                    <div class="officer-legend-row"><span class="officer-legend-dot dot-blue" aria-hidden="true"></span><span class="officer-legend-label">In Progress</span><span class="officer-legend-number"><%= inProgress %></span></div>
                    <div class="officer-legend-row"><span class="officer-legend-dot dot-green" aria-hidden="true"></span><span class="officer-legend-label">Resolved</span><span class="officer-legend-number"><%= resolved %></span></div>
                    <div class="officer-legend-row"><span class="officer-legend-dot dot-red" aria-hidden="true"></span><span class="officer-legend-label">Escalated</span><span class="officer-legend-number"><%= escalated %></span></div>
                </div>
            </div>
        </div>

        <div class="officer-chart-box">
            <h2 class="officer-chart-title">Status Graph</h2>
            <p class="officer-chart-subtitle">Current workload</p>
            <div class="officer-bar-chart" role="img" aria-label="Bar chart: Pending <%= pending %>, In Progress <%= inProgress %>, Resolved <%= resolved %>, Escalated <%= escalated %>">
                <div class="officer-bar-item"><div class="officer-bar-track"><div class="officer-bar bar-yellow" style="height:<%= pendingHeight %>%;"></div></div><strong class="officer-bar-value"><%= pending %></strong><span class="officer-bar-label">Pending</span></div>
                <div class="officer-bar-item"><div class="officer-bar-track"><div class="officer-bar bar-blue" style="height:<%= progressHeight %>%;"></div></div><strong class="officer-bar-value"><%= inProgress %></strong><span class="officer-bar-label">In Progress</span></div>
                <div class="officer-bar-item"><div class="officer-bar-track"><div class="officer-bar bar-green" style="height:<%= resolvedHeight %>%;"></div></div><strong class="officer-bar-value"><%= resolved %></strong><span class="officer-bar-label">Resolved</span></div>
                <div class="officer-bar-item"><div class="officer-bar-track"><div class="officer-bar bar-red" style="height:<%= escalatedHeight %>%;"></div></div><strong class="officer-bar-value"><%= escalated %></strong><span class="officer-bar-label">Escalated</span></div>
            </div>
        </div>
    </section>

    <section class="officer-actions" aria-labelledby="quick-actions-title">
        <h2 class="officer-chart-title" id="quick-actions-title">Quick Actions</h2>
        <p class="officer-chart-subtitle">Manage your assigned complaints</p>
        <div class="officer-action-grid">
            <a href="<%= contextPath %>/officerComplaints" class="officer-action action-blue"><strong>View Assigned Complaints</strong><small>Open complaints currently assigned to you.</small></a>
            <a href="<%= contextPath %>/officerComplaints" class="officer-action action-purple"><strong>Update Complaint</strong><small>Change status and add remarks.</small></a>
        </div>
    </section>
</main>
</body>
</html>