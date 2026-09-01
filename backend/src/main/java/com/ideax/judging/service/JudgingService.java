package com.ideax.judging.service;

import com.ideax.judging.dto.request.CompleteJudgingRequest;
import com.ideax.judging.dto.request.CriteriaScoreItem;
import com.ideax.judging.dto.request.SaveScoresRequest;
import com.ideax.judging.dto.response.JudgeDashboardResponse;
import com.ideax.judging.dto.response.JudgeTeamResponse;
import com.ideax.judging.dto.response.JudgingCriteriaScoreResponse;
import com.ideax.judging.dto.response.JudgingSessionResponse;
import com.ideax.judging.entity.*;
import com.ideax.judging.exception.ResourceNotFoundException;
import com.ideax.judging.exception.ValidationException;
import com.ideax.judging.repository.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.*;
import java.util.stream.Collectors;

@Service
public class JudgingService {

    private static final Logger log = LoggerFactory.getLogger(JudgingService.class);

    private final JudgingRepository judgingRepository;
    private final TeamRepository teamRepository;
    private final CriteriaRepository criteriaRepository;
    private final UserRepository userRepository;

    public JudgingService(
            JudgingRepository judgingRepository,
            TeamRepository teamRepository,
            CriteriaRepository criteriaRepository,
            UserRepository userRepository
    ) {
        this.judgingRepository = judgingRepository;
        this.teamRepository = teamRepository;
        this.criteriaRepository = criteriaRepository;
        this.userRepository = userRepository;
    }

    @Transactional(readOnly = true)
    public JudgeDashboardResponse getJudgeDashboard(Long judgeId) {
        List<Team> activeTeams = teamRepository.findByActiveTrueOrderByDisplayOrderAsc();
        List<Judging> judgings = judgingRepository.findByJudgeIdAndTeam_ActiveTrue(judgeId);

        Map<Long, Judging> judgingMap = judgings.stream()
                .collect(Collectors.toMap(j -> j.getTeam().getId(), j -> j, (a, b) -> a));

        Long totalMaxScoreLong = criteriaRepository.sumMaxScoreByActiveTrue();
        int totalMaxScore = totalMaxScoreLong != null ? totalMaxScoreLong.intValue() : 0;

        long totalTeams = activeTeams.size();
        long completedTeams = judgings.stream()
                .filter(j -> j.getStatus() == JudgingStatus.COMPLETED)
                .count();
        long remainingTeams = Math.max(0, totalTeams - completedTeams);
        double progressPercentage = totalTeams > 0 ? ((double) completedTeams / totalTeams) * 100.0 : 0.0;

        JudgeTeamResponse nextTeamResponse = null;
        for (Team team : activeTeams) {
            Judging judging = judgingMap.get(team.getId());
            JudgingStatus status = judging != null ? judging.getStatus() : JudgingStatus.NOT_STARTED;
            if (status != JudgingStatus.COMPLETED) {
                int totalScore = calculateTotalScore(judging);
                nextTeamResponse = new JudgeTeamResponse(
                        team.getId(),
                        team.getTeamName(),
                        team.getProjectName(),
                        team.getIdea(),
                        team.getDisplayOrder(),
                        status,
                        totalScore,
                        totalMaxScore
                );
                break;
            }
        }

        return new JudgeDashboardResponse(
                totalTeams,
                completedTeams,
                remainingTeams,
                progressPercentage,
                nextTeamResponse
        );
    }

    @Transactional(readOnly = true)
    public List<JudgeTeamResponse> getJudgeTeams(Long judgeId) {
        List<Team> activeTeams = teamRepository.findByActiveTrueOrderByDisplayOrderAsc();
        List<Judging> judgings = judgingRepository.findByJudgeIdAndTeam_ActiveTrue(judgeId);

        Map<Long, Judging> judgingMap = judgings.stream()
                .collect(Collectors.toMap(j -> j.getTeam().getId(), j -> j, (a, b) -> a));

        Long totalMaxScoreLong = criteriaRepository.sumMaxScoreByActiveTrue();
        int totalMaxScore = totalMaxScoreLong != null ? totalMaxScoreLong.intValue() : 0;

        return activeTeams.stream().map(team -> {
            Judging judging = judgingMap.get(team.getId());
            JudgingStatus status = judging != null ? judging.getStatus() : JudgingStatus.NOT_STARTED;
            int totalScore = calculateTotalScore(judging);
            return new JudgeTeamResponse(
                    team.getId(),
                    team.getTeamName(),
                    team.getProjectName(),
                    team.getIdea(),
                    team.getDisplayOrder(),
                    status,
                    totalScore,
                    totalMaxScore
            );
        }).toList();
    }

    @Transactional(readOnly = true)
    public JudgingSessionResponse getJudgingSession(Long judgeId, Long teamId) {
        Team team = getActiveTeamOrThrow(teamId);
        Optional<Judging> optionalJudging = judgingRepository.findByJudgeIdAndTeamId(judgeId, teamId);

        Judging judging = optionalJudging.orElse(null);
        return buildJudgingSessionResponse(team, judging);
    }

    @Transactional
    public JudgingSessionResponse startJudging(Long judgeId, Long teamId) {
        User judge = getJudgeUserOrThrow(judgeId);
        Team team = getActiveTeamOrThrow(teamId);

        Optional<Judging> optionalJudging = judgingRepository.findByJudgeIdAndTeamId(judgeId, teamId);
        Judging judging;

        if (optionalJudging.isPresent()) {
            judging = optionalJudging.get();
            if (judging.getStatus() == JudgingStatus.NOT_STARTED) {
                judging.setStatus(JudgingStatus.IN_PROGRESS);
                judging = judgingRepository.save(judging);
                log.info("Judge {} updated judging session for team {} to IN_PROGRESS", judgeId, teamId);
            }
        } else {
            judging = new Judging(judge, team, JudgingStatus.IN_PROGRESS, null);
            judging = judgingRepository.save(judging);
            log.info("Judge {} started new judging session for team {}", judgeId, teamId);
        }

        return buildJudgingSessionResponse(team, judging);
    }

    @Transactional
    public JudgingSessionResponse saveScores(Long judgeId, Long teamId, SaveScoresRequest request) {
        User judge = getJudgeUserOrThrow(judgeId);
        Team team = getActiveTeamOrThrow(teamId);

        Judging judging = judgingRepository.findByJudgeIdAndTeamId(judgeId, teamId)
                .orElseGet(() -> judgingRepository.save(new Judging(judge, team, JudgingStatus.IN_PROGRESS, null)));

        if (judging.getStatus() == JudgingStatus.COMPLETED) {
            throw new ValidationException("Completed judging sessions are immutable and cannot be modified");
        }

        applyAndValidateScores(judging, request.getScores());
        judging = judgingRepository.save(judging);
        log.info("Judge {} saved {} scores for team {}", judgeId, request.getScores().size(), teamId);

        return buildJudgingSessionResponse(team, judging);
    }

    @Transactional
    public JudgingSessionResponse saveComment(Long judgeId, Long teamId, String comment) {
        User judge = getJudgeUserOrThrow(judgeId);
        Team team = getActiveTeamOrThrow(teamId);

        Judging judging = judgingRepository.findByJudgeIdAndTeamId(judgeId, teamId)
                .orElseGet(() -> judgingRepository.save(new Judging(judge, team, JudgingStatus.IN_PROGRESS, null)));

        if (judging.getStatus() == JudgingStatus.COMPLETED) {
            throw new ValidationException("Completed judging sessions are immutable and cannot be modified");
        }

        judging.setComment(comment != null ? comment.trim() : null);
        judging = judgingRepository.save(judging);
        log.info("Judge {} saved comment for team {}", judgeId, teamId);

        return buildJudgingSessionResponse(team, judging);
    }

    @Transactional
    public JudgingSessionResponse completeJudging(Long judgeId, Long teamId, CompleteJudgingRequest request) {
        User judge = getJudgeUserOrThrow(judgeId);
        Team team = getActiveTeamOrThrow(teamId);

        Judging judging = judgingRepository.findByJudgeIdAndTeamId(judgeId, teamId)
                .orElseGet(() -> judgingRepository.save(new Judging(judge, team, JudgingStatus.IN_PROGRESS, null)));

        if (judging.getStatus() == JudgingStatus.COMPLETED) {
            throw new ValidationException("Judging session for this team is already completed");
        }

        // Apply scores if provided in complete request
        if (request.getScores() != null && !request.getScores().isEmpty()) {
            applyAndValidateScores(judging, request.getScores());
        }

        // Update comment if provided
        if (request.getComment() != null) {
            judging.setComment(request.getComment().trim());
        }

        // Enforce completion rules: Every ACTIVE criterion must have a valid score
        List<Criteria> activeCriteria = criteriaRepository.findByActiveTrueOrderByDisplayOrderAsc();
        if (activeCriteria.isEmpty()) {
            throw new ValidationException("Cannot complete judging: no active criteria are configured");
        }

        Map<Long, Integer> existingScoreMap = judging.getScores().stream()
                .collect(Collectors.toMap(s -> s.getCriteria().getId(), Score::getScore, (a, b) -> a));

        for (Criteria criterion : activeCriteria) {
            Integer score = existingScoreMap.get(criterion.getId());
            if (score == null) {
                throw new ValidationException("Cannot complete judging: missing score for criterion '" + criterion.getName() + "'");
            }
            if (score < 0 || score > criterion.getMaxScore()) {
                throw new ValidationException("Score for '" + criterion.getName() + "' must be between 0 and " + criterion.getMaxScore());
            }
        }

        judging.setStatus(JudgingStatus.COMPLETED);
        judging.setCompletedAt(LocalDateTime.now());
        judging = judgingRepository.save(judging);
        log.info("Judge {} successfully marked judging as COMPLETED for team {}", judgeId, teamId);

        return buildJudgingSessionResponse(team, judging);
    }

    private void applyAndValidateScores(Judging judging, List<CriteriaScoreItem> scoreItems) {
        Map<Long, Criteria> criteriaMap = criteriaRepository.findAllById(
                scoreItems.stream().map(CriteriaScoreItem::getCriteriaId).toList()
        ).stream().collect(Collectors.toMap(Criteria::getId, c -> c));

        Map<Long, Score> existingScores = judging.getScores().stream()
                .collect(Collectors.toMap(s -> s.getCriteria().getId(), s -> s, (a, b) -> a));

        for (CriteriaScoreItem item : scoreItems) {
            Criteria criterion = criteriaMap.get(item.getCriteriaId());
            if (criterion == null) {
                throw new ValidationException("Criteria not found with id: " + item.getCriteriaId());
            }

            if (item.getScore() < 0 || item.getScore() > criterion.getMaxScore()) {
                throw new ValidationException("Score for '" + criterion.getName() + "' must be between 0 and " + criterion.getMaxScore());
            }

            Score existingScore = existingScores.get(criterion.getId());
            if (existingScore != null) {
                existingScore.setScore(item.getScore());
            } else {
                Score newScore = new Score(judging, criterion, item.getScore());
                judging.addScore(newScore);
            }
        }
    }

    private JudgingSessionResponse buildJudgingSessionResponse(Team team, Judging judging) {
        JudgingStatus status = judging != null ? judging.getStatus() : JudgingStatus.NOT_STARTED;
        Long judgingId = judging != null ? judging.getId() : null;
        String comment = judging != null ? judging.getComment() : null;
        LocalDateTime completedAt = judging != null ? judging.getCompletedAt() : null;

        Map<Long, Integer> scoreMap = new HashMap<>();
        if (judging != null && judging.getScores() != null) {
            for (Score s : judging.getScores()) {
                scoreMap.put(s.getCriteria().getId(), s.getScore());
            }
        }

        List<Criteria> activeCriteria = criteriaRepository.findByActiveTrueOrderByDisplayOrderAsc();

        List<JudgingCriteriaScoreResponse> criteriaScoreResponses = new ArrayList<>();
        int totalScore = 0;
        int totalMaxScore = 0;

        for (Criteria c : activeCriteria) {
            Integer score = scoreMap.get(c.getId());
            if (score != null) {
                totalScore += score;
            }
            totalMaxScore += c.getMaxScore();
            criteriaScoreResponses.add(new JudgingCriteriaScoreResponse(
                    c.getId(),
                    c.getName(),
                    c.getDescription(),
                    c.getMaxScore(),
                    c.getDisplayOrder(),
                    score
            ));
        }

        return new JudgingSessionResponse(
                judgingId,
                team.getId(),
                team.getTeamName(),
                team.getProjectName(),
                team.getIdea(),
                team.getDisplayOrder(),
                status,
                comment,
                completedAt,
                criteriaScoreResponses,
                totalScore,
                totalMaxScore
        );
    }

    private int calculateTotalScore(Judging judging) {
        if (judging == null || judging.getScores() == null) {
            return 0;
        }
        return judging.getScores().stream()
                .mapToInt(Score::getScore)
                .sum();
    }

    private Team getActiveTeamOrThrow(Long teamId) {
        Team team = teamRepository.findById(teamId)
                .orElseThrow(() -> new ResourceNotFoundException("Team not found with id: " + teamId));
        if (!team.isActive()) {
            throw new ValidationException("Team is inactive and cannot be judged");
        }
        return team;
    }

    private User getJudgeUserOrThrow(Long judgeId) {
        User user = userRepository.findById(judgeId)
                .orElseThrow(() -> new ResourceNotFoundException("Judge user not found with id: " + judgeId));
        if (user.getRole() != Role.JUDGE) {
            throw new ValidationException("User is not a judge");
        }
        if (!user.isActive()) {
            throw new ValidationException("Judge account is inactive");
        }
        return user;
    }
}
