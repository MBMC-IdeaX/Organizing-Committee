package com.ideax.judging.dto.response;

public class ResultsSummaryResponse {
    private long totalTeams;
    private long activeTeams;
    private long totalJudges;
    private long activeJudges;
    private long totalCriteria;
    private long activeCriteria;
    private int totalPossibleScorePerJudge;
    private long totalRequiredEvaluations;
    private long completedEvaluations;
    private long remainingEvaluations;
    private double judgingCompletionPercentage;
    private boolean judgingComplete;
    private boolean resultsAvailable;

    public ResultsSummaryResponse() {}

    public ResultsSummaryResponse(long totalTeams, long activeTeams, long totalJudges, long activeJudges,
                                  long totalCriteria, long activeCriteria, int totalPossibleScorePerJudge,
                                  long totalRequiredEvaluations, long completedEvaluations, long remainingEvaluations,
                                  double judgingCompletionPercentage, boolean judgingComplete, boolean resultsAvailable) {
        this.totalTeams = totalTeams;
        this.activeTeams = activeTeams;
        this.totalJudges = totalJudges;
        this.activeJudges = activeJudges;
        this.totalCriteria = totalCriteria;
        this.activeCriteria = activeCriteria;
        this.totalPossibleScorePerJudge = totalPossibleScorePerJudge;
        this.totalRequiredEvaluations = totalRequiredEvaluations;
        this.completedEvaluations = completedEvaluations;
        this.remainingEvaluations = remainingEvaluations;
        this.judgingCompletionPercentage = judgingCompletionPercentage;
        this.judgingComplete = judgingComplete;
        this.resultsAvailable = resultsAvailable;
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

    public int getTotalPossibleScorePerJudge() {
        return totalPossibleScorePerJudge;
    }

    public void setTotalPossibleScorePerJudge(int totalPossibleScorePerJudge) {
        this.totalPossibleScorePerJudge = totalPossibleScorePerJudge;
    }

    public long getTotalRequiredEvaluations() {
        return totalRequiredEvaluations;
    }

    public void setTotalRequiredEvaluations(long totalRequiredEvaluations) {
        this.totalRequiredEvaluations = totalRequiredEvaluations;
    }

    public long getCompletedEvaluations() {
        return completedEvaluations;
    }

    public void setCompletedEvaluations(long completedEvaluations) {
        this.completedEvaluations = completedEvaluations;
    }

    public long getRemainingEvaluations() {
        return remainingEvaluations;
    }

    public void setRemainingEvaluations(long remainingEvaluations) {
        this.remainingEvaluations = remainingEvaluations;
    }

    public double getJudgingCompletionPercentage() {
        return judgingCompletionPercentage;
    }

    public void setJudgingCompletionPercentage(double judgingCompletionPercentage) {
        this.judgingCompletionPercentage = judgingCompletionPercentage;
    }

    public boolean isJudgingComplete() {
        return judgingComplete;
    }

    public void setJudgingComplete(boolean judgingComplete) {
        this.judgingComplete = judgingComplete;
    }

    public boolean isResultsAvailable() {
        return resultsAvailable;
    }

    public void setResultsAvailable(boolean resultsAvailable) {
        this.resultsAvailable = resultsAvailable;
    }
}
