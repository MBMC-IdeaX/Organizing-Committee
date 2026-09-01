package com.ideax.judging.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.ideax.judging.dto.request.LoginRequest;
import com.ideax.judging.entity.Role;
import com.ideax.judging.entity.User;
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
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
class AuthControllerIntegrationTests {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private com.ideax.judging.repository.ScoreRepository scoreRepository;

    @Autowired
    private com.ideax.judging.repository.JudgingRepository judgingRepository;

    @Autowired
    private com.ideax.judging.repository.TeamRepository teamRepository;

    @Autowired
    private com.ideax.judging.repository.CriteriaRepository criteriaRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Autowired
    private JwtService jwtService;

    @Autowired
    private ObjectMapper objectMapper;

    private User adminUser;
    private User judgeUser;

    @BeforeEach
    void setUp() {
        scoreRepository.deleteAll();
        judgingRepository.deleteAll();
        teamRepository.deleteAll();
        criteriaRepository.deleteAll();
        userRepository.deleteAll();

        adminUser = userRepository.save(new User(
                "admin_test",
                passwordEncoder.encode("Password123!"),
                Role.ADMIN,
                true
        ));

        judgeUser = userRepository.save(new User(
                "judge_test",
                passwordEncoder.encode("Password123!"),
                Role.JUDGE,
                true
        ));

        userRepository.save(new User(
                "inactive_user",
                passwordEncoder.encode("Password123!"),
                Role.JUDGE,
                false
        ));
    }

    @Test
    void shouldLoginAdminSuccessfully() throws Exception {
        LoginRequest request = new LoginRequest("admin_test", "Password123!");

        mockMvc.perform(post("/api/v1/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success", is(true)))
                .andExpect(jsonPath("$.message", is("Login successful")))
                .andExpect(jsonPath("$.data.token", notNullValue()))
                .andExpect(jsonPath("$.data.tokenType", is("Bearer")))
                .andExpect(jsonPath("$.data.user.username", is("admin_test")))
                .andExpect(jsonPath("$.data.user.role", is("ADMIN")))
                .andExpect(jsonPath("$.data.user.passwordHash").doesNotExist());
    }

    @Test
    void shouldLoginJudgeSuccessfully() throws Exception {
        LoginRequest request = new LoginRequest("judge_test", "Password123!");

        mockMvc.perform(post("/api/v1/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success", is(true)))
                .andExpect(jsonPath("$.data.token", notNullValue()))
                .andExpect(jsonPath("$.data.user.username", is("judge_test")))
                .andExpect(jsonPath("$.data.user.role", is("JUDGE")));
    }

    @Test
    void shouldRejectInvalidCredentials() throws Exception {
        LoginRequest request = new LoginRequest("admin_test", "WrongPassword!");

        mockMvc.perform(post("/api/v1/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.success", is(false)))
                .andExpect(jsonPath("$.errorCode", is("INVALID_CREDENTIALS")));
    }

    @Test
    void shouldRejectInactiveUser() throws Exception {
        LoginRequest request = new LoginRequest("inactive_user", "Password123!");

        mockMvc.perform(post("/api/v1/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.success", is(false)))
                .andExpect(jsonPath("$.message", containsString("inactive")));
    }

    @Test
    void shouldRejectEmptyCredentialsWithValidationError() throws Exception {
        LoginRequest request = new LoginRequest("", "");

        mockMvc.perform(post("/api/v1/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.success", is(false)))
                .andExpect(jsonPath("$.errorCode", is("VALIDATION_ERROR")));
    }

    @Test
    void shouldReturnCurrentUserWithValidToken() throws Exception {
        String token = jwtService.generateToken(judgeUser.getId(), judgeUser.getUsername(), judgeUser.getRole());

        mockMvc.perform(get("/api/v1/auth/me")
                        .header("Authorization", "Bearer " + token))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success", is(true)))
                .andExpect(jsonPath("$.data.username", is("judge_test")))
                .andExpect(jsonPath("$.data.role", is("JUDGE")));
    }

    @Test
    void shouldRejectMeRequestWithoutToken() throws Exception {
        mockMvc.perform(get("/api/v1/auth/me"))
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.success", is(false)))
                .andExpect(jsonPath("$.errorCode", is("UNAUTHORIZED")));
    }

    @Test
    void shouldRejectMeRequestWithInvalidToken() throws Exception {
        mockMvc.perform(get("/api/v1/auth/me")
                        .header("Authorization", "Bearer invalid.jwt.token"))
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.success", is(false)))
                .andExpect(jsonPath("$.errorCode", is("UNAUTHORIZED")));
    }

    @Test
    void shouldAllowAdminToAccessAdminPing() throws Exception {
        String adminToken = jwtService.generateToken(adminUser.getId(), adminUser.getUsername(), adminUser.getRole());

        mockMvc.perform(get("/api/v1/admin/ping")
                        .header("Authorization", "Bearer " + adminToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success", is(true)))
                .andExpect(jsonPath("$.message", containsString("Admin authorization verified")));
    }

    @Test
    void shouldForbidJudgeFromAccessingAdminPing() throws Exception {
        String judgeToken = jwtService.generateToken(judgeUser.getId(), judgeUser.getUsername(), judgeUser.getRole());

        mockMvc.perform(get("/api/v1/admin/ping")
                        .header("Authorization", "Bearer " + judgeToken))
                .andExpect(status().isForbidden())
                .andExpect(jsonPath("$.success", is(false)))
                .andExpect(jsonPath("$.errorCode", is("ACCESS_DENIED")));
    }

    @Test
    void shouldAllowJudgeToAccessJudgePing() throws Exception {
        String judgeToken = jwtService.generateToken(judgeUser.getId(), judgeUser.getUsername(), judgeUser.getRole());

        mockMvc.perform(get("/api/v1/judge/ping")
                        .header("Authorization", "Bearer " + judgeToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success", is(true)))
                .andExpect(jsonPath("$.message", containsString("Judge authorization verified")));
    }

    @Test
    void shouldForbidAdminFromAccessingJudgePing() throws Exception {
        String adminToken = jwtService.generateToken(adminUser.getId(), adminUser.getUsername(), adminUser.getRole());

        mockMvc.perform(get("/api/v1/judge/ping")
                        .header("Authorization", "Bearer " + adminToken))
                .andExpect(status().isForbidden())
                .andExpect(jsonPath("$.success", is(false)))
                .andExpect(jsonPath("$.errorCode", is("ACCESS_DENIED")));
    }

    @Test
    void shouldHandleCorsPreflightFromDynamicFlutterWebOrigin() throws Exception {
        mockMvc.perform(org.springframework.test.web.servlet.request.MockMvcRequestBuilders.options("/api/v1/auth/login")
                        .header("Origin", "http://localhost:53338")
                        .header("Access-Control-Request-Method", "POST")
                        .header("Access-Control-Request-Headers", "content-type,authorization,accept"))
                .andExpect(status().isOk())
                .andExpect(header().string("Access-Control-Allow-Origin", "http://localhost:53338"))
                .andExpect(header().string("Access-Control-Allow-Credentials", "true"));
    }

    @Test
    void shouldAllowLoginFromFlutterWebDynamicOrigin() throws Exception {
        LoginRequest request = new LoginRequest("admin_test", "Password123!");

        mockMvc.perform(post("/api/v1/auth/login")
                        .header("Origin", "http://localhost:53338")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(header().string("Access-Control-Allow-Origin", "http://localhost:53338"))
                .andExpect(jsonPath("$.success", is(true)))
                .andExpect(jsonPath("$.data.token", notNullValue()));
    }
}
