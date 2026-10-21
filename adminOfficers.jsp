<%@ page import="com.grievance.model.User" %>
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

    String contextPath = request.getContextPath();
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
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate">
    <meta http-equiv="Pragma" content="no-cache">
    <meta http-equiv="Expires" content="0">
    <title>Manage Officers</title>
    <link rel="stylesheet" href="<%= contextPath %>/css/style.css">
    <script src="<%= contextPath %>/js/script.js" defer></script>
</head>
<body>

<header class="site-header">
    <div class="header-inner">
        <a class="brand" href="<%= contextPath %>/adminDashboard.jsp">Grievance System</a>
        <nav class="nav-links" aria-label="Admin navigation">
            <a href="<%= contextPath %>/adminDashboard.jsp">Dashboard</a>
            <a href="<%= contextPath %>/adminComplaints">Complaints</a>
            <a class="active" href="<%= contextPath %>/adminOfficers.jsp" aria-current="page">Officers</a>
            <a href="<%= contextPath %>/changePassword">Change Password</a>
            <a href="<%= contextPath %>/logout">Logout</a>
        </nav>
    </div>
</header>

<main class="page">
    <h1 class="page-title">Officer Management</h1>
    <p class="page-subtitle">Welcome, <strong><%= user.getName() %></strong>.</p>

    <% if ("officerAdded".equals(success)) { %>
        <div class="message success" role="status" tabindex="-1" id="pageMessage">
            Officer added successfully.
        </div>
    <% } else if ("missing".equals(error) || "required".equals(error)) { %>
        <div class="message error" role="alert" tabindex="-1" id="pageMessage">
            Please enter all required details.
        </div>
    <% } else if ("username".equals(error)) { %>
        <div class="message error" role="alert" tabindex="-1" id="pageMessage">
            Username already exists.
        </div>
    <% } else if ("email".equals(error)) { %>
        <div class="message error" role="alert" tabindex="-1" id="pageMessage">
            Email already exists.
        </div>
    <% } else if ("weakPassword".equals(error)) { %>
        <div class="message error" role="alert" tabindex="-1" id="pageMessage">
            Password must contain at least 12 characters, one uppercase letter, one lowercase letter, one number, and one special character.
        </div>
    <% } else if ("invalidData".equals(error) || "invalid".equals(error)) { %>
        <div class="message error" role="alert" tabindex="-1" id="pageMessage">
            Please enter valid officer details.
        </div>
    <% } else if ("failed".equals(error)) { %>
        <div class="message error" role="alert" tabindex="-1" id="pageMessage">
            Officer could not be added.
        </div>
    <% } else if ("server".equals(error)) { %>
        <div class="message error" role="alert" tabindex="-1" id="pageMessage">
            A server error occurred.
        </div>
    <% } %>

    <div class="two-column">
        <div class="content-card">
            <h2>Add Officer</h2>

            <form class="inline-form" action="<%= contextPath %>/addOfficer" method="post" autocomplete="on">
                <div class="form-field">
                    <label for="name">Name</label>
                    <input type="text" id="name" name="name" maxlength="100" autocomplete="name" required>
                </div>

                <div class="form-field">
                    <label for="email">Email</label>
                    <input type="email" id="email" name="email" maxlength="255" autocomplete="email" required>
                </div>

                <div class="form-field">
                    <label for="phone">Phone</label>
                    <input type="tel" id="phone" name="phone" maxlength="15" inputmode="numeric" pattern="[0-9]{10,15}" aria-describedby="phoneHelp">
                    <small id="phoneHelp">Enter 10 to 15 digits if providing a phone number.</small>
                </div>

                <div class="form-field">
                    <label for="username">Username</label>
                    <input type="text" id="username" name="username" maxlength="100" autocomplete="username" required>
                </div>

                <div class="form-field">
                    <label for="password">Password</label>
                    <input type="password" id="password" name="password" minlength="12" autocomplete="new-password" aria-describedby="passwordHelp" required>
                    <small id="passwordHelp">Use at least 12 characters, including uppercase, lowercase, a number, and a special character.</small>
                </div>

                <div class="form-field">
                    <label for="departmentId">Department</label>
                    <select id="departmentId" name="departmentId" required>
                        <option value="">Select Department</option>
                        <option value="1">Roads</option>
                        <option value="2">Water Supply</option>
                        <option value="3">Electricity</option>
                        <option value="4">Sanitation</option>
                        <option value="5">Drainage</option>
                        <option value="6">Garbage Collection</option>
                        <option value="7">Street Lighting</option>
                    </select>
                </div>

                <div class="form-field">
                    <label for="officerLevel">Officer Level</label>
                    <select id="officerLevel" name="officerLevel" required>
                        <option value="">Select Level</option>
                        <option value="1">Level 1</option>
                        <option value="2">Level 2</option>
                        <option value="3">Level 3</option>
                    </select>
                </div>

                <div class="form-actions">
                    <input type="submit" value="Add Officer">
                </div>
            </form>
        </div>

        <div class="content-card">
            <h2>Officer Structure</h2>
            <p class="small">Each department uses three escalation levels.</p>
            <ul class="action-list">
                <li>
                    <div class="quick-link">
                        <strong>Level 1</strong> First assigned officer
                    </div>
                </li>
                <li>
                    <div class="quick-link">
                        <strong>Level 2</strong> First escalation
                    </div>
                </li>
                <li>
                    <div class="quick-link">
                        <strong>Level 3</strong> Final escalation level
                    </div>
                </li>
            </ul>
        </div>
    </div>

    <div class="content-card">
        <h2>Existing Officers</h2>

        <% if (officers == null || officers.isEmpty()) { %>
            <p>No officers found.</p>
        <% } else { %>
            <div class="table-wrap" role="region" aria-label="Existing officers table" tabindex="0">
                <table>
                    <caption class="sr-only">Existing officers and their department assignments</caption>
                    <thead>
                        <tr>
                            <th scope="col">ID</th>
                            <th scope="col">Name</th>
                            <th scope="col">Email</th>
                            <th scope="col">Username</th>
                            <th scope="col">Department</th>
                            <th scope="col">Level</th>
                        </tr>
                    </thead>
                    <tbody>
                    <% for (User officer : officers) {
                        int deptId = officer.getDepartmentId() == null
                                ? 0 : officer.getDepartmentId();

                        String deptName = deptId >= 1 && deptId < departmentNames.length
                                ? departmentNames[deptId]
                                : "Unknown";
                    %>
                        <tr>
                            <td><%= officer.getUserId() %></td>
                            <td><%= officer.getName() %></td>
                            <td><%= officer.getEmail() %></td>
                            <td><%= officer.getUsername() %></td>
                            <td><%= deptName %></td>
                            <td>Level <%= officer.getOfficerLevel() %></td>
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

<script>
    const pageMessage = document.getElementById("pageMessage");
    if (pageMessage) {
        pageMessage.focus();
    }
</script>

</body>
</html>