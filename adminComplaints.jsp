<%@ page import="com.grievance.model.User" %>
<%@ page import="com.grievance.model.Complaint" %>
<%@ page import="com.grievance.dao.OfficerDAO" %>
<%@ page import="java.util.List" %>
<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    User user = (User) session.getAttribute("user");

    if (user == null || !"ADMIN".equals(user.getRole())) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    List<Complaint> complaints =
            (List<Complaint>) request.getAttribute("complaints");

    OfficerDAO officerDAO = new OfficerDAO();
    List<User> officers = officerDAO.getAllOfficers();

    String error = request.getParameter("error");
    String success = request.getParameter("success");
    String contextPath = request.getContextPath();

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
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate">
    <meta http-equiv="Pragma" content="no-cache">
    <meta http-equiv="Expires" content="0">
    <title>All Complaints</title>
    <link rel="stylesheet" href="<%= contextPath %>/css/style.css">
    <script src="<%= contextPath %>/js/script.js" defer></script>
</head>
<body>

<header class="site-header">
    <div class="header-inner">
        <a class="brand" href="<%= contextPath %>/adminDashboard.jsp">Grievance System</a>
        <nav class="nav-links" aria-label="Admin navigation">
            <a href="<%= contextPath %>/adminDashboard.jsp">Dashboard</a>
            <a class="active" href="<%= contextPath %>/adminComplaints">Complaints</a>
            <a href="<%= contextPath %>/adminOfficers.jsp">Officers</a>
            <a href="<%= contextPath %>/changePassword">Change Password</a>
            <a href="<%= contextPath %>/logout">Logout</a>
        </nav>
    </div>
</header>

<main class="page">
    <h1 class="page-title">All Complaints</h1>
    <p class="page-subtitle">Welcome, <strong><%= user.getName() %></strong>.</p>

    <% if ("assigned".equals(success)) { %>
        <div class="message success" role="status">Complaint assigned successfully.</div>
    <% } %>

    <% if ("missing".equals(error)) { %>
        <div class="message error" role="alert">Please enter all required details.</div>
    <% } else if ("invalid".equals(error)) { %>
        <div class="message error" role="alert">Invalid complaint details.</div>
    <% } else if ("failed".equals(error)) { %>
        <div class="message error" role="alert">Complaint could not be assigned.</div>
    <% } else if ("server".equals(error)) { %>
        <div class="message error" role="alert">A server error occurred.</div>
    <% } %>

    <div class="content-card">
        <% if (complaints == null || complaints.isEmpty()) { %>
            <p>No complaints found.</p>
        <% } else { %>
            <div class="table-wrap" role="region" aria-label="All complaints table" tabindex="0">
                <table>
                    <caption class="sr-only">All registered complaints and administrator actions</caption>
                    <thead>
                        <tr>
                            <th scope="col">Complaint ID</th>
                            <th scope="col">Citizen ID</th>
                            <th scope="col">Department</th>
                            <th scope="col">Title</th>
                            <th scope="col">Category</th>
                            <th scope="col">Priority</th>
                            <th scope="col">Location</th>
                            <th scope="col">Image</th>
                            <th scope="col">Status</th>
                            <th scope="col">History</th>
                            <th scope="col">Admin Action</th>
                        </tr>
                    </thead>
                    <tbody>
                    <% for (Complaint complaint : complaints) {
                        int deptId = complaint.getDepartmentId();

                        String deptName =
                                deptId >= 1 && deptId < departmentNames.length
                                ? departmentNames[deptId]
                                : String.valueOf(deptId);

                        String complaintStatus = complaint.getStatus() == null
                                ? ""
                                : complaint.getStatus().toLowerCase().replace('_', '-');

                        String priority = complaint.getPriority() == null
                                ? "medium"
                                : complaint.getPriority().toLowerCase();
                    %>
                        <tr>
                            <td><%= complaint.getComplaintId() %></td>
                            <td><%= complaint.getCitizenId() %></td>
                            <td><%= deptName %></td>
                            <td><%= complaint.getTitle() %></td>
                            <td><%= complaint.getCategory() %></td>
                            <td>
                                <span class="priority priority-<%= priority %>">
                                    <%= complaint.getPriority() == null ? "MEDIUM" : complaint.getPriority() %>
                                </span>
                            </td>
                            <td><%= complaint.getLocation() %></td>
                            <td>
                                <% if (complaint.getImage() != null
                                        && !complaint.getImage().trim().isEmpty()) { %>
                                    <a href="<%= contextPath %>/<%= complaint.getImage().replace("\\", "/").replaceFirst("^/+", "") %>"
                                       target="_blank"
                                       rel="noopener noreferrer">
                                        View Image
                                    </a>
                                <% } else { %>
                                    <span class="small">No image</span>
                                <% } %>
                            </td>
                            <td>
                                <span class="status status-<%= complaintStatus %>">
                                    <%= complaint.getStatus() == null ? "Unknown" : complaint.getStatus() %>
                                </span>
                            </td>
                            <td>
                                <a href="<%= contextPath %>/complaintHistory?complaintId=<%= complaint.getComplaintId() %>">
                                    View History
                                </a>
                            </td>
                            <td>
                                <% if ("ESCALATION_PENDING".equals(complaint.getStatus())) { %>
                                    <form class="inline-form"
                                          action="<%= contextPath %>/adminAssignComplaint"
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
                                            <% for (User officer : officers) {
                                                int officerDept = officer.getDepartmentId() == null
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
                                            <% } %>
                                        </select>

                                        <input type="submit" value="Reassign">
                                    </form>
                                <% } else { %>
                                    <span class="small">No action required</span>
                                <% } %>
                            </td>
                        </tr>
                    <% } %>
                    </tbody>
                </table>
            </div>
        <% } %>
    </div>

    <div class="page-footer">
        <a href="<%= contextPath %>/adminDashboard.jsp">Back to Admin Dashboard</a>
    </div>
</main>

</body>
</html>