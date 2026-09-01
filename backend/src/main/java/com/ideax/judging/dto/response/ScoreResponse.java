package com.ideax.judging.dto.response;

import java.time.LocalDateTime;

public class ScoreResponse {

    private Long id;
    private Long judgingId;
    private Long criteriaId;
    private String criteriaName;
    private Integer score;
    private Integer maxScore;
    private LocalDateTime createdAt;

    public ScoreResponse() {
    }

    public ScoreResponse(Long id, Long judgingId, Long criteriaId, String criteriaName, Integer score, Integer maxScore, LocalDateTime createdAt) {
        this.id = id;
        this.judgingId = judgingId;
        this.criteriaId = criteriaId;
        this.criteriaName = criteriaName;
        this.score = score;
        this.maxScore = maxScore;
        this.createdAt = createdAt;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public Long getJudgingId() {
        return judgingId;
    }

    public void setJudgingId(Long judgingId) {
        this.judgingId = judgingId;
    }

    public Long getCriteriaId() {
        return criteriaId;
    }

    public void setCriteriaId(Long criteriaId) {
        this.criteriaId = criteriaId;
    }

    public String getCriteriaName() {
        return criteriaName;
    }

    public void setCriteriaName(String criteriaName) {
        this.criteriaName = criteriaName;
    }

    public Integer getScore() {
        return score;
    }

    public void setScore(Integer score) {
        this.score = score;
    }

    public Integer getMaxScore() {
        return maxScore;
    }

    public void setMaxScore(Integer maxScore) {
        this.maxScore = maxScore;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }
}
