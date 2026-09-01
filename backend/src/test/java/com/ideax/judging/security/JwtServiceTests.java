package com.ideax.judging.security;

import com.ideax.judging.config.ApplicationProperties;
import com.ideax.judging.entity.Role;
import com.ideax.judging.entity.User;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

class JwtServiceTests {

    private JwtService jwtService;
    private ApplicationProperties properties;

    @BeforeEach
    void setUp() {
        properties = new ApplicationProperties();
        properties.getJwt().setSecret("404E635266556A586E3272357538782F413F4428472B4B6250645367566B5970");
        properties.getJwt().setExpirationMs(3600000);
        jwtService = new JwtService(properties);
    }

    @Test
    void shouldGenerateAndValidateTokenSuccessfully() {
        Long userId = 100L;
        String username = "lead_judge";
        Role role = Role.JUDGE;

        String token = jwtService.generateToken(userId, username, role);

        assertNotNull(token);
        assertTrue(jwtService.validateToken(token));
        assertEquals(username, jwtService.extractUsername(token));
        assertEquals(userId, jwtService.extractUserId(token));
        assertEquals("JUDGE", jwtService.extractRole(token));

        User user = new User(username, "hash", role, true);
        user.setId(userId);
        CustomUserDetails userDetails = new CustomUserDetails(user);

        assertTrue(jwtService.isTokenValid(token, userDetails));
    }

    @Test
    void shouldRejectMalformedToken() {
        assertFalse(jwtService.validateToken("malformed.jwt.token"));
        assertFalse(jwtService.validateToken(""));
        assertFalse(jwtService.validateToken(null));
    }

    @Test
    void shouldRejectExpiredToken() {
        properties.getJwt().setExpirationMs(-1000); // Already expired in past
        JwtService expiredJwtService = new JwtService(properties);

        String expiredToken = expiredJwtService.generateToken(1L, "expired_user", Role.JUDGE);

        assertFalse(jwtService.validateToken(expiredToken));

        User user = new User("expired_user", "hash", Role.JUDGE, true);
        user.setId(1L);
        CustomUserDetails userDetails = new CustomUserDetails(user);

        assertFalse(jwtService.isTokenValid(expiredToken, userDetails));
    }

    @Test
    void shouldRejectTokenWhenUsernameMismatch() {
        String token = jwtService.generateToken(1L, "user_one", Role.JUDGE);

        User differentUser = new User("user_two", "hash", Role.JUDGE, true);
        differentUser.setId(2L);
        CustomUserDetails userDetails = new CustomUserDetails(differentUser);

        assertFalse(jwtService.isTokenValid(token, userDetails));
    }
}
