package com.ideax.judging.controller;

import com.ideax.judging.dto.response.ApiResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

@RestController
@RequestMapping("/api/v1/admin")
@Tag(name = "Admin Foundation", description = "Admin-only secured endpoints")
@SecurityRequirement(name = "Bearer Authentication")
@PreAuthorize("hasRole('ADMIN')")
public class AdminController {

    @GetMapping("/ping")
    @Operation(summary = "Admin authorization ping test")
    public ResponseEntity<ApiResponse<Map<String, Object>>> adminPing(Authentication authentication) {
        return ResponseEntity.ok(ApiResponse.ok(
                "Admin authorization verified",
                Map.of(
                        "authenticatedUser", authentication.getName(),
                        "authorities", authentication.getAuthorities().toString(),
                        "access", "GRANTED_ADMIN"
                )
        ));
    }
}
