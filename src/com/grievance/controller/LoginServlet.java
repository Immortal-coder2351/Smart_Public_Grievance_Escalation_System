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
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        String username = request.getParameter("username");
        String password = request.getParameter("password");

        User user = userDAO.loginUser(username, password);

        if (user != null) {

            HttpSession session = request.getSession();
            session.setAttribute("user", user);

            String role = user.getRole();

            if ("CITIZEN".equals(role)) {

                response.sendRedirect("citizenDashboard");

            } else if ("OFFICER".equals(role)) {

                response.sendRedirect("officerDashboard.jsp");

            } else if ("ADMIN".equals(role)) {

                response.sendRedirect("adminDashboard.jsp");

            } else {

                response.getWriter().println(
                        "Invalid user role."
                );
            }

        } else {

            response.getWriter().println(
                    "Invalid username or password."
            );
        }
    }
}