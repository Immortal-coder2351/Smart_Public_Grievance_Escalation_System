package com.grievance.dao;

import com.grievance.model.Complaint;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

public class ComplaintDAO {

    public boolean registerComplaint(Complaint complaint) {

        String complaintSql =
                "INSERT INTO complaints " +
                "(citizen_id, department_id, title, category, priority, " +
                "description, location, image, status) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";

        String officerSql =
                "SELECT user_id " +
                "FROM users " +
                "WHERE role = 'OFFICER' " +
                "AND officer_level = 1 " +
                "AND department_id = ? " +
                "ORDER BY user_id " +
                "LIMIT 1";

        String assignmentSql =
                "INSERT INTO complaint_assignments " +
                "(complaint_id, officer_id, escalation_level, " +
                "assigned_at, deadline, status, remarks) " +
                "VALUES (?, ?, 1, NOW(), " +
                "DATE_ADD(NOW(), INTERVAL 7 DAY), " +
                "'PENDING', 'INITIAL ASSIGNMENT')";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement complaintStatement =
                     connection.prepareStatement(
                             complaintSql,
                             Statement.RETURN_GENERATED_KEYS);
             PreparedStatement officerStatement =
                     connection.prepareStatement(officerSql);
             PreparedStatement assignmentStatement =
                     connection.prepareStatement(assignmentSql)) {

            connection.setAutoCommit(false);

            // Insert complaint
            complaintStatement.setInt(
                    1, complaint.getCitizenId());

            complaintStatement.setInt(
                    2, complaint.getDepartmentId());

            complaintStatement.setString(
                    3, complaint.getTitle());

            complaintStatement.setString(
                    4, complaint.getCategory());

            complaintStatement.setString(
                    5, complaint.getPriority());

            complaintStatement.setString(
                    6, complaint.getDescription());

            complaintStatement.setString(
                    7, complaint.getLocation());

            complaintStatement.setString(
                    8, complaint.getImage());

            complaintStatement.setString(
                    9, "PENDING");

            int complaintRows =
                    complaintStatement.executeUpdate();

            if (complaintRows == 0) {
                connection.rollback();
                return false;
            }

            // Get newly created complaint ID
            int complaintId;

            try (ResultSet generatedKeys =
                         complaintStatement.getGeneratedKeys()) {

                if (!generatedKeys.next()) {
                    connection.rollback();
                    return false;
                }

                complaintId =
                        generatedKeys.getInt(1);

                complaint.setComplaintId(complaintId);
            }

            // Find Level 1 officer for this department
            officerStatement.setInt(
                    1, complaint.getDepartmentId());

            int officerId = 0;

            try (ResultSet resultSet =
                         officerStatement.executeQuery()) {

                if (resultSet.next()) {
                    officerId =
                            resultSet.getInt("user_id");
                }
            }

            // A complaint must have a Level 1 officer for its department.
            if (officerId <= 0) {
                connection.rollback();
                return false;
            }

            assignmentStatement.setInt(
                    1, complaintId);

            assignmentStatement.setInt(
                    2, officerId);

            int assignmentRows =
                    assignmentStatement.executeUpdate();

            if (assignmentRows == 0) {
                connection.rollback();
                return false;
            }

            connection.commit();
            return true;

        } catch (SQLException e) {

            e.printStackTrace();
            return false;
        }
    }


    public Complaint getComplaintById(int complaintId) {

        String sql =
                "SELECT * FROM complaints " +
                "WHERE complaint_id = ?";

        try (Connection connection =
                     DBConnection.getConnection();
             PreparedStatement statement =
                     connection.prepareStatement(sql)) {

            statement.setInt(1, complaintId);

            ResultSet resultSet =
                    statement.executeQuery();

            if (resultSet.next()) {

                Complaint complaint =
                        new Complaint();

                complaint.setComplaintId(
                        resultSet.getInt("complaint_id"));

                complaint.setCitizenId(
                        resultSet.getInt("citizen_id"));

                complaint.setDepartmentId(
                        resultSet.getInt("department_id"));

                complaint.setTitle(
                        resultSet.getString("title"));

                complaint.setCategory(
                        resultSet.getString("category"));

                complaint.setPriority(
                        resultSet.getString("priority"));

                complaint.setDescription(
                        resultSet.getString("description"));

                complaint.setLocation(
                        resultSet.getString("location"));

                complaint.setImage(
                        resultSet.getString("image"));

                complaint.setStatus(
                        resultSet.getString("status"));

                return complaint;
            }

        } catch (SQLException e) {

            e.printStackTrace();
        }

        return null;
    }


    public List<Complaint> getComplaintsByCitizen(
            int citizenId) {

        List<Complaint> complaints =
                new ArrayList<>();

        String sql =
                "SELECT * FROM complaints " +
                "WHERE citizen_id = ? " +
                "ORDER BY created_at DESC";

        try (Connection connection =
                     DBConnection.getConnection();
             PreparedStatement statement =
                     connection.prepareStatement(sql)) {

            statement.setInt(1, citizenId);

            ResultSet resultSet =
                    statement.executeQuery();

            while (resultSet.next()) {

                Complaint complaint =
                        new Complaint();

                complaint.setComplaintId(
                        resultSet.getInt("complaint_id"));

                complaint.setCitizenId(
                        resultSet.getInt("citizen_id"));

                complaint.setDepartmentId(
                        resultSet.getInt("department_id"));

                complaint.setTitle(
                        resultSet.getString("title"));

                complaint.setCategory(
                        resultSet.getString("category"));

                complaint.setPriority(
                        resultSet.getString("priority"));

                complaint.setDescription(
                        resultSet.getString("description"));

                complaint.setLocation(
                        resultSet.getString("location"));

                complaint.setImage(
                        resultSet.getString("image"));

                complaint.setStatus(
                        resultSet.getString("status"));

                complaint.setCreatedAt(
                        resultSet.getTimestamp("created_at"));

                complaints.add(complaint);
            }

        } catch (SQLException e) {

            e.printStackTrace();
        }

        return complaints;
    }
}