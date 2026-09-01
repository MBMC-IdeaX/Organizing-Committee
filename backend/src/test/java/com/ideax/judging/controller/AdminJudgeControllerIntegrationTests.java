package com.ideax.judging.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.ideax.judging.dto.request.CreateJudgeRequest;
import com.ideax.judging.dto.request.StatusUpdateRequest;
import com.ideax.judging.dto.request.UpdateJudgeRequest;
import com.ideax.judging.entity.Judging;
import com.ideax.judging.entity.JudgingStatus;
import com.ideax.judging.entity.Role;
import com.ideax.judging.entity.Team;
import com.ideax.judging.entity.User;
import com.ideax.judging.repository.JudgingRepository;
import com.ideax.judging.repository.TeamRepository;
import com.ideax.judging.repository.UserRepository;
import com.ideax.judging.security.JwtService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;

import static org.hamcrest.Matchers.*;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
class AdminJudgeControllerIntegrationTests {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private TeamRepository teamRepository;

    @Autowired
    private JudgingRepository judgingRepository;

    @Autowired
    private com.ideax.judging.repository.ScoreRepository scoreRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Autowired
    private JwtService jwtService;

    @Autowired
    private ObjectMapper objectMapper;

    private String adminToken;
    private String judgeToken;
    private User testJudge;

    @BeforeEach
    void setUp() {
        scoreRepository.deleteAll();
        judgingRepository.deleteAll();
        teamRepository.deleteAll();
        userRepository.deleteAll();

        User admin = userRepository.save(new User("admin_judge_mgr", "hash", Role.ADMIN, true));
        testJudge = userRepository.save(new User("judge_regular", "hash", Role.JUDGE, true));

        adminToken = jwtService.generateToken(admin.getId(), admin.getUsername(), admin.getRole());
        judgeToken = jwtService.generateToken(testJudge.getId(), testJudge.getUsername(), testJudge.getRole());
    }

    @Test
    void shouldAllowAdminToCreateJudgeWithAutoAssignedRole() throws Exception {
        CreateJudgeRequest request = new CreateJudgeRequest("judge_newbie", "SecurePass123!");

        mockMvc.perform(post("/api/v1/admin/judges")
                        .header("Authorization", "Bearer " + adminToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.success", is(true)))
                .andExpect(jsonPath("$.data.username", is("judge_newbie")))
                .andExpect(jsonPath("$.data.role", is("JUDGE")))
                .andExpect(jsonPath("$.data.active", is(true)))
                .andExpect(jsonPath("$.data.password").doesNotExist())
                .andExpect(jsonPath("$.data.passwordHash").doesNotExist());

        User saved = userRepository.findByUsername("judge_newbie").orElseThrow();
        assertTrue(passwordEncoder.matches("SecurePass123!", saved.getPasswordHash()));
    }

    @Test
    void shouldRejectDuplicateJudgeUsername() throws Exception {
        userRepository.save(new User("judge_duplicate", "hash", Role.JUDGE, true));

        CreateJudgeRequest request = new CreateJudgeRequest("judge_duplicate", "Pass1234!");

        mockMvc.perform(post("/api/v1/admin/judges")
                        .header("Authorization", "Bearer " + adminToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isConflict())
                .andExpect(jsonPath("$.errorCode", is("DUPLICATE_RESOURCE")));
    }

    @Test
    void shouldAllowAdminToUpdateJudgeAndToggleStatus() throws Exception {
        User judge = userRepository.save(new User("judge_to_edit", "oldHash", Role.JUDGE, true));

        UpdateJudgeRequest updateRequest = new UpdateJudgeRequest("judge_renamed", "NewPassword123!");

        mockMvc.perform(put("/api/v1/admin/judges/" + judge.getId())
                        .header("Authorization", "Bearer " + adminToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(updateRequest)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.username", is("judge_renamed")))
                .andExpect(jsonPath("$.data.role", is("JUDGE"))); // Strictly preserved

        StatusUpdateRequest statusRequest = new StatusUpdateRequest(false);
        mockMvc.perform(patch("/api/v1/admin/judges/" + judge.getId() + "/status")
                        .header("Authorization", "Bearer " + adminToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(statusRequest)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.active", is(false)));
    }

    @Test
    void shouldRevokeAccessImmediatelyWhenJudgeIsDeactivated() throws Exception {
        User judge = userRepository.save(new User("judge_active_now", passwordEncoder.encode("Pass123!"), Role.JUDGE, true));
        String activeJudgeToken = jwtService.generateToken(judge.getId(), judge.getUsername(), judge.getRole());

        // 1. Verify active token works initially (200 OK on authenticated endpoint)
        mockMvc.perform(get("/api/v1/auth/me")
                        .header("Authorization", "Bearer " + activeJudgeToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.username", is("judge_active_now")));

        // 2. Admin deactivates the judge
        StatusUpdateRequest deactivateRequest = new StatusUpdateRequest(false);
        mockMvc.perform(patch("/api/v1/admin/judges/" + judge.getId() + "/status")
                        .header("Authorization", "Bearer " + adminToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(deactivateRequest)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.active", is(false)));

        // 3. Verify existing JWT is now rejected with 401 UNAUTHORIZED
        mockMvc.perform(get("/api/v1/auth/me")
                        .header("Authorization", "Bearer " + activeJudgeToken))
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.errorCode", is("UNAUTHORIZED")));

        // 4. Verify login attempt returns 401 UNAUTHORIZED
        String loginPayload = "{\"username\":\"judge_active_now\",\"password\":\"Pass123!\"}";
        mockMvc.perform(post("/api/v1/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(loginPayload))
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.errorCode", is("UNAUTHORIZED")));
    }

    @Test
    void shouldAllowAdminToDeleteUnusedJudge() throws Exception {
        User judge = userRepository.save(new User("judge_unused", "hash", Role.JUDGE, true));

        mockMvc.perform(delete("/api/v1/admin/judges/" + judge.getId())
                        .header("Authorization", "Bearer " + adminToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success", is(true)))
                .andExpect(jsonPath("$.message", is("Judge account deleted successfully")));

        mockMvc.perform(get("/api/v1/admin/judges/" + judge.getId())
                        .header("Authorization", "Bearer " + adminToken))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.errorCode", is("RESOURCE_NOT_FOUND")));
    }

    @Test
    void shouldRejectDeleteJudgeWhenJudgingRecordsExist() throws Exception {
        Team team = teamRepository.save(new Team("Team Evaluation", "Project E", "Idea", 1, true));
        judgingRepository.save(new Judging(testJudge, team, JudgingStatus.COMPLETED, "Great project!"));

        mockMvc.perform(delete("/api/v1/admin/judges/" + testJudge.getId())
                        .header("Authorization", "Bearer " + adminToken))
                .andExpect(status().isConflict())
                .andExpect(jsonPath("$.success", is(false)))
                .andExpect(jsonPath("$.errorCode", is("JUDGE_HAS_JUDGING_RECORDS")))
                .andExpect(jsonPath("$.message", containsString("evaluation records exist")));

        // Verify judge still exists in database
        mockMvc.perform(get("/api/v1/admin/judges/" + testJudge.getId())
                        .header("Authorization", "Bearer " + adminToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.username", is("judge_regular")));
    }

    @Test
    void shouldForbidJudgeFromDeletingJudge() throws Exception {
        User judge = userRepository.save(new User("judge_victim", "hash", Role.JUDGE, true));

        mockMvc.perform(delete("/api/v1/admin/judges/" + judge.getId())
                        .header("Authorization", "Bearer " + judgeToken))
                .andExpect(status().isForbidden())
                .andExpect(jsonPath("$.errorCode", is("ACCESS_DENIED")));
    }

    @Test
    void shouldRejectUnauthenticatedUserFromDeletingJudge() throws Exception {
        User judge = userRepository.save(new User("judge_victim", "hash", Role.JUDGE, true));

        mockMvc.perform(delete("/api/v1/admin/judges/" + judge.getId()))
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.errorCode", is("UNAUTHORIZED")));
    }

    @Test
    void shouldRejectDeletingAdminViaJudgeEndpoint() throws Exception {
        User otherAdmin = userRepository.save(new User("super_admin_2", "hash", Role.ADMIN, true));

        mockMvc.perform(delete("/api/v1/admin/judges/" + otherAdmin.getId())
                        .header("Authorization", "Bearer " + adminToken))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.errorCode", is("RESOURCE_NOT_FOUND")));
    }
}

