package com.ideax.judging.service;

import com.ideax.judging.dto.request.CreateTeamRequest;
import com.ideax.judging.dto.request.UpdateTeamRequest;
import com.ideax.judging.dto.response.TeamResponse;
import com.ideax.judging.entity.Judging;
import com.ideax.judging.entity.Team;
import com.ideax.judging.exception.AppException;
import com.ideax.judging.exception.ErrorCode;
import com.ideax.judging.exception.ResourceNotFoundException;
import com.ideax.judging.mapper.TeamMapper;
import com.ideax.judging.repository.JudgingRepository;
import com.ideax.judging.repository.ScoreRepository;
import com.ideax.judging.repository.TeamRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
public class TeamService {

    private static final Logger log = LoggerFactory.getLogger(TeamService.class);

    private final TeamRepository teamRepository;
    private final TeamMapper teamMapper;
    private final JudgingRepository judgingRepository;
    private final ScoreRepository scoreRepository;

    public TeamService(TeamRepository teamRepository, TeamMapper teamMapper, JudgingRepository judgingRepository, ScoreRepository scoreRepository) {
        this.teamRepository = teamRepository;
        this.teamMapper = teamMapper;
        this.judgingRepository = judgingRepository;
        this.scoreRepository = scoreRepository;
    }

    @Transactional(readOnly = true)
    public List<TeamResponse> getAllTeams() {
        return teamRepository.findAllByOrderByDisplayOrderAsc()
                .stream()
                .map(teamMapper::toResponse)
                .toList();
    }

    @Transactional(readOnly = true)
    public TeamResponse getTeamById(Long id) {
        Team team = teamRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Team not found with id: " + id));
        return teamMapper.toResponse(team);
    }

    @Transactional
    public TeamResponse createTeam(CreateTeamRequest request) {
        Team team = new Team(
                request.getTeamName().trim(),
                request.getProjectName().trim(),
                request.getIdea() != null ? request.getIdea().trim() : null,
                request.getDisplayOrder() != null ? request.getDisplayOrder() : 0,
                true
        );

        Team saved = teamRepository.save(team);
        log.info("Admin created team id: {}, name: {}", saved.getId(), saved.getTeamName());
        return teamMapper.toResponse(saved);
    }

    @Transactional
    public TeamResponse updateTeam(Long id, UpdateTeamRequest request) {
        Team team = teamRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Team not found with id: " + id));

        team.setTeamName(request.getTeamName().trim());
        team.setProjectName(request.getProjectName().trim());
        team.setIdea(request.getIdea() != null ? request.getIdea().trim() : null);
        if (request.getDisplayOrder() != null) {
            team.setDisplayOrder(request.getDisplayOrder());
        }

        Team updated = teamRepository.save(team);
        log.info("Admin updated team id: {}, name: {}", updated.getId(), updated.getTeamName());
        return teamMapper.toResponse(updated);
    }

    @Transactional
    public TeamResponse updateTeamStatus(Long id, boolean active) {
        Team team = teamRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Team not found with id: " + id));

        team.setActive(active);
        Team updated = teamRepository.save(team);
        log.info("Admin updated team id: {} status to active={}", updated.getId(), active);
        return teamMapper.toResponse(updated);
    }

    @Transactional
    public List<TeamResponse> reorderTeams(List<Long> orderedIds) {
        log.info("Admin reordering teams with order: {}", orderedIds);
        for (int i = 0; i < orderedIds.size(); i++) {
            Long id = orderedIds.get(i);
            Team team = teamRepository.findById(id)
                    .orElseThrow(() -> new ResourceNotFoundException("Team not found with id: " + id));
            team.setDisplayOrder(i + 1);
            teamRepository.save(team);
        }
        return getAllTeams();
    }

    @Transactional
    public void deleteTeam(Long id) {
        deleteTeam(id, false);
    }

    @Transactional
    public void deleteTeam(Long id, boolean force) {
        Team team = teamRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Team not found with id: " + id));

        if (!force && judgingRepository.existsByTeamId(id)) {
            throw new AppException(
                    "This team cannot be permanently deleted because judging records exist for it. Deactivate the team instead.",
                    HttpStatus.CONFLICT,
                    ErrorCode.TEAM_HAS_JUDGING_RECORDS
            );
        }

        if (force) {
            List<Judging> judgings = judgingRepository.findByTeamId(id);
            for (Judging j : judgings) {
                scoreRepository.deleteAll(scoreRepository.findByJudgingId(j.getId()));
            }
            judgingRepository.deleteAll(judgings);
            log.info("Force delete cleared {} judging sessions for team id: {}", judgings.size(), id);
        }

        teamRepository.delete(team);
        log.info("Admin deleted team id: {}, name: {}, force={}", team.getId(), team.getTeamName(), force);

        // Re-index remaining teams sequentially
        List<Team> remainingTeams = teamRepository.findAllByOrderByDisplayOrderAsc();
        for (int i = 0; i < remainingTeams.size(); i++) {
            Team t = remainingTeams.get(i);
            int newOrder = i + 1;
            if (t.getDisplayOrder() == null || t.getDisplayOrder() != newOrder) {
                t.setDisplayOrder(newOrder);
                teamRepository.save(t);
            }
        }
    }
}
