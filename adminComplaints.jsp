<%@ page import="com.grievance.model.User" %>
<%@ page import="com.grievance.model.Complaint" %>
<%@ page import="com.grievance.dao.OfficerDAO" %>
<%@ page import="java.util.List" %>
<%
    User user = (User) session.getAttribute("user");

    if (user == null || !"ADMIN".equals(user.getRole())) {
        response.sendRedirect("login.jsp");
        return;
    }

    List<Complaint> complaints =
            (List<Complaint>) request.getAttribute("complaints");

    OfficerDAO officerDAO = new OfficerDAO();
    List<User> officers = officerDAO.getAllOfficers();

    String error = request.getParameter("error");
    String success = request.getParameter("success");

    String[] departmentNames = {
        "",
        "Roads",
        "Water Supply",
        "Electricity",
        "Sanitation",
        "Drainage",
        "Garbage Collection",
        "Street Lighting"
    };
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>All Complaints</title>
    <link rel="stylesheet" href="css/style.css">
    <script src="js/script.js" defer></script>
</head>
<body>

<header class="site-header">
    <div class="header-inner">
        <a class="brand" href="adminDashboard.jsp">Grievance System</a>
        <nav class="nav-links">
            <a href="adminDashboard.jsp">Dashboard</a>
            <a class="active" href="adminComplaints">Complaints</a>
            <a href="adminOfficers.jsp">Officers</a>
            <a href="changePassword">Change Password</a>
            <a href="logout">Logout</a>
        </nav>
    </div>
</header>

<main class="page">
    <h1 class="page-title">All Complaints</h1>
    <p class="page-subtitle">Welcome, <strong><%= user.getName() %></strong>.</p>

<%
    if ("assigned".equals(success)) {
%>
    <div class="message success">Complaint assigned successfully.</div>
<%
    }

    if ("missing".equals(error)) {
%>
    <div class="message error">Please enter all required details.</div>
<%
    } else if ("invalid".equals(error)) {
%>
    <div class="message error">Invalid complaint details.</div>
<%
    } else if ("failed".equals(error)) {
%>
    <div class="message error">Complaint could not be assigned.</div>
<%
    } else if ("server".equals(error)) {
%>
    <div class="message error">A server error occurred.</div>
<%
    }
%>

    <div class="content-card">
<%
    if (complaints == null || complaints.isEmpty()) {
%>
        <p>No complaints found.</p>
<%
    } else {
%>
        <div class="table-wrap">
            <table>
                <tr>
                    <th>Complaint ID</th>
                    <th>Citizen ID</th>
                    <th>Department</th>
                    <th>Title</th>
                    <th>Category</th>
                    <th>Priority</th>
                    <th>Location</th>
                    <th>Image</th>
                    <th>Status</th>
                    <th>History</th>
                    <th>Admin Action</th>
                </tr>
<%
        for (Complaint complaint : complaints) {
            int deptId = complaint.getDepartmentId();
            String deptName =
                    deptId >= 1 && deptId < departmentNames.length
                    ? departmentNames[deptId]
                    : String.valueOf(deptId);

            String status = complaint.getStatus() == null
                    ? ""
                    : complaint.getStatus().toLowerCase().replace('_', '-');
%>
                <tr>
                    <td><%= complaint.getComplaintId() %></td>
                    <td><%= complaint.getCitizenId() %></td>
                    <td><%= deptName %></td>
                    <td><%= complaint.getTitle() %></td>
                    <td><%= complaint.getCategory() %></td>
                    <td><span class="priority priority-<%= complaint.getPriority() == null ? "medium" : complaint.getPriority().toLowerCase() %>"><%= complaint.getPriority() == null ? "MEDIUM" : complaint.getPriority() %></span></td>
                    <td><%= complaint.getLocation() %></td>
                    <td>
                        <% if (complaint.getImage() != null && !complaint.getImage().trim().isEmpty()) { %>
                            <a href="<%= complaint.getImage() %>" target="_blank" rel="noopener">
                                View Image
                            </a>
                        <% } else { %>
                            <span class="small">No image</span>
                        <% } %>
                    </td>
                    <td>
                        <span class="status status-<%= status %>">
                            <%= complaint.getStatus() %>
                        </span>
                    </td>
                    <td>
                        <a href="complaintHistory?complaintId=<%= complaint.getComplaintId() %>">
                            View History
                        </a>
                    </td>
                    <td>
<%
            if ("ESCALATION_PENDING".equals(complaint.getStatus())) {
%>
                        <form class="inline-form"
                              action="adminAssignComplaint"
                              method="post">

                            <input type="hidden"
                                   name="complaintId"
                                   value="<%= complaint.getComplaintId() %>">

                            <label for="officer-<%= complaint.getComplaintId() %>">
                                Reassign Officer
                            </label>

                            <select id="officer-<%= complaint.getComplaintId() %>"
                                    name="officerId"
                                    required>
                                <option value="">Select Officer</option>
<%
                for (User officer : officers) {
                    int officerDept =
                            officer.getDepartmentId() == null
                            ? 0
                            : officer.getDepartmentId();

                    if (officerDept != deptId) {
                        continue;
                    }

                    String officerDeptName =
                            officerDept >= 1 && officerDept < departmentNames.length
                            ? departmentNames[officerDept]
                            : String.valueOf(officerDept);
%>
                                <option value="<%= officer.getUserId() %>">
                                    <%= officer.getName() %>
                                    - Level <%= officer.getOfficerLevel() %>
                                    - <%= officerDeptName %>
                                </option>
<%
                }
%>
                            </select>

                            <input type="submit" value="Reassign">
                        </form>
<%
            } else {
%>
                        <span class="small">No action required</span>
<%
            }
%>
                    </td>
                </tr>
<%
        }
%>
            </table>
        </div>
<%
    }
%>
    </div>

    <div class="page-footer">
        <a href="adminDashboard.jsp">Back to Admin Dashboard</a>
    </div>
</main>

</body>
</html>
