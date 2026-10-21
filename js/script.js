"use strict";

const showMessage = (message) => {
    window.alert(message);
};

const validateRequiredFields = (form) => {
    const fields = form.querySelectorAll("[required]");

    for (const field of fields) {
        if (!String(field.value || "").trim()) {
            showMessage(`${field.labels?.[0]?.textContent || field.name || "This field"} is required.`);
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

const isStrongPassword = (password) => {
    return password.length >= 12 &&
        /\p{Lu}/u.test(password) &&
        /\p{Ll}/u.test(password) &&
        /\d/u.test(password) &&
        /[^\p{L}\p{N}\s]/u.test(password);
};

const validateEmail = (email) => {
    const emailPattern = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return emailPattern.test(email.value.trim());
};

const validatePhone = (phone) => {
    const phonePattern = /^[0-9]{10,15}$/;
    return phonePattern.test(phone.value.trim());
};

const initializePasswordStrength = () => {
    const passwordFields = [
        document.getElementById("password"),
        document.getElementById("newPassword")
    ].filter(Boolean);

    passwordFields.forEach((passwordField) => {
        let feedback = passwordField.parentElement.querySelector(
            ".password-strength-feedback"
        );

        if (!feedback) {
            feedback = document.createElement("small");
            feedback.className = "password-strength-feedback";
            feedback.setAttribute("aria-live", "polite");
            passwordField.insertAdjacentElement("afterend", feedback);
        }

        const updateStrength = () => {
            const password = passwordField.value;

            if (!password) {
                feedback.textContent =
                    "Use 12+ characters with uppercase, lowercase, a number, and a special character.";
                feedback.style.color = "";
                return;
            }

            const checks = [
                password.length >= 12,
                /\p{Lu}/u.test(password),
                /\p{Ll}/u.test(password),
                /\d/u.test(password),
                /[^\p{L}\p{N}\s]/u.test(password)
            ];

            const passed = checks.filter(Boolean).length;

            if (passed === 5) {
                feedback.textContent = "Strong password";
                feedback.style.color = "green";
            } else {
                const missing = [];

                if (password.length < 12) {
                    missing.push("at least 12 characters");
                }
                if (!checks[1]) {
                    missing.push("an uppercase letter");
                }
                if (!checks[2]) {
                    missing.push("a lowercase letter");
                }
                if (!checks[3]) {
                    missing.push("a number");
                }
                if (!checks[4]) {
                    missing.push("a special character");
                }

                feedback.textContent = "Password needs: " + missing.join(", ") + ".";
                feedback.style.color = "red";
            }
        };

        passwordField.addEventListener("input", updateStrength);
        updateStrength();
    });
};

const initializeFormValidation = () => {
    const forms = document.querySelectorAll("form");

    forms.forEach((form) => {
        form.addEventListener("submit", (event) => {
            if (!validateRequiredFields(form)) {
                event.preventDefault();
                return;
            }

            const email = form.querySelector('input[type="email"]');

            if (email && !validateEmail(email)) {
                showMessage("Please enter a valid email address.");
                email.focus();
                event.preventDefault();
                return;
            }

            const phone = form.querySelector('input[name="phone"]');

            if (phone && phone.value.trim() && !validatePhone(phone)) {
                showMessage("Please enter a valid phone number.");
                phone.focus();
                event.preventDefault();
                return;
            }

            const password = form.querySelector(
                'input[name="password"], input[name="newPassword"]'
            );

            if (password && !isStrongPassword(password.value)) {
                showMessage(
                    "Password must contain at least 12 characters, one uppercase letter, one lowercase letter, one number, and one special character."
                );
                password.focus();
                event.preventDefault();
                return;
            }

            const registrationPassword = form.querySelector("#password");
            const confirmPassword = form.querySelector("#confirmPassword");

            if (registrationPassword && confirmPassword) {
                if (!validatePasswordMatch("password", "confirmPassword")) {
                    event.preventDefault();
                    return;
                }
            }

            const newPassword = form.querySelector("#newPassword");
            const confirmNewPassword = form.querySelector("#confirmNewPassword");

            if (newPassword && confirmNewPassword) {
                if (!validatePasswordMatch("newPassword", "confirmNewPassword")) {
                    event.preventDefault();
                }
            }
        });
    });
};

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
    let previewObjectUrl = null;

    const stopCamera = () => {
        if (cameraStream) {
            cameraStream.getTracks().forEach((track) => track.stop());
            cameraStream = null;
        }

        cameraPreview.srcObject = null;
        cameraPanel.hidden = true;
    };

    const clearPreview = () => {
        imagePreview.hidden = true;
        imagePreview.removeAttribute("src");

        if (previewObjectUrl) {
            URL.revokeObjectURL(previewObjectUrl);
            previewObjectUrl = null;
        }
    };

    const showPreview = (file) => {
        if (!file) {
            clearPreview();
            return;
        }

        const extension = file.name.split(".").pop().toLowerCase();
        const allowedExtensions = ["jpg", "jpeg", "png", "gif", "webp"];

        if (!file.type.startsWith("image/") ||
            !allowedExtensions.includes(extension)) {
            clearPreview();
            uploadError.textContent = "Please select a valid image file.";
            uploadError.hidden = false;
            return;
        }

        if (file.size > 5 * 1024 * 1024) {
            clearPreview();
            uploadError.textContent = "Image size must be 5 MB or less.";
            uploadError.hidden = false;
            return;
        }

        uploadError.hidden = true;
        clearPreview();

        previewObjectUrl = URL.createObjectURL(file);
        imagePreview.src = previewObjectUrl;
        imagePreview.hidden = false;

        if (imageFileNote) {
            imageFileNote.textContent = `Selected image: ${file.name}`;
        }
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
        if (!navigator.mediaDevices ||
            !navigator.mediaDevices.getUserMedia) {
            cameraImage.click();
            return;
        }

        try {
            stopCamera();

            cameraStream = await navigator.mediaDevices.getUserMedia({
                video: { facingMode: { ideal: "environment" } },
                audio: false
            });

            cameraPreview.srcObject = cameraStream;
            cameraPanel.hidden = false;

            try {
                await cameraPreview.play();
            } catch (error) {
                showMessage("Camera opened. If the preview does not appear, try again.");
            }
        } catch (error) {
            stopCamera();
            cameraImage.click();
        }
    });

    capturePhotoBtn.addEventListener("click", () => {
        if (!cameraStream ||
            !cameraPreview.videoWidth ||
            !cameraPreview.videoHeight) {
            showMessage("Camera is not ready. Please try again.");
            return;
        }

        const canvas = document.createElement("canvas");
        canvas.width = cameraPreview.videoWidth;
        canvas.height = cameraPreview.videoHeight;

        const context = canvas.getContext("2d");

        if (!context) {
            showMessage("Unable to capture the photo. Please try again.");
            return;
        }

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
        const file = browserImage.files[0] || cameraImage.files[0];

        if (!file) {
            event.preventDefault();
            uploadError.textContent =
                "Please attach a complaint image before submitting.";
            uploadError.hidden = false;
            uploadError.scrollIntoView({
                behavior: "smooth",
                block: "center"
            });
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
            uploadError.scrollIntoView({
                behavior: "smooth",
                block: "center"
            });
            return;
        }

        if (file.size > 5 * 1024 * 1024) {
            event.preventDefault();
            uploadError.textContent = "Image size must be 5 MB or less.";
            uploadError.hidden = false;
            uploadError.scrollIntoView({
                behavior: "smooth",
                block: "center"
            });
            return;
        }

        uploadError.hidden = true;
        stopCamera();
    });

    window.addEventListener("beforeunload", stopCamera);
    window.addEventListener("pagehide", stopCamera);
};

document.addEventListener("DOMContentLoaded", () => {
    initializeFormValidation();
    initializePasswordStrength();
    initializeComplaintImageUpload();
});

window.addEventListener("pageshow", (event) => {
    if (event.persisted) {
        window.location.reload();
    }
});