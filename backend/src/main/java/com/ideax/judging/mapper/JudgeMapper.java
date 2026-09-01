package com.ideax.judging.mapper;

import com.ideax.judging.dto.response.JudgeResponse;
import com.ideax.judging.entity.User;
import org.springframework.stereotype.Component;

@Component
public class JudgeMapper {

    public JudgeResponse toResponse(User user) {
        if (user == null) return null;
        return new JudgeResponse(
                user.getId(),
                user.getUsername(),
                user.getRole(),
                user.isActive(),
                user.getCreatedAt(),
                user.getUpdatedAt()
        );
    }
}
