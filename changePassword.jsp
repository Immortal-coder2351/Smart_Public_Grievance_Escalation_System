<%@ page import="com.grievance.model.User" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String dashboard = "CITIZEN".equals(user.getRole())
            ? "citizenDashboard"
            : "OFFICER".equals(user.getRole())
                ? "officerDashboard.jsp"
                : "adminDashboard.jsp";
    String error = request.getParameter("error");
    String success = request.getParameter("success");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Change Password - Grievance System</title>
    <link rel="stylesheet" href="css/style.css">
    <script src="js/script.js" defer></script>
</head>
<body>

<header class="site-header">
    <div class="header-inner">
        <a class="brand dashboard-brand" href="<%= dashboard %>">
            <span class="brand-logo" aria-hidden="true"><svg viewBox="0 0 48 48"><path d="M7 18 24 8l17 10M10 20h28M12 39h24M15 20v17m9-17v17m9-17v17M8 42h32"/><path d="m19 29 4 4 8-9"/></svg></span>
            Grievance System
        </a>
        <nav class="nav-links" aria-label="Account navigation">
            <a href="<%= dashboard %>">Dashboard</a>
            <a class="active" href="changePassword">Change Password</a>
            <a href="logout">Logout</a>
        </nav>
    </div>
</header>

<main class="page">
    <section class="form-card narrow password-card">
        <div class="center">
            <p class="eyebrow">Account security</p>
            <h1 class="page-title">Change Password</h1>
            <p class="page-subtitle">Enter your current password and choose a new one.</p>
        </div>

        <% if ("updated".equals(success)) { %>
            <p class="password-message success" role="status">Your password has been changed successfully.</p>
        <% } else if ("required".equals(error)) { %>
            <p class="password-message error" role="alert">Enter your current password, new password, and confirmation.</p>
        <% } else if ("mismatch".equals(error)) { %>
            <p class="password-message error" role="alert">The new password and confirmation do not match.</p>
        <% } else if ("same".equals(error)) { %>
            <p class="password-message error" role="alert">Your new password must be different from your current password.</p>
        <% } else if ("current".equals(error)) { %>
            <p class="password-message error" role="alert">Your current password is incorrect.</p>
        <% } %>

        <form id="changePasswordForm" action="changePassword" method="post">
            <div class="form-field">
                <label for="currentPassword">Current password</label>
                <input type="password" id="currentPassword" name="currentPassword"
                       autocomplete="current-password" required>
            </div>

            <div class="form-field">
                <label for="newPassword">New password</label>
                <input type="password" id="newPassword" name="newPassword"
                       autocomplete="new-password" required>
            </div>

            <div class="form-field">
                <label for="confirmNewPassword">Confirm new password</label>
                <input type="password" id="confirmNewPassword" name="confirmNewPassword"
                       autocomplete="new-password" required>
            </div>

            <div class="form-actions">
                <input type="submit" value="Update Password">
            </div>
        </form>

        <div class="link-row">
            <a href="<%= dashboard %>">Back to Dashboard</a>
        </div>
    </section>
</main>

</body>
</html>
