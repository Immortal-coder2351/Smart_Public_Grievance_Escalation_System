package com.grievance.controller;

import com.grievance.dao.ComplaintHistoryDAO;
import com.grievance.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

@WebServlet("/complaintHistory")
public class ComplaintHistoryServlet extends HttpServlet {

    private ComplaintHistoryDAO complaintHistoryDAO;

    @Override
    public void init() {
        complaintHistoryDAO = new ComplaintHistoryDAO();
    }

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        response.setHeader("Pragma", "no-cache");
        response.setDateHeader("Expires", 0);

        String loginPage = request.getContextPath() + "/login.jsp";

        HttpSession session = request.getSession(false);

        if (session == null) {
            response.sendRedirect(loginPage);
            return;
        }

        Object sessionUser = session.getAttribute("user");

        if (!(sessionUser instanceof User)) {
            response.sendRedirect(loginPage);
            return;
        }

        User user = (User) sessionUser;
        String role = user.getRole();

        if (!"ADMIN".equals(role)
                && !"CITIZEN".equals(role)
                && !"OFFICER".equals(role)) {
            response.sendRedirect(loginPage);
            return;
        }

        String complaintIdText = request.getParameter("complaintId");

        if (complaintIdText == null || complaintIdText.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/" + getDashboardPath(role));
            return;
        }

        try {
            int complaintId = Integer.parseInt(complaintIdText.trim());

            if (complaintId <= 0) {
                response.sendRedirect(request.getContextPath() + "/" + getDashboardPath(role));
                return;
            }

            boolean authorized;

            if ("ADMIN".equals(role)) {
                authorized = true;
            } else if ("CITIZEN".equals(role)) {
                authorized = complaintHistoryDAO.citizenOwnsComplaint(
                        complaintId,
                        user.getUserId());
            } else {
                authorized = complaintHistoryDAO.officerHasComplaint(
                        complaintId,
                        user.getUserId());
            }

            if (!authorized) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN);
                return;
            }

            List<String[]> history =
                    complaintHistoryDAO.getComplaintHistory(complaintId);

            request.setAttribute("history", history);
            request.setAttribute("complaintId", complaintId);

            request.getRequestDispatcher("/complaintHistory.jsp")
                    .forward(request, response);

        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/" + getDashboardPath(role));
        } catch (Exception e) {
            throw new ServletException("Unable to retrieve complaint history.", e);
        }
    }

    private String getDashboardPath(String role) {
        if ("CITIZEN".equals(role)) {
            return "citizenDashboard";
        }

        if ("OFFICER".equals(role)) {
            return "officerDashboard.jsp";
        }

        return "adminDashboard.jsp";
    }
}