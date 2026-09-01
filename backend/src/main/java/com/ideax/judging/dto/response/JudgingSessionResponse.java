package com.ideax.judging.dto.response;

import com.ideax.judging.entity.JudgingStatus;
import java.time.LocalDateTime;
import java.util.List;

public class JudgingSessionResponse {

    private Long judgingId;
    private Long teamId;
    private String teamName;
    private String projectName;
    private String idea;
    private Integer displayOrder;
    private JudgingStatus status;
    private String comment;
    private LocalDateTime completedAt;
    private List<JudgingCriteriaScoreResponse> criteriaScores;
    private int totalScore;
    private int totalMaxScore;

    public JudgingSessionResponse() {
    }

    public JudgingSessionResponse(Long judgingId, Long teamId, String teamName, String projectName, String idea, Integer displayOrder, JudgingStatus status, String comment, LocalDateTime completedAt, List<JudgingCriteriaScoreResponse> criteriaScores, int totalScore, int totalMaxScore) {
        this.judgingId = judgingId;
        this.teamId = teamId;
        this.teamName = teamName;
        this.projectName = projectName;
        this.idea = idea;
        this.displayOrder = displayOrder;
        this.status = status;
        this.comment = comment;
        this.completedAt = completedAt;
        this.criteriaScores = criteriaScores;
        this.totalScore = totalScore;
        this.totalMaxScore = totalMaxScore;
    }

    public Long getJudgingId() {
        return judgingId;
    }

    public void setJudgingId(Long judgingId) {
        this.judgingId = judgingId;
    }

    public Long getTeamId() {
        return teamId;
    }

    public void setTeamId(Long teamId) {
        this.teamId = teamId;
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

    public String getComment() {
        return comment;
    }

    public void setComment(String comment) {
        this.comment = comment;
    }

    public LocalDateTime getCompletedAt() {
        return completedAt;
    }

    public void setCompletedAt(LocalDateTime completedAt) {
        this.completedAt = completedAt;
    }

    public List<JudgingCriteriaScoreResponse> getCriteriaScores() {
        return criteriaScores;
    }

    public void setCriteriaScores(List<JudgingCriteriaScoreResponse> criteriaScores) {
        this.criteriaScores = criteriaScores;
    }

    public int getTotalScore() {
        return totalScore;
    }

    public void setTotalScore(int totalScore) {
        this.totalScore = totalScore;
    }

    public int getTotalMaxScore() {
        return totalMaxScore;
    }

    public void setTotalMaxScore(int totalMaxScore) {
        this.totalMaxScore = totalMaxScore;
    }
}
