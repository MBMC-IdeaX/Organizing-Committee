package com.ideax.judging.dto.response;

import java.util.Map;

public class JudgeScoreBreakdownResponse {
    private String judgeUsername;
    private int totalScore;
    private int maxScore;
    private Map<String, Integer> criterionScores;
    private String comment;

    public JudgeScoreBreakdownResponse() {}

    public JudgeScoreBreakdownResponse(String judgeUsername, int totalScore, int maxScore,
                                       Map<String, Integer> criterionScores, String comment) {
        this.judgeUsername = judgeUsername;
        this.totalScore = totalScore;
        this.maxScore = maxScore;
        this.criterionScores = criterionScores;
        this.comment = comment;
    }

    public String getJudgeUsername() {
        return judgeUsername;
    }

    public void setJudgeUsername(String judgeUsername) {
        this.judgeUsername = judgeUsername;
    }

    public int getTotalScore() {
        return totalScore;
    }

    public void setTotalScore(int totalScore) {
        this.totalScore = totalScore;
    }

    public int getMaxScore() {
        return maxScore;
    }

    public void setMaxScore(int maxScore) {
        this.maxScore = maxScore;
    }

    public Map<String, Integer> getCriterionScores() {
        return criterionScores;
    }

    public void setCriterionScores(Map<String, Integer> criterionScores) {
        this.criterionScores = criterionScores;
    }

    public String getComment() {
        return comment;
    }

    public void setComment(String comment) {
        this.comment = comment;
    }
}
