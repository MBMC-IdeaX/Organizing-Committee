package com.ideax.judging.dto.response;

public class JudgingCriteriaScoreResponse {

    private Long criteriaId;
    private String criteriaName;
    private String description;
    private Integer maxScore;
    private Integer displayOrder;
    private Integer score; // null if not yet entered

    public JudgingCriteriaScoreResponse() {
    }

    public JudgingCriteriaScoreResponse(Long criteriaId, String criteriaName, String description, Integer maxScore, Integer displayOrder, Integer score) {
        this.criteriaId = criteriaId;
        this.criteriaName = criteriaName;
        this.description = description;
        this.maxScore = maxScore;
        this.displayOrder = displayOrder;
        this.score = score;
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

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public Integer getMaxScore() {
        return maxScore;
    }

    public void setMaxScore(Integer maxScore) {
        this.maxScore = maxScore;
    }

    public Integer getDisplayOrder() {
        return displayOrder;
    }

    public void setDisplayOrder(Integer displayOrder) {
        this.displayOrder = displayOrder;
    }

    public Integer getScore() {
        return score;
    }

    public void setScore(Integer score) {
        this.score = score;
    }
}
