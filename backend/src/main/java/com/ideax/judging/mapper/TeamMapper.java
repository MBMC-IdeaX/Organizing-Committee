package com.ideax.judging.mapper;

import com.ideax.judging.dto.response.TeamResponse;
import com.ideax.judging.entity.Team;
import org.springframework.stereotype.Component;

@Component
public class TeamMapper {

    public TeamResponse toResponse(Team team) {
        if (team == null) return null;
        return new TeamResponse(
                team.getId(),
                team.getTeamName(),
                team.getProjectName(),
                team.getIdea(),
                team.getDisplayOrder(),
                team.isActive(),
                team.getCreatedAt(),
                team.getUpdatedAt()
        );
    }
}
