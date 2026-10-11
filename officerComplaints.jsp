<%@ page import="com.grievance.model.User" %>
<%@ page import="com.grievance.model.Complaint" %>
<%@ page import="java.util.List" %>
<%
    User user = (User) session.getAttribute("user");

    if (user == null || !"OFFICER".equals(user.getRole())) {
        response.sendRedirect("login.jsp");
        return;
    }

    List<Complaint> complaints =
            (List<Complaint>) request.getAttribute("complaints");

    String error = request.getParameter("error");
    String success = request.getParameter("success");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Assigned Complaints</title>
    <link rel="stylesheet" href="css/style.css">
    <script src="js/script.js" defer></script>
</head>
<body>

<header class="site-header">
    <div class="header-inner">
        <a class="brand" href="officerDashboard.jsp">Grievance System</a>
        <nav class="nav-links">
            <a href="officerDashboard.jsp">Dashboard</a>
            <a class="active" href="officerComplaints">Assigned Complaints</a>
            <a href="changePassword">Change Password</a>
            <a href="logout">Logout</a>
        </nav>
    </div>
</header>

<main class="page">
    <h1 class="page-title">Assigned Complaints</h1>
    <p class="page-subtitle">
        Officer: <strong><%= user.getName() %></strong>
        &nbsp;|&nbsp; Level <strong><%= user.getOfficerLevel() %></strong>
    </p>

<%
    if ("updated".equals(success)) {
%>
    <div class="message success">Complaint updated successfully.</div>
<%
    }

    if ("missing".equals(error)) {
%>
    <div class="message error">Please enter all required details.</div>
<%
    } else if ("invalid".equals(error)) {
%>
    <div class="message error">Invalid complaint ID.</div>
<%
    } else if ("failed".equals(error)) {
%>
    <div class="message error">Complaint could not be updated. It may no longer be assigned to you.</div>
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
        <p>No complaints are currently assigned to you.</p>
<%
    } else {
%>
        <div class="table-wrap">
            <table>
                <tr>
                    <th>Complaint ID</th>
                    <th>Title</th>
                    <th>Category</th>
                    <th>Priority</th>
                    <th>Description</th>
                    <th>Location</th>
                    <th>Image</th>
                    <th>Status</th>
                    <th>History</th>
                    <th>Update</th>
                </tr>
<%
        for (Complaint complaint : complaints) {
            String status = complaint.getStatus() == null
                    ? ""
                    : complaint.getStatus().toLowerCase().replace('_', '-');
%>
                <tr>
                    <td><%= complaint.getComplaintId() %></td>
                    <td><%= complaint.getTitle() %></td>
                    <td><%= complaint.getCategory() %></td>
                    <td><span class="priority priority-<%= complaint.getPriority() == null ? "medium" : complaint.getPriority().toLowerCase() %>"><%= complaint.getPriority() == null ? "MEDIUM" : complaint.getPriority() %></span></td>
                    <td><%= complaint.getDescription() %></td>
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
                        <form class="inline-form" action="updateComplaint" method="post">
                            <input type="hidden"
                                   name="complaintId"
                                   value="<%= complaint.getComplaintId() %>">

                            <label>Status:</label>
                            <select name="status" required>
                                <option value="">Select Status</option>
                                <option value="IN_PROGRESS">IN PROGRESS</option>
                                <option value="RESOLVED">RESOLVED</option>
                            </select>

                            <label>Remarks:</label>
                            <textarea name="remarks"
                                      rows="4"
                                      placeholder="Enter remarks"
                                      required></textarea>

                            <input type="submit" value="Update">
                        </form>
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
        <a href="officerDashboard.jsp">Back to Officer Dashboard</a>
    </div>
</main>

</body>
</html>
