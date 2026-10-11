package com.grievance.dao;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBConnection {

    public static Connection getConnection() throws SQLException {

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new SQLException(
                    "MySQL JDBC Driver not found.",
                    e
            );
        }

        String host = getSetting("DB_HOST", "localhost");
        String port = getSetting("DB_PORT", "3306");
        String database = getSetting("DB_NAME", "smart_grievance");
        String user = getSetting("DB_USER", "root");
        String password = getSetting("DB_PASSWORD", "");
        String url = "jdbc:mysql://" + host + ":" + port + "/" + database;

        return DriverManager.getConnection(
                url,
                user,
                password
        );
    }

    private static String getSetting(String name, String defaultValue) {
        String value = System.getenv(name);
        return value == null || value.trim().isEmpty()
                ? defaultValue
                : value.trim();
    }
}