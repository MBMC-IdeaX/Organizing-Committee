package com.ideax.judging.dto.response;

import com.ideax.judging.entity.JudgingStatus;
import java.time.LocalDateTime;
import java.util.List;

public class JudgingResponse {

    private Long id;
    private Long judgeId;
    private String judgeUsername;
    private Long teamId;
    private String teamName;
    private String projectName;
    private JudgingStatus status;
    private String comment;
    private LocalDateTime completedAt;
    private LocalDateTime createdAt;
    private List<ScoreResponse> scores;

    public JudgingResponse() {
    }

    public JudgingResponse(Long id, Long judgeId, String judgeUsername, Long teamId, String teamName, String projectName, JudgingStatus status, String comment, LocalDateTime completedAt, LocalDateTime createdAt, List<ScoreResponse> scores) {
        this.id = id;
        this.judgeId = judgeId;
        this.judgeUsername = judgeUsername;
        this.teamId = teamId;
        this.teamName = teamName;
        this.projectName = projectName;
        this.status = status;
        this.comment = comment;
        this.completedAt = completedAt;
        this.createdAt = createdAt;
        this.scores = scores;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public Long getJudgeId() {
        return judgeId;
    }

    public void setJudgeId(Long judgeId) {
        this.judgeId = judgeId;
    }

    public String getJudgeUsername() {
        return judgeUsername;
    }

    public void setJudgeUsername(String judgeUsername) {
        this.judgeUsername = judgeUsername;
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

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public List<ScoreResponse> getScores() {
        return scores;
    }

    public void setScores(List<ScoreResponse> scores) {
        this.scores = scores;
    }
}
