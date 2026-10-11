package com.grievance.controller;

import com.grievance.dao.AdminComplaintDAO;
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

@WebServlet("/adminComplaints")
public class AdminComplaintsServlet extends HttpServlet {

    private AdminComplaintDAO adminComplaintDAO;

    @Override
    public void init() {
        adminComplaintDAO = new AdminComplaintDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request,
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

        List<Complaint> complaints =
                adminComplaintDAO.getAllComplaints();

        request.setAttribute("complaints", complaints);

        request.getRequestDispatcher("adminComplaints.jsp")
               .forward(request, response);
    }
}