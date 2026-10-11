package com.grievance.dao;

import java.sql.Connection;

public class TestConnection {

    public static void main(String[] args) {

        try {

            Connection connection = DBConnection.getConnection();

            if (connection != null) {
                System.out.println("DATABASE CONNECTION SUCCESSFUL!");
                connection.close();
            }

        } catch (Exception e) {

            System.out.println("DATABASE CONNECTION FAILED!");
            e.printStackTrace();
        }
    }
}