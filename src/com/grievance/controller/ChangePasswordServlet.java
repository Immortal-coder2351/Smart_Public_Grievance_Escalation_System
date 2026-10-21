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

        response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        response.setHeader("Pragma", "no-cache");
        response.setDateHeader("Expires", 0);

        String contextPath = request.getContextPath();
        HttpSession session = request.getSession(false);

        if (session == null ||
                !(session.getAttribute("user") instanceof User)) {
            response.sendRedirect(contextPath + "/login.jsp");
            return;
        }

        request.getRequestDispatcher("/changePassword.jsp")
                .forward(request, response);
    }

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        response.setHeader("Pragma", "no-cache");
        response.setDateHeader("Expires", 0);

        String contextPath = request.getContextPath();
        String changePasswordUrl = contextPath + "/changePassword";

        HttpSession session = request.getSession(false);

        if (session == null ||
                !(session.getAttribute("user") instanceof User)) {
            response.sendRedirect(contextPath + "/login.jsp");
            return;
        }

        User user = (User) session.getAttribute("user");

        String currentPassword = request.getParameter("currentPassword");
        String newPassword = request.getParameter("newPassword");
        String confirmNewPassword = request.getParameter("confirmNewPassword");

        if (isBlank(currentPassword) ||
                isBlank(newPassword) ||
                isBlank(confirmNewPassword)) {
            response.sendRedirect(changePasswordUrl + "?error=required");
            return;
        }

        if (!PasswordValidator.isStrong(newPassword)) {
            response.sendRedirect(changePasswordUrl + "?error=weakPassword");
            return;
        }

        if (!newPassword.equals(confirmNewPassword)) {
            response.sendRedirect(changePasswordUrl + "?error=mismatch");
            return;
        }

        if (currentPassword.equals(newPassword)) {
            response.sendRedirect(changePasswordUrl + "?error=same");
            return;
        }

        try {
            boolean changed = userDAO.changePassword(
                    user.getUserId(),
                    currentPassword,
                    newPassword
            );

            if (changed) {
                user.setPassword(null);
                session.setAttribute("user", user);

                response.sendRedirect(changePasswordUrl + "?success=updated");
            } else {
                response.sendRedirect(changePasswordUrl + "?error=current");
            }
        } catch (RuntimeException e) {
            throw new ServletException(
                    "Could not change account password.", e);
        }
    }

    private boolean isBlank(String value) {
        return value == null || value.trim().isEmpty();
    }
}