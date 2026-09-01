package com.ideax.judging.service;

import com.ideax.judging.dto.response.*;
import com.ideax.judging.entity.*;
import com.ideax.judging.exception.AppException;
import com.ideax.judging.exception.ErrorCode;
import com.ideax.judging.repository.*;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.*;
import java.util.stream.Collectors;

@Service
@Transactional(readOnly = true)
public class ResultsService {

    private final TeamRepository teamRepository;
    private final UserRepository userRepository;
    private final CriteriaRepository criteriaRepository;
    private final JudgingRepository judgingRepository;

    public ResultsService(
            TeamRepository teamRepository,
            UserRepository userRepository,
            CriteriaRepository criteriaRepository,
            JudgingRepository judgingRepository) {
        this.teamRepository = teamRepository;
        this.userRepository = userRepository;
        this.criteriaRepository = criteriaRepository;
        this.judgingRepository = judgingRepository;
    }

    public ResultsSummaryResponse getResultsSummary() {
        long totalTeams = teamRepository.count();
        long activeTeams = teamRepository.countByActiveTrue();
        long totalJudges = userRepository.countByRole(Role.JUDGE);
        long activeJudges = userRepository.countByRoleAndActiveTrue(Role.JUDGE);
        long totalCriteria = criteriaRepository.count();
        long activeCriteria = criteriaRepository.countByActiveTrue();

        long totalPossibleScorePerJudge = criteriaRepository.findByActiveTrueOrderByDisplayOrderAsc()
                .stream()
                .mapToLong(Criteria::getMaxScore)
                .sum();

        long totalRequiredEvaluations = activeTeams * activeJudges;
        long completedEvaluations = judgingRepository.countByStatusAndTeam_ActiveTrueAndJudge_ActiveTrue(JudgingStatus.COMPLETED);
        long remainingEvaluations = Math.max(0L, totalRequiredEvaluations - completedEvaluations);

        double completionPercentage = totalRequiredEvaluations > 0
                ? ((double) completedEvaluations / totalRequiredEvaluations) * 100.0
                : 0.0;

        boolean judgingComplete = totalRequiredEvaluations > 0 && completedEvaluations == totalRequiredEvaluations;

        return new ResultsSummaryResponse(
                totalTeams,
                activeTeams,
                totalJudges,
                activeJudges,
                totalCriteria,
                activeCriteria,
                (int) totalPossibleScorePerJudge,
                totalRequiredEvaluations,
                completedEvaluations,
                remainingEvaluations,
                completionPercentage,
                judgingComplete,
                judgingComplete
        );
    }

    public List<RankingResultResponse> getRanking() {
        ResultsSummaryResponse summary = getResultsSummary();
        if (!summary.isResultsAvailable()) {
            throw new AppException(
                    "Final results are not available until all judging evaluations are complete.",
                    HttpStatus.CONFLICT,
                    ErrorCode.RESULTS_NOT_READY
            );
        }

        List<CalculatedTeamResult> calculatedResults = calculateResults();
        return calculatedResults.stream()
                .map(r -> new RankingResultResponse(
                        r.rank,
                        r.team.getId(),
                        r.team.getTeamName(),
                        r.team.getProjectName(),
                        r.aggregateTotal,
                        r.aggregateMaxScore,
                        r.averageScore,
                        r.averageMaxScore,
                        r.percentage,
                        r.completedJudges,
                        summary.getActiveJudges(),
                        true
                ))
                .collect(Collectors.toList());
    }

    public TeamResultResponse getTeamResult(Long teamId) {
        ResultsSummaryResponse summary = getResultsSummary();
        if (!summary.isResultsAvailable()) {
            throw new AppException(
                    "Final results are not available until all judging evaluations are complete.",
                    HttpStatus.CONFLICT,
                    ErrorCode.RESULTS_NOT_READY
            );
        }

        List<CalculatedTeamResult> calculatedResults = calculateResults();
        CalculatedTeamResult match = calculatedResults.stream()
                .filter(r -> r.team.getId().equals(teamId))
                .findFirst()
                .orElseThrow(() -> new AppException("Team results not found", HttpStatus.NOT_FOUND, ErrorCode.RESOURCE_NOT_FOUND));

        return new TeamResultResponse(
                match.team.getId(),
                match.team.getTeamName(),
                match.team.getProjectName(),
                match.team.getIdea(),
                match.rank,
                match.aggregateTotal,
                match.aggregateMaxScore,
                match.averageScore,
                match.averageMaxScore,
                match.percentage,
                true,
                match.judgeBreakdowns,
                match.criterionBreakdowns
        );
    }

    private List<CalculatedTeamResult> calculateResults() {
        List<Team> activeTeams = teamRepository.findByActiveTrueOrderByDisplayOrderAsc();
        List<Criteria> activeCriteria = criteriaRepository.findByActiveTrueOrderByDisplayOrderAsc();
        long activeJudgesCount = userRepository.countByRoleAndActiveTrue(Role.JUDGE);

        int maxScorePerJudge = activeCriteria.stream().mapToInt(Criteria::getMaxScore).sum();

        // Load all completed judgings with their scores
        List<Judging> completedJudgings = judgingRepository.findCompletedJudgingsWithScores(JudgingStatus.COMPLETED);

        // Group judgings by Team ID
        Map<Long, List<Judging>> judgingsByTeam = completedJudgings.stream()
                .collect(Collectors.groupingBy(j -> j.getTeam().getId()));

        List<CalculatedTeamResult> results = new ArrayList<>();

        for (Team team : activeTeams) {
            List<Judging> teamJudgings = judgingsByTeam.getOrDefault(team.getId(), Collections.emptyList());

            int aggregateTotal = 0;
            long completedJudges = teamJudgings.size();

            List<JudgeScoreBreakdownResponse> judgeBreakdowns = new ArrayList<>();
            Map<Long, Integer> criteriaTotalScores = new HashMap<>();

            for (Judging j : teamJudgings) {
                int judgeTotal = 0;
                Map<String, Integer> criterionScores = new LinkedHashMap<>();

                // Index scores by criteria ID
                Map<Long, Integer> scoresByCritId = j.getScores().stream()
                        .collect(Collectors.toMap(s -> s.getCriteria().getId(), Score::getScore));

                for (Criteria c : activeCriteria) {
                    int scoreVal = scoresByCritId.getOrDefault(c.getId(), 0);
                    judgeTotal += scoreVal;
                    criterionScores.put(c.getName(), scoreVal);

                    // Add to criteria totals for average breakdown
                    criteriaTotalScores.put(c.getId(), criteriaTotalScores.getOrDefault(c.getId(), 0) + scoreVal);
                }

                aggregateTotal += judgeTotal;

                judgeBreakdowns.add(new JudgeScoreBreakdownResponse(
                        j.getJudge().getUsername(),
                        judgeTotal,
                        maxScorePerJudge,
                        criterionScores,
                        j.getComment()
                ));
            }

            int aggregateMaxScore = maxScorePerJudge * (int) completedJudges;
            double averageScore = completedJudges > 0 ? (double) aggregateTotal / completedJudges : 0.0;
            double percentage = maxScorePerJudge > 0 ? (averageScore / maxScorePerJudge) * 100.0 : 0.0;

            List<CriterionResultBreakdownResponse> criterionBreakdowns = new ArrayList<>();
            Map<Long, Double> criterionAverages = new HashMap<>();

            for (Criteria c : activeCriteria) {
                int critTotal = criteriaTotalScores.getOrDefault(c.getId(), 0);
                double critAvg = completedJudges > 0 ? (double) critTotal / completedJudges : 0.0;
                criterionAverages.put(c.getId(), critAvg);

                criterionBreakdowns.add(new CriterionResultBreakdownResponse(
                        c.getId(),
                        c.getName(),
                        critAvg,
                        c.getMaxScore()
                ));
            }

            results.add(new CalculatedTeamResult(
                    team,
                    aggregateTotal,
                    aggregateMaxScore,
                    averageScore,
                    maxScorePerJudge,
                    percentage,
                    completedJudges,
                    judgeBreakdowns,
                    criterionBreakdowns,
                    criterionAverages
            ));
        }

        // Apply primary comparator sorting with tie-breaker
        results.sort((a, b) -> {
            // 1. Percentage descending
            int cmp = Double.compare(b.percentage, a.percentage);
            if (cmp != 0) return cmp;

            // 2. AggregateTotal descending
            cmp = Integer.compare(b.aggregateTotal, a.aggregateTotal);
            if (cmp != 0) return cmp;

            // 3. Active criteria averages in displayOrder ascending (which is criteria displayOrder/priority order)
            for (Criteria criteria : activeCriteria) {
                double avgA = a.criterionAverages.getOrDefault(criteria.getId(), 0.0);
                double avgB = b.criterionAverages.getOrDefault(criteria.getId(), 0.0);
                cmp = Double.compare(avgB, avgA);
                if (cmp != 0) return cmp;
            }

            return 0; // Exact tie
        });

        // Assign competition ranks: 1, 2, 2, 4
        for (int i = 0; i < results.size(); i++) {
            CalculatedTeamResult current = results.get(i);
            if (i > 0) {
                CalculatedTeamResult previous = results.get(i - 1);
                if (areTied(current, previous, activeCriteria)) {
                    current.rank = previous.rank;
                } else {
                    current.rank = i + 1;
                }
            } else {
                current.rank = 1;
            }
        }

        return results;
    }

    private boolean areTied(CalculatedTeamResult a, CalculatedTeamResult b, List<Criteria> activeCriteria) {
        if (Double.compare(a.percentage, b.percentage) != 0) return false;
        if (a.aggregateTotal != b.aggregateTotal) return false;

        for (Criteria criteria : activeCriteria) {
            double avgA = a.criterionAverages.getOrDefault(criteria.getId(), 0.0);
            double avgB = b.criterionAverages.getOrDefault(criteria.getId(), 0.0);
            if (Double.compare(avgA, avgB) != 0) return false;
        }

        return true;
    }

    private static class CalculatedTeamResult {
        private final Team team;
        private final int aggregateTotal;
        private final int aggregateMaxScore;
        private final double averageScore;
        private final int averageMaxScore;
        private final double percentage;
        private final long completedJudges;
        private final List<JudgeScoreBreakdownResponse> judgeBreakdowns;
        private final List<CriterionResultBreakdownResponse> criterionBreakdowns;
        private final Map<Long, Double> criterionAverages;
        private int rank;

        public CalculatedTeamResult(
                Team team,
                int aggregateTotal,
                int aggregateMaxScore,
                double averageScore,
                int averageMaxScore,
                double percentage,
                long completedJudges,
                List<JudgeScoreBreakdownResponse> judgeBreakdowns,
                List<CriterionResultBreakdownResponse> criterionBreakdowns,
                Map<Long, Double> criterionAverages) {
            this.team = team;
            this.aggregateTotal = aggregateTotal;
            this.aggregateMaxScore = aggregateMaxScore;
            this.averageScore = averageScore;
            this.averageMaxScore = averageMaxScore;
            this.percentage = percentage;
            this.completedJudges = completedJudges;
            this.judgeBreakdowns = judgeBreakdowns;
            this.criterionBreakdowns = criterionBreakdowns;
            this.criterionAverages = criterionAverages;
        }
    }
}
