<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Login - Grievance System</title>
    <link rel="stylesheet" href="css/style.css">
    <script src="js/script.js" defer></script>
</head>
<body>

<header class="site-header">
    <div class="header-inner">
        <a class="brand" href="index.jsp">Grievance System</a>
        <nav class="nav-links">
            <a href="index.jsp">Home</a>
            <a href="register.jsp">Register</a>
            <a class="active" href="login.jsp">Login</a>
        </nav>
    </div>
</header>

<main class="page">
    <div class="form-card narrow">
        <div class="center">
            <h1 class="page-title">User Login</h1>
            <p class="page-subtitle">Sign in to access your grievance portal.</p>
        </div>

        <form action="login" method="post">
            <div class="form-field">
                <label for="username">Username</label>
                <input type="text" id="username" name="username" required>
            </div>

            <div class="form-field">
                <label for="password">Password</label>
                <input type="password" id="password" name="password" required>
            </div>

            <div class="form-actions">
                <input type="submit" value="Login">
            </div>
        </form>

        <div class="link-row">
            <a href="register.jsp">Don't have an account? Register</a>
        </div>
    </div>
</main>

</body>
</html>
