package com.ideax.judging.dto.response;

public class AdminDashboardSummaryResponse {

    private long totalTeams;
    private long activeTeams;
    private long totalCriteria;
    private long activeCriteria;
    private int totalMaxScore; // Sum of maxScore where active = true
    private long totalJudges;
    private long activeJudges;
    private boolean readyForJudging;

    public AdminDashboardSummaryResponse() {
    }

    public AdminDashboardSummaryResponse(long totalTeams, long activeTeams, long totalCriteria, long activeCriteria, int totalMaxScore, long totalJudges, long activeJudges, boolean readyForJudging) {
        this.totalTeams = totalTeams;
        this.activeTeams = activeTeams;
        this.totalCriteria = totalCriteria;
        this.activeCriteria = activeCriteria;
        this.totalMaxScore = totalMaxScore;
        this.totalJudges = totalJudges;
        this.activeJudges = activeJudges;
        this.readyForJudging = readyForJudging;
    }

    public long getTotalTeams() {
        return totalTeams;
    }

    public void setTotalTeams(long totalTeams) {
        this.totalTeams = totalTeams;
    }

    public long getActiveTeams() {
        return activeTeams;
    }

    public void setActiveTeams(long activeTeams) {
        this.activeTeams = activeTeams;
    }

    public long getTotalCriteria() {
        return totalCriteria;
    }

    public void setTotalCriteria(long totalCriteria) {
        this.totalCriteria = totalCriteria;
    }

    public long getActiveCriteria() {
        return activeCriteria;
    }

    public void setActiveCriteria(long activeCriteria) {
        this.activeCriteria = activeCriteria;
    }

    public int getTotalMaxScore() {
        return totalMaxScore;
    }

    public void setTotalMaxScore(int totalMaxScore) {
        this.totalMaxScore = totalMaxScore;
    }

    public long getTotalJudges() {
        return totalJudges;
    }

    public void setTotalJudges(long totalJudges) {
        this.totalJudges = totalJudges;
    }

    public long getActiveJudges() {
        return activeJudges;
    }

    public void setActiveJudges(long activeJudges) {
        this.activeJudges = activeJudges;
    }

    public boolean isReadyForJudging() {
        return readyForJudging;
    }

    public void setReadyForJudging(boolean readyForJudging) {
        this.readyForJudging = readyForJudging;
    }
}
