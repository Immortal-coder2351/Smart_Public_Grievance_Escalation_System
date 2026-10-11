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
5. Set the database connection environment variables for your environment: `DB_HOST`, `DB_PORT`, `DB_NAME`, `DB_USER`, and `DB_PASSWORD`. The defaults support the existing local development setup. Do not commit production credentials.

## Deploy with Docker

The included `Dockerfile` builds the application from this repository root, compiles the Java sources, downloads MySQL Connector/J during the image build, and runs it on port `10000`. The image does not include uploaded complaint photos, compiled classes from your workstation, or local JAR files.

1. Initialize a MySQL or MariaDB database using `database/grievance.sql`, and ensure the database is reachable from the container.
2. Build the image from the repository root:

   ```sh
   docker build -t smart-grievance .
   ```

3. Run it with the database connection settings for your environment:

   ```sh
   docker run --rm -p 10000:10000 \
     -e DB_HOST=host.docker.internal \
     -e DB_PORT=3306 \
     -e DB_NAME=smart_grievance \
     -e DB_USER=your_database_user \
     -e DB_PASSWORD=your_database_password \
     -v grievance-uploads:/var/data/uploads \
     smart-grievance
   ```

   Replace the example database host and credentials with values for your database. Keep secrets in your deployment provider's environment settings, not in source control. On Linux, `host.docker.internal` may need to be configured explicitly when the database runs on the Docker host.

4. Open `http://localhost:10000/`. Configure a persistent volume at `/var/data/uploads` on your hosting provider so uploaded complaint images survive container replacement.

The entrypoint uses the hosting provider's `PORT` value when supplied (default `10000`). The image expects the application to connect to an external MySQL-compatible database; it does not bundle or start a database server.

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
├── Dockerfile            # Container image build
├── js/                   # Client-side form behavior
├── render-entrypoint.sh  # Container startup and port configuration
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
