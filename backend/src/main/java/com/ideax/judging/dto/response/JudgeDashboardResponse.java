package com.ideax.judging.dto.response;

public class JudgeDashboardResponse {

    private long totalTeams;
    private long completedTeams;
    private long remainingTeams;
    private double progressPercentage;
    private JudgeTeamResponse nextTeam; // null if all completed or no active teams

    public JudgeDashboardResponse() {
    }

    public JudgeDashboardResponse(long totalTeams, long completedTeams, long remainingTeams, double progressPercentage, JudgeTeamResponse nextTeam) {
        this.totalTeams = totalTeams;
        this.completedTeams = completedTeams;
        this.remainingTeams = remainingTeams;
        this.progressPercentage = progressPercentage;
        this.nextTeam = nextTeam;
    }

    public long getTotalTeams() {
        return totalTeams;
    }

    public void setTotalTeams(long totalTeams) {
        this.totalTeams = totalTeams;
    }

    public long getCompletedTeams() {
        return completedTeams;
    }

    public void setCompletedTeams(long completedTeams) {
        this.completedTeams = completedTeams;
    }

    public long getRemainingTeams() {
        return remainingTeams;
    }

    public void setRemainingTeams(long remainingTeams) {
        this.remainingTeams = remainingTeams;
    }

    public double getProgressPercentage() {
        return progressPercentage;
    }

    public void setProgressPercentage(double progressPercentage) {
        this.progressPercentage = progressPercentage;
    }

    public JudgeTeamResponse getNextTeam() {
        return nextTeam;
    }

    public void setNextTeam(JudgeTeamResponse nextTeam) {
        this.nextTeam = nextTeam;
    }
}
