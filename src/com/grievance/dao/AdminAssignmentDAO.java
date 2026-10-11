package com.grievance.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.sql.Timestamp;
import java.time.LocalDateTime;

public class AdminAssignmentDAO {

    public boolean assignComplaintToOfficer(
            int complaintId,
            int officerId) {

        String clearEscalationsSql =
                "UPDATE complaint_assignments " +
                "SET status = 'REASSIGNED' " +
                "WHERE complaint_id = ? " +
                "AND UPPER(TRIM(COALESCE(status, ''))) = 'ESCALATED'";

        String assignmentSql =
                "INSERT INTO complaint_assignments " +
                "(complaint_id, officer_id, escalation_level, " +
                "assigned_at, deadline, status, remarks) " +
                "VALUES (?, ?, 3, ?, ?, 'PENDING', 'ADMIN INTERVENTION')";

        String complaintStatusSql =
                "UPDATE complaints SET status = 'PENDING' " +
                "WHERE complaint_id = ?";

        LocalDateTime assignedAt = LocalDateTime.now();
        LocalDateTime deadline = assignedAt.plusDays(7);

        try (Connection connection = DBConnection.getConnection()) {
            connection.setAutoCommit(false);

            try (PreparedStatement clearStatement =
                         connection.prepareStatement(clearEscalationsSql);
                 PreparedStatement assignmentStatement =
                         connection.prepareStatement(assignmentSql);
                 PreparedStatement complaintStatusStatement =
                         connection.prepareStatement(complaintStatusSql)) {

                clearStatement.setInt(1, complaintId);
                clearStatement.executeUpdate();

                assignmentStatement.setInt(1, complaintId);
                assignmentStatement.setInt(2, officerId);
                assignmentStatement.setTimestamp(
                        3, Timestamp.valueOf(assignedAt));
                assignmentStatement.setTimestamp(
                        4, Timestamp.valueOf(deadline));

                if (assignmentStatement.executeUpdate() == 0) {
                    connection.rollback();
                    return false;
                }

                complaintStatusStatement.setInt(1, complaintId);
                if (complaintStatusStatement.executeUpdate() == 0) {
                    connection.rollback();
                    return false;
                }
            }

            connection.commit();
            return true;

        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean updateComplaintStatus(
            int complaintId,
            String status) {

        String sql =
                "UPDATE complaints " +
                "SET status = ? " +
                "WHERE complaint_id = ?";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement =
                     connection.prepareStatement(sql)) {

            statement.setString(1, status);
            statement.setInt(2, complaintId);

            return statement.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
}