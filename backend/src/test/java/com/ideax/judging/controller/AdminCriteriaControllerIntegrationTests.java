package com.ideax.judging.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.ideax.judging.dto.request.CreateCriteriaRequest;
import com.ideax.judging.dto.request.ReorderRequest;
import com.ideax.judging.entity.Criteria;
import com.ideax.judging.entity.Role;
import com.ideax.judging.entity.User;
import com.ideax.judging.repository.CriteriaRepository;
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
class AdminCriteriaControllerIntegrationTests {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private CriteriaRepository criteriaRepository;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private com.ideax.judging.repository.ScoreRepository scoreRepository;

    @Autowired
    private com.ideax.judging.repository.JudgingRepository judgingRepository;

    @Autowired
    private com.ideax.judging.repository.TeamRepository teamRepository;

    @Autowired
    private JwtService jwtService;

    @Autowired
    private ObjectMapper objectMapper;

    private String adminToken;

    @BeforeEach
    void setUp() {
        scoreRepository.deleteAll();
        judgingRepository.deleteAll();
        teamRepository.deleteAll();
        criteriaRepository.deleteAll();
        userRepository.deleteAll();

        User admin = userRepository.save(new User("admin_crit_mgr", "hash", Role.ADMIN, true));

        adminToken = jwtService.generateToken(admin.getId(), admin.getUsername(), admin.getRole());
    }

    @Test
    void shouldAllowAdminToCreateAndGetCriteria() throws Exception {
        CreateCriteriaRequest request = new CreateCriteriaRequest("Innovation", "Novelty & uniqueness", 20, 1);

        mockMvc.perform(post("/api/v1/admin/criteria")
                        .header("Authorization", "Bearer " + adminToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.success", is(true)))
                .andExpect(jsonPath("$.data.name", is("Innovation")))
                .andExpect(jsonPath("$.data.maxScore", is(20)));

        mockMvc.perform(get("/api/v1/admin/criteria")
                        .header("Authorization", "Bearer " + adminToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success", is(true)))
                .andExpect(jsonPath("$.data", hasSize(1)));
    }

    @Test
    void shouldRejectInvalidMaxScore() throws Exception {
        CreateCriteriaRequest request = new CreateCriteriaRequest("Impact", "Desc", 0, 1);

        mockMvc.perform(post("/api/v1/admin/criteria")
                        .header("Authorization", "Bearer " + adminToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.errorCode", is("VALIDATION_ERROR")));
    }

    @Test
    void shouldCalculateActiveTotalMaxScoreOnly() throws Exception {
        criteriaRepository.save(new Criteria("Innovation", "D1", 20, 1, true));
        criteriaRepository.save(new Criteria("Technical", "D2", 20, 2, true));
        criteriaRepository.save(new Criteria("Archived Rule", "D3", 30, 3, false)); // Inactive: should be excluded

        mockMvc.perform(get("/api/v1/admin/criteria/total-score")
                        .header("Authorization", "Bearer " + adminToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.totalMaxScore", is(40))); // 20 + 20 = 40 (inactive 30 excluded)
    }

    @Test
    void shouldBatchReorderCriteriaAndPersistOrderInDatabase() throws Exception {
        Criteria c1 = criteriaRepository.save(new Criteria("Crit 1", "D1", 10, 1, true));
        Criteria c2 = criteriaRepository.save(new Criteria("Crit 2", "D2", 20, 2, true));

        ReorderRequest reorder = new ReorderRequest(List.of(c2.getId(), c1.getId()));

        mockMvc.perform(put("/api/v1/admin/criteria/reorder")
                        .header("Authorization", "Bearer " + adminToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(reorder)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data[0].id", is(c2.getId().intValue())))
                .andExpect(jsonPath("$.data[0].displayOrder", is(1)))
                .andExpect(jsonPath("$.data[1].id", is(c1.getId().intValue())))
                .andExpect(jsonPath("$.data[1].displayOrder", is(2)));

        // Distinct subsequent GET to verify persisted database state
        mockMvc.perform(get("/api/v1/admin/criteria")
                        .header("Authorization", "Bearer " + adminToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data[0].id", is(c2.getId().intValue())))
                .andExpect(jsonPath("$.data[0].name", is("Crit 2")))
                .andExpect(jsonPath("$.data[0].displayOrder", is(1)))
                .andExpect(jsonPath("$.data[1].id", is(c1.getId().intValue())))
                .andExpect(jsonPath("$.data[1].name", is("Crit 1")))
                .andExpect(jsonPath("$.data[1].displayOrder", is(2)));
    }
}
