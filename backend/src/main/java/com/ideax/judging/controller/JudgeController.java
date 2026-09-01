package com.ideax.judging.controller;

import com.ideax.judging.dto.request.CompleteJudgingRequest;
import com.ideax.judging.dto.request.SaveCommentRequest;
import com.ideax.judging.dto.request.SaveScoresRequest;
import com.ideax.judging.dto.response.ApiResponse;
import com.ideax.judging.dto.response.JudgeDashboardResponse;
import com.ideax.judging.dto.response.JudgeTeamResponse;
import com.ideax.judging.dto.response.JudgingSessionResponse;
import com.ideax.judging.repository.UserRepository;
import com.ideax.judging.security.CustomUserDetails;
import com.ideax.judging.service.JudgingService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/v1/judge")
@Tag(name = "Judge Scoring", description = "Judge live evaluation, scoring, and progress endpoints")
@SecurityRequirement(name = "Bearer Authentication")
@PreAuthorize("hasRole('JUDGE')")
public class JudgeController {

    private final JudgingService judgingService;
    private final UserRepository userRepository;

    public JudgeController(JudgingService judgingService, UserRepository userRepository) {
        this.judgingService = judgingService;
        this.userRepository = userRepository;
    }

    @GetMapping("/ping")
    @Operation(summary = "Judge authorization ping test")
    public ResponseEntity<ApiResponse<Map<String, Object>>> judgePing(Authentication authentication) {
        return ResponseEntity.ok(ApiResponse.ok(
                "Judge authorization verified",
                Map.of(
                        "authenticatedUser", authentication.getName(),
                        "authorities", authentication.getAuthorities().toString(),
                        "access", "GRANTED_JUDGE"
                )
        ));
    }

    @GetMapping("/dashboard")
    @Operation(summary = "Get judge dashboard progress and next project")
    public ResponseEntity<ApiResponse<JudgeDashboardResponse>> getJudgeDashboard(Authentication authentication) {
        Long judgeId = extractJudgeId(authentication);
        JudgeDashboardResponse dashboard = judgingService.getJudgeDashboard(judgeId);
        return ResponseEntity.ok(ApiResponse.ok("Judge dashboard retrieved successfully", dashboard));
    }

    @GetMapping("/teams")
    @Operation(summary = "Get list of active teams with judge evaluation status in displayOrder")
    public ResponseEntity<ApiResponse<List<JudgeTeamResponse>>> getJudgeTeams(Authentication authentication) {
        Long judgeId = extractJudgeId(authentication);
        List<JudgeTeamResponse> teams = judgingService.getJudgeTeams(judgeId);
        return ResponseEntity.ok(ApiResponse.ok("Judge teams retrieved successfully", teams));
    }

    @GetMapping("/judgings/{teamId}")
    @Operation(summary = "Get current judging session and criteria scores for a team")
    public ResponseEntity<ApiResponse<JudgingSessionResponse>> getJudgingSession(
            @PathVariable Long teamId,
            Authentication authentication
    ) {
        Long judgeId = extractJudgeId(authentication);
        JudgingSessionResponse session = judgingService.getJudgingSession(judgeId, teamId);
        return ResponseEntity.ok(ApiResponse.ok("Judging session retrieved successfully", session));
    }

    @PostMapping("/judgings/{teamId}/start")
    @Operation(summary = "Start or retrieve an active judging evaluation for a team")
    public ResponseEntity<ApiResponse<JudgingSessionResponse>> startJudging(
            @PathVariable Long teamId,
            Authentication authentication
    ) {
        Long judgeId = extractJudgeId(authentication);
        JudgingSessionResponse session = judgingService.startJudging(judgeId, teamId);
        return ResponseEntity.ok(ApiResponse.ok("Judging session started successfully", session));
    }

    @PutMapping("/judgings/{teamId}/scores")
    @Operation(summary = "Batch save criteria scores for a team")
    public ResponseEntity<ApiResponse<JudgingSessionResponse>> saveScores(
            @PathVariable Long teamId,
            @Valid @RequestBody SaveScoresRequest request,
            Authentication authentication
    ) {
        Long judgeId = extractJudgeId(authentication);
        JudgingSessionResponse session = judgingService.saveScores(judgeId, teamId, request);
        return ResponseEntity.ok(ApiResponse.ok("Scores saved successfully", session));
    }

    @PutMapping("/judgings/{teamId}/comment")
    @Operation(summary = "Save optional comment for a judging session")
    public ResponseEntity<ApiResponse<JudgingSessionResponse>> saveComment(
            @PathVariable Long teamId,
            @RequestBody SaveCommentRequest request,
            Authentication authentication
    ) {
        Long judgeId = extractJudgeId(authentication);
        JudgingSessionResponse session = judgingService.saveComment(judgeId, teamId, request.getComment());
        return ResponseEntity.ok(ApiResponse.ok("Comment saved successfully", session));
    }

    @PostMapping("/judgings/{teamId}/complete")
    @Operation(summary = "Mark judging session as complete and immutable")
    public ResponseEntity<ApiResponse<JudgingSessionResponse>> completeJudging(
            @PathVariable Long teamId,
            @Valid @RequestBody CompleteJudgingRequest request,
            Authentication authentication
    ) {
        Long judgeId = extractJudgeId(authentication);
        JudgingSessionResponse session = judgingService.completeJudging(judgeId, teamId, request);
        return ResponseEntity.ok(ApiResponse.ok("Judging evaluation completed successfully", session));
    }

    private Long extractJudgeId(Authentication authentication) {
        if (authentication.getPrincipal() instanceof CustomUserDetails userDetails) {
            return userDetails.getId();
        }
        return userRepository.findByUsername(authentication.getName())
                .orElseThrow(() -> new IllegalStateException("Authenticated judge not found in database"))
                .getId();
    }
}

