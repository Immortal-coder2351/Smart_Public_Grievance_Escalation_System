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

@WebServlet("/citizenDashboard")
public class CitizenDashboardServlet extends HttpServlet {

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

        HttpSession session = request.getSession(false);

        if (session == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        User user = (User) session.getAttribute("user");

        if (user == null || !"CITIZEN".equals(user.getRole())) {
            response.sendRedirect("login.jsp");
            return;
        }

        List<Complaint> complaints =
                complaintDAO.getComplaintsByCitizen(user.getUserId());
        request.setAttribute("complaints", complaints);
        request.getRequestDispatcher("citizendashboard.jsp")
                .forward(request, response);
    }
}
