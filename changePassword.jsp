<%@ page import="com.grievance.model.User" %>
<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    User user = (User) session.getAttribute("user");

    if (user == null ||
            (!"CITIZEN".equals(user.getRole())
            && !"OFFICER".equals(user.getRole())
            && !"ADMIN".equals(user.getRole()))) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    String contextPath = request.getContextPath();

    String dashboard = "CITIZEN".equals(user.getRole())
            ? contextPath + "/citizenDashboard"
            : "OFFICER".equals(user.getRole())
                ? contextPath + "/officerDashboard.jsp"
                : contextPath + "/adminDashboard.jsp";

    String error = request.getParameter("error");
    String success = request.getParameter("success");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate">
    <meta http-equiv="Pragma" content="no-cache">
    <meta http-equiv="Expires" content="0">
    <title>Change Password - Grievance System</title>
    <link rel="stylesheet" href="<%= contextPath %>/css/style.css">
    <script src="<%= contextPath %>/js/script.js" defer></script>
</head>
<body>

<header class="site-header">
    <div class="header-inner">
        <a class="brand dashboard-brand" href="<%= dashboard %>">
            <span class="brand-logo" aria-hidden="true">
                <svg viewBox="0 0 48 48">
                    <path d="M7 18 24 8l17 10M10 20h28M12 39h24M15 20v17m9-17v17m9-17v17M8 42h32"/>
                    <path d="m19 29 4 4 8-9"/>
                </svg>
            </span>
            Grievance System
        </a>

        <nav class="nav-links" aria-label="Account navigation">
            <a href="<%= dashboard %>">Dashboard</a>
            <a class="active" href="<%= contextPath %>/changePassword">Change Password</a>
            <a href="<%= contextPath %>/logout">Logout</a>
        </nav>
    </div>
</header>

<main class="page">
    <section class="form-card narrow password-card">

        <div class="center">
            <p class="eyebrow">Account security</p>
            <h1 class="page-title">Change Password</h1>
            <p class="page-subtitle">
                Enter your current password and choose a new one.
            </p>
        </div>

        <% if ("updated".equals(success)) { %>
            <p class="password-message success" role="status">
                Your password has been changed successfully.
            </p>
        <% } else if ("required".equals(error)) { %>
            <p class="password-message error" role="alert">
                Enter your current password, new password, and confirmation.
            </p>
        <% } else if ("weakPassword".equals(error)) { %>
            <p class="password-message error" role="alert">
                Your new password must contain at least 12 characters,
                one uppercase letter, one lowercase letter, one number,
                and one special character.
            </p>
        <% } else if ("mismatch".equals(error)) { %>
            <p class="password-message error" role="alert">
                The new password and confirmation do not match.
            </p>
        <% } else if ("same".equals(error)) { %>
            <p class="password-message error" role="alert">
                Your new password must be different from your current password.
            </p>
        <% } else if ("current".equals(error)) { %>
            <p class="password-message error" role="alert">
                Your current password is incorrect.
            </p>
        <% } %>

        <form id="changePasswordForm" action="<%= contextPath %>/changePassword" method="post">

            <div class="form-field">
                <label for="currentPassword">Current password</label>
                <input
                    type="password"
                    id="currentPassword"
                    name="currentPassword"
                    autocomplete="current-password"
                    required>
            </div>

            <div class="form-field">
                <label for="newPassword">New password</label>
                <input
                    type="password"
                    id="newPassword"
                    name="newPassword"
                    autocomplete="new-password"
                    minlength="12"
                    required>
                <small>
                    At least 12 characters, including uppercase and lowercase
                    letters, a number, and a special character.
                </small>
            </div>

            <div class="form-field">
                <label for="confirmNewPassword">Confirm new password</label>
                <input
                    type="password"
                    id="confirmNewPassword"
                    name="confirmNewPassword"
                    autocomplete="new-password"
                    minlength="12"
                    required>
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