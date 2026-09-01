package com.ideax.judging.dto.response;

import java.util.List;

public class TeamResultResponse {
    private Long teamId;
    private String teamName;
    private String projectName;
    private String idea;
    private int rank;
    private int aggregateTotal;
    private int aggregateMaxScore;
    private double averageScore;
    private int averageMaxScore;
    private double percentage;
    private boolean complete;
    private List<JudgeScoreBreakdownResponse> judgeBreakdowns;
    private List<CriterionResultBreakdownResponse> criterionBreakdowns;

    public TeamResultResponse() {}

    public TeamResultResponse(Long teamId, String teamName, String projectName, String idea, int rank,
                              int aggregateTotal, int aggregateMaxScore, double averageScore, int averageMaxScore,
                              double percentage, boolean complete, List<JudgeScoreBreakdownResponse> judgeBreakdowns,
                              List<CriterionResultBreakdownResponse> criterionBreakdowns) {
        this.teamId = teamId;
        this.teamName = teamName;
        this.projectName = projectName;
        this.idea = idea;
        this.rank = rank;
        this.aggregateTotal = aggregateTotal;
        this.aggregateMaxScore = aggregateMaxScore;
        this.averageScore = averageScore;
        this.averageMaxScore = averageMaxScore;
        this.percentage = percentage;
        this.complete = complete;
        this.judgeBreakdowns = judgeBreakdowns;
        this.criterionBreakdowns = criterionBreakdowns;
    }

    public Long getTeamId() {
        return teamId;
    }

    public void setTeamId(Long teamId) {
        this.teamId = teamId;
    }

    public String getTeamName() {
        return teamName;
    }

    public void setTeamName(String teamName) {
        this.teamName = teamName;
    }

    public String getProjectName() {
        return projectName;
    }

    public void setProjectName(String projectName) {
        this.projectName = projectName;
    }

    public String getIdea() {
        return idea;
    }

    public void setIdea(String idea) {
        this.idea = idea;
    }

    public int getRank() {
        return rank;
    }

    public void setRank(int rank) {
        this.rank = rank;
    }

    public int getAggregateTotal() {
        return aggregateTotal;
    }

    public void setAggregateTotal(int aggregateTotal) {
        this.aggregateTotal = aggregateTotal;
    }

    public int getAggregateMaxScore() {
        return aggregateMaxScore;
    }

    public void setAggregateMaxScore(int aggregateMaxScore) {
        this.aggregateMaxScore = aggregateMaxScore;
    }

    public double getAverageScore() {
        return averageScore;
    }

    public void setAverageScore(double averageScore) {
        this.averageScore = averageScore;
    }

    public int getAverageMaxScore() {
        return averageMaxScore;
    }

    public void setAverageMaxScore(int averageMaxScore) {
        this.averageMaxScore = averageMaxScore;
    }

    public double getPercentage() {
        return percentage;
    }

    public void setPercentage(double percentage) {
        this.percentage = percentage;
    }

    public boolean isComplete() {
        return complete;
    }

    public void setComplete(boolean complete) {
        this.complete = complete;
    }

    public List<JudgeScoreBreakdownResponse> getJudgeBreakdowns() {
        return judgeBreakdowns;
    }

    public void setJudgeBreakdowns(List<JudgeScoreBreakdownResponse> judgeBreakdowns) {
        this.judgeBreakdowns = judgeBreakdowns;
    }

    public List<CriterionResultBreakdownResponse> getCriterionBreakdowns() {
        return criterionBreakdowns;
    }

    public void setCriterionBreakdowns(List<CriterionResultBreakdownResponse> criterionBreakdowns) {
        this.criterionBreakdowns = criterionBreakdowns;
    }
}
