package com.grievance.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;

public class ComplaintUpdateDAO {

    public boolean updateComplaintStatus(
            int complaintId,
            int officerId,
            String status,
            String remarks) {

        String sql =
                "UPDATE complaints c " +
                "INNER JOIN complaint_assignments ca " +
                "ON c.complaint_id = ca.complaint_id " +
                "SET c.status = ?, " +
                "ca.remarks = ?, " +
                "ca.status = ? " +
                "WHERE c.complaint_id = ? " +
                "AND ca.officer_id = ? " +
                "AND ca.status = 'PENDING'";

        String assignmentStatus = "RESOLVED".equals(status)
                ? "RESOLVED"
                : "PENDING";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement =
                     connection.prepareStatement(sql)) {

            statement.setString(1, status);
            statement.setString(2, remarks);
            statement.setString(3, assignmentStatus);
            statement.setInt(4, complaintId);
            statement.setInt(5, officerId);

            return statement.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
}