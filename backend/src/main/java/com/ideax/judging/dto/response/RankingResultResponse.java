package com.ideax.judging.dto.response;

public class RankingResultResponse {
    private int rank;
    private Long teamId;
    private String teamName;
    private String projectName;
    private int aggregateTotal;
    private int aggregateMaxScore;
    private double averageScore;
    private int averageMaxScore;
    private double percentage;
    private long completedJudges;
    private long totalJudges;
    private boolean complete;

    public RankingResultResponse() {}

    public RankingResultResponse(int rank, Long teamId, String teamName, String projectName, int aggregateTotal,
                                 int aggregateMaxScore, double averageScore, int averageMaxScore, double percentage,
                                 long completedJudges, long totalJudges, boolean complete) {
        this.rank = rank;
        this.teamId = teamId;
        this.teamName = teamName;
        this.projectName = projectName;
        this.aggregateTotal = aggregateTotal;
        this.aggregateMaxScore = aggregateMaxScore;
        this.averageScore = averageScore;
        this.averageMaxScore = averageMaxScore;
        this.percentage = percentage;
        this.completedJudges = completedJudges;
        this.totalJudges = totalJudges;
        this.complete = complete;
    }

    public int getRank() {
        return rank;
    }

    public void setRank(int rank) {
        this.rank = rank;
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

    public long getCompletedJudges() {
        return completedJudges;
    }

    public void setCompletedJudges(long completedJudges) {
        this.completedJudges = completedJudges;
    }

    public long getTotalJudges() {
        return totalJudges;
    }

    public void setTotalJudges(long totalJudges) {
        this.totalJudges = totalJudges;
    }

    public boolean isComplete() {
        return complete;
    }

    public void setComplete(boolean complete) {
        this.complete = complete;
    }
}
