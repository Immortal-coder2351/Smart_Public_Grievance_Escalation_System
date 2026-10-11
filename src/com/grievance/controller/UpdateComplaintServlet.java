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

@WebServlet("/updateComplaint")
public class UpdateComplaintServlet extends HttpServlet {

    private ComplaintUpdateDAO complaintUpdateDAO;

    @Override
    public void init() {
        complaintUpdateDAO = new ComplaintUpdateDAO();
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

        if (!"OFFICER".equals(user.getRole())) {
            response.sendRedirect("login.jsp");
            return;
        }

        String complaintIdText = request.getParameter("complaintId");
        String status = request.getParameter("status");
        String remarks = request.getParameter("remarks");

        if (complaintIdText == null || complaintIdText.trim().isEmpty() ||
            status == null || status.trim().isEmpty()) {

            response.sendRedirect("officerComplaints?error=missing");
            return;
        }

        try {

            int complaintId = Integer.parseInt(complaintIdText);

            boolean success =
                    complaintUpdateDAO.updateComplaintStatus(
                            complaintId,
                            user.getUserId(),
                            status,
                            remarks
                    );

            if (success) {
                response.sendRedirect("officerComplaints?success=updated");
            } else {
                response.sendRedirect("officerComplaints?error=failed");
            }

        } catch (NumberFormatException e) {

            response.sendRedirect("officerComplaints?error=invalid");

        } catch (Exception e) {

            e.printStackTrace();
            response.sendRedirect("officerComplaints?error=server");
        }
    }
}