package com.ideax.judging.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.ideax.judging.dto.request.CompleteJudgingRequest;
import com.ideax.judging.dto.request.CriteriaScoreItem;
import com.ideax.judging.dto.request.SaveCommentRequest;
import com.ideax.judging.dto.request.SaveScoresRequest;
import com.ideax.judging.entity.*;
import com.ideax.judging.repository.*;
import com.ideax.judging.security.JwtService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;

import java.util.List;

import static org.hamcrest.Matchers.*;
import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
class JudgeScoringIntegrationTests {

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
    private JwtService jwtService;

    @Autowired
    private ObjectMapper objectMapper;

    private User judge1;
    private User judge2;
    private User admin;
    private String judge1Token;
    private String judge2Token;
    private String adminToken;

    private Team team1;
    private Team team2;
    private Team team3;

    private Criteria crit1;
    private Criteria crit2;

    @BeforeEach
    void setUp() {
        scoreRepository.deleteAll();
        judgingRepository.deleteAll();
        criteriaRepository.deleteAll();
        teamRepository.deleteAll();
        userRepository.deleteAll();

        judge1 = userRepository.save(new User("judge_alpha", "hash", Role.JUDGE, true));
        judge2 = userRepository.save(new User("judge_beta", "hash", Role.JUDGE, true));
        admin = userRepository.save(new User("admin_super", "hash", Role.ADMIN, true));

        judge1Token = jwtService.generateToken(judge1.getId(), judge1.getUsername(), judge1.getRole());
        judge2Token = jwtService.generateToken(judge2.getId(), judge2.getUsername(), judge2.getRole());
        adminToken = jwtService.generateToken(admin.getId(), admin.getUsername(), admin.getRole());

        // Teams in displayOrder 1, 2, 3
        team1 = teamRepository.save(new Team("Team Alpha", "Project A", "Idea A", 1, true));
        team2 = teamRepository.save(new Team("Team Beta", "Project B", "Idea B", 2, true));
        team3 = teamRepository.save(new Team("Team Gamma", "Project C", "Idea C", 3, true));
        teamRepository.save(new Team("Inactive Team", "Project X", "Idea X", 4, false));

        // Criteria: Innovation (20, order 1), Technical (30, order 2)
        crit1 = criteriaRepository.save(new Criteria("Innovation", "Novelty", 20, 1, true));
        crit2 = criteriaRepository.save(new Criteria("Technical", "Architecture", 30, 2, true));
        criteriaRepository.save(new Criteria("Archived Criterion", "Old", 10, 3, false));
    }

    @Test
    void shouldEnforceRoleBasedAccessControlOnJudgeEndpoints() throws Exception {
        // 1. Unauthenticated -> 401
        mockMvc.perform(get("/api/v1/judge/dashboard"))
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.errorCode", is("UNAUTHORIZED")));

        // 2. ADMIN role accessing Judge endpoint -> 403
        mockMvc.perform(get("/api/v1/judge/dashboard")
                        .header("Authorization", "Bearer " + adminToken))
                .andExpect(status().isForbidden())
                .andExpect(jsonPath("$.errorCode", is("ACCESS_DENIED")));

        // 3. Judge role -> 200
        mockMvc.perform(get("/api/v1/judge/dashboard")
                        .header("Authorization", "Bearer " + judge1Token))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success", is(true)))
                .andExpect(jsonPath("$.data.totalTeams", is(3)))
                .andExpect(jsonPath("$.data.completedTeams", is(0)))
                .andExpect(jsonPath("$.data.remainingTeams", is(3)))
                .andExpect(jsonPath("$.data.progressPercentage", is(0.0)))
                .andExpect(jsonPath("$.data.nextTeam.id", is(team1.getId().intValue())))
                .andExpect(jsonPath("$.data.nextTeam.status", is("NOT_STARTED")));
    }

    @Test
    void shouldReturnActiveTeamsInDisplayOrderAsc() throws Exception {
        mockMvc.perform(get("/api/v1/judge/teams")
                        .header("Authorization", "Bearer " + judge1Token))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data", hasSize(3)))
                .andExpect(jsonPath("$.data[0].id", is(team1.getId().intValue())))
                .andExpect(jsonPath("$.data[0].displayOrder", is(1)))
                .andExpect(jsonPath("$.data[1].id", is(team2.getId().intValue())))
                .andExpect(jsonPath("$.data[1].displayOrder", is(2)))
                .andExpect(jsonPath("$.data[2].id", is(team3.getId().intValue())))
                .andExpect(jsonPath("$.data[2].displayOrder", is(3)));
    }

    @Test
    void shouldStartJudgingIdempotently() throws Exception {
        // Start judging team 1
        mockMvc.perform(post("/api/v1/judge/judgings/" + team1.getId() + "/start")
                        .header("Authorization", "Bearer " + judge1Token))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.teamId", is(team1.getId().intValue())))
                .andExpect(jsonPath("$.data.status", is("IN_PROGRESS")))
                .andExpect(jsonPath("$.data.criteriaScores", hasSize(2))); // only 2 active criteria

        assertEquals(1, judgingRepository.count());

        // Start again on same team -> returns existing session without duplicate
        mockMvc.perform(post("/api/v1/judge/judgings/" + team1.getId() + "/start")
                        .header("Authorization", "Bearer " + judge1Token))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.status", is("IN_PROGRESS")));

        assertEquals(1, judgingRepository.count());
    }

    @Test
    void shouldSaveScoresWithinPointBoundsAndCalculateTotal() throws Exception {
        SaveScoresRequest request = new SaveScoresRequest(List.of(
                new CriteriaScoreItem(crit1.getId(), 18),
                new CriteriaScoreItem(crit2.getId(), 27)
        ));

        mockMvc.perform(put("/api/v1/judge/judgings/" + team1.getId() + "/scores")
                        .header("Authorization", "Bearer " + judge1Token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.status", is("IN_PROGRESS")))
                .andExpect(jsonPath("$.data.totalScore", is(45)))
                .andExpect(jsonPath("$.data.totalMaxScore", is(50)))
                .andExpect(jsonPath("$.data.criteriaScores[0].score", is(18)))
                .andExpect(jsonPath("$.data.criteriaScores[1].score", is(27)));

        // Verify recovery after leaving screen
        mockMvc.perform(get("/api/v1/judge/judgings/" + team1.getId())
                        .header("Authorization", "Bearer " + judge1Token))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.totalScore", is(45)))
                .andExpect(jsonPath("$.data.criteriaScores[0].score", is(18)))
                .andExpect(jsonPath("$.data.criteriaScores[1].score", is(27)));
    }

    @Test
    void shouldRejectScoreExceedingCriterionMaxScore() throws Exception {
        // crit1 maxScore is 20, sending 25
        SaveScoresRequest request = new SaveScoresRequest(List.of(
                new CriteriaScoreItem(crit1.getId(), 25)
        ));

        mockMvc.perform(put("/api/v1/judge/judgings/" + team1.getId() + "/scores")
                        .header("Authorization", "Bearer " + judge1Token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.errorCode", is("VALIDATION_ERROR")));
    }

    @Test
    void shouldSaveOptionalComment() throws Exception {
        SaveCommentRequest request = new SaveCommentRequest("Outstanding prototype and clear pitch!");

        mockMvc.perform(put("/api/v1/judge/judgings/" + team1.getId() + "/comment")
                        .header("Authorization", "Bearer " + judge1Token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.comment", is("Outstanding prototype and clear pitch!")));
    }

    @Test
    void shouldPreventCompletionWhenActiveCriteriaScoresAreMissing() throws Exception {
        // Save score for only crit1 (missing crit2)
        SaveScoresRequest request = new SaveScoresRequest(List.of(
                new CriteriaScoreItem(crit1.getId(), 18)
        ));

        mockMvc.perform(put("/api/v1/judge/judgings/" + team1.getId() + "/scores")
                        .header("Authorization", "Bearer " + judge1Token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk());

        CompleteJudgingRequest completeRequest = new CompleteJudgingRequest("Nice job", null);

        mockMvc.perform(post("/api/v1/judge/judgings/" + team1.getId() + "/complete")
                        .header("Authorization", "Bearer " + judge1Token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(completeRequest)))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.message", containsString("missing score")));
    }

    @Test
    void shouldCompleteJudgingAndEnforceImmutability() throws Exception {
        CompleteJudgingRequest completeRequest = new CompleteJudgingRequest(
                "Finalized evaluation",
                List.of(
                        new CriteriaScoreItem(crit1.getId(), 20),
                        new CriteriaScoreItem(crit2.getId(), 28)
                )
        );

        mockMvc.perform(post("/api/v1/judge/judgings/" + team1.getId() + "/complete")
                        .header("Authorization", "Bearer " + judge1Token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(completeRequest)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.status", is("COMPLETED")))
                .andExpect(jsonPath("$.data.totalScore", is(48)))
                .andExpect(jsonPath("$.data.completedAt", notNullValue()));

        Judging completedSession = judgingRepository.findByJudgeIdAndTeamId(judge1.getId(), team1.getId()).orElseThrow();
        assertEquals(JudgingStatus.COMPLETED, completedSession.getStatus());
        assertNotNull(completedSession.getCompletedAt());

        // Subsequent edits must be rejected
        SaveScoresRequest editScoresRequest = new SaveScoresRequest(List.of(
                new CriteriaScoreItem(crit1.getId(), 15)
        ));
        mockMvc.perform(put("/api/v1/judge/judgings/" + team1.getId() + "/scores")
                        .header("Authorization", "Bearer " + judge1Token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(editScoresRequest)))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.message", containsString("immutable")));

        // Subsequent comment edit must be rejected
        mockMvc.perform(put("/api/v1/judge/judgings/" + team1.getId() + "/comment")
                        .header("Authorization", "Bearer " + judge1Token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(new SaveCommentRequest("Changed my mind"))))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.message", containsString("immutable")));
    }

    @Test
    void shouldAdvanceNextRecommendedTeamAndCalculateProgressOnDashboard() throws Exception {
        // Complete Team 1
        CompleteJudgingRequest complete1 = new CompleteJudgingRequest("Done 1", List.of(
                new CriteriaScoreItem(crit1.getId(), 19),
                new CriteriaScoreItem(crit2.getId(), 25)
        ));
        mockMvc.perform(post("/api/v1/judge/judgings/" + team1.getId() + "/complete")
                        .header("Authorization", "Bearer " + judge1Token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(complete1)))
                .andExpect(status().isOk());

        // Check Dashboard -> Progress 1/3 (33.3%), next team is Team Beta (team2)
        mockMvc.perform(get("/api/v1/judge/dashboard")
                        .header("Authorization", "Bearer " + judge1Token))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.totalTeams", is(3)))
                .andExpect(jsonPath("$.data.completedTeams", is(1)))
                .andExpect(jsonPath("$.data.remainingTeams", is(2)))
                .andExpect(jsonPath("$.data.nextTeam.id", is(team2.getId().intValue())))
                .andExpect(jsonPath("$.data.nextTeam.teamName", is("Team Beta")));

        // Complete Team 2
        CompleteJudgingRequest complete2 = new CompleteJudgingRequest("Done 2", List.of(
                new CriteriaScoreItem(crit1.getId(), 15),
                new CriteriaScoreItem(crit2.getId(), 20)
        ));
        mockMvc.perform(post("/api/v1/judge/judgings/" + team2.getId() + "/complete")
                        .header("Authorization", "Bearer " + judge1Token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(complete2)))
                .andExpect(status().isOk());

        // Complete Team 3
        CompleteJudgingRequest complete3 = new CompleteJudgingRequest("Done 3", List.of(
                new CriteriaScoreItem(crit1.getId(), 18),
                new CriteriaScoreItem(crit2.getId(), 22)
        ));
        mockMvc.perform(post("/api/v1/judge/judgings/" + team3.getId() + "/complete")
                        .header("Authorization", "Bearer " + judge1Token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(complete3)))
                .andExpect(status().isOk());

        // All 3 teams completed -> nextTeam should be null, progress 100%
        mockMvc.perform(get("/api/v1/judge/dashboard")
                        .header("Authorization", "Bearer " + judge1Token))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.completedTeams", is(3)))
                .andExpect(jsonPath("$.data.remainingTeams", is(0)))
                .andExpect(jsonPath("$.data.progressPercentage", is(100.0)))
                .andExpect(jsonPath("$.data.nextTeam").doesNotExist());
    }

    @Test
    void shouldIsolateJudgingsBetweenJudges() throws Exception {
        // Judge 1 scores Team 1 (45 pts)
        CompleteJudgingRequest complete1 = new CompleteJudgingRequest("Judge 1 evaluation", List.of(
                new CriteriaScoreItem(crit1.getId(), 20),
                new CriteriaScoreItem(crit2.getId(), 25)
        ));
        mockMvc.perform(post("/api/v1/judge/judgings/" + team1.getId() + "/complete")
                        .header("Authorization", "Bearer " + judge1Token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(complete1)))
                .andExpect(status().isOk());

        // Judge 2 checks Team 1 -> Should be NOT_STARTED with no scores for Judge 2
        mockMvc.perform(get("/api/v1/judge/judgings/" + team1.getId())
                        .header("Authorization", "Bearer " + judge2Token))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.status", is("NOT_STARTED")))
                .andExpect(jsonPath("$.data.totalScore", is(0)))
                .andExpect(jsonPath("$.data.criteriaScores[0].score").doesNotExist());
    }
}
