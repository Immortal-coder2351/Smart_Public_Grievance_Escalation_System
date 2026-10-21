<%@ page import="com.grievance.model.User" %>
<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    User currentUser = (User) session.getAttribute("user");

    if (currentUser != null) {
        String role = currentUser.getRole();
        String dashboard = null;

        if ("ADMIN".equals(role)) {
            dashboard = "adminDashboard.jsp";
        } else if ("OFFICER".equals(role)) {
            dashboard = "officerDashboard.jsp";
        } else if ("CITIZEN".equals(role)) {
            dashboard = "citizenDashboard";
        }

        if (dashboard != null) {
            response.sendRedirect(request.getContextPath() + "/" + dashboard);
            return;
        }

        session.invalidate();
    }

    String contextPath = request.getContextPath();
    String error = request.getParameter("error");
    String message = null;

    if ("invalid".equals(error)) {
        message = "Invalid username or password.";
    } else if ("required".equals(error)) {
        message = "Please enter your username and password.";
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate">
    <meta http-equiv="Pragma" content="no-cache">
    <meta http-equiv="Expires" content="0">
    <title>Login - Grievance System</title>
    <link rel="stylesheet" href="<%= contextPath %>/css/style.css">
    <script src="<%= contextPath %>/js/script.js" defer></script>
</head>
<body>

<header class="site-header">
    <div class="header-inner">
        <a class="brand" href="<%= contextPath %>/index.jsp">Grievance System</a>
        <nav class="nav-links" aria-label="Main navigation">
            <a href="<%= contextPath %>/index.jsp">Home</a>
            <a href="<%= contextPath %>/register.jsp">Register</a>
            <a class="active" href="<%= contextPath %>/login.jsp" aria-current="page">Login</a>
        </nav>
    </div>
</header>

<main class="page">
    <div class="form-card narrow">
        <div class="center">
            <h1 class="page-title">User Login</h1>
            <p class="page-subtitle">Sign in to access your grievance portal.</p>
        </div>

        <% if (message != null) { %>
            <div class="message error" role="alert" tabindex="-1" id="loginError"><%= message %></div>
            <script>
                document.addEventListener("DOMContentLoaded", function () {
                    const errorMessage = document.getElementById("loginError");
                    if (errorMessage) {
                        errorMessage.focus();
                    }
                });
            </script>
        <% } %>

        <form action="<%= contextPath %>/login" method="post" autocomplete="on">
            <div class="form-field">
                <label for="username">Username</label>
                <input
                    type="text"
                    id="username"
                    name="username"
                    autocomplete="username"
                    maxlength="100"
                    required>
            </div>

            <div class="form-field">
                <label for="password">Password</label>
                <input
                    type="password"
                    id="password"
                    name="password"
                    autocomplete="current-password"
                    required>
            </div>

            <div class="form-actions">
                <input type="submit" value="Login">
            </div>
        </form>

        <div class="link-row">
            <a href="<%= contextPath %>/register.jsp">Don't have an account? Register</a>
        </div>
    </div>
</main>

</body>
</html>