package com.ideax.judging.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.ideax.judging.dto.request.CreateTeamRequest;
import com.ideax.judging.dto.request.ReorderRequest;
import com.ideax.judging.dto.request.StatusUpdateRequest;
import com.ideax.judging.dto.request.UpdateTeamRequest;
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
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;

import java.util.List;

import static org.hamcrest.Matchers.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
class AdminTeamControllerIntegrationTests {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private TeamRepository teamRepository;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private com.ideax.judging.repository.ScoreRepository scoreRepository;

    @Autowired
    private JudgingRepository judgingRepository;

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

        User admin = userRepository.save(new User("admin_team_mgr", "hash", Role.ADMIN, true));
        testJudge = userRepository.save(new User("judge_team_mgr", "hash", Role.JUDGE, true));

        adminToken = jwtService.generateToken(admin.getId(), admin.getUsername(), admin.getRole());
        judgeToken = jwtService.generateToken(testJudge.getId(), testJudge.getUsername(), testJudge.getRole());
    }

    @Test
    void shouldAllowAdminToCreateAndGetTeams() throws Exception {
        CreateTeamRequest request = new CreateTeamRequest("Team Nova", "Smart Ag", "IoT monitoring", 1);

        mockMvc.perform(post("/api/v1/admin/teams")
                        .header("Authorization", "Bearer " + adminToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.success", is(true)))
                .andExpect(jsonPath("$.data.teamName", is("Team Nova")))
                .andExpect(jsonPath("$.data.projectName", is("Smart Ag")))
                .andExpect(jsonPath("$.data.active", is(true)));

        mockMvc.perform(get("/api/v1/admin/teams")
                        .header("Authorization", "Bearer " + adminToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success", is(true)))
                .andExpect(jsonPath("$.data", hasSize(1)))
                .andExpect(jsonPath("$.data[0].teamName", is("Team Nova")));
    }

    @Test
    void shouldAllowAdminToUpdateAndToggleTeamStatus() throws Exception {
        Team team = teamRepository.save(new Team("Team Spark", "Solar AI", "Clean Energy", 2, true));

        UpdateTeamRequest updateRequest = new UpdateTeamRequest("Team Spark Updated", "Solar AI Pro", "Enhanced AI", 5);

        mockMvc.perform(put("/api/v1/admin/teams/" + team.getId())
                        .header("Authorization", "Bearer " + adminToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(updateRequest)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.teamName", is("Team Spark Updated")))
                .andExpect(jsonPath("$.data.displayOrder", is(5)));

        StatusUpdateRequest statusRequest = new StatusUpdateRequest(false);
        mockMvc.perform(patch("/api/v1/admin/teams/" + team.getId() + "/status")
                        .header("Authorization", "Bearer " + adminToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(statusRequest)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.active", is(false)));
    }

    @Test
    void shouldBatchReorderTeamsAndPersistOrderInDatabase() throws Exception {
        Team t1 = teamRepository.save(new Team("Team Alpha", "P1", "Idea 1", 1, true));
        Team t2 = teamRepository.save(new Team("Team Beta", "P2", "Idea 2", 2, true));
        Team t3 = teamRepository.save(new Team("Team Gamma", "P3", "Idea 3", 3, true));

        ReorderRequest reorder = new ReorderRequest(List.of(t3.getId(), t1.getId(), t2.getId()));

        mockMvc.perform(put("/api/v1/admin/teams/reorder")
                        .header("Authorization", "Bearer " + adminToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(reorder)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data", hasSize(3)))
                .andExpect(jsonPath("$.data[0].id", is(t3.getId().intValue())))
                .andExpect(jsonPath("$.data[0].displayOrder", is(1)))
                .andExpect(jsonPath("$.data[1].id", is(t1.getId().intValue())))
                .andExpect(jsonPath("$.data[1].displayOrder", is(2)))
                .andExpect(jsonPath("$.data[2].id", is(t2.getId().intValue())))
                .andExpect(jsonPath("$.data[2].displayOrder", is(3)));

        // Distinct subsequent GET to verify persisted database state
        mockMvc.perform(get("/api/v1/admin/teams")
                        .header("Authorization", "Bearer " + adminToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data[0].id", is(t3.getId().intValue())))
                .andExpect(jsonPath("$.data[0].teamName", is("Team Gamma")))
                .andExpect(jsonPath("$.data[0].displayOrder", is(1)))
                .andExpect(jsonPath("$.data[1].id", is(t1.getId().intValue())))
                .andExpect(jsonPath("$.data[1].teamName", is("Team Alpha")))
                .andExpect(jsonPath("$.data[1].displayOrder", is(2)))
                .andExpect(jsonPath("$.data[2].id", is(t2.getId().intValue())))
                .andExpect(jsonPath("$.data[2].teamName", is("Team Beta")))
                .andExpect(jsonPath("$.data[2].displayOrder", is(3)));
    }

    @Test
    void shouldForbidJudgeFromAccessingAdminTeams() throws Exception {
        mockMvc.perform(get("/api/v1/admin/teams")
                        .header("Authorization", "Bearer " + judgeToken))
                .andExpect(status().isForbidden())
                .andExpect(jsonPath("$.errorCode", is("ACCESS_DENIED")));
    }

    @Test
    void shouldRejectUnauthenticatedRequests() throws Exception {
        mockMvc.perform(get("/api/v1/admin/teams"))
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.errorCode", is("UNAUTHORIZED")));
    }

    @Test
    void shouldAllowAdminToDeleteUnusedTeamAndReindexRemainingTeams() throws Exception {
        Team t1 = teamRepository.save(new Team("Team Alpha", "P1", "Idea 1", 1, true));
        Team t2 = teamRepository.save(new Team("Team Nova", "P2", "Idea 2", 2, true));
        Team t3 = teamRepository.save(new Team("Team Vision", "P3", "Idea 3", 3, true));

        mockMvc.perform(delete("/api/v1/admin/teams/" + t2.getId())
                        .header("Authorization", "Bearer " + adminToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success", is(true)))
                .andExpect(jsonPath("$.message", is("Team deleted successfully")));

        // Verify t2 is gone and t1, t3 are re-indexed consecutively (1, 2)
        mockMvc.perform(get("/api/v1/admin/teams")
                        .header("Authorization", "Bearer " + adminToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data", hasSize(2)))
                .andExpect(jsonPath("$.data[0].id", is(t1.getId().intValue())))
                .andExpect(jsonPath("$.data[0].teamName", is("Team Alpha")))
                .andExpect(jsonPath("$.data[0].displayOrder", is(1)))
                .andExpect(jsonPath("$.data[1].id", is(t3.getId().intValue())))
                .andExpect(jsonPath("$.data[1].teamName", is("Team Vision")))
                .andExpect(jsonPath("$.data[1].displayOrder", is(2)));
    }

    @Test
    void shouldRejectDeleteTeamWhenJudgingRecordsExist() throws Exception {
        Team team = teamRepository.save(new Team("Team Judged", "P Judged", "Idea Judged", 1, true));
        judgingRepository.save(new Judging(testJudge, team, JudgingStatus.IN_PROGRESS, "Evaluating..."));

        mockMvc.perform(delete("/api/v1/admin/teams/" + team.getId())
                        .header("Authorization", "Bearer " + adminToken))
                .andExpect(status().isConflict())
                .andExpect(jsonPath("$.success", is(false)))
                .andExpect(jsonPath("$.errorCode", is("TEAM_HAS_JUDGING_RECORDS")))
                .andExpect(jsonPath("$.message", containsString("judging records exist for it")));

        // Verify team still exists
        mockMvc.perform(get("/api/v1/admin/teams/" + team.getId())
                        .header("Authorization", "Bearer " + adminToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.id", is(team.getId().intValue())));
    }

    @Test
    void shouldForbidJudgeFromDeletingTeam() throws Exception {
        Team team = teamRepository.save(new Team("Team Secret", "P Secret", "Idea", 1, true));

        mockMvc.perform(delete("/api/v1/admin/teams/" + team.getId())
                        .header("Authorization", "Bearer " + judgeToken))
                .andExpect(status().isForbidden())
                .andExpect(jsonPath("$.errorCode", is("ACCESS_DENIED")));
    }

    @Test
    void shouldRejectUnauthenticatedUserFromDeletingTeam() throws Exception {
        Team team = teamRepository.save(new Team("Team Secret", "P Secret", "Idea", 1, true));

        mockMvc.perform(delete("/api/v1/admin/teams/" + team.getId()))
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.errorCode", is("UNAUTHORIZED")));
    }
}
