package com.grievance.controller;

import com.grievance.dao.AssignmentDAO;
import com.grievance.dao.OfficerDAO;
import com.grievance.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

@WebServlet("/assignComplaint")
public class AssignComplaintServlet extends HttpServlet {

    private AssignmentDAO assignmentDAO;
    private OfficerDAO officerDAO;

    @Override
    public void init() {
        assignmentDAO = new AssignmentDAO();
        officerDAO = new OfficerDAO();
    }

    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        User user = (User) session.getAttribute("user");

        if (!"ADMIN".equals(user.getRole())) {
            response.sendRedirect("login.jsp");
            return;
        }

        String complaintIdText = request.getParameter("complaintId");
        String departmentIdText = request.getParameter("departmentId");

        if (complaintIdText == null || departmentIdText == null) {
            response.sendRedirect("adminDashboard.jsp?error=Invalid complaint details");
            return;
        }

        try {

            int complaintId = Integer.parseInt(complaintIdText);
            int departmentId = Integer.parseInt(departmentIdText);

            List<User> officers =
                    officerDAO.getOfficersByDepartmentAndLevel(
                            departmentId, 1);

            if (officers.isEmpty()) {
                response.sendRedirect(
                        "adminDashboard.jsp?error=No Level 1 officer available for this department");
                return;
            }

            User officer = officers.get(0);

            boolean assigned =
                    assignmentDAO.assignComplaint(
                            complaintId,
                            officer.getUserId(),
                            1);

            if (assigned) {

                assignmentDAO.updateComplaintStatus(
                        complaintId,
                        "PENDING");

                response.sendRedirect(
                        "adminDashboard.jsp?success=Complaint assigned successfully");

            } else {

                response.sendRedirect(
                        "adminDashboard.jsp?error=Complaint assignment failed");
            }

        } catch (NumberFormatException e) {

            response.sendRedirect(
                    "adminDashboard.jsp?error=Invalid complaint or department ID");

        } catch (Exception e) {

            e.printStackTrace();

            response.sendRedirect(
                    "adminDashboard.jsp?error=Server error during complaint assignment");
        }
    }
}