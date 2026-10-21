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
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.Locale;
import java.util.UUID;

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

        response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        response.setHeader("Pragma", "no-cache");
        response.setDateHeader("Expires", 0);

        String contextPath = request.getContextPath();
        HttpSession session = request.getSession(false);

        if (session == null || !(session.getAttribute("user") instanceof User)) {
            response.sendRedirect(contextPath + "/login.jsp");
            return;
        }

        User user = (User) session.getAttribute("user");

        if (!"CITIZEN".equals(user.getRole())) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        String title = request.getParameter("title");
        String departmentId = request.getParameter("departmentId");
        String category = request.getParameter("category");
        String priority = request.getParameter("priority");
        String description = request.getParameter("description");
        String location = request.getParameter("location");

        if (isBlank(title) || isBlank(departmentId) ||
                isBlank(category) || isBlank(priority) ||
                isBlank(description) || isBlank(location)) {
            response.sendError(
                    HttpServletResponse.SC_BAD_REQUEST,
                    "Please complete all required complaint fields.");
            return;
        }

        priority = priority.trim().toUpperCase(Locale.ROOT);

        if (!"HIGH".equals(priority) &&
                !"MEDIUM".equals(priority) &&
                !"LOW".equals(priority)) {
            response.sendError(
                    HttpServletResponse.SC_BAD_REQUEST,
                    "Invalid priority value.");
            return;
        }

        int departmentIdValue;

        try {
            departmentIdValue = Integer.parseInt(departmentId.trim());

            if (departmentIdValue <= 0) {
                throw new NumberFormatException();
            }
        } catch (NumberFormatException e) {
            response.sendError(
                    HttpServletResponse.SC_BAD_REQUEST,
                    "Invalid department.");
            return;
        }

        Part imagePart;

        try {
            Part browserImage = request.getPart("browserImage");
            Part cameraImage = request.getPart("cameraImage");

            imagePart = chooseImagePart(browserImage, cameraImage);

            if (imagePart == null || imagePart.getSize() == 0) {
                response.sendError(
                        HttpServletResponse.SC_BAD_REQUEST,
                        "Please attach a complaint image before submitting.");
                return;
            }
        } catch (IllegalStateException e) {
            response.sendError(
                    HttpServletResponse.SC_REQUEST_ENTITY_TOO_LARGE,
                    "The uploaded request is too large.");
            return;
        }

        String imagePath;

        try {
            imagePath = saveUploadedImage(imagePart);
        } catch (IllegalArgumentException e) {
            response.sendError(
                    HttpServletResponse.SC_BAD_REQUEST,
                    e.getMessage());
            return;
        }

        Complaint complaint = new Complaint();

        complaint.setCitizenId(user.getUserId());
        complaint.setDepartmentId(departmentIdValue);
        complaint.setTitle(title.trim());
        complaint.setCategory(category.trim());
        complaint.setPriority(priority);
        complaint.setDescription(description.trim());
        complaint.setLocation(location.trim());
        complaint.setImage(imagePath);

        try {
            boolean registered = complaintDAO.registerComplaint(complaint);

            if (registered) {
                response.sendRedirect(
                        contextPath + "/complaintSuccess.jsp?complaintId="
                                + complaint.getComplaintId());
            } else {
                response.sendError(
                        HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                        "Complaint registration failed. Please try again.");
            }
        } catch (Exception e) {
            throw new ServletException("Unable to register complaint.", e);
        }
    }

    private boolean isBlank(String value) {
        return value == null || value.trim().isEmpty();
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

    private String saveUploadedImage(Part imagePart) throws IOException {
        if (imagePart.getSize() > 5 * 1024 * 1024) {
            throw new IllegalArgumentException(
                    "Image size must be 5 MB or less.");
        }

        String contentType = imagePart.getContentType();

        if (contentType == null ||
                !contentType.toLowerCase(Locale.ROOT).startsWith("image/")) {
            throw new IllegalArgumentException(
                    "Please upload a valid image file.");
        }

        String submittedFileName = imagePart.getSubmittedFileName();

        String extension = submittedFileName != null &&
                submittedFileName.contains(".")
                ? submittedFileName.substring(
                        submittedFileName.lastIndexOf('.')).toLowerCase(Locale.ROOT)
                : "";

        if (!extension.matches("\\.(jpg|jpeg|png|gif|webp)")) {
            throw new IllegalArgumentException(
                    "Please upload a JPG, JPEG, PNG, GIF or WEBP image.");
        }

        String fileName = UUID.randomUUID() + extension;

        String configuredUploadPath = System.getenv("UPLOAD_DIR");
        Path uploadDirectory;

        if (configuredUploadPath == null ||
                configuredUploadPath.trim().isEmpty()) {
            String uploadPath = getServletContext().getRealPath("/uploads");

            if (uploadPath == null) {
                throw new IOException("Upload directory is not available.");
            }

            uploadDirectory = Paths.get(uploadPath);
        } else {
            uploadDirectory = Paths.get(configuredUploadPath.trim());
        }

        Files.createDirectories(uploadDirectory);

        Path target = uploadDirectory.resolve(fileName).normalize();

        if (!target.startsWith(uploadDirectory.toAbsolutePath().normalize())
                && !target.startsWith(uploadDirectory.normalize())) {
            throw new IOException("Invalid upload destination.");
        }

        try (InputStream input = imagePart.getInputStream()) {
            Files.copy(input, target, StandardCopyOption.REPLACE_EXISTING);
        }

        return "uploads/" + fileName;
    }
}