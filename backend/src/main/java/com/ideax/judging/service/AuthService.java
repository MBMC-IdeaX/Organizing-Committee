package com.ideax.judging.service;

import com.ideax.judging.dto.request.LoginRequest;
import com.ideax.judging.dto.request.RegisterUserRequest;
import com.ideax.judging.dto.response.AuthResponse;
import com.ideax.judging.dto.response.UserResponse;
import com.ideax.judging.entity.User;
import com.ideax.judging.exception.DuplicateResourceException;
import com.ideax.judging.exception.ResourceNotFoundException;
import com.ideax.judging.mapper.UserMapper;
import com.ideax.judging.repository.UserRepository;
import com.ideax.judging.security.CustomUserDetails;
import com.ideax.judging.security.JwtService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class AuthService {

    private static final Logger log = LoggerFactory.getLogger(AuthService.class);

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;
    private final AuthenticationManager authenticationManager;
    private final UserMapper userMapper;

    public AuthService(
            UserRepository userRepository,
            PasswordEncoder passwordEncoder,
            JwtService jwtService,
            AuthenticationManager authenticationManager,
            UserMapper userMapper
    ) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
        this.jwtService = jwtService;
        this.authenticationManager = authenticationManager;
        this.userMapper = userMapper;
    }

    public AuthResponse login(LoginRequest request) {
        log.info("Attempting login for user: {}", request.getUsername());

        Authentication authentication = authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(request.getUsername(), request.getPassword())
        );

        CustomUserDetails userDetails = (CustomUserDetails) authentication.getPrincipal();
        User user = userRepository.findById(userDetails.getId())
                .orElseThrow(() -> new ResourceNotFoundException("User not found: " + userDetails.getUsername()));

        String token = jwtService.generateToken(user.getId(), user.getUsername(), user.getRole());
        UserResponse userResponse = userMapper.toResponse(user);

        log.info("User {} successfully authenticated with role {}", user.getUsername(), user.getRole());
        return new AuthResponse(token, userResponse);
    }

    @Transactional
    public UserResponse register(RegisterUserRequest request) {
        if (userRepository.existsByUsername(request.getUsername())) {
            throw new DuplicateResourceException("Username is already taken: " + request.getUsername());
        }

        User user = new User(
                request.getUsername(),
                passwordEncoder.encode(request.getPassword()),
                request.getRole(),
                true
        );

        User savedUser = userRepository.save(user);
        log.info("Created new user: {} with role: {}", savedUser.getUsername(), savedUser.getRole());
        return userMapper.toResponse(savedUser);
    }

    @Transactional(readOnly = true)
    public UserResponse getCurrentUser(String username) {
        User user = userRepository.findByUsername(username)
                .orElseThrow(() -> new ResourceNotFoundException("User not found: " + username));
        return userMapper.toResponse(user);
    }
}
