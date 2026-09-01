package com.ideax.judging.controller;

import com.ideax.judging.dto.response.AdminDashboardSummaryResponse;
import com.ideax.judging.dto.response.ApiResponse;
import com.ideax.judging.service.AdminDashboardService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/admin/dashboard")
@Tag(name = "Admin - Dashboard", description = "Endpoints for event overview and configuration readiness")
@SecurityRequirement(name = "bearerAuth")
public class AdminDashboardController {

    private final AdminDashboardService adminDashboardService;

    public AdminDashboardController(AdminDashboardService adminDashboardService) {
        this.adminDashboardService = adminDashboardService;
    }

    @GetMapping("/summary")
    @Operation(summary = "Get admin dashboard event metrics and configuration readiness")
    public ResponseEntity<ApiResponse<AdminDashboardSummaryResponse>> getDashboardSummary() {
        AdminDashboardSummaryResponse summary = adminDashboardService.getDashboardSummary();
        return ResponseEntity.ok(ApiResponse.ok("Dashboard summary retrieved successfully", summary));
    }
}
