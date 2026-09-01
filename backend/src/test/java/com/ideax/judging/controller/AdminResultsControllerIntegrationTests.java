package com.ideax.judging.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.ideax.judging.entity.*;
import com.ideax.judging.exception.ErrorCode;
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

import java.time.LocalDateTime;

import static org.hamcrest.Matchers.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
class AdminResultsControllerIntegrationTests {

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

    private User admin;
    private User judge1;
    private User judge2;
    private User inactiveJudge;

    private String adminToken;
    private String judgeToken;

    private Team teamA;
    private Team teamB;
    private Team teamC;
    private Team inactiveTeam;

    private Criteria crit1;
    private Criteria crit2;
    private Criteria inactiveCrit;

    @BeforeEach
    void setUp() {
        scoreRepository.deleteAll();
        judgingRepository.deleteAll();
        criteriaRepository.deleteAll();
        teamRepository.deleteAll();
        userRepository.deleteAll();

        admin = userRepository.save(new User("admin_results", "hash", Role.ADMIN, true));
        judge1 = userRepository.save(new User("judge_alpha", "hash", Role.JUDGE, true));
        judge2 = userRepository.save(new User("judge_beta", "hash", Role.JUDGE, true));
        inactiveJudge = userRepository.save(new User("judge_inactive", "hash", Role.JUDGE, false));

        adminToken = jwtService.generateToken(admin.getId(), admin.getUsername(), admin.getRole());
        judgeToken = jwtService.generateToken(judge1.getId(), judge1.getUsername(), judge1.getRole());

        // Teams in displayOrder 1, 2, 3
        teamA = teamRepository.save(new Team("Team A", "Project A", "Idea A", 1, true));
        teamB = teamRepository.save(new Team("Team B", "Project B", "Idea B", 2, true));
        teamC = teamRepository.save(new Team("Team C", "Project C", "Idea C", 3, true));
        inactiveTeam = teamRepository.save(new Team("Team Inactive", "Project I", "Idea I", 4, false));

        // Active criteria (max 20 each) and inactive
        crit1 = criteriaRepository.save(new Criteria("Innovation", "Description 1", 20, 1, true));
        crit2 = criteriaRepository.save(new Criteria("Technical", "Description 2", 20, 2, true));
        inactiveCrit = criteriaRepository.save(new Criteria("Presentation", "Description 3", 10, 3, false));
    }

    @Test
    void shouldEnforceSecurityConstraints() throws Exception {
        // Summary: 401 without token
        mockMvc.perform(get("/api/v1/admin/results/summary"))
                .andExpect(status().isUnauthorized());

        // Summary: 403 for Judge
        mockMvc.perform(get("/api/v1/admin/results/summary")
                        .header("Authorization", "Bearer " + judgeToken))
                .andExpect(status().isForbidden());

        // Summary: 200 for Admin
        mockMvc.perform(get("/api/v1/admin/results/summary")
                        .header("Authorization", "Bearer " + adminToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success", is(true)));
    }

    @Test
    void shouldReturnConflictWhenJudgingIsIncomplete() throws Exception {
        // 3 active teams, 2 active judges -> 6 required evaluations.
        // Let's complete only 5 evaluations.
        seedEvaluation(judge1, teamA, 15, 15, "Good comment");
        seedEvaluation(judge1, teamB, 12, 18, null);
        seedEvaluation(judge1, teamC, 10, 10, null);
        seedEvaluation(judge2, teamA, 14, 16, null);
        seedEvaluation(judge2, teamB, 11, 19, null);

        // Verify summary reports incomplete status
        mockMvc.perform(get("/api/v1/admin/results/summary")
                        .header("Authorization", "Bearer " + adminToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.judgingComplete", is(false)))
                .andExpect(jsonPath("$.data.completedEvaluations", is(5)))
                .andExpect(jsonPath("$.data.totalRequiredEvaluations", is(6)))
                .andExpect(jsonPath("$.data.resultsAvailable", is(false)));

        // Ranking endpoint must return 409 Conflict
        mockMvc.perform(get("/api/v1/admin/results/ranking")
                        .header("Authorization", "Bearer " + adminToken))
                .andExpect(status().isConflict())
                .andExpect(jsonPath("$.success", is(false)))
                .andExpect(jsonPath("$.errorCode", is(ErrorCode.RESULTS_NOT_READY.name())));

        // Team detail endpoint must return 409 Conflict
        mockMvc.perform(get("/api/v1/admin/results/teams/" + teamA.getId())
                        .header("Authorization", "Bearer " + adminToken))
                .andExpect(status().isConflict())
                .andExpect(jsonPath("$.success", is(false)))
                .andExpect(jsonPath("$.errorCode", is(ErrorCode.RESULTS_NOT_READY.name())));
    }

    @Test
    void shouldReturnCorrectResultsAndTieBreakersWhenComplete() throws Exception {
        // Required evaluations: 6 (3 teams * 2 active judges)
        // Let's complete all 6 evaluations.
        // Team A scores:
        // Judge 1: crit1=18, crit2=16 (Total=34)
        // Judge 2: crit1=17, crit2=17 (Total=34)
        // Team A Aggregate = 68 / 80 (Average = 34 / 40, Percentage = 85.0%)
        seedEvaluation(judge1, teamA, 18, 16, "A1 comment");
        seedEvaluation(judge2, teamA, 17, 17, "A2 comment");

        // Team B scores:
        // Judge 1: crit1=19, crit2=15 (Total=34)
        // Judge 2: crit1=16, crit2=18 (Total=34)
        // Team B Aggregate = 68 / 80 (Average = 34 / 40, Percentage = 85.0%)
        // Note: Team A and Team B have EXACT same percentage (85%) and aggregate (68).
        // Tie-breaker rule (crit1 displayOrder=1):
        // Team A crit1 scores: 18 + 17 = 35 (Avg = 17.5)
        // Team B crit1 scores: 19 + 16 = 35 (Avg = 17.5)
        // Tied on crit1 average as well.
        // Second tie-breaker (crit2 displayOrder=2):
        // Team A crit2 scores: 16 + 17 = 33 (Avg = 16.5)
        // Team B crit2 scores: 15 + 18 = 33 (Avg = 16.5)
        // They are exactly tied on everything! They must receive the same rank (Rank 1).
        seedEvaluation(judge1, teamB, 19, 15, null);
        seedEvaluation(judge2, teamB, 16, 18, null);

        // Team C scores:
        // Judge 1: crit1=10, crit2=12 (Total=22)
        // Judge 2: crit1=11, crit2=11 (Total=22)
        // Team C Aggregate = 44 / 80 (Average = 22 / 40, Percentage = 55.0%)
        // Rank should be Rank 3
        seedEvaluation(judge1, teamC, 10, 12, null);
        seedEvaluation(judge2, teamC, 11, 11, null);

        // Inactive team / criterion / judge evaluations should be excluded from requirement/ranking totals
        // Let's seed an evaluation for inactive team to verify it is ignored from active results
        seedEvaluation(judge1, inactiveTeam, 20, 20, null);

        // Verify summary reports judgingComplete = true
        mockMvc.perform(get("/api/v1/admin/results/summary")
                        .header("Authorization", "Bearer " + adminToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.judgingComplete", is(true)))
                .andExpect(jsonPath("$.data.completedEvaluations", is(6)))
                .andExpect(jsonPath("$.data.resultsAvailable", is(true)));

        // Verify rankings list
        mockMvc.perform(get("/api/v1/admin/results/ranking")
                        .header("Authorization", "Bearer " + adminToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data", hasSize(3)))
                // Rank 1 ties
                .andExpect(jsonPath("$.data[0].rank", is(1)))
                .andExpect(jsonPath("$.data[1].rank", is(1)))
                // Competition ranking: 1, 1, 3
                .andExpect(jsonPath("$.data[2].rank", is(3)))
                .andExpect(jsonPath("$.data[2].teamName", is("Team C")))
                .andExpect(jsonPath("$.data[2].percentage", closeTo(55.0, 0.001)));

        // Verify single team result detailed breakdown
        mockMvc.perform(get("/api/v1/admin/results/teams/" + teamA.getId())
                        .header("Authorization", "Bearer " + adminToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.teamName", is("Team A")))
                .andExpect(jsonPath("$.data.rank", is(1)))
                .andExpect(jsonPath("$.data.aggregateTotal", is(68)))
                .andExpect(jsonPath("$.data.aggregateMaxScore", is(80)))
                .andExpect(jsonPath("$.data.percentage", closeTo(85.0, 0.001)))
                .andExpect(jsonPath("$.data.judgeBreakdowns", hasSize(2)))
                .andExpect(jsonPath("$.data.criterionBreakdowns", hasSize(2)))
                .andExpect(jsonPath("$.data.criterionBreakdowns[0].criteriaName", is("Innovation")))
                .andExpect(jsonPath("$.data.criterionBreakdowns[0].averageScore", closeTo(17.5, 0.001)))
                .andExpect(jsonPath("$.data.criterionBreakdowns[1].criteriaName", is("Technical")))
                .andExpect(jsonPath("$.data.criterionBreakdowns[1].averageScore", closeTo(16.5, 0.001)));
    }

    private void seedEvaluation(User judge, Team team, int score1, int score2, String comment) {
        Judging judging = new Judging(judge, team, JudgingStatus.COMPLETED, comment);
        judging.setCompletedAt(LocalDateTime.now());
        judging = judgingRepository.save(judging);

        scoreRepository.save(new Score(judging, crit1, score1));
        scoreRepository.save(new Score(judging, crit2, score2));
        scoreRepository.save(new Score(judging, inactiveCrit, 5)); // Should be ignored in calculations
    }
}
