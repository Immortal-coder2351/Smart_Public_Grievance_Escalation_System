package com.grievance.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.LocalDateTime;

public class AssignmentDAO {

    public boolean assignComplaint(int complaintId, int officerId, int level) {

        String sql = "INSERT INTO complaint_assignments " +
                     "(complaint_id, officer_id, escalation_level, assigned_at, deadline, status) " +
                     "VALUES (?, ?, ?, ?, ?, 'PENDING')";

        LocalDateTime assignedAt = LocalDateTime.now();
        LocalDateTime deadline = assignedAt.plusDays(7);

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {

            statement.setInt(1, complaintId);
            statement.setInt(2, officerId);
            statement.setInt(3, level);
            statement.setTimestamp(4, Timestamp.valueOf(assignedAt));
            statement.setTimestamp(5, Timestamp.valueOf(deadline));

            return statement.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean updateComplaintStatus(int complaintId, String status) {

        String sql = "UPDATE complaints SET status = ? WHERE complaint_id = ?";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {

            statement.setString(1, status);
            statement.setInt(2, complaintId);

            return statement.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean markAssignmentEscalated(int assignmentId) {

        String sql = "UPDATE complaint_assignments " +
                     "SET status = 'ESCALATED', escalated_at = NOW() " +
                     "WHERE assignment_id = ?";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {

            statement.setInt(1, assignmentId);

            return statement.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public int getNextOfficerLevel(int complaintId) {

        String sql = "SELECT MAX(escalation_level) " +
                     "FROM complaint_assignments " +
                     "WHERE complaint_id = ?";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {

            statement.setInt(1, complaintId);

            ResultSet resultSet = statement.executeQuery();

            if (resultSet.next()) {
                return resultSet.getInt(1) + 1;
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return 1;
    }
}