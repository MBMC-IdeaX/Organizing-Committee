package com.ideax.judging.controller;

import com.ideax.judging.dto.request.ResetDataRequest;
import com.ideax.judging.dto.response.ApiResponse;
import com.ideax.judging.service.AdminSystemResetService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

@RestController
@RequestMapping("/api/v1/admin/system")
@Tag(name = "Admin - System Operations", description = "High-security administrative operations")
@SecurityRequirement(name = "bearerAuth")
@PreAuthorize("hasRole('ADMIN')")
public class AdminSystemController {

    private final AdminSystemResetService adminSystemResetService;

    public AdminSystemController(AdminSystemResetService adminSystemResetService) {
        this.adminSystemResetService = adminSystemResetService;
    }

    @PostMapping("/reset-data")
    @Operation(summary = "Reset competition data and clear accounts with admin password confirmation")
    public ResponseEntity<ApiResponse<Map<String, Object>>> resetCompetitionData(
            Authentication authentication,
            @Valid @RequestBody ResetDataRequest request
    ) {
        Map<String, Object> result = adminSystemResetService.resetCompetitionData(authentication.getName(), request);
        return ResponseEntity.ok(ApiResponse.ok("Competition data reset successfully.", result));
    }
}
