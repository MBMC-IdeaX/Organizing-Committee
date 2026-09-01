package com.ideax.judging.dto.response;

public class CriterionResultBreakdownResponse {
    private Long criteriaId;
    private String criteriaName;
    private double averageScore;
    private int maxScore;

    public CriterionResultBreakdownResponse() {}

    public CriterionResultBreakdownResponse(Long criteriaId, String criteriaName, double averageScore, int maxScore) {
        this.criteriaId = criteriaId;
        this.criteriaName = criteriaName;
        this.averageScore = averageScore;
        this.maxScore = maxScore;
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

    public double getAverageScore() {
        return averageScore;
    }

    public void setAverageScore(double averageScore) {
        this.averageScore = averageScore;
    }

    public int getMaxScore() {
        return maxScore;
    }

    public void setMaxScore(int maxScore) {
        this.maxScore = maxScore;
    }
}
