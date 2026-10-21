package com.grievance.controller;

import com.grievance.dao.OfficerDAO;
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

@WebServlet("/addOfficer")
public class AddOfficerServlet extends HttpServlet {

    private OfficerDAO officerDAO;
    private UserDAO userDAO;

    @Override
    public void init() {
        officerDAO = new OfficerDAO();
        userDAO = new UserDAO();
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
        HttpSession session = request.getSession(false);

        if (session == null || !(session.getAttribute("user") instanceof User)) {
            response.sendRedirect(contextPath + "/login.jsp");
            return;
        }

        User loggedInUser = (User) session.getAttribute("user");

        if (!"ADMIN".equals(loggedInUser.getRole())) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        String name = request.getParameter("name");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        String officerLevelText = request.getParameter("officerLevel");
        String departmentIdText = request.getParameter("departmentId");

        String redirectUrl = contextPath + "/adminOfficers.jsp";

        if (name == null || name.trim().isEmpty()
                || email == null || email.trim().isEmpty()
                || phone == null || phone.trim().isEmpty()
                || username == null || username.trim().isEmpty()
                || password == null || password.trim().isEmpty()
                || officerLevelText == null || officerLevelText.trim().isEmpty()
                || departmentIdText == null || departmentIdText.trim().isEmpty()) {

            response.sendRedirect(redirectUrl + "?error=missing");
            return;
        }

        if (!PasswordValidator.isStrong(password)) {
            response.sendRedirect(redirectUrl + "?error=weakPassword");
            return;
        }

        try {
            int officerLevel = Integer.parseInt(officerLevelText.trim());
            int departmentId = Integer.parseInt(departmentIdText.trim());

            if (officerLevel < 1 || departmentId < 1) {
                response.sendRedirect(redirectUrl + "?error=invalid");
                return;
            }

            User officer = new User();
            officer.setName(name.trim());
            officer.setEmail(email.trim());
            officer.setPhone(phone.trim());
            officer.setUsername(username.trim());
            officer.setPassword(password);
            officer.setRole("OFFICER");
            officer.setOfficerLevel(officerLevel);
            officer.setDepartmentId(departmentId);

            boolean added = officerDAO.addOfficer(officer);

            if (added) {
                response.sendRedirect(redirectUrl + "?success=officerAdded");
            } else {
                response.sendRedirect(redirectUrl + "?error=failed");
            }

        } catch (NumberFormatException e) {
            response.sendRedirect(redirectUrl + "?error=invalid");
        } catch (Exception e) {
            throw new ServletException("Unable to add officer.", e);
        }
    }
}