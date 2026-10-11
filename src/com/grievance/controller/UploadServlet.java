package com.grievance.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.InvalidPathException;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;

@WebServlet("/uploads/*")
public class UploadServlet extends HttpServlet {

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        String pathInfo = request.getPathInfo();
        if (pathInfo == null || pathInfo.length() < 2 ||
                pathInfo.indexOf('/', 1) >= 0) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        String fileName = pathInfo.substring(1);
        String extension = getAllowedExtension(fileName);
        if (extension == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        Path uploadDirectory = getUploadDirectory();
        Path file = uploadDirectory.resolve(fileName).normalize();
        if (!file.getParent().equals(uploadDirectory) ||
                !Files.isRegularFile(file)) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        response.setContentType(getContentType(extension));
        response.setContentLengthLong(Files.size(file));
        response.setHeader("X-Content-Type-Options", "nosniff");
        response.setHeader("Cache-Control", "private, max-age=3600");
        try (var input = Files.newInputStream(file);
             var output = response.getOutputStream()) {
            input.transferTo(output);
        }
    }

    private Path getUploadDirectory() throws IOException {
        String configuredUploadPath = System.getenv("UPLOAD_DIR");
        if (configuredUploadPath == null ||
                configuredUploadPath.trim().isEmpty()) {
            String uploadPath = getServletContext().getRealPath("/uploads");
            if (uploadPath == null) {
                throw new IOException("Upload directory is not available.");
            }
            return Paths.get(uploadPath).toAbsolutePath().normalize();
        }

        try {
            return Paths.get(configuredUploadPath.trim())
                    .toAbsolutePath()
                    .normalize();
        } catch (InvalidPathException e) {
            throw new IOException("Upload directory path is invalid.", e);
        }
    }

    private String getAllowedExtension(String fileName) {
        int extensionIndex = fileName.lastIndexOf('.');
        if (extensionIndex < 0 ||
                !fileName.substring(0, extensionIndex)
                        .matches("[0-9a-fA-F-]{36}")) {
            return null;
        }

        String extension = fileName.substring(extensionIndex + 1)
                .toLowerCase(java.util.Locale.ROOT);
        if (!extension.matches("jpg|jpeg|png|gif|webp")) {
            return null;
        }

        return extension;
    }

    private String getContentType(String extension) {
        switch (extension) {
            case "jpg":
            case "jpeg":
                return "image/jpeg";
            case "png":
                return "image/png";
            case "gif":
                return "image/gif";
            case "webp":
                return "image/webp";
            default:
                throw new IllegalArgumentException("Unsupported image type.");
        }
    }
}
