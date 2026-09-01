package com.ideax.judging.service;

import com.ideax.judging.dto.request.LoginRequest;
import com.ideax.judging.dto.request.RegisterUserRequest;
import com.ideax.judging.dto.response.AuthResponse;
import com.ideax.judging.dto.response.UserResponse;
import com.ideax.judging.entity.Role;
import com.ideax.judging.entity.User;
import com.ideax.judging.exception.DuplicateResourceException;
import com.ideax.judging.mapper.UserMapper;
import com.ideax.judging.repository.UserRepository;
import com.ideax.judging.security.CustomUserDetails;
import com.ideax.judging.security.JwtService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.crypto.password.PasswordEncoder;

import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class AuthServiceTests {

    @Mock
    private UserRepository userRepository;

    @Mock
    private PasswordEncoder passwordEncoder;

    @Mock
    private JwtService jwtService;

    @Mock
    private AuthenticationManager authenticationManager;

    @Mock
    private UserMapper userMapper;

    @InjectMocks
    private AuthService authService;

    private User sampleUser;

    @BeforeEach
    void setUp() {
        sampleUser = new User("judge_john", "encoded_password", Role.JUDGE, true);
        sampleUser.setId(10L);
    }

    @Test
    void shouldLoginSuccessfully() {
        LoginRequest request = new LoginRequest("judge_john", "secret123");
        CustomUserDetails userDetails = new CustomUserDetails(sampleUser);
        Authentication authentication = mock(Authentication.class);
        when(authentication.getPrincipal()).thenReturn(userDetails);

        when(authenticationManager.authenticate(any(UsernamePasswordAuthenticationToken.class))).thenReturn(authentication);
        when(userRepository.findById(10L)).thenReturn(Optional.of(sampleUser));
        when(jwtService.generateToken(10L, "judge_john", Role.JUDGE)).thenReturn("mocked.jwt.token");
        when(userMapper.toResponse(sampleUser)).thenReturn(new UserResponse(10L, "judge_john", Role.JUDGE, true, null));

        AuthResponse response = authService.login(request);

        assertNotNull(response);
        assertEquals("mocked.jwt.token", response.getToken());
        assertEquals("judge_john", response.getUser().getUsername());
        assertEquals(Role.JUDGE, response.getUser().getRole());
    }

    @Test
    void shouldThrowWhenRegisteringDuplicateUsername() {
        RegisterUserRequest request = new RegisterUserRequest("judge_john", "secret123", Role.JUDGE);
        when(userRepository.existsByUsername("judge_john")).thenReturn(true);

        assertThrows(DuplicateResourceException.class, () -> authService.register(request));
    }
}
