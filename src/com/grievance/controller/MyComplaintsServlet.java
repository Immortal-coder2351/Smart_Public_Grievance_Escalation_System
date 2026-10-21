package com.grievance.controller;

import com.grievance.dao.ComplaintDAO;
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

@WebServlet("/myComplaints")
public class MyComplaintsServlet extends HttpServlet {

    private ComplaintDAO complaintDAO;

    @Override
    public void init() {
        complaintDAO = new ComplaintDAO();
    }

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        response.setHeader("Pragma", "no-cache");
        response.setDateHeader("Expires", 0);

        String loginPage = request.getContextPath() + "/login.jsp";

        HttpSession session = request.getSession(false);

        if (session == null) {
            response.sendRedirect(loginPage);
            return;
        }

        Object sessionUser = session.getAttribute("user");

        if (!(sessionUser instanceof User)) {
            response.sendRedirect(loginPage);
            return;
        }

        User user = (User) sessionUser;

        if (!"CITIZEN".equals(user.getRole())) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        try {
            List<Complaint> complaints =
                    complaintDAO.getComplaintsByCitizen(user.getUserId());

            request.setAttribute("complaints", complaints);

            request.getRequestDispatcher("/myComplaints.jsp")
                    .forward(request, response);

        } catch (Exception e) {
            throw new ServletException("Unable to load your complaints.", e);
        }
    }
}