<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Registration - Grievance System</title>
    <link rel="stylesheet" href="css/style.css">
    <script src="js/script.js" defer></script>
</head>
<body>

<header class="site-header">
    <div class="header-inner">
        <a class="brand" href="index.jsp">Grievance System</a>
        <nav class="nav-links">
            <a href="index.jsp">Home</a>
            <a class="active" href="register.jsp">Register</a>
            <a href="login.jsp">Login</a>
        </nav>
    </div>
</header>

<main class="page">
    <div class="form-card">
        <div class="center">
            <h1 class="page-title">User Registration</h1>
            <p class="page-subtitle">Create your citizen account.</p>
        </div>

        <form action="register" method="post">
            <div class="form-grid">
                <div class="form-field full">
                    <label for="name">Full Name</label>
                    <input type="text" id="name" name="name" required>
                </div>

                <div class="form-field">
                    <label for="phone">Mobile Number</label>
                    <input type="text" id="phone" name="phone">
                </div>

                <div class="form-field">
                    <label for="email">Email Address</label>
                    <input type="email" id="email" name="email" required>
                </div>

                <div class="form-field">
                    <label for="username">Username</label>
                    <input type="text" id="username" name="username" required>
                </div>

                <div class="form-field">
                    <label for="password">Password</label>
                    <input type="password" id="password" name="password" required>
                </div>

                <div class="form-field full">
                    <label for="confirmPassword">Confirm Password</label>
                    <input type="password" id="confirmPassword" name="confirmPassword" required>
                </div>

                <div class="form-actions full">
                    <input type="submit" value="Register">
                </div>
            </div>
        </form>

        <div class="link-row">
            Already have an account?
            <a href="login.jsp">Login</a>
        </div>
    </div>
</main>

</body>
</html>
