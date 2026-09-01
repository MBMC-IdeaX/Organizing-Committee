package com.ideax.judging.repository;

import com.ideax.judging.entity.Role;
import com.ideax.judging.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface UserRepository extends JpaRepository<User, Long> {

    Optional<User> findByUsername(String username);

    boolean existsByUsername(String username);

    List<User> findByRoleAndActiveTrue(Role role);

    List<User> findByRoleOrderByCreatedAtDesc(Role role);

    long countByRole(Role role);

    long countByRoleAndActiveTrue(Role role);
}
