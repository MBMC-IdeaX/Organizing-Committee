package com.ideax.judging.controller;

import com.ideax.judging.dto.response.*;
import com.ideax.judging.service.ResultsService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/v1/admin/results")
@Tag(name = "Admin - Results", description = "Endpoints for score aggregation, podium standings, and ranking audit reports")
@SecurityRequirement(name = "bearerAuth")
public class AdminResultsController {

    private final ResultsService resultsService;

    public AdminResultsController(ResultsService resultsService) {
        this.resultsService = resultsService;
    }

    @GetMapping("/summary")
    @Operation(summary = "Get active scoring summary and competition completion stats")
    public ResponseEntity<ApiResponse<ResultsSummaryResponse>> getResultsSummary() {
        ResultsSummaryResponse summary = resultsService.getResultsSummary();
        return ResponseEntity.ok(ApiResponse.ok("Results summary retrieved successfully", summary));
    }

    @GetMapping("/ranking")
    @Operation(summary = "Get final competition ranking list (requires complete judging)")
    public ResponseEntity<ApiResponse<List<RankingResultResponse>>> getRanking() {
        List<RankingResultResponse> ranking = resultsService.getRanking();
        return ResponseEntity.ok(ApiResponse.ok("Competition rankings retrieved successfully", ranking));
    }

    @GetMapping("/teams/{teamId}")
    @Operation(summary = "Get detailed scores audit and criterion breakdowns for a team")
    public ResponseEntity<ApiResponse<TeamResultResponse>> getTeamResult(@PathVariable Long teamId) {
        TeamResultResponse result = resultsService.getTeamResult(teamId);
        return ResponseEntity.ok(ApiResponse.ok("Team result details retrieved successfully", result));
    }
}
