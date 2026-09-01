package com.ideax.judging.repository;

import com.ideax.judging.entity.Criteria;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface CriteriaRepository extends JpaRepository<Criteria, Long> {

    List<Criteria> findByActiveTrueOrderByDisplayOrderAsc();

    List<Criteria> findAllByOrderByDisplayOrderAsc();

    boolean existsByName(String name);

    long countByActiveTrue();

    @Query("SELECT COALESCE(SUM(c.maxScore), 0L) FROM Criteria c WHERE c.active = true")
    Long sumMaxScoreByActiveTrue();
}
