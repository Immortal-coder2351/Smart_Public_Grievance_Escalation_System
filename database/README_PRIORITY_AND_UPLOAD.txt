SMART GRIEVANCE - PRIORITY AND IMAGE UPLOAD UPDATE

1. Existing database migration
Run once in phpMyAdmin:

ALTER TABLE complaints
    ADD COLUMN priority ENUM('HIGH', 'MEDIUM', 'LOW') NOT NULL DEFAULT 'MEDIUM'
    AFTER category;

Existing complaints automatically receive MEDIUM as the default.

2. Image upload
- Browser/Gallery/Files: use the normal image picker. On a phone, the picker can expose Gallery, Google Photos, Google Drive and other installed file/photo providers supported by the device/browser.
- Camera: use the Take Photo with Camera option. The page first tries the browser camera and falls back to a mobile camera input when live camera access is unavailable.
- Accepted image types: JPG, JPEG, PNG, GIF, WEBP.
- Maximum image size: 5 MB.

3. Java compilation
Because ComplaintServlet and the DAO/model classes changed, compile the Java source after deployment using the same Tomcat 11 servlet-api.jar and MySQL connector you use on your machine.
