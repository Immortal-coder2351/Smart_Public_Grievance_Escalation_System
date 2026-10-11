"use strict";

const showMessage = (message) => {
    window.alert(message);
};

const validateRequiredFields = (form) => {
    const fields = form.querySelectorAll("[required]");

    for (const field of fields) {
        if (!field.value.trim()) {
            showMessage(`${field.name || "This field"} is required.`);
            field.focus();
            return false;
        }
    }

    return true;
};

const validatePasswordMatch = (passwordId, confirmPasswordId) => {
    const password = document.getElementById(passwordId);
    const confirmPassword = document.getElementById(confirmPasswordId);

    if (!password || !confirmPassword) {
        return true;
    }

    if (password.value !== confirmPassword.value) {
        showMessage("Passwords do not match.");
        confirmPassword.focus();
        return false;
    }

    return true;
};

const validateEmail = (email) => {
    const emailPattern =
        /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

    return emailPattern.test(email.value.trim());
};

const validatePhone = (phone) => {
    const phonePattern = /^[0-9]{10,15}$/;

    return phonePattern.test(phone.value.trim());
};

document.addEventListener("DOMContentLoaded", () => {

    const forms = document.querySelectorAll("form");

    forms.forEach((form) => {

        form.addEventListener("submit", (event) => {

            if (!validateRequiredFields(form)) {
                event.preventDefault();
                return;
            }

            const email = form.querySelector(
                'input[type="email"]'
            );

            if (email && !validateEmail(email)) {
                showMessage("Please enter a valid email address.");
                email.focus();
                event.preventDefault();
                return;
            }

            const phone = form.querySelector(
                'input[name="phone"]'
            );

            if (phone && phone.value.trim() &&
                !validatePhone(phone)) {

                showMessage(
                    "Please enter a valid phone number."
                );

                phone.focus();
                event.preventDefault();
                return;
            }

            const password =
                document.getElementById("password");

            const confirmPassword =
                document.getElementById("confirmPassword");

            if (password && confirmPassword) {

                if (!validatePasswordMatch(
                    "password",
                    "confirmPassword")) {

                    event.preventDefault();
                    return;
                }
            }
        });
    });
});

const initializeComplaintImageUpload = () => {
    const form = document.getElementById("complaintForm");
    const browserImage = document.getElementById("browserImage");
    const cameraImage = document.getElementById("cameraImage");
    const openCameraBtn = document.getElementById("openCameraBtn");
    const cameraPanel = document.getElementById("cameraPanel");
    const cameraPreview = document.getElementById("cameraPreview");
    const capturePhotoBtn = document.getElementById("capturePhotoBtn");
    const closeCameraBtn = document.getElementById("closeCameraBtn");
    const imagePreview = document.getElementById("imagePreview");
    const imageFileNote = document.getElementById("imageFileNote");
    const uploadError = document.getElementById("uploadError");

    if (!form || !browserImage || !cameraImage || !openCameraBtn ||
        !cameraPanel || !cameraPreview || !capturePhotoBtn ||
        !closeCameraBtn || !imagePreview || !uploadError) {
        return;
    }

    let cameraStream = null;

    const stopCamera = () => {
        if (cameraStream) {
            cameraStream.getTracks().forEach((track) => track.stop());
            cameraStream = null;
        }

        cameraPreview.srcObject = null;
        cameraPanel.hidden = true;
    };

    const showPreview = (file) => {
        if (!file) {
            imagePreview.hidden = true;
            imagePreview.removeAttribute("src");
            return;
        }

        const extension = file.name.split(".").pop().toLowerCase();
        const allowedExtensions = ["jpg", "jpeg", "png", "gif", "webp"];

        if (!file.type.startsWith("image/") ||
            !allowedExtensions.includes(extension)) {
            imagePreview.hidden = true;
            imagePreview.removeAttribute("src");
            uploadError.textContent = "Please select a valid image file.";
            uploadError.hidden = false;
            return;
        }

        if (file.size > 5 * 1024 * 1024) {
            imagePreview.hidden = true;
            imagePreview.removeAttribute("src");
            uploadError.textContent = "Image size must be 5 MB or less.";
            uploadError.hidden = false;
            return;
        }

        uploadError.hidden = true;
        imagePreview.src = URL.createObjectURL(file);
        imagePreview.hidden = false;
        imageFileNote.textContent = `Selected image: ${file.name}`;
    };

    browserImage.addEventListener("change", () => {
        if (browserImage.files.length > 0) {
            cameraImage.value = "";
            showPreview(browserImage.files[0]);
        }
    });

    cameraImage.addEventListener("change", () => {
        if (cameraImage.files.length > 0) {
            browserImage.value = "";
            showPreview(cameraImage.files[0]);
        }
    });

    openCameraBtn.addEventListener("click", async () => {
        if (!navigator.mediaDevices || !navigator.mediaDevices.getUserMedia) {
            cameraImage.click();
            return;
        }

        try {
            cameraStream = await navigator.mediaDevices.getUserMedia({
                video: { facingMode: { ideal: "environment" } },
                audio: false
            });

            cameraPreview.srcObject = cameraStream;
            cameraPanel.hidden = false;
        } catch (error) {
            cameraImage.click();
        }
    });

    capturePhotoBtn.addEventListener("click", () => {
        if (!cameraStream) {
            return;
        }

        const canvas = document.createElement("canvas");
        canvas.width = cameraPreview.videoWidth || 1280;
        canvas.height = cameraPreview.videoHeight || 720;

        const context = canvas.getContext("2d");
        context.drawImage(cameraPreview, 0, 0, canvas.width, canvas.height);

        canvas.toBlob((blob) => {
            if (!blob) {
                showMessage("Unable to capture the photo. Please try again.");
                return;
            }

            const file = new File(
                [blob],
                `camera-${Date.now()}.jpg`,
                { type: "image/jpeg" }
            );

            const dataTransfer = new DataTransfer();
            dataTransfer.items.add(file);
            cameraImage.files = dataTransfer.files;
            browserImage.value = "";

            showPreview(file);
            stopCamera();
        }, "image/jpeg", 0.9);
    });

    closeCameraBtn.addEventListener("click", stopCamera);

    form.addEventListener("submit", (event) => {
        const browserFile = browserImage.files[0];
        const cameraFile = cameraImage.files[0];
        const file = browserFile || cameraFile;

        if (!file) {
            event.preventDefault();
            uploadError.textContent = "Please attach a complaint image before submitting.";
            uploadError.hidden = false;
            uploadError.scrollIntoView({ behavior: "smooth", block: "center" });
            openCameraBtn.focus();
            stopCamera();
            return;
        }

        const extension = file.name.split(".").pop().toLowerCase();
        const allowedExtensions = ["jpg", "jpeg", "png", "gif", "webp"];

        if (!file.type.startsWith("image/") ||
            !allowedExtensions.includes(extension)) {
            event.preventDefault();
            uploadError.textContent = "Please upload a valid image file.";
            uploadError.hidden = false;
            uploadError.scrollIntoView({ behavior: "smooth", block: "center" });
            return;
        }

        if (file.size > 5 * 1024 * 1024) {
            event.preventDefault();
            uploadError.textContent = "Image size must be 5 MB or less.";
            uploadError.hidden = false;
            uploadError.scrollIntoView({ behavior: "smooth", block: "center" });
            return;
        }

        uploadError.hidden = true;
        stopCamera();
    });

    window.addEventListener("beforeunload", stopCamera);
};


document.addEventListener("DOMContentLoaded", initializeComplaintImageUpload);

document.addEventListener("DOMContentLoaded", () => {
    const form = document.getElementById("changePasswordForm");
    const newPassword = document.getElementById("newPassword");
    const confirmNewPassword =
        document.getElementById("confirmNewPassword");

    if (!form || !newPassword || !confirmNewPassword) {
        return;
    }

    form.addEventListener("submit", (event) => {
        if (newPassword.value !== confirmNewPassword.value) {
            event.preventDefault();
            showMessage("The new password and confirmation do not match.");
            confirmNewPassword.focus();
        }
    });
});
