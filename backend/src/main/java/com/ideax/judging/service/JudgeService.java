package com.ideax.judging.service;

import com.ideax.judging.dto.request.CreateJudgeRequest;
import com.ideax.judging.dto.request.UpdateJudgeRequest;
import com.ideax.judging.dto.response.JudgeResponse;
import com.ideax.judging.entity.Judging;
import com.ideax.judging.entity.Role;
import com.ideax.judging.entity.User;
import com.ideax.judging.exception.AppException;
import com.ideax.judging.exception.DuplicateResourceException;
import com.ideax.judging.exception.ErrorCode;
import com.ideax.judging.exception.ResourceNotFoundException;
import com.ideax.judging.mapper.JudgeMapper;
import com.ideax.judging.repository.JudgingRepository;
import com.ideax.judging.repository.ScoreRepository;
import com.ideax.judging.repository.UserRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
public class JudgeService {

    private static final Logger log = LoggerFactory.getLogger(JudgeService.class);

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JudgeMapper judgeMapper;
    private final JudgingRepository judgingRepository;
    private final ScoreRepository scoreRepository;

    public JudgeService(UserRepository userRepository, PasswordEncoder passwordEncoder, JudgeMapper judgeMapper, JudgingRepository judgingRepository, ScoreRepository scoreRepository) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
        this.judgeMapper = judgeMapper;
        this.judgingRepository = judgingRepository;
        this.scoreRepository = scoreRepository;
    }

    @Transactional(readOnly = true)
    public List<JudgeResponse> getAllJudges() {
        return userRepository.findByRoleOrderByCreatedAtDesc(Role.JUDGE)
                .stream()
                .map(judgeMapper::toResponse)
                .toList();
    }

    @Transactional(readOnly = true)
    public JudgeResponse getJudgeById(Long id) {
        User user = userRepository.findById(id)
                .filter(u -> u.getRole() == Role.JUDGE)
                .orElseThrow(() -> new ResourceNotFoundException("Judge account not found with id: " + id));
        return judgeMapper.toResponse(user);
    }

    @Transactional
    public JudgeResponse createJudge(CreateJudgeRequest request) {
        String username = request.getUsername().trim();
        if (userRepository.existsByUsername(username)) {
            throw new DuplicateResourceException("Username already exists: " + username);
        }

        User judge = new User(
                username,
                passwordEncoder.encode(request.getPassword()),
                Role.JUDGE, // Automatically enforce JUDGE role
                true
        );

        User saved = userRepository.save(judge);
        log.info("Admin created judge account id: {}, username: {}", saved.getId(), saved.getUsername());
        return judgeMapper.toResponse(saved);
    }

    @Transactional
    public JudgeResponse updateJudge(Long id, UpdateJudgeRequest request) {
        User judge = userRepository.findById(id)
                .filter(u -> u.getRole() == Role.JUDGE)
                .orElseThrow(() -> new ResourceNotFoundException("Judge account not found with id: " + id));

        String newUsername = request.getUsername().trim();
        if (!judge.getUsername().equalsIgnoreCase(newUsername) && userRepository.existsByUsername(newUsername)) {
            throw new DuplicateResourceException("Username already exists: " + newUsername);
        }

        judge.setUsername(newUsername);
        if (request.getPassword() != null && !request.getPassword().trim().isEmpty()) {
            judge.setPasswordHash(passwordEncoder.encode(request.getPassword().trim()));
            log.info("Admin updated password for judge id: {}", judge.getId());
        }

        // Strictly preserve role = JUDGE
        judge.setRole(Role.JUDGE);

        User updated = userRepository.save(judge);
        log.info("Admin updated judge account id: {}, username: {}", updated.getId(), updated.getUsername());
        return judgeMapper.toResponse(updated);
    }

    @Transactional
    public JudgeResponse updateJudgeStatus(Long id, boolean active) {
        User judge = userRepository.findById(id)
                .filter(u -> u.getRole() == Role.JUDGE)
                .orElseThrow(() -> new ResourceNotFoundException("Judge account not found with id: " + id));

        judge.setActive(active);
        User updated = userRepository.save(judge);
        log.info("Admin updated judge id: {} status to active={}", updated.getId(), active);
        return judgeMapper.toResponse(updated);
    }

    @Transactional
    public void deleteJudge(Long id) {
        deleteJudge(id, false);
    }

    @Transactional
    public void deleteJudge(Long id, boolean force) {
        User judge = userRepository.findById(id)
                .filter(u -> u.getRole() == Role.JUDGE)
                .orElseThrow(() -> new ResourceNotFoundException("Judge account not found with id: " + id));

        if (!force && judgingRepository.existsByJudgeId(id)) {
            throw new AppException(
                    "This judge cannot be permanently deleted because evaluation records exist. Deactivate the account instead.",
                    HttpStatus.CONFLICT,
                    ErrorCode.JUDGE_HAS_JUDGING_RECORDS
            );
        }

        if (force) {
            List<Judging> judgings = judgingRepository.findByJudgeId(id);
            for (Judging j : judgings) {
                scoreRepository.deleteAll(scoreRepository.findByJudgingId(j.getId()));
            }
            judgingRepository.deleteAll(judgings);
            log.info("Force delete cleared {} judging sessions for judge id: {}", judgings.size(), id);
        }

        userRepository.delete(judge);
        log.info("Admin deleted judge account id: {}, username: {}, force={}", judge.getId(), judge.getUsername(), force);
    }
}
