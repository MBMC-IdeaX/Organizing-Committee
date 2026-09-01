package com.ideax.judging.mapper;

import com.ideax.judging.dto.response.CriteriaResponse;
import com.ideax.judging.entity.Criteria;
import org.springframework.stereotype.Component;

@Component
public class CriteriaMapper {

    public CriteriaResponse toResponse(Criteria criteria) {
        if (criteria == null) return null;
        return new CriteriaResponse(
                criteria.getId(),
                criteria.getName(),
                criteria.getDescription(),
                criteria.getMaxScore(),
                criteria.getDisplayOrder(),
                criteria.isActive(),
                criteria.getCreatedAt(),
                criteria.getUpdatedAt()
        );
    }
}
