package com.grievance.dao;

import com.grievance.model.User;
import com.grievance.util.PasswordValidator;
import com.grievance.util.PasswordUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class UserDAO {

    public boolean registerUser(User user) {
        if (user == null
                || user.getName() == null
                || user.getEmail() == null
                || user.getUsername() == null
                || !PasswordValidator.isStrong(user.getPassword())) {
            return false;
        }

        String sql = "INSERT INTO users "
                + "(name, email, phone, username, password, role, officer_level, department_id) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {

            statement.setString(1, user.getName());
            statement.setString(2, user.getEmail());
            statement.setString(3, user.getPhone());
            statement.setString(4, user.getUsername());
            statement.setString(5, PasswordUtil.hashPassword(user.getPassword()));
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

            return statement.executeUpdate() == 1;

        } catch (SQLException e) {
            throw new RuntimeException("Unable to register user.", e);
        }
    }

    public User loginUser(String username, String password) {
        if (username == null || username.trim().isEmpty()
                || password == null || password.isEmpty()) {
            return null;
        }

        String sql = "SELECT * FROM users WHERE username = ?";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {

            statement.setString(1, username.trim());

            User user;
            String storedPassword;

            try (ResultSet resultSet = statement.executeQuery()) {
                if (!resultSet.next()) {
                    return null;
                }

                storedPassword = resultSet.getString("password");

                if (!PasswordUtil.verifyPassword(password, storedPassword)) {
                    return null;
                }

                user = new User();
                user.setUserId(resultSet.getInt("user_id"));
                user.setName(resultSet.getString("name"));
                user.setEmail(resultSet.getString("email"));
                user.setPhone(resultSet.getString("phone"));
                user.setUsername(resultSet.getString("username"));
                user.setRole(resultSet.getString("role"));

                int officerLevel = resultSet.getInt("officer_level");
                user.setOfficerLevel(resultSet.wasNull() ? null : officerLevel);

                int departmentId = resultSet.getInt("department_id");
                user.setDepartmentId(resultSet.wasNull() ? null : departmentId);
            }

            if (storedPassword != null && !storedPassword.startsWith("PBKDF2$")) {
                String upgradedPassword = PasswordUtil.hashPassword(password);

                try (PreparedStatement update = connection.prepareStatement(
                        "UPDATE users SET password = ? WHERE user_id = ?")) {
                    update.setString(1, upgradedPassword);
                    update.setInt(2, user.getUserId());
                    update.executeUpdate();
                }
            }

            user.setPassword(null);
            return user;

        } catch (SQLException e) {
            throw new RuntimeException("Unable to authenticate user.", e);
        }
    }

    public boolean changePassword(int userId, String currentPassword, String newPassword) {
        if (currentPassword == null
                || newPassword == null
                || !PasswordValidator.isStrong(newPassword)
                || currentPassword.equals(newPassword)) {
            return false;
        }

        String selectSql = "SELECT password FROM users WHERE user_id = ?";
        String updateSql = "UPDATE users SET password = ? WHERE user_id = ?";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement select = connection.prepareStatement(selectSql)) {

            select.setInt(1, userId);

            try (ResultSet resultSet = select.executeQuery()) {
                if (!resultSet.next()) {
                    return false;
                }

                String storedPassword = resultSet.getString("password");

                if (!PasswordUtil.verifyPassword(currentPassword, storedPassword)) {
                    return false;
                }
            }

            try (PreparedStatement update = connection.prepareStatement(updateSql)) {
                update.setString(1, PasswordUtil.hashPassword(newPassword));
                update.setInt(2, userId);

                return update.executeUpdate() == 1;
            }

        } catch (SQLException e) {
            throw new RuntimeException("Unable to update password.", e);
        }
    }

    public boolean usernameExists(String username) {
        if (username == null || username.trim().isEmpty()) {
            return false;
        }

        String sql = "SELECT user_id FROM users WHERE username = ?";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {

            statement.setString(1, username.trim());

            try (ResultSet resultSet = statement.executeQuery()) {
                return resultSet.next();
            }

        } catch (SQLException e) {
            throw new RuntimeException("Unable to check username availability.", e);
        }
    }

    public boolean emailExists(String email) {
        if (email == null || email.trim().isEmpty()) {
            return false;
        }

        String sql = "SELECT user_id FROM users WHERE email = ?";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {

            statement.setString(1, email.trim());

            try (ResultSet resultSet = statement.executeQuery()) {
                return resultSet.next();
            }

        } catch (SQLException e) {
            throw new RuntimeException("Unable to check email availability.", e);
        }
    }
}