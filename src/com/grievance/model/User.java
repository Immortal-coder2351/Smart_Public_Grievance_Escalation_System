package com.grievance.model;

public class User {

    private int userId;
    private String name;
    private String email;
    private String phone;
    private String username;
    private String password;
    private String role;
    private Integer officerLevel;
    private Integer departmentId;

    public User() {
    }

    public User(String name, String email, String phone,
                String username, String password,
                String role, Integer officerLevel,
                Integer departmentId) {

        this.name = name;
        this.email = email;
        this.phone = phone;
        this.username = username;
        this.password = password;
        this.role = role;
        this.officerLevel = officerLevel;
        this.departmentId = departmentId;
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public String getRole() {
        return role;
    }

    public void setRole(String role) {
        this.role = role;
    }

    public Integer getOfficerLevel() {
        return officerLevel;
    }

    public void setOfficerLevel(Integer officerLevel) {
        this.officerLevel = officerLevel;
    }

    public Integer getDepartmentId() {
        return departmentId;
    }

    public void setDepartmentId(Integer departmentId) {
        this.departmentId = departmentId;
    }
}