<%@ page import="com.grievance.model.User" %>
<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    User user = (User) session.getAttribute("user");

    if (user == null || !"CITIZEN".equals(user.getRole())) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate">
    <meta http-equiv="Pragma" content="no-cache">
    <meta http-equiv="Expires" content="0">
    <title>Raise a New Complaint</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
    <script src="<%= request.getContextPath() %>/js/script.js" defer></script>
</head>
<body>

<header class="site-header">
    <div class="header-inner">
        <a class="brand" href="<%= request.getContextPath() %>/citizenDashboard">Grievance System</a>
        <nav class="nav-links">
            <a href="<%= request.getContextPath() %>/citizenDashboard">Dashboard</a>
            <a class="active" href="<%= request.getContextPath() %>/complaint.jsp">Register Complaint</a>
            <a href="<%= request.getContextPath() %>/myComplaints">My Complaints</a>
            <a href="<%= request.getContextPath() %>/changePassword">Change Password</a>
            <a href="<%= request.getContextPath() %>/logout">Logout</a>
        </nav>
    </div>
</header>

<main class="page">
    <div class="form-card complaint-card">
        <div class="complaint-intro">
            <p class="eyebrow">Citizen services</p>
            <h1 class="page-title">Raise a New Complaint</h1>
            <p class="page-subtitle">Share the details of your issue so it can reach the right department.</p>
        </div>

        <form id="complaintForm" action="<%= request.getContextPath() %>/complaint" method="post" enctype="multipart/form-data">
            <div class="form-grid">

                <div class="form-field">
                    <label for="category">Category</label>
                    <select id="category" name="category" required>
                        <option value="">Select Category</option>
                        <option value="Roads">Roads</option>
                        <option value="Water Supply">Water Supply</option>
                        <option value="Electricity">Electricity</option>
                        <option value="Sanitation">Sanitation</option>
                        <option value="Drainage">Drainage</option>
                        <option value="Garbage Collection">Garbage Collection</option>
                        <option value="Street Lighting">Street Lighting</option>
                    </select>
                </div>

                <div class="form-field">
                    <label for="location">Location</label>
                    <input type="text" id="location" name="location" placeholder="Enter location" maxlength="255" required>
                </div>

                <div class="form-field">
                    <label for="departmentId">Department</label>
                    <select id="departmentId" name="departmentId" required>
                        <option value="">Select Department</option>
                        <option value="1">Roads</option>
                        <option value="2">Water Supply</option>
                        <option value="3">Electricity</option>
                        <option value="4">Sanitation</option>
                        <option value="5">Drainage</option>
                        <option value="6">Garbage Collection</option>
                        <option value="7">Street Lighting</option>
                    </select>
                </div>

                <div class="form-field">
                    <label for="title">Subject</label>
                    <input type="text" id="title" name="title" maxlength="255" required>
                </div>

                <div class="form-field full">
                    <label for="description">Description</label>
                    <textarea id="description" name="description" rows="5" maxlength="5000" required></textarea>
                </div>

                <div class="form-field">
                    <label for="priority">Priority</label>
                    <select id="priority" name="priority" required>
                        <option value="">Select Priority</option>
                        <option value="HIGH">High</option>
                        <option value="MEDIUM">Medium</option>
                        <option value="LOW">Low</option>
                    </select>
                    <div class="field-note">Priority is stored with the complaint and shown to officers and administrators.</div>
                </div>

                <div class="form-field full">
                    <section class="image-upload-section" aria-labelledby="imageUploadTitle">
                        <div class="upload-heading">
                            <span class="upload-heading-icon" aria-hidden="true">
                                <svg viewBox="0 0 24 24"><path d="M4 7h3l1.5-2h7L17 7h3a1 1 0 0 1 1 1v10a1 1 0 0 1-1 1H4a1 1 0 0 1-1-1V8a1 1 0 0 1 1-1Z"/><circle cx="12" cy="13" r="4"/></svg>
                            </span>
                            <div>
                                <h2 id="imageUploadTitle">Add a photo <span class="required-label">Required</span></h2>
                                <p>Attach a photo to help the department understand and resolve your complaint.</p>
                            </div>
                        </div>

                        <div class="upload-options">
                            <div class="upload-option">
                                <span class="upload-option-icon" aria-hidden="true">
                                    <svg viewBox="0 0 24 24"><rect x="3" y="4" width="18" height="16" rx="2"/><circle cx="8.5" cy="9" r="1.5"/><path d="m21 15-5-5L5 20"/></svg>
                                </span>
                                <div class="upload-option-copy">
                                    <h3>Choose an image</h3>
                                    <p>Browse Gallery, Files, Drive or Photos. On mobile, available device sources appear in the picker.</p>
                                </div>
                                <label for="browserImage" class="upload-label">Browse files</label>
                                <input type="file" id="browserImage" name="browserImage" accept="image/jpeg,image/png,image/gif,image/webp" class="visually-hidden">
                            </div>

                            <div class="upload-option">
                                <span class="upload-option-icon camera-icon" aria-hidden="true">
                                    <svg viewBox="0 0 24 24"><path d="M4 7h3l1.5-2h7L17 7h3a1 1 0 0 1 1 1v10a1 1 0 0 1-1 1H4a1 1 0 0 1-1-1V8a1 1 0 0 1 1-1Z"/><circle cx="12" cy="13" r="4"/><path d="M18 9h.01"/></svg>
                                </span>
                                <div class="upload-option-copy">
                                    <h3>Take a photo</h3>
                                    <p>Use live camera access where supported, or open your mobile camera picker.</p>
                                </div>
                                <button type="button" class="upload-label camera-btn" id="openCameraBtn">Open camera</button>
                                <input type="file" id="cameraImage" name="cameraImage" accept="image/jpeg,image/png,image/gif,image/webp" capture="environment" class="visually-hidden">
                            </div>
                        </div>

                        <div id="cameraPanel" class="camera-panel" hidden>
                            <video id="cameraPreview" autoplay playsinline></video>
                            <div class="camera-actions">
                                <button type="button" class="upload-label" id="capturePhotoBtn">Capture photo</button>
                                <button type="button" class="upload-label upload-label-secondary" id="closeCameraBtn">Close camera</button>
                            </div>
                        </div>

                        <div class="image-preview-card">
                            <div class="preview-image-wrap">
                                <img id="imagePreview" class="image-preview" alt="Selected image preview" hidden>
                                <div class="preview-placeholder" aria-hidden="true">
                                    <span class="preview-add-icon">
                                        <svg viewBox="0 0 24 24"><path d="M12 5v14M5 12h14"/></svg>
                                    </span>
                                    <strong>Your image preview will appear here</strong>
                                </div>
                            </div>
                            <div class="preview-details">
                                <strong>Image preview</strong>
                                <span id="imageFileNote" class="selected-file-note">No image selected</span>
                            </div>
                        </div>

                        <p class="upload-help">Required. Supported formats: JPG, JPEG, PNG, GIF or WEBP. Maximum file size: 5 MB.</p>
                        <p id="uploadError" class="upload-error" role="alert" hidden></p>
                    </section>
                </div>

                <div class="form-actions full">
                    <input type="submit" value="Submit Complaint">
                </div>
            </div>
        </form>

        <div class="link-row">
            <a href="<%= request.getContextPath() %>/citizenDashboard">Back to Citizen Dashboard</a>
        </div>
    </div>
</main>

</body>
</html>