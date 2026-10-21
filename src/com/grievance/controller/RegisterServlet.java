package com.grievance.controller;

import com.grievance.dao.UserDAO;
import com.grievance.model.User;
import com.grievance.util.PasswordValidator;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet("/register")
public class RegisterServlet extends HttpServlet {

    private UserDAO userDAO;

    @Override
    public void init() {
        userDAO = new UserDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        setNoCacheHeaders(response);
        response.sendRedirect(request.getContextPath() + "/register.jsp");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        setNoCacheHeaders(response);
        request.setCharacterEncoding("UTF-8");

        HttpSession existingSession = request.getSession(false);
        if (existingSession != null && existingSession.getAttribute("user") instanceof User) {
            User loggedInUser = (User) existingSession.getAttribute("user");
            String role = loggedInUser.getRole();

            if ("ADMIN".equals(role)) {
                response.sendRedirect(request.getContextPath() + "/adminDashboard.jsp");
                return;
            } else if ("OFFICER".equals(role)) {
                response.sendRedirect(request.getContextPath() + "/officerDashboard.jsp");
                return;
            } else if ("CITIZEN".equals(role)) {
                response.sendRedirect(request.getContextPath() + "/citizenDashboard");
                return;
            }
        }

        String name = trim(request.getParameter("name"));
        String email = trim(request.getParameter("email"));
        String phone = trim(request.getParameter("phone"));
        String username = trim(request.getParameter("username"));
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");

        if (name == null || name.isEmpty()
                || email == null || email.isEmpty()
                || username == null || username.isEmpty()
                || password == null || password.isEmpty()
                || confirmPassword == null || confirmPassword.isEmpty()) {
            redirectWithError(request, response, "required");
            return;
        }

        if (name.length() > 100
                || email.length() > 150
                || username.length() < 3
                || username.length() > 50
                || (phone != null && !phone.isEmpty()
                    && !phone.matches("[0-9]{10,15}"))) {
            redirectWithError(request, response, "invalid");
            return;
        }

        if (!email.matches("^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$")) {
            redirectWithError(request, response, "invalid");
            return;
        }

        if (!PasswordValidator.isStrong(password)) {
            redirectWithError(request, response, "weakPassword");
            return;
        }

        if (!password.equals(confirmPassword)) {
            redirectWithError(request, response, "passwordMismatch");
            return;
        }

        try {
            if (userDAO.usernameExists(username)) {
                redirectWithError(request, response, "username");
                return;
            }

            if (userDAO.emailExists(email)) {
                redirectWithError(request, response, "email");
                return;
            }

            User user = new User();
            user.setName(name);
            user.setEmail(email);
            user.setPhone(phone == null || phone.isEmpty() ? null : phone);
            user.setUsername(username);
            user.setPassword(password);
            user.setRole("CITIZEN");
            user.setOfficerLevel(null);
            user.setDepartmentId(null);

            if (userDAO.registerUser(user)) {
                response.sendRedirect(request.getContextPath() + "/login.jsp?registered=success");
            } else {
                redirectWithError(request, response, "failed");
            }
        } catch (RuntimeException e) {
            throw new ServletException("Registration failed.", e);
        }
    }

    private String trim(String value) {
        return value == null ? null : value.trim();
    }

    private void redirectWithError(HttpServletRequest request,
                                   HttpServletResponse response,
                                   String error) throws IOException {
        response.sendRedirect(request.getContextPath() + "/register.jsp?error=" + error);
    }

    private void setNoCacheHeaders(HttpServletResponse response) {
        response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        response.setHeader("Pragma", "no-cache");
        response.setDateHeader("Expires", 0);
    }
}