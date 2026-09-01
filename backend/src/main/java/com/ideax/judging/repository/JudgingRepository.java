package com.ideax.judging.repository;

import com.ideax.judging.entity.Judging;
import com.ideax.judging.entity.JudgingStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface JudgingRepository extends JpaRepository<Judging, Long> {

    Optional<Judging> findByJudgeIdAndTeamId(Long judgeId, Long teamId);

    List<Judging> findByJudgeId(Long judgeId);

    List<Judging> findByJudgeIdAndTeam_ActiveTrue(Long judgeId);

    List<Judging> findByTeamId(Long teamId);

    List<Judging> findByStatus(JudgingStatus status);

    boolean existsByJudgeIdAndTeamId(Long judgeId, Long teamId);

    boolean existsByTeamId(Long teamId);

    boolean existsByJudgeId(Long judgeId);

    long countByJudgeIdAndStatus(Long judgeId, JudgingStatus status);

    long countByStatusAndTeam_ActiveTrueAndJudge_ActiveTrue(JudgingStatus status);

    @org.springframework.data.jpa.repository.Query("SELECT DISTINCT j FROM Judging j LEFT JOIN FETCH j.scores WHERE j.status = :status AND j.team.active = true AND j.judge.active = true")
    List<Judging> findCompletedJudgingsWithScores(@org.springframework.data.repository.query.Param("status") JudgingStatus status);
}
