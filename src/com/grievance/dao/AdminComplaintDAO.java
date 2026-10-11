package com.grievance.dao;

import com.grievance.model.Complaint;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

public class AdminComplaintDAO {

    public List<Complaint> getAllComplaints() {

        List<Complaint> complaints = new ArrayList<>();

        String sql = "SELECT * FROM complaints ORDER BY created_at DESC";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql);
             ResultSet resultSet = statement.executeQuery()) {

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

    public List<Complaint> getRecentComplaints() {
        List<Complaint> complaints = new ArrayList<>();
        String sql = "SELECT * FROM complaints " +
                     "ORDER BY created_at DESC LIMIT 5";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql);
             ResultSet resultSet = statement.executeQuery()) {

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
        } catch (Exception e) {
            e.printStackTrace();
        }

        return complaints;
    }
}