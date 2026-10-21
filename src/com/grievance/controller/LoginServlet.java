package com.grievance.controller;

import com.grievance.dao.UserDAO;
import com.grievance.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {

    private UserDAO userDAO;

    @Override
    public void init() {
        userDAO = new UserDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        setNoCacheHeaders(response);
        response.sendRedirect(request.getContextPath() + "/login.jsp");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        setNoCacheHeaders(response);
        request.setCharacterEncoding("UTF-8");

        String contextPath = request.getContextPath();
        String username = request.getParameter("username");
        String password = request.getParameter("password");

        if (username == null || username.trim().isEmpty()
                || password == null || password.isEmpty()) {
            response.sendRedirect(contextPath + "/login.jsp?error=required");
            return;
        }

        try {
            User user = userDAO.loginUser(username.trim(), password);

            if (user == null) {
                response.sendRedirect(contextPath + "/login.jsp?error=invalid");
                return;
            }

            String role = user.getRole();

            if (!"CITIZEN".equals(role)
                    && !"OFFICER".equals(role)
                    && !"ADMIN".equals(role)) {
                response.sendRedirect(contextPath + "/login.jsp?error=invalid");
                return;
            }

            HttpSession existingSession = request.getSession(false);

            if (existingSession != null) {
                existingSession.invalidate();
            }

            HttpSession session = request.getSession(true);
            session.setAttribute("user", user);
            session.setMaxInactiveInterval(30 * 60);

            if ("CITIZEN".equals(role)) {
                response.sendRedirect(contextPath + "/citizenDashboard");
            } else if ("OFFICER".equals(role)) {
                response.sendRedirect(contextPath + "/officerDashboard.jsp");
            } else {
                response.sendRedirect(contextPath + "/adminDashboard.jsp");
            }

        } catch (RuntimeException e) {
            throw new ServletException("Unable to process login.", e);
        }
    }

    private void setNoCacheHeaders(HttpServletResponse response) {
        response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        response.setHeader("Pragma", "no-cache");
        response.setDateHeader("Expires", 0);
    }
}