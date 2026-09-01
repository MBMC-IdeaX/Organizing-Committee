package com.ideax.judging.dto.request;

import jakarta.validation.Valid;
import java.util.List;

public class CompleteJudgingRequest {

    private String comment;

    @Valid
    private List<CriteriaScoreItem> scores;

    public CompleteJudgingRequest() {
    }

    public CompleteJudgingRequest(String comment, List<CriteriaScoreItem> scores) {
        this.comment = comment;
        this.scores = scores;
    }

    public String getComment() {
        return comment;
    }

    public void setComment(String comment) {
        this.comment = comment;
    }

    public List<CriteriaScoreItem> getScores() {
        return scores;
    }

    public void setScores(List<CriteriaScoreItem> scores) {
        this.scores = scores;
    }
}
