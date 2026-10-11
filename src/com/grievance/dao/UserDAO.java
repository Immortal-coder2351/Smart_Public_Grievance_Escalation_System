package com.grievance.dao;

import com.grievance.model.User;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class UserDAO {

    // Register a new user
    public boolean registerUser(User user) {

        String sql = "INSERT INTO users " +
                "(name, email, phone, username, password, role, officer_level, department_id) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {

            statement.setString(1, user.getName());
            statement.setString(2, user.getEmail());
            statement.setString(3, user.getPhone());
            statement.setString(4, user.getUsername());
            statement.setString(5, user.getPassword());
            statement.setString(6, user.getRole());

            if (user.getOfficerLevel() == null) {
                statement.setNull(7, java.sql.Types.INTEGER);
            } else {
                statement.setInt(7, user.getOfficerLevel());
            }

            if (user.getDepartmentId() == null) {
                statement.setNull(8, java.sql.Types.INTEGER);
            } else {
                statement.setInt(8, user.getDepartmentId());
            }

            return statement.executeUpdate() > 0;

        }  catch (SQLException e) {
    System.out.println("REGISTRATION SQL ERROR:");
    e.printStackTrace();
      throw new RuntimeException(e);
  
}
    }


    // Login user
    public User loginUser(String username, String password) {

        String sql = "SELECT * FROM users " +
                     "WHERE username = ? AND password = ?";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {

            statement.setString(1, username);
            statement.setString(2, password);

            ResultSet resultSet = statement.executeQuery();

            if (resultSet.next()) {

                User user = new User();

                user.setUserId(resultSet.getInt("user_id"));
                user.setName(resultSet.getString("name"));
                user.setEmail(resultSet.getString("email"));
                user.setPhone(resultSet.getString("phone"));
                user.setUsername(resultSet.getString("username"));
                user.setPassword(resultSet.getString("password"));
                user.setRole(resultSet.getString("role"));

                int officerLevel =
                        resultSet.getInt("officer_level");

                if (resultSet.wasNull()) {
                    user.setOfficerLevel(null);
                } else {
                    user.setOfficerLevel(officerLevel);
                }

                int departmentId =
                        resultSet.getInt("department_id");

                if (resultSet.wasNull()) {
                    user.setDepartmentId(null);
                } else {
                    user.setDepartmentId(departmentId);
                }

                return user;
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return null;
    }

    public boolean changePassword(
            int userId,
            String currentPassword,
            String newPassword) {

        String sql = "UPDATE users SET password = ? " +
                     "WHERE user_id = ? AND password = ?";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {

            statement.setString(1, newPassword);
            statement.setInt(2, userId);
            statement.setString(3, currentPassword);

            return statement.executeUpdate() == 1;

        } catch (SQLException e) {
            e.printStackTrace();
            throw new RuntimeException("Unable to update password.", e);
        }
    }

    // Check whether username already exists
    public boolean usernameExists(String username) {

        String sql = "SELECT user_id FROM users WHERE username = ?";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {

            statement.setString(1, username);

            ResultSet resultSet = statement.executeQuery();

            return resultSet.next();

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }


    // Check whether email already exists
    public boolean emailExists(String email) {

        String sql = "SELECT user_id FROM users WHERE email = ?";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {

            statement.setString(1, email);

            ResultSet resultSet = statement.executeQuery();

            return resultSet.next();

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
}