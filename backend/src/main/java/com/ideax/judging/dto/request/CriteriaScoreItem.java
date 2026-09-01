package com.ideax.judging.dto.request;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;

public class CriteriaScoreItem {

    @NotNull(message = "Criteria ID is required")
    private Long criteriaId;

    @NotNull(message = "Score is required")
    @Min(value = 0, message = "Score cannot be negative")
    private Integer score;

    public CriteriaScoreItem() {
    }

    public CriteriaScoreItem(Long criteriaId, Integer score) {
        this.criteriaId = criteriaId;
        this.score = score;
    }

    public Long getCriteriaId() {
        return criteriaId;
    }

    public void setCriteriaId(Long criteriaId) {
        this.criteriaId = criteriaId;
    }

    public Integer getScore() {
        return score;
    }

    public void setScore(Integer score) {
        this.score = score;
    }
}
