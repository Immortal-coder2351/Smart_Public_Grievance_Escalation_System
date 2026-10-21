package com.grievance.controller;

import com.grievance.dao.ComplaintUpdateDAO;
import com.grievance.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.Locale;

@WebServlet("/updateComplaint")
public class UpdateComplaintServlet extends HttpServlet {

    private ComplaintUpdateDAO complaintUpdateDAO;

    @Override
    public void init() {
        complaintUpdateDAO = new ComplaintUpdateDAO();
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
        String complaintsPage = contextPath + "/officerComplaints";

        HttpSession session = request.getSession(false);

        if (session == null ||
                !(session.getAttribute("user") instanceof User)) {
            response.sendRedirect(contextPath + "/login.jsp");
            return;
        }

        User user = (User) session.getAttribute("user");

        if (!"OFFICER".equals(user.getRole())) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        String complaintIdText = request.getParameter("complaintId");
        String status = request.getParameter("status");
        String remarks = request.getParameter("remarks");

        if (complaintIdText == null || complaintIdText.trim().isEmpty()
                || status == null || status.trim().isEmpty()) {
            response.sendRedirect(complaintsPage + "?error=missing");
            return;
        }

        status = status.trim().toUpperCase(Locale.ROOT);

        if (!"PENDING".equals(status)
                && !"IN_PROGRESS".equals(status)
                && !"RESOLVED".equals(status)) {
            response.sendRedirect(complaintsPage + "?error=invalid");
            return;
        }

        if (remarks != null && remarks.length() > 1000) {
            response.sendRedirect(complaintsPage + "?error=invalid");
            return;
        }

        try {
            int complaintId = Integer.parseInt(complaintIdText.trim());

            if (complaintId <= 0) {
                response.sendRedirect(complaintsPage + "?error=invalid");
                return;
            }

            boolean success = complaintUpdateDAO.updateComplaintStatus(
                    complaintId,
                    user.getUserId(),
                    status,
                    remarks == null ? "" : remarks.trim()
            );

            if (success) {
                response.sendRedirect(complaintsPage + "?success=updated");
            } else {
                response.sendRedirect(complaintsPage + "?error=failed");
            }

        } catch (NumberFormatException e) {
            response.sendRedirect(complaintsPage + "?error=invalid");
        } catch (Exception e) {
            throw new ServletException("Unable to update complaint status.", e);
        }
    }
}