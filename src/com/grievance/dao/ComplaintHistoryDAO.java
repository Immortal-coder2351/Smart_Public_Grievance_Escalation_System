package com.grievance.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class ComplaintHistoryDAO {

    public List<String[]> getComplaintHistory(int complaintId) {

        List<String[]> history = new ArrayList<>();

        String sql = "SELECT ca.assignment_id, " +
                     "u.name AS officer_name, " +
                     "u.officer_level, " +
                     "ca.escalation_level, " +
                     "ca.assigned_at, " +
                     "ca.deadline, " +
                     "ca.status, " +
                     "ca.escalated_at, " +
                     "ca.remarks " +
                     "FROM complaint_assignments ca " +
                     "INNER JOIN users u ON ca.officer_id = u.user_id " +
                     "WHERE ca.complaint_id = ? " +
                     "AND UPPER(TRIM(COALESCE(ca.status, ''))) = 'ESCALATED' " +
                     "AND ca.escalated_at IS NOT NULL " +
                     "ORDER BY ca.escalated_at DESC";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement =
                     connection.prepareStatement(sql)) {

            statement.setInt(1, complaintId);

            ResultSet resultSet = statement.executeQuery();

            while (resultSet.next()) {

                String[] record = new String[9];

                record[0] = String.valueOf(
                        resultSet.getInt("assignment_id"));

                record[1] = resultSet.getString("officer_name");

                record[2] = String.valueOf(
                        resultSet.getInt("officer_level"));

                record[3] = String.valueOf(
                        resultSet.getInt("escalation_level"));

                record[4] = String.valueOf(
                        resultSet.getTimestamp("assigned_at"));

                record[5] = String.valueOf(
                        resultSet.getTimestamp("deadline"));

                record[6] = resultSet.getString("status");

                record[7] = String.valueOf(
                        resultSet.getTimestamp("escalated_at"));

                record[8] = resultSet.getString("remarks");

                history.add(record);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return history;
    }

    public boolean citizenOwnsComplaint(
            int complaintId,
            int citizenId) {

        String sql =
                "SELECT complaint_id " +
                "FROM complaints " +
                "WHERE complaint_id = ? " +
                "AND citizen_id = ?";

        try (Connection connection =
                     DBConnection.getConnection();
             PreparedStatement statement =
                     connection.prepareStatement(sql)) {

            statement.setInt(1, complaintId);
            statement.setInt(2, citizenId);

            ResultSet resultSet =
                    statement.executeQuery();

            return resultSet.next();

        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean officerHasComplaint(
            int complaintId,
            int officerId) {

        String sql =
                "SELECT assignment_id " +
                "FROM complaint_assignments " +
                "WHERE complaint_id = ? " +
                "AND officer_id = ?";

        try (Connection connection =
                     DBConnection.getConnection();
             PreparedStatement statement =
                     connection.prepareStatement(sql)) {

            statement.setInt(1, complaintId);
            statement.setInt(2, officerId);

            ResultSet resultSet =
                    statement.executeQuery();

            return resultSet.next();

        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
}