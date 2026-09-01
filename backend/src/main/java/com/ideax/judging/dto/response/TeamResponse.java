package com.ideax.judging.dto.response;

import java.time.LocalDateTime;

public class TeamResponse {

    private Long id;
    private String teamName;
    private String projectName;
    private String idea;
    private Integer displayOrder;
    private boolean active;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    public TeamResponse() {
    }

    public TeamResponse(Long id, String teamName, String projectName, String idea, Integer displayOrder, boolean active, LocalDateTime createdAt, LocalDateTime updatedAt) {
        this.id = id;
        this.teamName = teamName;
        this.projectName = projectName;
        this.idea = idea;
        this.displayOrder = displayOrder;
        this.active = active;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getTeamName() {
        return teamName;
    }

    public void setTeamName(String teamName) {
        this.teamName = teamName;
    }

    public String getProjectName() {
        return projectName;
    }

    public void setProjectName(String projectName) {
        this.projectName = projectName;
    }

    public String getIdea() {
        return idea;
    }

    public void setIdea(String idea) {
        this.idea = idea;
    }

    public Integer getDisplayOrder() {
        return displayOrder;
    }

    public void setDisplayOrder(Integer displayOrder) {
        this.displayOrder = displayOrder;
    }

    public boolean isActive() {
        return active;
    }

    public void setActive(boolean active) {
        this.active = active;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public LocalDateTime getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(LocalDateTime updatedAt) {
        this.updatedAt = updatedAt;
    }
}
