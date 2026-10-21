<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    String contextPath = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="theme-color" content="#f4f8f6">
    <meta name="description" content="Report civic issues, follow complaint progress and stay connected with your local authorities.">
    <meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate">
    <meta http-equiv="Pragma" content="no-cache">
    <meta http-equiv="Expires" content="0">
    <title>Smart Grievance | Your voice, better communities</title>
    <link rel="stylesheet" href="<%= contextPath %>/css/home.css">
</head>
<body>

<header class="site-header">
    <div class="header-inner">
        <a class="brand" href="<%= contextPath %>/index.jsp" aria-label="Smart Grievance home">
            <span class="brand-mark" aria-hidden="true">
                <svg viewBox="0 0 48 48"><path d="M7 19 24 8l17 11M11 21h26M13 21v16m11-16v16m11-16v16M9 41h30"/><path d="m18 29 4 4 8-9"/></svg>
            </span>
            <span class="brand-copy"><strong>Smart Grievance</strong><small>PUBLIC SERVICE PORTAL</small></span>
        </a>

        <nav class="main-nav" aria-label="Main navigation">
            <a class="nav-current" href="<%= contextPath %>/index.jsp">Home</a>
            <a href="#how-it-works">How it works</a>
            <a href="#services">Services</a>
        </nav>

        <div class="header-actions">
            <a class="button button-login" href="<%= contextPath %>/login.jsp">
                <svg aria-hidden="true" viewBox="0 0 24 24"><path d="M10 17l5-5-5-5m5 5H3"/><path d="M13 4h5a2 2 0 0 1 2 2v12a2 2 0 0 1-2 2h-5"/></svg>
                Log in
            </a>
            <a class="button button-account button-primary" href="<%= contextPath %>/register.jsp">
                <svg aria-hidden="true" viewBox="0 0 24 24"><path d="M12 5v14m-7-7h14"/></svg>
                Create account
            </a>
        </div>
    </div>
</header>

<main>
    <section class="hero">
        <div class="hero-inner">
            <div class="hero-copy">
                <p class="eyebrow"><span class="eyebrow-dot"></span> A better way to be heard</p>
                <h1>Your voice can make <span>your community</span> better.</h1>
                <p class="hero-description">Report a local issue, follow every update and help the right team take action. Your community deserves a service that listens.</p>
                <div class="hero-actions">
                    <a class="button button-primary" href="<%= contextPath %>/register.jsp">Raise a complaint <svg aria-hidden="true" viewBox="0 0 24 24"><path d="M5 12h14m-6-6 6 6-6 6"/></svg></a>
                    <a class="button button-quiet" href="<%= contextPath %>/login.jsp"><span class="play-icon" aria-hidden="true"><svg viewBox="0 0 24 24"><circle cx="11" cy="11" r="7"/><path d="m16 16 4 4m-9-12v6l4 2"/></svg></span> Track a complaint</a>
                </div>
                <div class="hero-assurance">
                    <span class="assurance-icon" aria-hidden="true">
                        <svg viewBox="0 0 24 24"><path d="m12 3 7 3v5c0 4.6-2.9 8-7 10-4.1-2-7-5.4-7-10V6l7-3Z"/><path d="m9 12 2 2 4-4"/></svg>
                    </span>
                    <span><strong>Every report matters</strong><small>Follow progress with clear status updates</small></span>
                </div>
            </div>

            <div class="hero-art" aria-label="Illustration of a citizen submitting a neighborhood concern" role="img">
                <div class="art-orbit orbit-one"></div>
                <div class="art-orbit orbit-two"></div>
                <div class="sun"></div>
                <div class="city">
                    <div class="building building-back"><span></span><span></span><span></span><span></span></div>
                    <div class="building building-mid"><span></span><span></span><span></span><span></span><span></span><span></span></div>
                    <div class="building building-front"><span></span><span></span><span></span><span></span></div>
                    <div class="civic-building">
                        <div class="civic-roof"></div>
                        <div class="civic-top"><span></span><span></span><span></span></div>
                        <div class="civic-base"></div>
                    </div>
                    <div class="tree tree-one"><i></i><b></b></div>
                    <div class="tree tree-two"><i></i><b></b></div>
                    <div class="ground"></div>
                </div>
                <div class="report-card">
                    <div class="report-card-top">
                        <span class="report-icon" aria-hidden="true">
                            <svg viewBox="0 0 24 24"><path d="M12 3 2.8 19h18.4L12 3Z"/><path d="M12 9v4m0 3h.01"/></svg>
                        </span>
                        <span class="report-label"><strong>New report received</strong><small>Neighborhood services</small></span>
                        <span class="report-check" aria-hidden="true"><svg viewBox="0 0 24 24"><path d="m5 12 4 4L19 6"/></svg></span>
                    </div>
                    <div class="report-progress"><span></span></div>
                    <div class="report-foot"><span>Request #SG-2048</span><span>Just now</span></div>
                </div>
                <div class="art-caption"><span class="caption-pulse"></span> Building a more responsive community</div>
            </div>
        </div>
        <div class="hero-bottom">
            <span>One simple place to report</span>
            <span class="bottom-line"></span>
            <span>Roads</span><span class="bottom-dot"></span><span>Water</span><span class="bottom-dot"></span><span>Sanitation</span><span class="bottom-dot"></span><span>And more</span>
        </div>
    </section>

    <section class="services section-wrap" id="services">
        <div class="section-heading">
            <div>
                <p class="eyebrow">Here for your neighborhood</p>
                <h2>What needs attention?</h2>
            </div>
            <a class="text-link" href="<%= contextPath %>/register.jsp">Report an issue <svg aria-hidden="true" viewBox="0 0 24 24"><path d="M7 17 17 7M8 7h9v9"/></svg></a>
        </div>

        <div class="service-grid">
            <a class="service-card" href="<%= contextPath %>/complaint.jsp?category=Roads">
                <span class="service-icon roads" aria-hidden="true"><svg viewBox="0 0 24 24"><path d="M8 3 5 21m11-18 3 18M12 5v3m0 4v3m0 4v2"/></svg></span>
                <span class="service-name">Roads &amp; streets</span><span class="service-arrow" aria-hidden="true"><svg viewBox="0 0 24 24"><path d="M7 17 17 7M8 7h9v9"/></svg></span>
            </a>
            <a class="service-card" href="<%= contextPath %>/complaint.jsp?category=Water%20Supply">
                <span class="service-icon water" aria-hidden="true"><svg viewBox="0 0 24 24"><path d="M12 3s-6 7-6 11a6 6 0 0 0 12 0c0-4-6-11-6-11Z"/><path d="M9 15a3 3 0 0 0 3 3"/></svg></span>
                <span class="service-name">Water supply</span><span class="service-arrow" aria-hidden="true"><svg viewBox="0 0 24 24"><path d="M7 17 17 7M8 7h9v9"/></svg></span>
            </a>
            <a class="service-card" href="<%= contextPath %>/complaint.jsp?category=Electricity">
                <span class="service-icon power" aria-hidden="true"><svg viewBox="0 0 24 24"><path d="m13 2-9 12h7l-1 8 10-13h-7l1-7Z"/></svg></span>
                <span class="service-name">Electricity</span><span class="service-arrow" aria-hidden="true"><svg viewBox="0 0 24 24"><path d="M7 17 17 7M8 7h9v9"/></svg></span>
            </a>
            <a class="service-card" href="<%= contextPath %>/complaint.jsp?category=Sanitation">
                <span class="service-icon clean" aria-hidden="true"><svg viewBox="0 0 24 24"><path d="M4 20h16M6 16l2-8h8l2 8M9 8V5h6v3m-3-6v3"/><path d="M10 12h4"/></svg></span>
                <span class="service-name">Sanitation</span><span class="service-arrow" aria-hidden="true"><svg viewBox="0 0 24 24"><path d="M7 17 17 7M8 7h9v9"/></svg></span>
            </a>
            <a class="service-card" href="<%= contextPath %>/complaint.jsp?category=Other">
                <span class="service-icon other" aria-hidden="true"><svg viewBox="0 0 24 24"><circle cx="5" cy="12" r="1"/><circle cx="12" cy="12" r="1"/><circle cx="19" cy="12" r="1"/><path d="M5 5h14M5 19h14"/></svg></span>
                <span class="service-name">Something else</span><span class="service-arrow" aria-hidden="true"><svg viewBox="0 0 24 24"><path d="M7 17 17 7M8 7h9v9"/></svg></span>
            </a>
        </div>
    </section>

    <section class="how-section" id="how-it-works">
        <div class="section-wrap how-inner">
            <div class="how-intro">
                <p class="eyebrow">Simple from start to finish</p>
                <h2>From concern to action, without the runaround.</h2>
                <p>Stay informed at every step. Your report goes to the right people, and you can check its progress whenever you need.</p>
                <a class="text-link" href="<%= contextPath %>/register.jsp">Get started today <svg aria-hidden="true" viewBox="0 0 24 24"><path d="M5 12h14m-6-6 6 6-6 6"/></svg></a>
            </div>
            <div class="steps">
                <article class="step-card">
                    <span class="step-number" aria-hidden="true"><svg viewBox="0 0 24 24"><path d="M12 20h9"/><path d="M16.5 3.5a2.1 2.1 0 0 1 3 3L8 18l-4 1 1-4Z"/><path d="m14 6 4 4"/></svg></span>
                    <span class="step-icon" aria-hidden="true"><svg viewBox="0 0 24 24"><path d="M12 20h9"/><path d="M16.5 3.5a2.1 2.1 0 0 1 3 3L8 18l-4 1 1-4Z"/><path d="m14 6 4 4"/></svg></span>
                    <h3>Tell us what happened</h3>
                    <p>Share the details and location so your concern reaches the right team.</p>
                </article>
                <article class="step-card">
                    <span class="step-number" aria-hidden="true"><svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="9"/><path d="M12 7v5l3 2"/></svg></span>
                    <span class="step-icon step-icon-teal" aria-hidden="true"><svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="9"/><path d="M12 7v5l3 2"/></svg></span>
                    <h3>Follow every update</h3>
                    <p>See when your complaint is received, assigned, or escalated.</p>
                </article>
                <article class="step-card">
                    <span class="step-number" aria-hidden="true"><svg viewBox="0 0 24 24"><path d="m5 12 4 4L19 6"/><path d="M21 12a9 9 0 1 1-5.5-8.3"/></svg></span>
                    <span class="step-icon step-icon-gold" aria-hidden="true"><svg viewBox="0 0 24 24"><path d="m5 12 4 4L19 6"/><path d="M21 12a9 9 0 1 1-5.5-8.3"/></svg></span>
                    <h3>See the difference</h3>
                    <p>Get a clear outcome when the responsible team takes action.</p>
                </article>
            </div>
        </div>
    </section>
</main>

<footer class="site-footer">
    <div class="footer-inner">
        <a class="brand footer-brand" href="<%= contextPath %>/index.jsp">
            <span class="brand-mark" aria-hidden="true"><svg viewBox="0 0 48 48"><path d="M7 19 24 8l17 11M11 21h26M13 21v16m11-16v16m11-16v16M9 41h30"/><path d="m18 29 4 4 8-9"/></svg></span>
            <span class="brand-copy"><strong>Smart Grievance</strong><small>PUBLIC SERVICE PORTAL</small></span>
        </a>
        <p>Your voice matters. Together, we make communities better.</p>
        <div class="footer-links">
            <a class="button button-login footer-button" href="<%= contextPath %>/login.jsp">
                <svg aria-hidden="true" viewBox="0 0 24 24"><path d="M10 17l5-5-5-5m5 5H3"/><path d="M13 4h5a2 2 0 0 1 2 2v12a2 2 0 0 1-2 2h-5"/></svg>
                Log in
            </a>
            <a class="button button-account button-primary footer-button" href="<%= contextPath %>/register.jsp">
                <svg aria-hidden="true" viewBox="0 0 24 24"><path d="M12 5v14m-7-7h14"/></svg>
                Create account
            </a>
        </div>
    </div>
</footer>

</body>
</html>