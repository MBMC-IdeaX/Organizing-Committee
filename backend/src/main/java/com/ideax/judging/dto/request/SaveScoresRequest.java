package com.ideax.judging.dto.request;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotEmpty;
import java.util.List;

public class SaveScoresRequest {

    @NotEmpty(message = "Scores list cannot be empty")
    @Valid
    private List<CriteriaScoreItem> scores;

    public SaveScoresRequest() {
    }

    public SaveScoresRequest(List<CriteriaScoreItem> scores) {
        this.scores = scores;
    }

    public List<CriteriaScoreItem> getScores() {
        return scores;
    }

    public void setScores(List<CriteriaScoreItem> scores) {
        this.scores = scores;
    }
}
