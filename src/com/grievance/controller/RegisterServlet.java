package com.grievance.controller;

import com.grievance.dao.UserDAO;
import com.grievance.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

@WebServlet("/register")
public class RegisterServlet extends HttpServlet {

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

        String name = request.getParameter("name");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        String confirmPassword =
                request.getParameter("confirmPassword");

        // Check password confirmation
        if (!password.equals(confirmPassword)) {

            response.getWriter().println(
                    "Passwords do not match."
            );

            return;
        }

        // Check existing username
        if (userDAO.usernameExists(username)) {

            response.getWriter().println(
                    "Username already exists."
            );

            return;
        }

        // Check existing email
        if (userDAO.emailExists(email)) {

            response.getWriter().println(
                    "Email already exists."
            );

            return;
        }

        // Create citizen user
        User user = new User();

        user.setName(name);
        user.setEmail(email);
        user.setPhone(phone);
        user.setUsername(username);
        user.setPassword(password);

        // Citizens are automatically assigned CITIZEN role
        user.setRole("CITIZEN");

        // Citizens don't have officer level
        user.setOfficerLevel(null);

        // Citizen isn't assigned to a department
        user.setDepartmentId(null);

        boolean registered =
                userDAO.registerUser(user);

        if (registered) {

            response.sendRedirect("login.jsp");

        } else {

            response.getWriter().println(
                    "Registration failed. Check Tomcat console for SQL error."
            );
        }
    }
}