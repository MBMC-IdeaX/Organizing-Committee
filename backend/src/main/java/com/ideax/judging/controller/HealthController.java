package com.ideax.judging.controller;

import com.ideax.judging.dto.response.ApiResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDateTime;
import java.util.Map;

@RestController
@RequestMapping("/api/v1/health")
@Tag(name = "Health", description = "System health check endpoint")
public class HealthController {

    @GetMapping
    @Operation(summary = "Check backend API health status")
    public ResponseEntity<ApiResponse<Map<String, Object>>> healthCheck() {
        Map<String, Object> healthData = Map.of(
                "status", "UP",
                "service", "ideax-judging-backend",
                "timestamp", LocalDateTime.now(),
                "phase", "Phase 1 Foundation"
        );
        return ResponseEntity.ok(ApiResponse.ok("IdeaX Backend API is operational", healthData));
    }
}
