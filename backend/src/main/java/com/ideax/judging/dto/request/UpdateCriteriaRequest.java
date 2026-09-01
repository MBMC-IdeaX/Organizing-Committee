package com.ideax.judging.dto.request;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

public class UpdateCriteriaRequest {

    @NotBlank(message = "Criteria name is required")
    @Size(min = 2, max = 150, message = "Criteria name must be between 2 and 150 characters")
    private String name;

    @Size(max = 2000, message = "Description must be less than 2000 characters")
    private String description;

    @NotNull(message = "Max score is required")
    @Min(value = 1, message = "Max score must be greater than 0")
    private Integer maxScore;

    @NotNull(message = "Display order is required")
    @Min(value = 0, message = "Display order must be non-negative")
    private Integer displayOrder;

    public UpdateCriteriaRequest() {
    }

    public UpdateCriteriaRequest(String name, String description, Integer maxScore, Integer displayOrder) {
        this.name = name;
        this.description = description;
        this.maxScore = maxScore;
        this.displayOrder = displayOrder;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
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
}
