package com.ideax.judging.mapper;

import com.ideax.judging.dto.response.UserResponse;
import com.ideax.judging.entity.User;
import org.springframework.stereotype.Component;

@Component
public class UserMapper {

    public UserResponse toResponse(User user) {
        if (user == null) {
            return null;
        }
        return new UserResponse(
                user.getId(),
                user.getUsername(),
                user.getRole(),
                user.isActive(),
                user.getCreatedAt()
        );
    }
}
