
package com.grievance.util;

public class PasswordValidator {

    public static boolean isStrong(String password) {
        if (password == null || password.length() < 12) {
            return false;
        }

        boolean upper = false;
        boolean lower = false;
        boolean digit = false;
        boolean special = false;

        for (int i = 0; i < password.length(); i++) {
            char c = password.charAt(i);

            if (Character.isUpperCase(c)) {
                upper = true;
            } else if (Character.isLowerCase(c)) {
                lower = true;
            } else if (Character.isDigit(c)) {
                digit = true;
            } else if (!Character.isWhitespace(c)) {
                special = true;
            }
        }

        return upper && lower && digit && special;
    }

    public static String getRequirements() {
        return "Password must contain at least 12 characters, "
                + "one uppercase letter, one lowercase letter, "
                + "one number, and one special character.";
    }
}
