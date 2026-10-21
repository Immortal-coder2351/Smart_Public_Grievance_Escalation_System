<%@ page import="com.grievance.model.User" %>
<%@ page import="com.grievance.model.Complaint" %>
<%@ page import="java.util.List" %>
<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    User user = (User) session.getAttribute("user");

    if (user == null || !"OFFICER".equals(user.getRole())) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    List<Complaint> complaints =
            (List<Complaint>) request.getAttribute("complaints");

    String error = request.getParameter("error");
    String success = request.getParameter("success");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Assigned Complaints</title>
    <link rel="stylesheet" href="css/style.css">
    <script src="js/script.js" defer></script>
    <style>
        .mobile-table-help {
            margin: 0 0 12px;
            font-size: 0.9rem;
            line-height: 1.5;
            color: #555;
        }

        .accessible-table-wrap {
            width: 100%;
            max-width: 100%;
            overflow-x: auto;
            -webkit-overflow-scrolling: touch;
        }

        .officer-complaints-table {
            width: 100%;
            min-width: 850px;
            border-collapse: collapse;
        }

        .officer-complaints-table th,
        .officer-complaints-table td {
            padding: 12px;
            text-align: left;
            vertical-align: top;
        }

        .officer-complaints-table th {
            white-space: nowrap;
        }

        .accessible-table-wrap:focus-visible,
        .officer-complaints-table a:focus-visible,
        .officer-complaints-table button:focus-visible,
        .officer-complaints-table select:focus-visible,
        .officer-complaints-table textarea:focus-visible {
            outline: 3px solid #1769aa;
            outline-offset: 3px;
        }

        .officer-complaints-table td {
            overflow-wrap: anywhere;
        }

        @media (max-width: 600px) {
            .officer-complaints-table th,
            .officer-complaints-table td {
                padding: 10px;
            }
        }
    </style>
</head>
<body>

<header class="site-header">
    <div class="header-inner">
        <a class="brand dashboard-brand" href="officerDashboard.jsp">
            <span class="brand-logo" aria-hidden="true">
                <svg viewBox="0 0 48 48">
                    <path d="M7 18 24 8l17 10M10 20h28M12 39h24M15 20v17m9-17v17m9-17v17M8 42h32"/>
                    <path d="m19 29 4 4 8-9"/>
                </svg>
            </span>
            Grievance System
        </a>
        <nav class="nav-links" aria-label="Officer navigation">
            <a href="officerDashboard.jsp">Dashboard</a>
            <a class="active" href="officerComplaints">Assigned Complaints</a>
            <a href="changePassword">Change Password</a>
            <a href="logout">Logout</a>
        </nav>
    </div>
</header>

<main class="dashboard-page complaints-page">
    <section class="dashboard-topbar">
        <div>
            <p class="eyebrow">Officer portal</p>
            <h1 class="page-title">Assigned Complaints</h1>
            <p class="page-subtitle">Review assigned complaints and update their status.</p>
        </div>
        <div class="welcome-pill">
            Welcome, <strong><%= user.getName() %></strong>
        </div>
    </section>

    <% if ("updated".equals(success)) { %>
        <p class="success-message" role="status">Complaint status updated successfully.</p>
    <% } %>

    <% if (error != null) { %>
        <p class="error-message" role="alert">
            <% if ("invalid".equals(error)) { %>
                The submitted complaint information is invalid.
            <% } else if ("failed".equals(error)) { %>
                The complaint could not be updated. Please try again.
            <% } else if ("unauthorized".equals(error)) { %>
                You are not authorized to update this complaint.
            <% } else { %>
                An error occurred while processing your request.
            <% } %>
        </p>
    <% } %>

    <section class="table-panel" aria-labelledby="assigned-complaints-heading">
        <div class="panel-heading">
            <div>
                <h2 id="assigned-complaints-heading">Your Complaints</h2>
                <p class="complaints-table-caption">Review the details and current status of each assigned complaint.</p>
            </div>
        </div>

        <% if (complaints == null || complaints.isEmpty()) { %>
            <p class="empty-complaints" role="status">No complaints are currently assigned to you.</p>
        <% } else { %>
            <p class="mobile-table-help" id="officer-table-help">
                On a small screen, swipe horizontally to view all complaint details.
            </p>

            <div class="accessible-table-wrap"
                 role="region"
                 aria-label="Assigned complaint records"
                 aria-describedby="officer-table-help"
                 tabindex="0">
                <table class="officer-complaints-table">
                    <caption class="sr-only">Assigned complaints with status update actions and history links.</caption>
                    <thead>
                        <tr>
                            <th scope="col">Complaint ID</th>
                            <th scope="col">Citizen ID</th>
                            <th scope="col">Category</th>
                            <th scope="col">Title</th>
                            <th scope="col">Location</th>
                            <th scope="col">Priority</th>
                            <th scope="col">Status</th>
                            <th scope="col">Image</th>
                            <th scope="col">History</th>
                            <th scope="col">Update Status</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% for (Complaint complaint : complaints) {
                            String status = complaint.getStatus() == null
                                    ? "PENDING"
                                    : complaint.getStatus().trim().toUpperCase(java.util.Locale.ROOT);

                            String statusClass = status.toLowerCase(java.util.Locale.ROOT)
                                    .replace('_', '-');

                            String priority = complaint.getPriority() == null
                                    ? "Medium"
                                    : complaint.getPriority().toLowerCase(java.util.Locale.ROOT);
                        %>
                        <tr>
                            <th scope="row">#<%= complaint.getComplaintId() %></th>
                            <td><%= complaint.getCitizenId() %></td>
                            <td><%= complaint.getCategory() %></td>
                            <td><%= complaint.getTitle() %></td>
                            <td><%= complaint.getLocation() %></td>
                            <td><%= priority %></td>
                            <td>
                                <span class="status status-<%= statusClass %>">
                                    <%= status.replace('_', ' ') %>
                                </span>
                            </td>
                            <td>
                                <% if (complaint.getImage() != null
                                        && !complaint.getImage().trim().isEmpty()) { %>
                                    <a href="<%= request.getContextPath() %>/<%= complaint.getImage() %>"
                                       target="_blank"
                                       rel="noopener noreferrer"
                                       aria-label="View image for complaint <%= complaint.getComplaintId() %>">
                                        View Image
                                    </a>
                                <% } else { %>
                                    —
                                <% } %>
                            </td>
                            <td>
                                <a class="table-link"
                                   href="complaintHistory?complaintId=<%= complaint.getComplaintId() %>"
                                   aria-label="View history for complaint <%= complaint.getComplaintId() %>">
                                    History
                                </a>
                            </td>
                            <td>
                                <form action="updateComplaint" method="post">
                                    <input type="hidden" name="complaintId"
                                           value="<%= complaint.getComplaintId() %>">

                                    <label for="status-<%= complaint.getComplaintId() %>">
                                        Status for complaint #<%= complaint.getComplaintId() %>
                                    </label>

                                    <select id="status-<%= complaint.getComplaintId() %>"
                                            name="status" required>
                                        <option value="PENDING" <%= "PENDING".equals(status) ? "selected" : "" %>>Pending</option>
                                        <option value="IN_PROGRESS" <%= "IN_PROGRESS".equals(status) ? "selected" : "" %>>In Progress</option>
                                        <option value="RESOLVED" <%= "RESOLVED".equals(status) ? "selected" : "" %>>Resolved</option>
                                    </select>

                                    <label for="remarks-<%= complaint.getComplaintId() %>">
                                        Remarks
                                    </label>

                                    <textarea id="remarks-<%= complaint.getComplaintId() %>"
                                              name="remarks"
                                              rows="2"
                                              maxlength="1000"
                                              placeholder="Enter update remarks"></textarea>

                                    <button type="submit">Update</button>
                                </form>
                            </td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
        <% } %>
    </section>

    <div class="page-footer">
        <a href="officerDashboard.jsp">Back to Officer Dashboard</a>
    </div>
</main>

</body>
</html>