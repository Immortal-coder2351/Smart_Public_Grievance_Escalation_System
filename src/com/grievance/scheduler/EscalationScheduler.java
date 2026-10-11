package com.grievance.scheduler;

import com.grievance.dao.AssignmentDAO;
import com.grievance.dao.DBConnection;
import com.grievance.dao.OfficerDAO;
import com.grievance.model.User;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.List;

public class EscalationScheduler {

    public void processEscalations() {

        String sql = "SELECT assignment_id, complaint_id, escalation_level " +
                     "FROM complaint_assignments " +
                     "WHERE status = 'PENDING' AND deadline <= NOW()";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql);
             ResultSet resultSet = statement.executeQuery()) {

            while (resultSet.next()) {

                int assignmentId = resultSet.getInt("assignment_id");
                int complaintId = resultSet.getInt("complaint_id");
                int currentLevel = resultSet.getInt("escalation_level");

                escalateComplaint(
                        assignmentId,
                        complaintId,
                        currentLevel);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private void escalateComplaint(
            int assignmentId,
            int complaintId,
            int currentLevel) {

        AssignmentDAO assignmentDAO = new AssignmentDAO();
        OfficerDAO officerDAO = new OfficerDAO();

        try {

            assignmentDAO.markAssignmentEscalated(assignmentId);

            if (currentLevel >= 3) {

                assignmentDAO.updateComplaintStatus(
                        complaintId,
                        "ESCALATION_PENDING");

                return;
            }

            String departmentSql =
                    "SELECT department_id FROM complaints WHERE complaint_id = ?";

            int departmentId = 0;

            try (Connection connection = DBConnection.getConnection();
                 PreparedStatement statement =
                         connection.prepareStatement(departmentSql)) {

                statement.setInt(1, complaintId);

                ResultSet resultSet = statement.executeQuery();

                if (resultSet.next()) {
                    departmentId =
                            resultSet.getInt("department_id");
                }
            }

            int nextLevel = currentLevel + 1;

            List<User> officers =
                    officerDAO.getOfficersByDepartmentAndLevel(
                            departmentId,
                            nextLevel);

            if (officers.isEmpty()) {

                assignmentDAO.updateComplaintStatus(
                        complaintId,
                        "ESCALATION_PENDING");

                return;
            }

            User nextOfficer = officers.get(0);

            assignNextLevel(
                    complaintId,
                    nextOfficer.getUserId(),
                    nextLevel);

            assignmentDAO.updateComplaintStatus(
                    complaintId,
                    "ESCALATED");

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private void assignNextLevel(
            int complaintId,
            int officerId,
            int level) {

        String sql =
                "INSERT INTO complaint_assignments " +
                "(complaint_id, officer_id, escalation_level, " +
                "assigned_at, deadline, status) " +
                "VALUES (?, ?, ?, ?, ?, 'PENDING')";

        LocalDateTime assignedAt =
                LocalDateTime.now();

        LocalDateTime deadline =
                assignedAt.plusDays(7);

        try (Connection connection =
                     DBConnection.getConnection();
             PreparedStatement statement =
                     connection.prepareStatement(sql)) {

            statement.setInt(1, complaintId);
            statement.setInt(2, officerId);
            statement.setInt(3, level);
            statement.setTimestamp(
                    4,
                    Timestamp.valueOf(assignedAt));
            statement.setTimestamp(
                    5,
                    Timestamp.valueOf(deadline));

            statement.executeUpdate();

        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}