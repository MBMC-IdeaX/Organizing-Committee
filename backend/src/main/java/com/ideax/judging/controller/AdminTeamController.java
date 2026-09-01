package com.ideax.judging.controller;

import com.ideax.judging.dto.request.CreateTeamRequest;
import com.ideax.judging.dto.request.ReorderRequest;
import com.ideax.judging.dto.request.StatusUpdateRequest;
import com.ideax.judging.dto.request.UpdateTeamRequest;
import com.ideax.judging.dto.response.ApiResponse;
import com.ideax.judging.dto.response.TeamResponse;
import com.ideax.judging.service.TeamService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/admin/teams")
@Tag(name = "Admin - Teams", description = "Endpoints for managing hackathon participating teams")
@SecurityRequirement(name = "bearerAuth")
public class AdminTeamController {

    private final TeamService teamService;

    public AdminTeamController(TeamService teamService) {
        this.teamService = teamService;
    }

    @GetMapping
    @Operation(summary = "Get all teams ordered by display order")
    public ResponseEntity<ApiResponse<List<TeamResponse>>> getAllTeams() {
        List<TeamResponse> teams = teamService.getAllTeams();
        return ResponseEntity.ok(ApiResponse.ok("Teams retrieved successfully", teams));
    }

    @GetMapping("/{id}")
    @Operation(summary = "Get team by ID")
    public ResponseEntity<ApiResponse<TeamResponse>> getTeamById(@PathVariable Long id) {
        TeamResponse team = teamService.getTeamById(id);
        return ResponseEntity.ok(ApiResponse.ok(team));
    }

    @PostMapping
    @Operation(summary = "Create a new team")
    public ResponseEntity<ApiResponse<TeamResponse>> createTeam(@Valid @RequestBody CreateTeamRequest request) {
        TeamResponse created = teamService.createTeam(request);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.ok("Team created successfully", created));
    }

    @PutMapping("/{id}")
    @Operation(summary = "Update team details")
    public ResponseEntity<ApiResponse<TeamResponse>> updateTeam(
            @PathVariable Long id,
            @Valid @RequestBody UpdateTeamRequest request
    ) {
        TeamResponse updated = teamService.updateTeam(id, request);
        return ResponseEntity.ok(ApiResponse.ok("Team updated successfully", updated));
    }

    @PatchMapping("/{id}/status")
    @Operation(summary = "Activate or deactivate a team")
    public ResponseEntity<ApiResponse<TeamResponse>> updateTeamStatus(
            @PathVariable Long id,
            @Valid @RequestBody StatusUpdateRequest request
    ) {
        TeamResponse updated = teamService.updateTeamStatus(id, request.getActive());
        return ResponseEntity.ok(ApiResponse.ok("Team status updated successfully", updated));
    }

    @PutMapping("/reorder")
    @Operation(summary = "Batch reorder teams by ordered IDs")
    public ResponseEntity<ApiResponse<List<TeamResponse>>> reorderTeams(@Valid @RequestBody ReorderRequest request) {
        List<TeamResponse> reordered = teamService.reorderTeams(request.getOrderedIds());
        return ResponseEntity.ok(ApiResponse.ok("Teams reordered successfully", reordered));
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "Delete team by ID (safe by default, force=true to cascade delete scores)")
    public ResponseEntity<ApiResponse<Void>> deleteTeam(
            @PathVariable Long id,
            @RequestParam(name = "force", defaultValue = "false") boolean force
    ) {
        teamService.deleteTeam(id, force);
        return ResponseEntity.ok(ApiResponse.ok("Team deleted successfully", null));
    }
}
