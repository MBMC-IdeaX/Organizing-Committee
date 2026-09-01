package com.ideax.judging.controller;

import com.ideax.judging.dto.request.CreateJudgeRequest;
import com.ideax.judging.dto.request.StatusUpdateRequest;
import com.ideax.judging.dto.request.UpdateJudgeRequest;
import com.ideax.judging.dto.response.ApiResponse;
import com.ideax.judging.dto.response.JudgeResponse;
import com.ideax.judging.service.JudgeService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/admin/judges")
@Tag(name = "Admin - Judges", description = "Endpoints for managing judge user accounts")
@SecurityRequirement(name = "bearerAuth")
public class AdminJudgeController {

    private final JudgeService judgeService;

    public AdminJudgeController(JudgeService judgeService) {
        this.judgeService = judgeService;
    }

    @GetMapping
    @Operation(summary = "Get all judge accounts")
    public ResponseEntity<ApiResponse<List<JudgeResponse>>> getAllJudges() {
        List<JudgeResponse> judges = judgeService.getAllJudges();
        return ResponseEntity.ok(ApiResponse.ok("Judges retrieved successfully", judges));
    }

    @GetMapping("/{id}")
    @Operation(summary = "Get judge by ID")
    public ResponseEntity<ApiResponse<JudgeResponse>> getJudgeById(@PathVariable Long id) {
        JudgeResponse judge = judgeService.getJudgeById(id);
        return ResponseEntity.ok(ApiResponse.ok(judge));
    }

    @PostMapping
    @Operation(summary = "Create a new judge account")
    public ResponseEntity<ApiResponse<JudgeResponse>> createJudge(@Valid @RequestBody CreateJudgeRequest request) {
        JudgeResponse created = judgeService.createJudge(request);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.ok("Judge account created successfully", created));
    }

    @PutMapping("/{id}")
    @Operation(summary = "Update judge account username or password")
    public ResponseEntity<ApiResponse<JudgeResponse>> updateJudge(
            @PathVariable Long id,
            @Valid @RequestBody UpdateJudgeRequest request
    ) {
        JudgeResponse updated = judgeService.updateJudge(id, request);
        return ResponseEntity.ok(ApiResponse.ok("Judge account updated successfully", updated));
    }

    @PatchMapping("/{id}/status")
    @Operation(summary = "Activate or deactivate a judge account")
    public ResponseEntity<ApiResponse<JudgeResponse>> updateJudgeStatus(
            @PathVariable Long id,
            @Valid @RequestBody StatusUpdateRequest request
    ) {
        JudgeResponse updated = judgeService.updateJudgeStatus(id, request.getActive());
        return ResponseEntity.ok(ApiResponse.ok("Judge status updated successfully", updated));
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "Delete judge account by ID (safe by default, force=true to cascade delete scores)")
    public ResponseEntity<ApiResponse<Void>> deleteJudge(
            @PathVariable Long id,
            @RequestParam(name = "force", defaultValue = "false") boolean force
    ) {
        judgeService.deleteJudge(id, force);
        return ResponseEntity.ok(ApiResponse.ok("Judge account deleted successfully", null));
    }
}
