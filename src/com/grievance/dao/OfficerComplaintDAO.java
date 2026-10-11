package com.grievance.dao;

import com.grievance.model.Complaint;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

public class OfficerComplaintDAO {

    public List<Complaint> getAssignedComplaints(int officerId) {

        List<Complaint> complaints = new ArrayList<>();

        String sql = "SELECT c.* " +
                     "FROM complaints c " +
                     "INNER JOIN complaint_assignments ca " +
                     "ON c.complaint_id = ca.complaint_id " +
                     "WHERE ca.officer_id = ? " +
                     "AND ca.status = 'PENDING' " +
                     "ORDER BY ca.deadline ASC";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {

            statement.setInt(1, officerId);

            ResultSet resultSet = statement.executeQuery();

            while (resultSet.next()) {

                Complaint complaint = new Complaint();

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

                complaints.add(complaint);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return complaints;
    }

    public List<Complaint> getRecentOfficerComplaints(int officerId) {
        List<Complaint> complaints = new ArrayList<>();
        String sql = "SELECT c.* " +
                     "FROM complaints c " +
                     "WHERE c.complaint_id IN (" +
                     "SELECT ca.complaint_id FROM complaint_assignments ca " +
                     "WHERE ca.officer_id = ?) " +
                     "ORDER BY c.created_at DESC LIMIT 5";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {

            statement.setInt(1, officerId);
            try (ResultSet resultSet = statement.executeQuery()) {
                while (resultSet.next()) {
                    Complaint complaint = new Complaint();
                    complaint.setComplaintId(resultSet.getInt("complaint_id"));
                    complaint.setCitizenId(resultSet.getInt("citizen_id"));
                    complaint.setDepartmentId(resultSet.getInt("department_id"));
                    complaint.setTitle(resultSet.getString("title"));
                    complaint.setCategory(resultSet.getString("category"));
                    complaint.setPriority(resultSet.getString("priority"));
                    complaint.setLocation(resultSet.getString("location"));
                    complaint.setImage(resultSet.getString("image"));
                    complaint.setStatus(resultSet.getString("status"));
                    Timestamp createdAt = resultSet.getTimestamp("created_at");
                    complaint.setCreatedAt(createdAt);
                    complaints.add(complaint);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return complaints;
    }
}