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
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        response.setHeader("Pragma", "no-cache");
        response.setDateHeader("Expires", 0);

        String contextPath = request.getContextPath();
        HttpSession session = request.getSession(false);

        if (session == null || !(session.getAttribute("user") instanceof User)) {
            response.sendRedirect(contextPath + "/login.jsp");
            return;
        }

        User user = (User) session.getAttribute("user");

        if (!"ADMIN".equals(user.getRole())) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        String complaintIdText = request.getParameter("complaintId");
        String officerIdText = request.getParameter("officerId");

        String redirectUrl = contextPath + "/adminComplaints";

        if (complaintIdText == null || complaintIdText.trim().isEmpty()
                || officerIdText == null || officerIdText.trim().isEmpty()) {
            response.sendRedirect(redirectUrl + "?error=missing");
            return;
        }

        try {
            int complaintId = Integer.parseInt(complaintIdText.trim());
            int officerId = Integer.parseInt(officerIdText.trim());

            if (complaintId <= 0 || officerId <= 0) {
                response.sendRedirect(redirectUrl + "?error=invalid");
                return;
            }

            boolean assigned =
                    adminAssignmentDAO.assignComplaint(complaintId, officerId);

            if (assigned) {
                response.sendRedirect(redirectUrl + "?success=assigned");
            } else {
                response.sendRedirect(redirectUrl + "?error=failed");
            }

        } catch (NumberFormatException e) {
            response.sendRedirect(redirectUrl + "?error=invalid");
        } catch (Exception e) {
            throw new ServletException("Unable to assign complaint.", e);
        }
    }
}