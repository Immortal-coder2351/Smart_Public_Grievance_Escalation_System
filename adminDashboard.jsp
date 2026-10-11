<%@ page import="com.grievance.model.User" %>
<%@ page import="com.grievance.model.Complaint" %>
<%@ page import="com.grievance.dao.AdminComplaintDAO" %>
<%@ page import="com.grievance.dao.DBConnection" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="java.util.LinkedHashMap" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Locale" %>
<%@ page import="java.text.SimpleDateFormat" %>

<%
    User user = (User) session.getAttribute("user");

    if (user == null || !"ADMIN".equals(user.getRole())) {
        response.sendRedirect("login.jsp");
        return;
    }

    List<Complaint> recentComplaints =
            new AdminComplaintDAO().getRecentComplaints();
    SimpleDateFormat complaintDateFormat =
            new SimpleDateFormat("dd MMM yyyy", Locale.ENGLISH);

    int total = 0;
    int pending = 0;
    int inProgress = 0;
    int resolved = 0;
    int escalated = 0;
    int highPriority = 0;

    String statsError = null;
    String priorityError = null;
    String departmentError = null;

    Map<Integer, Integer> departmentCounts = new LinkedHashMap<Integer, Integer>();

    String[] departmentNames = {
        "", "Roads", "Water Supply", "Electricity", "Sanitation",
        "Drainage", "Garbage Collection", "Street Lighting"
    };

    /* Load total/status counts WITHOUT depending on the optional priority column. */
    String statusSql =
        "SELECT COUNT(*) AS total, " +
        "COALESCE(SUM(CASE WHEN UPPER(REPLACE(TRIM(COALESCE(status, 'PENDING')), ' ', '_')) = 'IN_PROGRESS' THEN 1 ELSE 0 END), 0) AS in_progress, " +
        "COALESCE(SUM(CASE WHEN UPPER(TRIM(COALESCE(status, 'PENDING'))) = 'RESOLVED' THEN 1 ELSE 0 END), 0) AS resolved, " +
        "COALESCE(SUM(CASE WHEN UPPER(TRIM(COALESCE(status, 'PENDING'))) IN ('ESCALATED', 'ESCALATION_PENDING') THEN 1 ELSE 0 END), 0) AS escalated " +
        "FROM complaints";

    try (Connection connection = DBConnection.getConnection();
         PreparedStatement statement = connection.prepareStatement(statusSql);
         ResultSet resultSet = statement.executeQuery()) {

        if (resultSet.next()) {
            total = resultSet.getInt("total");
            inProgress = resultSet.getInt("in_progress");
            resolved = resultSet.getInt("resolved");
            escalated = resultSet.getInt("escalated");
            /* Pending includes PENDING and any other not-yet-terminal status,
               so the chart's status segments reconcile with total complaints. */
            pending = Math.max(0, total - inProgress - resolved - escalated);
        }
    } catch (Exception e) {
        statsError = "Complaint counts could not be loaded. Check the Tomcat console and database connection.";
        e.printStackTrace();
    }

    /* Keep priority separate so a missing priority column cannot zero all dashboard counts. */
    String prioritySql =
        "SELECT COUNT(*) AS high_priority_count FROM complaints " +
        "WHERE UPPER(TRIM(COALESCE(priority, ''))) = 'HIGH'";

    try (Connection connection = DBConnection.getConnection();
         PreparedStatement statement = connection.prepareStatement(prioritySql);
         ResultSet resultSet = statement.executeQuery()) {
        if (resultSet.next()) {
            highPriority = resultSet.getInt("high_priority_count");
        }
    } catch (Exception e) {
        priorityError = "Priority count is unavailable. Confirm that complaints.priority exists in smart_grievance.";
        e.printStackTrace();
    }

    String deptSql =
        "SELECT department_id, COUNT(*) AS complaint_count " +
        "FROM complaints GROUP BY department_id ORDER BY department_id";

    try (Connection connection = DBConnection.getConnection();
         PreparedStatement statement = connection.prepareStatement(deptSql);
         ResultSet resultSet = statement.executeQuery()) {
        while (resultSet.next()) {
            departmentCounts.put(resultSet.getInt("department_id"),
                                 resultSet.getInt("complaint_count"));
        }
    } catch (Exception e) {
        departmentError = "Department counts could not be loaded. Check the database connection.";
        e.printStackTrace();
    }

    int chartTotal = total;
    int pieBase = chartTotal == 0 ? 1 : chartTotal;
    int pendingEnd = Math.round((pending * 360f) / pieBase);
    int inProgressEnd = Math.round(((pending + inProgress) * 360f) / pieBase);
    int resolvedEnd = Math.round(((pending + inProgress + resolved) * 360f) / pieBase);

    String pieStyle;
    if (chartTotal == 0) {
        pieStyle = "background: conic-gradient(#d1d5db 0deg 360deg);";
    } else {
        pieStyle = "background: conic-gradient(" +
            "#ffb703 0deg " + pendingEnd + "deg, " +
            "#3a86ff " + pendingEnd + "deg " + inProgressEnd + "deg, " +
            "#2ec4b6 " + inProgressEnd + "deg " + resolvedEnd + "deg, " +
            "#ef476f " + resolvedEnd + "deg 360deg);";
    }

    int maxDepartmentCount = 1;
    for (Integer value : departmentCounts.values()) {
        if (value != null && value > maxDepartmentCount) {
            maxDepartmentCount = value;
        }
    }
%>

<!DOCTYPE html>

<html>

<head>

    <meta charset="UTF-8">

    <title>
        Admin Dashboard - Smart Grievance System
    </title>

    <link rel="stylesheet" href="css/style.css">

    <script src="js/script.js" defer></script>


    <!-- Dashboard-specific styling -->

    <style>

        * {
            box-sizing: border-box;
        }

        body {
            margin: 0;
            font-family: Arial, Helvetica, sans-serif;
        }

        .admin-dashboard-page {

            min-height: 100vh;

            background:
                linear-gradient(
                    135deg,
                    #eef5ff 0%,
                    #f8f5ff 50%,
                    #fff5ee 100%
                );
        }


        /* HEADER */

        .admin-header {

            background: #ffffff;

            box-shadow:
                0 3px 18px rgba(0,0,0,.08);

            border-bottom: 0;
        }

        .admin-header .brand {

            font-size: 23px;

            font-weight: 800;

            background:
                linear-gradient(
                    90deg,
                    #4361ee,
                    #7b2cbf
                );

            -webkit-background-clip: text;
            background-clip: text;

            color: transparent;
        }


        .admin-main {

            max-width: 1250px;

            margin: 0 auto;

            padding: 28px 24px 50px;
        }


        /* HERO */

        .admin-hero-box {

            background:
                linear-gradient(
                    110deg,
                    #4361ee,
                    #7b2cbf 60%,
                    #b5179e
                );

            border-radius: 24px;

            padding: 34px;

            color: white;

            display: flex;

            justify-content: space-between;

            align-items: center;

            gap: 25px;

            box-shadow:
                0 15px 35px
                rgba(67,56,202,.20);
        }


        .admin-hero-box h1 {

            margin: 6px 0 8px;

            color: white;

            font-size: 34px;
        }


        .admin-hero-box p {

            margin: 0;

            color: rgba(255,255,255,.94);
        }


        .admin-hero-btn {

            display: inline-block;

            background: white;

            color: #372a8a;

            padding: 13px 20px;

            border-radius: 12px;

            font-weight: 800;

            text-decoration: none;

            box-shadow:
                0 8px 18px rgba(0,0,0,.12);
        }


        .admin-hero-btn:hover {

            color: #372a8a;

            text-decoration: none;

            transform: translateY(-1px);
        }


        /* STAT CARDS */

        .admin-stat-grid {

            display: grid;

            grid-template-columns:
                repeat(5, 1fr);

            gap: 16px;

            margin-top: 20px;
        }


        .admin-stat {

            min-height: 130px;

            border-radius: 18px;

            color: white;

            padding: 20px;

            display: flex;

            align-items: center;

            gap: 15px;

            box-shadow:
                0 10px 25px
                rgba(31,41,55,.12);
        }


        .admin-stat-icon {

            width: 54px;

            height: 54px;

            border-radius: 15px;

            display: grid;

            place-items: center;

            background:
                rgba(255,255,255,.22);

            font-size: 25px;

            font-weight: 900;
        }


        .admin-stat-label {

            display: block;

            font-size: 14px;

            font-weight: 700;

            opacity: .92;
        }


        .admin-stat-number {

            display: block;

            font-size: 35px;

            font-weight: 800;

            line-height: 1.1;

            margin-top: 5px;
        }


        .admin-blue {

            background:
                linear-gradient(
                    135deg,
                    #3a86ff,
                    #4361ee
                );
        }


        .admin-green {

            background:
                linear-gradient(
                    135deg,
                    #06b48a,
                    #2ec4b6
                );
        }


        .admin-orange {

            background:
                linear-gradient(
                    135deg,
                    #f59e0b,
                    #ffb703
                );
        }


        .admin-purple {

            background:
                linear-gradient(
                    135deg,
                    #7b2cbf,
                    #9d4edd
                );
        }


        .admin-red {

            background:
                linear-gradient(
                    135deg,
                    #ef476f,
                    #d90429
                );
        }


        /* CHART AREA */

        .admin-chart-grid {

            display: grid;

            grid-template-columns:
                1fr 1fr;

            gap: 20px;

            margin-top: 20px;
        }


        .admin-chart-card {

            background: white;

            border-radius: 20px;

            padding: 25px;

            box-shadow:
                0 10px 25px
                rgba(31,41,55,.09);
        }


        .admin-chart-title {

            margin: 0;

            font-size: 22px;

            color: #27346d;
        }


        .admin-chart-note {

            margin: 5px 0 20px;

            color: #64748b;

            font-size: 13px;
        }


        /* PIE CHART */

        .admin-pie-area {

            min-height: 320px;

            display: flex;

            justify-content: center;

            align-items: center;

            gap: 30px;

            flex-wrap: wrap;
        }


        .admin-pie {

            width: 220px;

            height: 220px;

            min-width: 220px;

            border-radius: 50%;

            position: relative;

            box-shadow:
                0 10px 22px
                rgba(31,41,55,.12);
        }


        .admin-pie-hole {

            position: absolute;

            inset: 42px;

            background: white;

            border-radius: 50%;

            display: flex;

            flex-direction: column;

            justify-content: center;

            align-items: center;

            box-shadow:
                0 5px 18px
                rgba(31,41,55,.12);
        }


        .admin-pie-hole strong {

            font-size: 33px;

            color: #27346d;
        }


        .admin-pie-hole span {

            font-size: 13px;

            color: #64748b;
        }


        .admin-legend {

            min-width: 205px;
        }


        .admin-legend-row {

            display: grid;

            grid-template-columns:
                13px 1fr auto;

            align-items: center;

            gap: 9px;

            padding: 11px 0;

            border-bottom:
                1px dashed #e2e8f0;
        }


        .admin-legend-row:last-child {

            border-bottom: 0;
        }


        .admin-dot {

            width: 11px;

            height: 11px;

            border-radius: 50%;
        }


        .admin-dot-pending {
            background: #ffb703;
        }

        .admin-dot-progress {
            background: #3a86ff;
        }

        .admin-dot-resolved {
            background: #2ec4b6;
        }

        .admin-dot-escalated {
            background: #ef476f;
        }


        .admin-legend-row span {

            color: #475569;
        }


        .admin-legend-row strong {

            color: #1e293b;
        }


        /* DEPARTMENT BAR GRAPH */

        .admin-bar-chart {

            padding-top: 5px;
        }


        .admin-bar-row {

            display: grid;

            grid-template-columns:
                145px 1fr 35px;

            gap: 10px;

            align-items: center;

            margin: 17px 0;
        }


        .admin-bar-label {

            font-size: 13px;

            font-weight: 700;

            color: #475569;
        }


        .admin-bar-track {

            height: 16px;

            background: #edf2f7;

            border-radius: 99px;

            overflow: hidden;
        }


        .admin-bar-fill {

            height: 100%;

            min-width: 0;

            border-radius: 99px;

            transition:
                width .5s ease;
        }


        .admin-fill-1 {
            background: #4361ee;
        }

        .admin-fill-2 {
            background: #06b48a;
        }

        .admin-fill-3 {
            background: #f59e0b;
        }

        .admin-fill-4 {
            background: #ef476f;
        }

        .admin-fill-5 {
            background: #7b2cbf;
        }

        .admin-fill-6 {
            background: #ff6d00;
        }

        .admin-fill-7 {
            background: #00b4d8;
        }


        .admin-bar-row strong {

            text-align: right;

            color: #1e293b;
        }


        /* QUICK ACTIONS */

        .admin-actions {

            margin-top: 20px;

            background: white;

            border-radius: 20px;

            padding: 25px;

            box-shadow:
                0 10px 25px
                rgba(31,41,55,.09);
        }


        .admin-actions h2 {

            margin: 0 0 5px;

            color: #27346d;
        }


        .admin-actions p {

            margin-top: 0;

            color: #64748b;
        }


        .admin-action-grid {

            display: grid;

            grid-template-columns:
                repeat(4,1fr);

            gap: 14px;

            margin-top: 18px;
        }


        .admin-action {

            min-height: 130px;

            padding: 19px;

            border-radius: 16px;

            color: white;

            text-decoration: none;

            display: flex;

            flex-direction: column;

            justify-content: center;

            gap: 7px;

            box-shadow:
                0 8px 18px
                rgba(31,41,55,.10);
        }


        .admin-action:hover {

            color: white;

            text-decoration: none;

            transform: translateY(-2px);
        }


        .admin-action strong {

            font-size: 17px;
        }


        .admin-action small {

            opacity: .92;

            line-height: 1.4;
        }


        .admin-action-blue {

            background:
                linear-gradient(
                    135deg,
                    #3a86ff,
                    #4361ee
                );
        }


        .admin-action-purple {

            background:
                linear-gradient(
                    135deg,
                    #7b2cbf,
                    #9d4edd
                );
        }


        .admin-action-orange {

            background:
                linear-gradient(
                    135deg,
                    #fb8500,
                    #ffb703
                );
        }


        .admin-action-green {

            background:
                linear-gradient(
                    135deg,
                    #06b48a,
                    #2ec4b6
                );
        }


        /* RESPONSIVE */

        @media (max-width: 1050px) {

            .admin-stat-grid {

                grid-template-columns:
                    repeat(3,1fr);
            }

            .admin-chart-grid {

                grid-template-columns:
                    1fr;
            }

            .admin-action-grid {

                grid-template-columns:
                    repeat(2,1fr);
            }
        }


        @media (max-width: 700px) {

            .admin-hero-box {

                flex-direction: column;

                align-items: flex-start;
            }

            .admin-stat-grid {

                grid-template-columns:
                    1fr 1fr;
            }

            .admin-action-grid {

                grid-template-columns:
                    1fr;
            }

            .admin-bar-row {

                grid-template-columns:
                    110px 1fr 30px;
            }

            .admin-pie {

                width: 180px;

                height: 180px;

                min-width: 180px;
            }
        }


        @media (max-width: 480px) {

            .admin-main {

                padding:
                    18px 10px 35px;
            }

            .admin-stat-grid {

                grid-template-columns:
                    1fr;
            }

            .admin-pie-area {

                flex-direction:
                    column;
            }
        }

    </style>

</head>


<body class="admin-dashboard-page">


<header class="site-header admin-header">

    <div class="header-inner">

        <a
            class="brand dashboard-brand"
            href="adminDashboard.jsp">

            <span class="brand-logo" aria-hidden="true"><svg viewBox="0 0 48 48"><path d="M7 18 24 8l17 10M10 20h28M12 39h24M15 20v17m9-17v17m9-17v17M8 42h32"/><path d="m19 29 4 4 8-9"/></svg></span>
            Smart Grievance System

        </a>


        <nav class="nav-links">

            <a
                class="active"
                href="adminDashboard.jsp">

                Dashboard

            </a>


            <a href="adminComplaints">

                Complaints

            </a>


            <a href="adminOfficers.jsp">

                Officers

            </a>

            <a href="changePassword">

                Change Password

            </a>


            <a href="logout">

                Logout

            </a>

        </nav>

    </div>

</header>


<main class="admin-main">


    <!-- HERO -->

    <section class="admin-hero-box">

        <div>

            <span class="eyebrow">
                ADMIN PANEL
            </span>


            <h1>
                Dashboard Overview
            </h1>


            <p>

                Welcome,

                <strong>
                    <%= user.getName() %>
                </strong>

                .
                Monitor complaints,
                officers and escalations.

            </p>

        </div>


        <a
            class="admin-hero-btn"
            href="adminComplaints">

            View All Complaints

        </a>

    </section>

    <% if (statsError != null || priorityError != null || departmentError != null) { %>
        <div role="alert" style="margin-top:16px;padding:14px 18px;border-radius:12px;background:#fff1f2;border:1px solid #fecdd3;color:#9f1239;">
            <% if (statsError != null) { %><div><strong>Dashboard stats:</strong> <%= statsError %></div><% } %>
            <% if (priorityError != null) { %><div style="margin-top:4px;"><strong>Priority:</strong> <%= priorityError %></div><% } %>
            <% if (departmentError != null) { %><div style="margin-top:4px;"><strong>Departments:</strong> <%= departmentError %></div><% } %>
        </div>
    <% } %>



    <!-- STATISTICS -->

    <section class="admin-stat-grid">


        <div class="admin-stat admin-blue">

            <div class="admin-stat-icon" aria-hidden="true"><svg viewBox="0 0 24 24"><path d="M7 3h7l5 5v13H7a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2Z"/><path d="M14 3v6h5M9 13h6m-6 4h6"/></svg></div>

            <div>

                <span class="admin-stat-label">
                    Total Complaints
                </span>

                <span class="admin-stat-number">
                    <%= total %>
                </span>

            </div>

        </div>


        <div class="admin-stat admin-green">

            <div class="admin-stat-icon" aria-hidden="true"><svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="9"/><path d="m8 12 2.5 2.5L16 9"/></svg></div>

            <div>

                <span class="admin-stat-label">
                    Resolved
                </span>

                <span class="admin-stat-number">
                    <%= resolved %>
                </span>

            </div>

        </div>


        <div class="admin-stat admin-orange">

            <div class="admin-stat-icon" aria-hidden="true"><svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="9"/><path d="M12 7v5l3 2"/></svg></div>

            <div>

                <span class="admin-stat-label">
                    Pending
                </span>

                <span class="admin-stat-number">
                    <%= pending %>
                </span>

            </div>

        </div>


        <div class="admin-stat admin-purple">

            <div class="admin-stat-icon" aria-hidden="true"><svg viewBox="0 0 24 24"><path d="m12 3 2.8 5.7 6.2.9-4.5 4.4 1.1 6.2-5.6-3-5.6 3 1.1-6.2L3 9.6l6.2-.9L12 3Z"/></svg></div>

            <div>

                <span class="admin-stat-label">
                    High Priority
                </span>

                <span class="admin-stat-number">
                    <%= highPriority %>
                </span>

            </div>

        </div>


        <div class="admin-stat admin-red">

            <div class="admin-stat-icon" aria-hidden="true"><svg viewBox="0 0 24 24"><path d="M12 3 22 20H2L12 3Z"/><path d="M12 9v5m0 3h.01"/></svg></div>

            <div>

                <span class="admin-stat-label">
                    Escalated
                </span>

                <span class="admin-stat-number">
                    <%= escalated %>
                </span>

            </div>

        </div>

    </section>


    <section class="table-panel dashboard-complaints-panel">
        <div class="panel-heading">
            <div>
                <h2>Recent Complaints</h2>
                <p class="complaints-table-caption">The latest complaints submitted across all departments.</p>
            </div>
            <a href="adminComplaints" class="mini-btn">View all complaints</a>
        </div>
        <% if (recentComplaints.isEmpty()) { %>
            <p class="empty-complaints">No complaints have been submitted yet.</p>
        <% } else { %>
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
                    <% for (Complaint complaint : recentComplaints) {
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
                    <% } %>
                    </tbody>
                </table>
            </div>
        <% } %>
    </section>

    <!-- CHARTS -->

    <section class="admin-chart-grid">


        <!-- PIE CHART -->

        <div class="admin-chart-card">

            <h2 class="admin-chart-title">
                Complaint Status
            </h2>


            <p class="admin-chart-note">
                Live complaint status analysis
            </p>


            <div class="admin-pie-area">


                <div
                    class="admin-pie"
                    style="<%= pieStyle %>">

                    <div class="admin-pie-hole">

                        <strong>
                            <%= total %>
                        </strong>

                        <span>
                            Total
                        </span>

                    </div>

                </div>


                <div class="admin-legend">


                    <div class="admin-legend-row">

                        <span
                            class="admin-dot admin-dot-pending">
                        </span>

                        <span>
                            Pending
                        </span>

                        <strong>
                            <%= pending %>
                        </strong>

                    </div>


                    <div class="admin-legend-row">

                        <span
                            class="admin-dot admin-dot-progress">
                        </span>

                        <span>
                            In Progress
                        </span>

                        <strong>
                            <%= inProgress %>
                        </strong>

                    </div>


                    <div class="admin-legend-row">

                        <span
                            class="admin-dot admin-dot-resolved">
                        </span>

                        <span>
                            Resolved
                        </span>

                        <strong>
                            <%= resolved %>
                        </strong>

                    </div>


                    <div class="admin-legend-row">

                        <span
                            class="admin-dot admin-dot-escalated">
                        </span>

                        <span>
                            Escalated
                        </span>

                        <strong>
                            <%= escalated %>
                        </strong>

                    </div>

                </div>

            </div>

        </div>


        <!-- DEPARTMENT BAR GRAPH -->

        <div class="admin-chart-card">

            <h2 class="admin-chart-title">
                Complaints by Department
            </h2>


            <p class="admin-chart-note">
                Complaint distribution across all departments
            </p>


            <div class="admin-bar-chart">

<%
    for (int i = 1;
         i < departmentNames.length;
         i++) {

        int count =
                departmentCounts.containsKey(i)
                ? departmentCounts.get(i)
                : 0;

        int width =
                count == 0
                ? 0
                : Math.max(
                    8,
                    Math.round(
                        (count * 100f)
                        / maxDepartmentCount
                    )
                );
%>

                <div class="admin-bar-row">

                    <span class="admin-bar-label">
                        <%= departmentNames[i] %>
                    </span>


                    <div class="admin-bar-track">

                        <div
                            class="admin-bar-fill admin-fill-<%= i %>"
                            style="width:<%= width %>%;">
                        </div>

                    </div>


                    <strong>
                        <%= count %>
                    </strong>

                </div>

<%
    }
%>

            </div>

        </div>

    </section>


    <!-- QUICK ACTIONS -->

    <section class="admin-actions">

        <h2>
            Administration
        </h2>


        <p>
            Quick access to important administrative functions.
        </p>


        <div class="admin-action-grid">


            <a
                class="admin-action admin-action-blue"
                href="adminOfficers.jsp">

                <strong>
                    Manage Officers
                </strong>

                <small>
                    Add and review department officers.
                </small>

            </a>


            <a
                class="admin-action admin-action-purple"
                href="adminComplaints">

                <strong>
                    View All Complaints
                </strong>

                <small>
                    Monitor complaints and assignments.
                </small>

            </a>


            <a
                class="admin-action admin-action-orange"
                href="adminComplaints">

                <strong>
                    Monitor Status
                </strong>

                <small>
                    Review pending, resolved and escalated cases.
                </small>

            </a>


            <a
                class="admin-action admin-action-green"
                href="adminComplaints">

                <strong>
                    Escalation History
                </strong>

                <small>
                    Inspect the complete escalation trail.
                </small>

            </a>

        </div>

    </section>

</main>


</body>

</html>