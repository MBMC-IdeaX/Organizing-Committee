package com.ideax.judging.entity;

import jakarta.persistence.*;

@Entity
@Table(name = "scores", uniqueConstraints = {
    @UniqueConstraint(name = "uk_judging_criteria", columnNames = {"judging_id", "criteria_id"})
})
public class Score extends BaseEntity {

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "judging_id", nullable = false, foreignKey = @ForeignKey(name = "fk_scores_judging"))
    private Judging judging;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "criteria_id", nullable = false, foreignKey = @ForeignKey(name = "fk_scores_criteria"))
    private Criteria criteria;

    @Column(name = "score", nullable = false)
    private Integer score;

    public Score() {
    }

    public Score(Judging judging, Criteria criteria, Integer score) {
        this.judging = judging;
        this.criteria = criteria;
        this.score = score;
    }

    public Judging getJudging() {
        return judging;
    }

    public void setJudging(Judging judging) {
        this.judging = judging;
    }

    public Criteria getCriteria() {
        return criteria;
    }

    public void setCriteria(Criteria criteria) {
        this.criteria = criteria;
    }

    public Integer getScore() {
        return score;
    }

    public void setScore(Integer score) {
        this.score = score;
    }
}
