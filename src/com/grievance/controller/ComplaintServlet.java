package com.grievance.controller;

import com.grievance.dao.ComplaintDAO;
import com.grievance.model.Complaint;
import com.grievance.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.Part;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet("/complaint")
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024,
        maxFileSize = 5 * 1024 * 1024,
        maxRequestSize = 8 * 1024 * 1024
)
public class ComplaintServlet extends HttpServlet {

    private ComplaintDAO complaintDAO;

    @Override
    public void init() {
        complaintDAO = new ComplaintDAO();
    }

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        User user = (User) session.getAttribute("user");

        if (user == null || !"CITIZEN".equals(user.getRole())) {
            response.sendRedirect("login.jsp");
            return;
        }

        String title = request.getParameter("title");
        String departmentId = request.getParameter("departmentId");
        String category = request.getParameter("category");
        String priority = request.getParameter("priority");
        String description = request.getParameter("description");
        String location = request.getParameter("location");
        String image = null;

        if (title == null || title.trim().isEmpty() ||
            departmentId == null || departmentId.trim().isEmpty() ||
            category == null || category.trim().isEmpty() ||
            priority == null || priority.trim().isEmpty() ||
            description == null || description.trim().isEmpty() ||
            location == null || location.trim().isEmpty()) {

            response.getWriter().println(
                    "Please complete all required complaint fields.");
            return;
        }

        if (!"HIGH".equals(priority) &&
            !"MEDIUM".equals(priority) &&
            !"LOW".equals(priority)) {

            response.getWriter().println(
                    "Invalid priority value.");
            return;
        }

        int departmentIdValue;
        try {
            departmentIdValue = Integer.parseInt(departmentId);
        } catch (NumberFormatException e) {
            response.getWriter().println(
                    "Invalid department.");
            return;
        }

        try {
            Part browserImage = request.getPart("browserImage");
            Part cameraImage = request.getPart("cameraImage");
            Part imagePart = chooseImagePart(browserImage, cameraImage);

            if (imagePart == null || imagePart.getSize() == 0) {
                response.getWriter().println(
                        "Please attach a complaint image before submitting.");
                return;
            }

            image = saveUploadedImage(imagePart, request);
        } catch (IllegalArgumentException e) {
            response.getWriter().println(e.getMessage());
            return;
        }

        Complaint complaint = new Complaint();

        complaint.setCitizenId(user.getUserId());
        complaint.setDepartmentId(departmentIdValue);
        complaint.setTitle(title);
        complaint.setCategory(category);
        complaint.setPriority(priority);
        complaint.setDescription(description);
        complaint.setLocation(location);
        complaint.setImage(image);

        boolean registered =
                complaintDAO.registerComplaint(complaint);

        if (registered) {

            response.sendRedirect("complaintSuccess.jsp?complaintId=" + complaint.getComplaintId());

        } else {

            response.getWriter().println(
                    "Complaint registration failed. Please try again."
            );
        }
    }

    private Part chooseImagePart(Part browserImage, Part cameraImage) {
        if (browserImage != null && browserImage.getSize() > 0) {
            return browserImage;
        }

        if (cameraImage != null && cameraImage.getSize() > 0) {
            return cameraImage;
        }

        return null;
    }

    private String saveUploadedImage(Part imagePart, HttpServletRequest request)
            throws IOException {

        if (imagePart.getSize() > 5 * 1024 * 1024) {
            throw new IllegalArgumentException(
                    "Image size must be 5 MB or less.");
        }

        String contentType = imagePart.getContentType();

        if (contentType == null ||
                !contentType.toLowerCase().startsWith("image/")) {
            throw new IllegalArgumentException(
                    "Please upload a valid image file.");
        }

        String submittedFileName = imagePart.getSubmittedFileName();
        String extension = submittedFileName != null &&
                submittedFileName.contains(".")
                ? submittedFileName.substring(
                        submittedFileName.lastIndexOf('.')).toLowerCase()
                : "";

        if (!extension.matches("\\.(jpg|jpeg|png|gif|webp)")) {
            throw new IllegalArgumentException(
                    "Please upload a JPG, JPEG, PNG, GIF or WEBP image.");
        }

        String fileName =
                java.util.UUID.randomUUID() + extension;

        String uploadPath =
                getServletContext().getRealPath("/uploads");

        if (uploadPath == null) {
            throw new IOException(
                    "Upload directory is not available.");
        }

        java.nio.file.Path uploadDirectory =
                java.nio.file.Paths.get(uploadPath);

        java.nio.file.Files.createDirectories(uploadDirectory);

        java.nio.file.Path target =
                uploadDirectory.resolve(fileName);

        try (java.io.InputStream input =
                     imagePart.getInputStream()) {

            java.nio.file.Files.copy(
                    input,
                    target,
                    java.nio.file.StandardCopyOption.REPLACE_EXISTING);
        }

        return "uploads/" + fileName;
    }

}