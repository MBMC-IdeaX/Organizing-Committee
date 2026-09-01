package com.ideax.judging.service;

import com.ideax.judging.dto.response.AdminDashboardSummaryResponse;
import com.ideax.judging.entity.Role;
import com.ideax.judging.repository.CriteriaRepository;
import com.ideax.judging.repository.TeamRepository;
import com.ideax.judging.repository.UserRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class AdminDashboardService {

    private final TeamRepository teamRepository;
    private final CriteriaRepository criteriaRepository;
    private final UserRepository userRepository;

    public AdminDashboardService(
            TeamRepository teamRepository,
            CriteriaRepository criteriaRepository,
            UserRepository userRepository
    ) {
        this.teamRepository = teamRepository;
        this.criteriaRepository = criteriaRepository;
        this.userRepository = userRepository;
    }

    @Transactional(readOnly = true)
    public AdminDashboardSummaryResponse getDashboardSummary() {
        long totalTeams = teamRepository.count();
        long activeTeams = teamRepository.countByActiveTrue();

        long totalCriteria = criteriaRepository.count();
        long activeCriteria = criteriaRepository.countByActiveTrue();
        Long sumMaxScore = criteriaRepository.sumMaxScoreByActiveTrue();
        int totalMaxScore = sumMaxScore != null ? sumMaxScore.intValue() : 0;

        long totalJudges = userRepository.countByRole(Role.JUDGE);
        long activeJudges = userRepository.countByRoleAndActiveTrue(Role.JUDGE);

        // Configuration readiness: requires at least 1 active team, 1 active criterion, and 1 active judge
        boolean readyForJudging = activeTeams > 0 && activeCriteria > 0 && activeJudges > 0;

        return new AdminDashboardSummaryResponse(
                totalTeams,
                activeTeams,
                totalCriteria,
                activeCriteria,
                totalMaxScore,
                totalJudges,
                activeJudges,
                readyForJudging
        );
    }
}
