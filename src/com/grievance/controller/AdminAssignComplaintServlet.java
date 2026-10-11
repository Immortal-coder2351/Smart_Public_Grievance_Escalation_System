package com.grievance.controller;

import com.grievance.dao.AdminAssignmentDAO;
import com.grievance.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet("/adminAssignComplaint")
public class AdminAssignComplaintServlet extends HttpServlet {

    private AdminAssignmentDAO adminAssignmentDAO;

    @Override
    public void init() {
        adminAssignmentDAO = new AdminAssignmentDAO();
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

        String complaintIdText =
                request.getParameter("complaintId");

        String officerIdText =
                request.getParameter("officerId");

        if (complaintIdText == null ||
            complaintIdText.trim().isEmpty() ||
            officerIdText == null ||
            officerIdText.trim().isEmpty()) {

            response.sendRedirect(
                    "adminComplaints?error=missing");

            return;
        }

        try {

            int complaintId =
                    Integer.parseInt(complaintIdText);

            int officerId =
                    Integer.parseInt(officerIdText);

            boolean success =
                    adminAssignmentDAO.assignComplaintToOfficer(
                            complaintId,
                            officerId);

            if (success) {
                response.sendRedirect(
                        "adminComplaints?success=assigned");

            } else {

                response.sendRedirect(
                        "adminComplaints?error=failed");
            }

        } catch (NumberFormatException e) {

            response.sendRedirect(
                    "adminComplaints?error=invalid");

        } catch (Exception e) {

            e.printStackTrace();

            response.sendRedirect(
                    "adminComplaints?error=server");
        }
    }
}