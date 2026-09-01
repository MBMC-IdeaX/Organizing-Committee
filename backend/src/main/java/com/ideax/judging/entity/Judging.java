package com.ideax.judging.entity;

import jakarta.persistence.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "judgings", uniqueConstraints = {
    @UniqueConstraint(name = "uk_judge_team", columnNames = {"judge_id", "team_id"})
}, indexes = {
    @Index(name = "idx_judgings_status", columnList = "status")
})
public class Judging extends BaseEntity {

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "judge_id", nullable = false, foreignKey = @ForeignKey(name = "fk_judgings_judge"))
    private User judge;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "team_id", nullable = false, foreignKey = @ForeignKey(name = "fk_judgings_team"))
    private Team team;

    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false, length = 30)
    private JudgingStatus status = JudgingStatus.NOT_STARTED;

    @Column(name = "comment", columnDefinition = "TEXT")
    private String comment;

    @Column(name = "completed_at")
    private LocalDateTime completedAt;

    @OneToMany(mappedBy = "judging", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<Score> scores = new ArrayList<>();

    public Judging() {
    }

    public Judging(User judge, Team team, JudgingStatus status, String comment) {
        this.judge = judge;
        this.team = team;
        this.status = status;
        this.comment = comment;
    }

    public User getJudge() {
        return judge;
    }

    public void setJudge(User judge) {
        this.judge = judge;
    }

    public Team getTeam() {
        return team;
    }

    public void setTeam(Team team) {
        this.team = team;
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

    public List<Score> getScores() {
        return scores;
    }

    public void setScores(List<Score> scores) {
        this.scores = scores;
    }

    public void addScore(Score score) {
        scores.add(score);
        score.setJudging(this);
    }
}
