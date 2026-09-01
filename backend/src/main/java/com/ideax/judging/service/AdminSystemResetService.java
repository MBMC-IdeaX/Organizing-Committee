package com.ideax.judging.service;

import com.ideax.judging.dto.request.ResetDataRequest;
import com.ideax.judging.entity.Judging;
import com.ideax.judging.entity.Role;
import com.ideax.judging.entity.Score;
import com.ideax.judging.entity.User;
import com.ideax.judging.exception.AppException;
import com.ideax.judging.exception.ErrorCode;
import com.ideax.judging.repository.JudgingRepository;
import com.ideax.judging.repository.ScoreRepository;
import com.ideax.judging.repository.TeamRepository;
import com.ideax.judging.repository.UserRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

@Service
public class AdminSystemResetService {

    private static final Logger log = LoggerFactory.getLogger(AdminSystemResetService.class);

    private final UserRepository userRepository;
    private final TeamRepository teamRepository;
    private final JudgingRepository judgingRepository;
    private final ScoreRepository scoreRepository;
    private final PasswordEncoder passwordEncoder;

    public AdminSystemResetService(UserRepository userRepository,
                                   TeamRepository teamRepository,
                                   JudgingRepository judgingRepository,
                                   ScoreRepository scoreRepository,
                                   PasswordEncoder passwordEncoder) {
        this.userRepository = userRepository;
        this.teamRepository = teamRepository;
        this.judgingRepository = judgingRepository;
        this.scoreRepository = scoreRepository;
        this.passwordEncoder = passwordEncoder;
    }

    @Transactional
    public Map<String, Object> resetCompetitionData(String adminUsername, ResetDataRequest request) {
        User admin = userRepository.findByUsername(adminUsername)
                .orElseThrow(() -> new AppException("Admin user not found", HttpStatus.UNAUTHORIZED, ErrorCode.RESET_UNAUTHORIZED));

        if (admin.getRole() != Role.ADMIN || !admin.isActive()) {
            throw new AppException("Only active administrators can reset competition data", HttpStatus.FORBIDDEN, ErrorCode.ACCESS_DENIED);
        }

        if (request.getAdminPassword() == null || request.getAdminPassword().trim().isEmpty() ||
                !passwordEncoder.matches(request.getAdminPassword().trim(), admin.getPasswordHash())) {
            log.warn("Failed system reset attempt by admin '{}': Invalid password", adminUsername);
            throw new AppException("Administrator verification failed. Please check your password.", HttpStatus.UNAUTHORIZED, ErrorCode.RESET_INVALID_PASSWORD);
        }

        if (!request.isClearJudgings() && !request.isClearJudges() && !request.isClearTeams()) {
            throw new AppException("At least one reset operation must be selected.", HttpStatus.BAD_REQUEST, ErrorCode.VALIDATION_ERROR);
        }

        log.info("Admin '{}' authorized system reset. Operations: clearJudgings={}, clearJudges={}, clearTeams={}",
                adminUsername, request.isClearJudgings(), request.isClearJudges(), request.isClearTeams());

        int scoresCleared = 0;
        int judgingsReset = 0;
        int judgesDeleted = 0;
        int teamsDeleted = 0;

        // 1. Clear all scores and judging sessions if Option A, or if clearing teams
        if (request.isClearJudgings() || request.isClearTeams()) {
            scoresCleared = (int) scoreRepository.count();
            scoreRepository.deleteAllInBatch();

            judgingsReset = (int) judgingRepository.count();
            judgingRepository.deleteAllInBatch();
        } else if (request.isClearJudges()) {
            // Delete scores and judgings only for judges being deleted
            List<User> judges = userRepository.findAll().stream()
                    .filter(u -> u.getRole() == Role.JUDGE)
                    .toList();
            for (User judge : judges) {
                List<Judging> judgeJudgings = judgingRepository.findByJudgeId(judge.getId());
                for (Judging j : judgeJudgings) {
                    List<Score> scores = scoreRepository.findByJudgingId(j.getId());
                    scoresCleared += scores.size();
                    scoreRepository.deleteAll(scores);
                }
                judgingsReset += judgeJudgings.size();
                judgingRepository.deleteAll(judgeJudgings);
            }
            judgingRepository.flush();
        }

        // 2. Delete all judge accounts if Option B is selected
        if (request.isClearJudges()) {
            List<User> judges = userRepository.findAll().stream()
                    .filter(u -> u.getRole() == Role.JUDGE)
                    .toList();
            judgesDeleted = judges.size();
            userRepository.deleteAll(judges);
            userRepository.flush();
            log.info("Deleted {} judge accounts (Admin accounts strictly preserved)", judgesDeleted);
        }

        // 3. Delete all participating teams if Option C is selected
        if (request.isClearTeams()) {
            teamsDeleted = (int) teamRepository.count();
            teamRepository.deleteAllInBatch();
            log.info("Deleted {} participating teams", teamsDeleted);
        }

        Map<String, Object> result = new LinkedHashMap<>();
        result.put("scoresCleared", scoresCleared);
        result.put("judgingsReset", judgingsReset);
        result.put("judgesDeleted", judgesDeleted);
        result.put("teamsDeleted", teamsDeleted);

        return result;
    }
}
