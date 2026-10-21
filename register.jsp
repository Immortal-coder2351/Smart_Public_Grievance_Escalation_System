<%@ page import="com.grievance.model.User" %>
<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    User loggedInUser = (User) session.getAttribute("user");

    if (loggedInUser != null) {
        String role = loggedInUser.getRole();

        if ("ADMIN".equals(role)) {
            response.sendRedirect(request.getContextPath() + "/adminDashboard.jsp");
            return;
        } else if ("OFFICER".equals(role)) {
            response.sendRedirect(request.getContextPath() + "/officerDashboard.jsp");
            return;
        } else if ("CITIZEN".equals(role)) {
            response.sendRedirect(request.getContextPath() + "/citizenDashboard");
            return;
        } else {
            session.invalidate();
        }
    }

    String contextPath = request.getContextPath();
    String error = request.getParameter("error");
    String message = null;

    if ("required".equals(error) || "missing".equals(error)) {
        message = "Please fill in all required fields.";
    } else if ("username".equals(error)) {
        message = "This username is already taken. Please choose another.";
    } else if ("email".equals(error)) {
        message = "An account with this email already exists.";
    } else if ("weakPassword".equals(error)) {
        message = "Password must contain at least 12 characters, including uppercase, lowercase, a number, and a special character.";
    } else if ("passwordMismatch".equals(error)) {
        message = "Password and confirm password do not match.";
    } else if ("invalid".equals(error) || "invalidData".equals(error)) {
        message = "Please enter valid registration details.";
    } else if ("failed".equals(error) || "server".equals(error)) {
        message = "Registration could not be completed. Please try again.";
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="theme-color" content="#f4f8f6">
    <title>Registration - Grievance System</title>
    <link rel="stylesheet" href="<%= contextPath %>/css/style.css">
    <script src="<%= contextPath %>/js/script.js" defer></script>
</head>
<body>

<header class="site-header">
    <div class="header-inner">
        <a class="brand" href="<%= contextPath %>/index.jsp">Grievance System</a>
        <nav class="nav-links" aria-label="Main navigation">
            <a href="<%= contextPath %>/index.jsp">Home</a>
            <a class="active" href="<%= contextPath %>/register.jsp" aria-current="page">Register</a>
            <a href="<%= contextPath %>/login.jsp">Login</a>
        </nav>
    </div>
</header>

<main class="page">
    <div class="form-card">
        <div class="center">
            <h1 class="page-title">User Registration</h1>
            <p class="page-subtitle">Create your citizen account.</p>
        </div>

        <% if (message != null) { %>
            <div class="form-error" role="alert" tabindex="-1" id="registrationError">
                <%= message %>
            </div>
        <% } %>

        <form id="registrationForm" action="<%= contextPath %>/register" method="post" autocomplete="on">
            <div class="form-grid">
                <div class="form-field full">
                    <label for="name">Full Name</label>
                    <input type="text" id="name" name="name" autocomplete="name" maxlength="100" required>
                </div>

                <div class="form-field">
                    <label for="phone">Mobile Number</label>
                    <input type="tel" id="phone" name="phone" autocomplete="tel" inputmode="numeric" pattern="[0-9]{10,15}" maxlength="15" aria-describedby="phoneHelp">
                    <small id="phoneHelp">Enter 10 to 15 digits if providing a mobile number.</small>
                </div>

                <div class="form-field">
                    <label for="email">Email Address</label>
                    <input type="email" id="email" name="email" autocomplete="email" maxlength="150" required>
                </div>

                <div class="form-field">
                    <label for="username">Username</label>
                    <input type="text" id="username" name="username" autocomplete="username" minlength="3" maxlength="50" required>
                </div>

                <div class="form-field">
                    <label for="password">Password</label>
                    <input type="password" id="password" name="password" autocomplete="new-password" minlength="12" aria-describedby="passwordHelp" required>
                    <small id="passwordHelp">At least 12 characters, with uppercase, lowercase, a number, and a special character.</small>
                </div>

                <div class="form-field full">
                    <label for="confirmPassword">Confirm Password</label>
                    <input type="password" id="confirmPassword" name="confirmPassword" autocomplete="new-password" minlength="12" required>
                </div>

                <div class="form-actions full">
                    <input type="submit" value="Register">
                </div>
            </div>
        </form>

        <div class="link-row">
            Already have an account?
            <a href="<%= contextPath %>/login.jsp">Login</a>
        </div>
    </div>
</main>

<script>
    const registrationError = document.getElementById("registrationError");

    if (registrationError) {
        registrationError.focus();
    }

    const registrationForm = document.getElementById("registrationForm");

    if (registrationForm) {
        registrationForm.addEventListener("submit", function (event) {
            const password = document.getElementById("password").value;
            const confirmPassword = document.getElementById("confirmPassword").value;

            if (password !== confirmPassword) {
                event.preventDefault();
                alert("Password and confirm password do not match.");
                document.getElementById("confirmPassword").focus();
            }
        });
    }
</script>

</body>
</html>