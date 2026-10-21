package com.grievance.controller;

import com.grievance.dao.OfficerComplaintDAO;
import com.grievance.model.Complaint;
import com.grievance.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

@WebServlet("/officerComplaints")
public class OfficerComplaintsServlet extends HttpServlet {

    private OfficerComplaintDAO officerComplaintDAO;

    @Override
    public void init() {
        officerComplaintDAO = new OfficerComplaintDAO();
    }

    @Override
    protected void doGet(
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

        if (!"OFFICER".equals(user.getRole())) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        try {
            List<Complaint> complaints =
                    officerComplaintDAO.getAssignedComplaints(user.getUserId());

            request.setAttribute("complaints", complaints);

            request.getRequestDispatcher("/officerComplaints.jsp")
                    .forward(request, response);

        } catch (Exception e) {
            throw new ServletException("Unable to load assigned complaints.", e);
        }
    }
}