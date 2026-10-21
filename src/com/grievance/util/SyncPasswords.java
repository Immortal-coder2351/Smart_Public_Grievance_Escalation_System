
package com.grievance.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class SyncPasswords {

    private static class Account {
        int id;
        String username;
        String password;

        Account(int id, String username, String password) {
            this.id = id;
            this.username = username;
            this.password = password;
        }
    }

    private static String setting(String name, String fallback) {
        String value = System.getenv(name);
        return value == null || value.trim().isEmpty()
                ? fallback : value.trim();
    }

    private static Connection connect(String prefix) throws SQLException {
        String host = setting(prefix + "DB_HOST", "");
        String port = setting(prefix + "DB_PORT", "3306");
        String database = setting(prefix + "DB_NAME", "smart_grievance");
        String user = setting(prefix + "DB_USER", "");
        String password = setting(prefix + "DB_PASSWORD", "");

        String url = "jdbc:mysql://" + host + ":" + port + "/" + database;

        if (host.isEmpty() || user.isEmpty()) {
            throw new SQLException("Missing database connection settings.");
        }

        return DriverManager.getConnection(url, user, password);
    }

    public static void main(String[] args) {
        List<Account> accounts = new ArrayList<>();

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");

            try (Connection local = connect("LOCAL_")) {
                String sql = "SELECT user_id, username, password FROM users ORDER BY user_id";

                try (PreparedStatement ps = local.prepareStatement(sql);
                     ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        int id = rs.getInt("user_id");
                        String username = rs.getString("username");
                        String password = rs.getString("password");

                        if (password == null || password.isEmpty()) {
                            throw new SQLException("Empty password found for account ID " + id);
                        }

                        String safePassword = password.startsWith("PBKDF2$")
                                ? password
                                : PasswordUtil.hashPassword(password);

                        accounts.add(new Account(id, username, safePassword));
                    }
                }
            }

            if (accounts.size() != 23) {
                throw new SQLException("Expected 23 local accounts; found " + accounts.size());
            }

            String host = setting("AIVEN_DB_HOST", "");
            String port = setting("AIVEN_DB_PORT", "18439");
            String database = setting("AIVEN_DB_NAME", "smart_grievance");
            String user = setting("AIVEN_DB_USER", "");
            String password = setting("AIVEN_DB_PASSWORD", "");

            if (host.isEmpty() || user.isEmpty() || password.isEmpty()) {
                throw new SQLException("Missing Aiven connection settings.");
            }

            String url = "jdbc:mysql://" + host + ":" + port + "/" + database
                    + "?sslMode=REQUIRED";

            try (Connection aiven = DriverManager.getConnection(url, user, password)) {
                if (args.length == 0 || !"--apply".equals(args[0])) {
                    String checkSql = "SELECT username FROM users WHERE user_id = ?";

                    try (PreparedStatement check = aiven.prepareStatement(checkSql)) {
                        for (Account account : accounts) {
                            check.setInt(1, account.id);

                            try (ResultSet rs = check.executeQuery()) {
                                if (!rs.next()
                                        || !account.username.equals(rs.getString("username"))) {
                                    throw new SQLException(
                                            "Account ID/username mismatch at ID " + account.id);
                                }
                            }
                        }
                    }

                    System.out.println("DRY RUN PASSED: All 23 account IDs and usernames match.");
                    System.out.println("No database records were changed.");
                    return;
                }

                aiven.setAutoCommit(false);

                try {
                    String checkSql =
                            "SELECT username FROM users WHERE user_id = ?";

                    String updateSql =
                            "UPDATE users SET password = ? WHERE user_id = ? AND username = ?";

                    try (PreparedStatement check = aiven.prepareStatement(checkSql);
                         PreparedStatement update = aiven.prepareStatement(updateSql)) {

                        for (Account account : accounts) {
                            check.setInt(1, account.id);

                            try (ResultSet rs = check.executeQuery()) {
                                if (!rs.next()
                                        || !account.username.equals(rs.getString("username"))) {
                                    throw new SQLException(
                                            "Account ID/username mismatch at ID " + account.id);
                                }
                            }

                            update.setString(1, account.password);
                            update.setInt(2, account.id);
                            update.setString(3, account.username);

                            if (update.executeUpdate() != 1) {
                                throw new SQLException(
                                        "Expected one updated row for account ID " + account.id);
                            }
                        }
                    }

                    aiven.commit();
                    System.out.println("SUCCESS: Updated passwords for 23 matching accounts.");
                    System.out.println("The two additional Aiven accounts were not changed.");

                } catch (Exception e) {
                    aiven.rollback();
                    throw e;
                } finally {
                    aiven.setAutoCommit(true);
                }
            }

        } catch (Exception e) {
            System.err.println("Synchronization failed: " + e.getMessage());
            System.err.println("No partial Aiven updates were committed.");
            System.exit(1);
        }
    }
}
