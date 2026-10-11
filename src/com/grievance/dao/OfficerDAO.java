package com.grievance.dao;

import com.grievance.model.User;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class OfficerDAO {

    // Add a new officer
    public boolean addOfficer(User officer) {

        String sql = "INSERT INTO users " +
                     "(name, email, phone, username, password, role, officer_level, department_id) " +
                     "VALUES (?, ?, ?, ?, ?, 'OFFICER', ?, ?)";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement =
                     connection.prepareStatement(sql)) {

            statement.setString(1, officer.getName());
            statement.setString(2, officer.getEmail());
            statement.setString(3, officer.getPhone());
            statement.setString(4, officer.getUsername());
            statement.setString(5, officer.getPassword());

            if (officer.getOfficerLevel() != null) {
                statement.setInt(6, officer.getOfficerLevel());
            } else {
                statement.setNull(6, java.sql.Types.INTEGER);
            }

            if (officer.getDepartmentId() != null) {
                statement.setInt(7, officer.getDepartmentId());
            } else {
                statement.setNull(7, java.sql.Types.INTEGER);
            }

            return statement.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }


    // Get all officers
    public List<User> getAllOfficers() {

        List<User> officers = new ArrayList<>();

        String sql = "SELECT * FROM users " +
                     "WHERE role = 'OFFICER' " +
                     "ORDER BY officer_level, name";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement =
                     connection.prepareStatement(sql)) {

            ResultSet resultSet = statement.executeQuery();

            while (resultSet.next()) {

                User officer = new User();

                officer.setUserId(resultSet.getInt("user_id"));
                officer.setName(resultSet.getString("name"));
                officer.setEmail(resultSet.getString("email"));
                officer.setPhone(resultSet.getString("phone"));
                officer.setUsername(resultSet.getString("username"));
                officer.setPassword(resultSet.getString("password"));
                officer.setRole(resultSet.getString("role"));

                int officerLevel =
                        resultSet.getInt("officer_level");

                if (resultSet.wasNull()) {
                    officer.setOfficerLevel(null);
                } else {
                    officer.setOfficerLevel(officerLevel);
                }

                int departmentId =
                        resultSet.getInt("department_id");

                if (resultSet.wasNull()) {
                    officer.setDepartmentId(null);
                } else {
                    officer.setDepartmentId(departmentId);
                }

                officers.add(officer);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return officers;
    }


    // Get officers belonging to a particular department and level
    public List<User> getOfficersByDepartmentAndLevel(
            int departmentId, int officerLevel) {

        List<User> officers = new ArrayList<>();

        String sql = "SELECT * FROM users " +
                     "WHERE role = 'OFFICER' " +
                     "AND department_id = ? " +
                     "AND officer_level = ? " +
                     "ORDER BY name";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement =
                     connection.prepareStatement(sql)) {

            statement.setInt(1, departmentId);
            statement.setInt(2, officerLevel);

            ResultSet resultSet = statement.executeQuery();

            while (resultSet.next()) {

                User officer = new User();

                officer.setUserId(resultSet.getInt("user_id"));
                officer.setName(resultSet.getString("name"));
                officer.setEmail(resultSet.getString("email"));
                officer.setPhone(resultSet.getString("phone"));
                officer.setUsername(resultSet.getString("username"));
                officer.setPassword(resultSet.getString("password"));
                officer.setRole(resultSet.getString("role"));

                int level =
                        resultSet.getInt("officer_level");

                if (resultSet.wasNull()) {
                    officer.setOfficerLevel(null);
                } else {
                    officer.setOfficerLevel(level);
                }

                int dept =
                        resultSet.getInt("department_id");

                if (resultSet.wasNull()) {
                    officer.setDepartmentId(null);
                } else {
                    officer.setDepartmentId(dept);
                }

                officers.add(officer);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return officers;
    }


    // Find officer by user ID
    public User getOfficerById(int userId) {

        String sql = "SELECT * FROM users " +
                     "WHERE user_id = ? AND role = 'OFFICER'";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement =
                     connection.prepareStatement(sql)) {

            statement.setInt(1, userId);

            ResultSet resultSet = statement.executeQuery();

            if (resultSet.next()) {

                User officer = new User();

                officer.setUserId(resultSet.getInt("user_id"));
                officer.setName(resultSet.getString("name"));
                officer.setEmail(resultSet.getString("email"));
                officer.setPhone(resultSet.getString("phone"));
                officer.setUsername(resultSet.getString("username"));
                officer.setPassword(resultSet.getString("password"));
                officer.setRole(resultSet.getString("role"));

                int level =
                        resultSet.getInt("officer_level");

                if (resultSet.wasNull()) {
                    officer.setOfficerLevel(null);
                } else {
                    officer.setOfficerLevel(level);
                }

                int departmentId =
                        resultSet.getInt("department_id");

                if (resultSet.wasNull()) {
                    officer.setDepartmentId(null);
                } else {
                    officer.setDepartmentId(departmentId);
                }

                return officer;
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return null;
    }
}

