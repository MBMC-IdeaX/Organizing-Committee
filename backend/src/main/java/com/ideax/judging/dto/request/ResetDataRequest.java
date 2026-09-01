package com.ideax.judging.dto.request;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;

@Schema(description = "Request payload to reset competition data with admin verification")
public class ResetDataRequest {

    @NotBlank(message = "Admin password is required for security verification")
    @Schema(description = "Current admin password for confirmation", example = "IdeaXAdmin2026!")
    private String adminPassword;

    @Schema(description = "Whether to clear all scorecards and judging ballots", example = "true")
    private boolean clearJudgings = true;

    @Schema(description = "Whether to delete all judge accounts (Admin account is always preserved)", example = "false")
    private boolean clearJudges = false;

    @Schema(description = "Whether to delete all teams", example = "false")
    private boolean clearTeams = false;

    public ResetDataRequest() {
    }

    public ResetDataRequest(String adminPassword, boolean clearJudgings, boolean clearJudges, boolean clearTeams) {
        this.adminPassword = adminPassword;
        this.clearJudgings = clearJudgings;
        this.clearJudges = clearJudges;
        this.clearTeams = clearTeams;
    }

    public String getAdminPassword() {
        return adminPassword;
    }

    public void setAdminPassword(String adminPassword) {
        this.adminPassword = adminPassword;
    }

    public boolean isClearJudgings() {
        return clearJudgings;
    }

    public void setClearJudgings(boolean clearJudgings) {
        this.clearJudgings = clearJudgings;
    }

    public boolean isClearJudges() {
        return clearJudges;
    }

    public void setClearJudges(boolean clearJudges) {
        this.clearJudges = clearJudges;
    }

    public boolean isClearTeams() {
        return clearTeams;
    }

    public void setClearTeams(boolean clearTeams) {
        this.clearTeams = clearTeams;
    }
}
