package com.ideax.judging.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.ideax.judging.dto.request.ResetDataRequest;
import com.ideax.judging.entity.*;
import com.ideax.judging.repository.*;
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

import java.util.List;

import static org.junit.jupiter.api.Assertions.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
class AdminSystemResetIntegrationTests {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private TeamRepository teamRepository;

    @Autowired
    private CriteriaRepository criteriaRepository;

    @Autowired
    private JudgingRepository judgingRepository;

    @Autowired
    private ScoreRepository scoreRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Autowired
    private JwtService jwtService;

    @Autowired
    private ObjectMapper objectMapper;

    private String adminToken;
    private String judgeToken;
    private User adminUser;
    private User judgeUser;
    private Team team1;
    private Team team2;
    private Criteria criteria1;

    @BeforeEach
    void setUp() {
        scoreRepository.deleteAll();
        judgingRepository.deleteAll();
        criteriaRepository.deleteAll();
        teamRepository.deleteAll();
        userRepository.deleteAll();

        adminUser = userRepository.save(new User(
                "admin_super",
                passwordEncoder.encode("SecretAdmin123!"),
                Role.ADMIN,
                true
        ));

        judgeUser = userRepository.save(new User(
                "judge_alpha",
                passwordEncoder.encode("JudgePass123!"),
                Role.JUDGE,
                true
        ));

        team1 = teamRepository.save(new Team(
                "Team Alpha",
                "Project Alpha",
                "Idea description",
                1,
                true
        ));

        team2 = teamRepository.save(new Team(
                "Team Beta",
                "Project Beta",
                "Idea description 2",
                2,
                true
        ));

        criteria1 = criteriaRepository.save(new Criteria(
                "Innovation",
                "Novelty",
                20,
                1,
                true
        ));

        adminToken = jwtService.generateToken(adminUser.getId(), adminUser.getUsername(), adminUser.getRole());
        judgeToken = jwtService.generateToken(judgeUser.getId(), judgeUser.getUsername(), judgeUser.getRole());

        // Create judging sessions with scores
        Judging judging1 = judgingRepository.save(new Judging(
                judgeUser,
                team1,
                JudgingStatus.COMPLETED,
                "Great work"
        ));

        scoreRepository.save(new Score(
                judging1,
                criteria1,
                18
        ));
    }

    @Test
    void test1_ValidAdminPasswordResetSucceeds() throws Exception {
        ResetDataRequest request = new ResetDataRequest("SecretAdmin123!", true, false, false);

        mockMvc.perform(post("/api/v1/admin/system/reset-data")
                        .header("Authorization", "Bearer " + adminToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.message").value("Competition data reset successfully."))
                .andExpect(jsonPath("$.data.scoresCleared").value(1))
                .andExpect(jsonPath("$.data.judgingsReset").value(1));

        assertEquals(0, scoreRepository.count());
        assertEquals(0, judgingRepository.count());
    }

    @Test
    void test2_InvalidAdminPasswordRejected() throws Exception {
        ResetDataRequest request = new ResetDataRequest("WrongPassword!", true, false, false);

        mockMvc.perform(post("/api/v1/admin/system/reset-data")
                        .header("Authorization", "Bearer " + adminToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.success").value(false))
                .andExpect(jsonPath("$.errorCode").value("RESET_INVALID_PASSWORD"))
                .andExpect(jsonPath("$.message").value("Administrator verification failed. Please check your password."));

        assertEquals(1, judgingRepository.count());
        assertEquals(1, scoreRepository.count());
    }

    @Test
    void test3_JudgeAttemptsResetForbidden() throws Exception {
        ResetDataRequest request = new ResetDataRequest("SecretAdmin123!", true, false, false);

        mockMvc.perform(post("/api/v1/admin/system/reset-data")
                        .header("Authorization", "Bearer " + judgeToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isForbidden());
    }

    @Test
    void test4_UnauthenticatedResetUnauthorized() throws Exception {
        ResetDataRequest request = new ResetDataRequest("SecretAdmin123!", true, false, false);

        mockMvc.perform(post("/api/v1/admin/system/reset-data")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isUnauthorized());
    }

    @Test
    void test5_ClearScoresOnly_OptionA() throws Exception {
        ResetDataRequest request = new ResetDataRequest("SecretAdmin123!", true, false, false);

        mockMvc.perform(post("/api/v1/admin/system/reset-data")
                        .header("Authorization", "Bearer " + adminToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.scoresCleared").value(1))
                .andExpect(jsonPath("$.data.judgingsReset").value(1))
                .andExpect(jsonPath("$.data.judgesDeleted").value(0))
                .andExpect(jsonPath("$.data.teamsDeleted").value(0));

        assertEquals(0, scoreRepository.count());
        assertEquals(0, judgingRepository.count());
        assertEquals(2, userRepository.count());
        assertEquals(2, teamRepository.count());
        assertEquals(1, criteriaRepository.count());
    }

    @Test
    void test6_DeleteJudgesOnly_OptionB() throws Exception {
        ResetDataRequest request = new ResetDataRequest("SecretAdmin123!", false, true, false);

        mockMvc.perform(post("/api/v1/admin/system/reset-data")
                        .header("Authorization", "Bearer " + adminToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.judgesDeleted").value(1))
                .andExpect(jsonPath("$.data.teamsDeleted").value(0));

        // Judge deleted, dependent scores/judgings removed
        assertEquals(0, scoreRepository.count());
        assertEquals(0, judgingRepository.count());
        assertEquals(1, userRepository.count());
        assertEquals(Role.ADMIN, userRepository.findAll().get(0).getRole());
        assertEquals(2, teamRepository.count());
    }

    @Test
    void test7_DeleteTeamsOnly_OptionC() throws Exception {
        ResetDataRequest request = new ResetDataRequest("SecretAdmin123!", false, false, true);

        mockMvc.perform(post("/api/v1/admin/system/reset-data")
                        .header("Authorization", "Bearer " + adminToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.teamsDeleted").value(2));

        assertEquals(0, teamRepository.count());
        assertEquals(0, scoreRepository.count());
        assertEquals(0, judgingRepository.count());
        assertEquals(2, userRepository.count()); // Admin and Judge preserved
    }

    @Test
    void test8_ClearScoresAndDeleteJudges_OptionAB() throws Exception {
        ResetDataRequest request = new ResetDataRequest("SecretAdmin123!", true, true, false);

        mockMvc.perform(post("/api/v1/admin/system/reset-data")
                        .header("Authorization", "Bearer " + adminToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.scoresCleared").value(1))
                .andExpect(jsonPath("$.data.judgesDeleted").value(1))
                .andExpect(jsonPath("$.data.teamsDeleted").value(0));

        assertEquals(1, userRepository.count());
        assertEquals(2, teamRepository.count());
    }

    @Test
    void test9_ClearScoresAndDeleteTeams_OptionAC() throws Exception {
        ResetDataRequest request = new ResetDataRequest("SecretAdmin123!", true, false, true);

        mockMvc.perform(post("/api/v1/admin/system/reset-data")
                        .header("Authorization", "Bearer " + adminToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.scoresCleared").value(1))
                .andExpect(jsonPath("$.data.teamsDeleted").value(2));

        assertEquals(2, userRepository.count());
        assertEquals(0, teamRepository.count());
    }

    @Test
    void test10_ResetEverything_OptionABC() throws Exception {
        ResetDataRequest request = new ResetDataRequest("SecretAdmin123!", true, true, true);

        mockMvc.perform(post("/api/v1/admin/system/reset-data")
                        .header("Authorization", "Bearer " + adminToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.scoresCleared").value(1))
                .andExpect(jsonPath("$.data.judgingsReset").value(1))
                .andExpect(jsonPath("$.data.judgesDeleted").value(1))
                .andExpect(jsonPath("$.data.teamsDeleted").value(2));

        assertEquals(0, scoreRepository.count());
        assertEquals(0, judgingRepository.count());
        assertEquals(0, teamRepository.count());
        assertEquals(1, criteriaRepository.count()); // Criteria preserved!

        List<User> remaining = userRepository.findAll();
        assertEquals(1, remaining.size());
        assertEquals("admin_super", remaining.get(0).getUsername());
        assertEquals(Role.ADMIN, remaining.get(0).getRole());
    }

    @Test
    void test11_AdminAccountIsNeverDeleted() throws Exception {
        ResetDataRequest request = new ResetDataRequest("SecretAdmin123!", true, true, true);

        mockMvc.perform(post("/api/v1/admin/system/reset-data")
                        .header("Authorization", "Bearer " + adminToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk());

        assertTrue(userRepository.findByUsername("admin_super").isPresent());
    }

    @Test
    void test12_CriteriaAreNeverDeleted() throws Exception {
        ResetDataRequest request = new ResetDataRequest("SecretAdmin123!", true, true, true);

        mockMvc.perform(post("/api/v1/admin/system/reset-data")
                        .header("Authorization", "Bearer " + adminToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk());

        assertEquals(1, criteriaRepository.count());
    }

    @Test
    void test13_EmptyDatabaseResetSucceeds() throws Exception {
        scoreRepository.deleteAll();
        judgingRepository.deleteAll();
        teamRepository.deleteAll();

        ResetDataRequest request = new ResetDataRequest("SecretAdmin123!", true, true, true);

        mockMvc.perform(post("/api/v1/admin/system/reset-data")
                        .header("Authorization", "Bearer " + adminToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.scoresCleared").value(0))
                .andExpect(jsonPath("$.data.judgingsReset").value(0))
                .andExpect(jsonPath("$.data.teamsDeleted").value(0));
    }

    @Test
    void test14_RepeatedResetIdempotent() throws Exception {
        ResetDataRequest request = new ResetDataRequest("SecretAdmin123!", true, true, true);

        mockMvc.perform(post("/api/v1/admin/system/reset-data")
                        .header("Authorization", "Bearer " + adminToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk());

        // Repeat identical reset
        mockMvc.perform(post("/api/v1/admin/system/reset-data")
                        .header("Authorization", "Bearer " + adminToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.scoresCleared").value(0))
                .andExpect(jsonPath("$.data.judgesDeleted").value(0));
    }

    @Test
    void test15_ResultsSummaryShowsZeroCompletedAfterReset() throws Exception {
        ResetDataRequest request = new ResetDataRequest("SecretAdmin123!", true, false, false);

        mockMvc.perform(post("/api/v1/admin/system/reset-data")
                        .header("Authorization", "Bearer " + adminToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk());

        // Check Results Summary
        mockMvc.perform(get("/api/v1/admin/results/summary")
                        .header("Authorization", "Bearer " + adminToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.completedEvaluations").value(0))
                .andExpect(jsonPath("$.data.judgingComplete").value(false));
    }

    @Test
    void test16_ForceDeleteTeam() throws Exception {
        mockMvc.perform(delete("/api/v1/admin/teams/" + team1.getId() + "?force=true")
                        .header("Authorization", "Bearer " + adminToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true));

        assertFalse(teamRepository.existsById(team1.getId()));
        assertEquals(0, scoreRepository.count());
    }

    @Test
    void test17_ForceDeleteJudge() throws Exception {
        mockMvc.perform(delete("/api/v1/admin/judges/" + judgeUser.getId() + "?force=true")
                        .header("Authorization", "Bearer " + adminToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true));

        assertFalse(userRepository.existsById(judgeUser.getId()));
        assertEquals(0, scoreRepository.count());
    }
}
