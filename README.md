# Smart Public Grievance Escalation System

A Java Servlet/JSP and MySQL web application for reporting public-service issues, tracking complaints, assigning them to officers, and escalating overdue cases.

## Features

- Citizen registration and login
- Complaint submission with category, priority, location, description, and an image
- Citizen complaint list, dashboard summaries, and escalation history
- Officer dashboard and assigned-complaint status updates
- Admin complaint overview and officer assignment
- Scheduled escalation processing across officer levels
- Password change for citizen, officer, and admin accounts
- Responsive public homepage and role-specific dashboards

## Technology

- Java 17 or later
- Apache Tomcat 11
- Jakarta Servlet 6.1 / JSP
- MySQL or MariaDB
- MySQL Connector/J

## Requirements

1. Install a JDK (Java 17+), Apache Tomcat 11, and MySQL or MariaDB.
2. Download the MySQL Connector/J JAR from the [official MySQL download page](https://dev.mysql.com/downloads/connector/j/) and place it in `WEB-INF/lib/`.
3. Create and initialize the database using [`database/grievance.sql`](database/grievance.sql). Run it against a new database; it creates the application tables and initial department rows.
4. If upgrading a database created before complaint priority was added, apply [`database/add_priority.sql`](database/add_priority.sql) instead of re-running the full schema script.
5. Update the local database URL, username, and password in `src/com/grievance/dao/DBConnection.java` before starting the app. Do not commit production credentials.

## Deploy on Tomcat

1. Clone this repository into Tomcat's `webapps` directory. Tomcat will use the folder name as the application context path.
2. Create the compiled-classes directory if it does not exist:

   ```powershell
   New-Item -ItemType Directory -Force WEB-INF\classes
   ```

3. Compile the Java source files from the project root:

   ```powershell
   $tomcat = "C:\Program Files\Apache Software Foundation\Tomcat 11.0"
   $sources = Get-ChildItem src -Recurse -Filter *.java | ForEach-Object { $_.FullName }
   javac -cp "$tomcat\lib\servlet-api.jar" -d WEB-INF\classes $sources
   ```

4. Ensure the MySQL Connector/J JAR is present in `WEB-INF/lib/`.
5. Start or restart Tomcat and open `http://localhost:8080/<folder-name>/`.
6. Register a citizen account. Provision the initial administrator account in the database; an administrator can add officers through the admin dashboard.

## Project layout

```text
.
├── css/                  # Shared and homepage styles
├── database/             # Initial schema and migration scripts
├── js/                   # Client-side form behavior
├── src/                  # Servlets, DAOs, models, and escalation scheduler
├── uploads/              # Runtime user uploads (not committed)
├── WEB-INF/
│   ├── classes/           # Compiled Java output (not committed)
│   ├── lib/               # Place MySQL Connector/J here (not committed)
│   └── web.xml
└── *.jsp                  # Public pages and dashboards
```

## Notes

- Complaint image uploads are stored locally under `uploads/` and are intentionally excluded from Git because they may contain personal information.
- The database connection file currently uses local-development settings. Configure it for your environment before deployment, and never publish production credentials.
- The existing application stores passwords using its current plain-text database format. Do not use real or sensitive passwords with this version; migrate password storage to a secure password-hashing scheme before production use.
- The escalation scheduler runs inside the web application and needs a live database connection.

## License

Distributed under the MIT License. See [`LICENSE`](LICENSE).
