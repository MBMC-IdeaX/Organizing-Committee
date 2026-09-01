package com.ideax.judging.entity;

import jakarta.persistence.*;

@Entity
@Table(name = "criteria", indexes = {
    @Index(name = "idx_criteria_display_order", columnList = "display_order, active")
})
public class Criteria extends BaseEntity {

    @Column(name = "name", nullable = false, length = 150)
    private String name;

    @Column(name = "description", columnDefinition = "TEXT")
    private String description;

    @Column(name = "max_score", nullable = false)
    private Integer maxScore;

    @Column(name = "display_order", nullable = false)
    private Integer displayOrder = 0;

    @Column(name = "active", nullable = false)
    private boolean active = true;

    public Criteria() {
    }

    public Criteria(String name, String description, Integer maxScore, Integer displayOrder, boolean active) {
        this.name = name;
        this.description = description;
        this.maxScore = maxScore;
        this.displayOrder = displayOrder;
        this.active = active;
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

    public boolean isActive() {
        return active;
    }

    public void setActive(boolean active) {
        this.active = active;
    }
}
