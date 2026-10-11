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

@WebServlet("/changePassword")
public class ChangePasswordServlet extends HttpServlet {

    private UserDAO userDAO;

    @Override
    public void init() {
        userDAO = new UserDAO();
    }

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || !(session.getAttribute("user") instanceof User)) {
            response.sendRedirect("login.jsp");
            return;
        }

        request.getRequestDispatcher("changePassword.jsp")
                .forward(request, response);
    }

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || !(session.getAttribute("user") instanceof User)) {
            response.sendRedirect("login.jsp");
            return;
        }

        User user = (User) session.getAttribute("user");
        String currentPassword = request.getParameter("currentPassword");
        String newPassword = request.getParameter("newPassword");
        String confirmNewPassword = request.getParameter("confirmNewPassword");

        if (isBlank(currentPassword) || isBlank(newPassword) ||
                isBlank(confirmNewPassword)) {
            response.sendRedirect("changePassword?error=required");
            return;
        }

        if (!newPassword.equals(confirmNewPassword)) {
            response.sendRedirect("changePassword?error=mismatch");
            return;
        }

        if (currentPassword.equals(newPassword)) {
            response.sendRedirect("changePassword?error=same");
            return;
        }

        try {
            if (userDAO.changePassword(
                    user.getUserId(),
                    currentPassword,
                    newPassword)) {
                user.setPassword(newPassword);
                session.setAttribute("user", user);
                response.sendRedirect("changePassword?success=updated");
            } else {
                response.sendRedirect("changePassword?error=current");
            }
        } catch (RuntimeException e) {
            throw new ServletException("Could not change account password.", e);
        }
    }

    private boolean isBlank(String value) {
        return value == null || value.trim().isEmpty();
    }
}
