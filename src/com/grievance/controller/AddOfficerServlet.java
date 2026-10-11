package com.grievance.controller;

import com.grievance.dao.OfficerDAO;
import com.grievance.model.User;

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

    @Override
    public void init() {
        officerDAO = new OfficerDAO();
    }

    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        // Check whether user is logged in
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        User loggedInUser = (User) session.getAttribute("user");

        // Only ADMIN can add officers
        if (!"ADMIN".equals(loggedInUser.getRole())) {
            response.sendRedirect("login.jsp");
            return;
        }

        // Get form values
        String name = request.getParameter("name");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        String officerLevelText = request.getParameter("officerLevel");
        String departmentIdText = request.getParameter("departmentId");

        // Basic validation
        if (name == null || name.trim().isEmpty() ||
            email == null || email.trim().isEmpty() ||
            username == null || username.trim().isEmpty() ||
            password == null || password.trim().isEmpty() ||
            officerLevelText == null || officerLevelText.trim().isEmpty() ||
            departmentIdText == null || departmentIdText.trim().isEmpty()) {

            response.sendRedirect("adminOfficers.jsp?error=missing");
            return;
        }

        try {

            int officerLevel = Integer.parseInt(officerLevelText);
            int departmentId = Integer.parseInt(departmentIdText);

            // Check whether username already exists
            com.grievance.dao.UserDAO userDAO =
                    new com.grievance.dao.UserDAO();

            if (userDAO.usernameExists(username)) {
                response.sendRedirect("adminOfficers.jsp?error=username");
                return;
            }

            // Check whether email already exists
            if (userDAO.emailExists(email)) {
                response.sendRedirect("adminOfficers.jsp?error=email");
                return;
            }

            // Create officer object
            User officer = new User();

            officer.setName(name);
            officer.setEmail(email);
            officer.setPhone(phone);
            officer.setUsername(username);
            officer.setPassword(password);
            officer.setRole("OFFICER");
            officer.setOfficerLevel(officerLevel);
            officer.setDepartmentId(departmentId);

            // Save officer
            boolean success = officerDAO.addOfficer(officer);

            if (success) {
                response.sendRedirect("adminOfficers.jsp?success=officerAdded");
            } else {
                response.sendRedirect("adminOfficers.jsp?error=failed");
            }

        } catch (NumberFormatException e) {

            response.sendRedirect("adminOfficers.jsp?error=invalidData");

        } catch (Exception e) {

            e.printStackTrace();
            response.sendRedirect("adminOfficers.jsp?error=server");
        }
    }
}
