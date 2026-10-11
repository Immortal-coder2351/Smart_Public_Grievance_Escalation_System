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
    protected void doGet(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null ||
            session.getAttribute("user") == null) {

            response.sendRedirect("login.jsp");
            return;
        }

        User user = (User) session.getAttribute("user");

        String complaintIdText =
                request.getParameter("complaintId");

        if (complaintIdText == null ||
            complaintIdText.trim().isEmpty()) {

            response.sendRedirect("login.jsp");
            return;
        }

        try {

            int complaintId =
                    Integer.parseInt(complaintIdText);

            boolean authorized = false;

            if ("ADMIN".equals(user.getRole())) {

                authorized = true;

            } else if ("CITIZEN".equals(user.getRole())) {

                authorized =
                        complaintHistoryDAO.citizenOwnsComplaint(
                                complaintId,
                                user.getUserId());

            } else if ("OFFICER".equals(user.getRole())) {

                authorized =
                        complaintHistoryDAO.officerHasComplaint(
                                complaintId,
                                user.getUserId());
            }

            if (!authorized) {
                response.sendRedirect("login.jsp");
                return;
            }

            List<String[]> history =
                    complaintHistoryDAO.getComplaintHistory(
                            complaintId);

            request.setAttribute("history", history);
            request.setAttribute("complaintId", complaintId);

            request.getRequestDispatcher(
                    "complaintHistory.jsp")
                   .forward(request, response);

        } catch (NumberFormatException e) {

            response.sendRedirect("login.jsp");

        } catch (Exception e) {

            e.printStackTrace();
            response.sendRedirect("login.jsp");
        }
    }
}