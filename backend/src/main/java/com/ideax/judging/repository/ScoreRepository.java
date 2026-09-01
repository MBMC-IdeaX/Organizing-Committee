package com.ideax.judging.repository;

import com.ideax.judging.entity.Score;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface ScoreRepository extends JpaRepository<Score, Long> {

    List<Score> findByJudgingId(Long judgingId);

    Optional<Score> findByJudgingIdAndCriteriaId(Long judgingId, Long criteriaId);

    boolean existsByJudgingIdAndCriteriaId(Long judgingId, Long criteriaId);
}
