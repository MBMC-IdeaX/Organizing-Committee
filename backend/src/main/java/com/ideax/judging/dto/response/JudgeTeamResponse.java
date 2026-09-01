package com.ideax.judging.dto.response;

import com.ideax.judging.entity.JudgingStatus;

public class JudgeTeamResponse {

    private Long id;
    private String teamName;
    private String projectName;
    private String idea;
    private Integer displayOrder;
    private JudgingStatus status;
    private Integer totalScore;
    private Integer totalMaxScore;

    public JudgeTeamResponse() {
    }

    public JudgeTeamResponse(Long id, String teamName, String projectName, String idea, Integer displayOrder, JudgingStatus status, Integer totalScore, Integer totalMaxScore) {
        this.id = id;
        this.teamName = teamName;
        this.projectName = projectName;
        this.idea = idea;
        this.displayOrder = displayOrder;
        this.status = status;
        this.totalScore = totalScore;
        this.totalMaxScore = totalMaxScore;
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

    public JudgingStatus getStatus() {
        return status;
    }

    public void setStatus(JudgingStatus status) {
        this.status = status;
    }

    public Integer getTotalScore() {
        return totalScore;
    }

    public void setTotalScore(Integer totalScore) {
        this.totalScore = totalScore;
    }

    public Integer getTotalMaxScore() {
        return totalMaxScore;
    }

    public void setTotalMaxScore(Integer totalMaxScore) {
        this.totalMaxScore = totalMaxScore;
    }
}
