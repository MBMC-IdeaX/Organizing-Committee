package com.ideax.judging.controller;

import com.ideax.judging.dto.request.CreateCriteriaRequest;
import com.ideax.judging.dto.request.ReorderRequest;
import com.ideax.judging.dto.request.StatusUpdateRequest;
import com.ideax.judging.dto.request.UpdateCriteriaRequest;
import com.ideax.judging.dto.response.ApiResponse;
import com.ideax.judging.dto.response.CriteriaResponse;
import com.ideax.judging.service.CriteriaService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/v1/admin/criteria")
@Tag(name = "Admin - Criteria", description = "Endpoints for managing evaluation criteria and rubrics")
@SecurityRequirement(name = "bearerAuth")
public class AdminCriteriaController {

    private final CriteriaService criteriaService;

    public AdminCriteriaController(CriteriaService criteriaService) {
        this.criteriaService = criteriaService;
    }

    @GetMapping
    @Operation(summary = "Get all criteria ordered by display order")
    public ResponseEntity<ApiResponse<List<CriteriaResponse>>> getAllCriteria() {
        List<CriteriaResponse> criteria = criteriaService.getAllCriteria();
        return ResponseEntity.ok(ApiResponse.ok("Criteria retrieved successfully", criteria));
    }

    @GetMapping("/{id}")
    @Operation(summary = "Get criteria by ID")
    public ResponseEntity<ApiResponse<CriteriaResponse>> getCriteriaById(@PathVariable Long id) {
        CriteriaResponse criteria = criteriaService.getCriteriaById(id);
        return ResponseEntity.ok(ApiResponse.ok(criteria));
    }

    @PostMapping
    @Operation(summary = "Create a new criterion")
    public ResponseEntity<ApiResponse<CriteriaResponse>> createCriteria(@Valid @RequestBody CreateCriteriaRequest request) {
        CriteriaResponse created = criteriaService.createCriteria(request);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.ok("Criteria created successfully", created));
    }

    @PutMapping("/{id}")
    @Operation(summary = "Update criterion details")
    public ResponseEntity<ApiResponse<CriteriaResponse>> updateCriteria(
            @PathVariable Long id,
            @Valid @RequestBody UpdateCriteriaRequest request
    ) {
        CriteriaResponse updated = criteriaService.updateCriteria(id, request);
        return ResponseEntity.ok(ApiResponse.ok("Criteria updated successfully", updated));
    }

    @PatchMapping("/{id}/status")
    @Operation(summary = "Activate or deactivate a criterion")
    public ResponseEntity<ApiResponse<CriteriaResponse>> updateCriteriaStatus(
            @PathVariable Long id,
            @Valid @RequestBody StatusUpdateRequest request
    ) {
        CriteriaResponse updated = criteriaService.updateCriteriaStatus(id, request.getActive());
        return ResponseEntity.ok(ApiResponse.ok("Criteria status updated successfully", updated));
    }

    @PutMapping("/reorder")
    @Operation(summary = "Batch reorder criteria by ordered IDs")
    public ResponseEntity<ApiResponse<List<CriteriaResponse>>> reorderCriteria(@Valid @RequestBody ReorderRequest request) {
        List<CriteriaResponse> reordered = criteriaService.reorderCriteria(request.getOrderedIds());
        return ResponseEntity.ok(ApiResponse.ok("Criteria reordered successfully", reordered));
    }

    @GetMapping("/total-score")
    @Operation(summary = "Get total maximum score of active criteria")
    public ResponseEntity<ApiResponse<Map<String, Integer>>> getTotalMaxScore() {
        int total = criteriaService.getTotalMaxScore();
        return ResponseEntity.ok(ApiResponse.ok(Map.of("totalMaxScore", total)));
    }
}
