package com.ideax.judging.repository;

import com.ideax.judging.entity.Team;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface TeamRepository extends JpaRepository<Team, Long> {

    List<Team> findByActiveTrueOrderByDisplayOrderAsc();

    List<Team> findAllByOrderByDisplayOrderAsc();

    boolean existsByTeamName(String teamName);

    long countByActiveTrue();
}
