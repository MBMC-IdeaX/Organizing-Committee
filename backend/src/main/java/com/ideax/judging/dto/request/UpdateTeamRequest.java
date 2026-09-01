package com.ideax.judging.dto.request;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

public class UpdateTeamRequest {

    @NotBlank(message = "Team name is required")
    @Size(min = 2, max = 150, message = "Team name must be between 2 and 150 characters")
    private String teamName;

    @NotBlank(message = "Project name is required")
    @Size(min = 2, max = 200, message = "Project name must be between 2 and 200 characters")
    private String projectName;

    @Size(max = 2000, message = "Idea description must be less than 2000 characters")
    private String idea;

    @NotNull(message = "Display order is required")
    @Min(value = 0, message = "Display order must be non-negative")
    private Integer displayOrder;

    public UpdateTeamRequest() {
    }

    public UpdateTeamRequest(String teamName, String projectName, String idea, Integer displayOrder) {
        this.teamName = teamName;
        this.projectName = projectName;
        this.idea = idea;
        this.displayOrder = displayOrder;
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
}
