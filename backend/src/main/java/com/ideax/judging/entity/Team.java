package com.ideax.judging.entity;

import jakarta.persistence.*;

@Entity
@Table(name = "teams", indexes = {
    @Index(name = "idx_teams_display_order", columnList = "display_order, active")
})
public class Team extends BaseEntity {

    @Column(name = "team_name", nullable = false, length = 150)
    private String teamName;

    @Column(name = "project_name", nullable = false, length = 200)
    private String projectName;

    @Column(name = "idea", columnDefinition = "TEXT")
    private String idea;

    @Column(name = "display_order", nullable = false)
    private Integer displayOrder = 0;

    @Column(name = "active", nullable = false)
    private boolean active = true;

    public Team() {
    }

    public Team(String teamName, String projectName, String idea, Integer displayOrder, boolean active) {
        this.teamName = teamName;
        this.projectName = projectName;
        this.idea = idea;
        this.displayOrder = displayOrder;
        this.active = active;
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
}
