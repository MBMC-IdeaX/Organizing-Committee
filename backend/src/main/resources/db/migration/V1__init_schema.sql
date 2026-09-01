-- ==========================================================
-- IdeaX Hackathon Judging System - Database Schema
-- Version: V1 (Initial Schema Foundation)
-- ==========================================================

-- 1. USERS TABLE
CREATE TABLE IF NOT EXISTS users (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(100) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role VARCHAR(20) NOT NULL,
    active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT uk_users_username UNIQUE (username)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 2. TEAMS TABLE
CREATE TABLE IF NOT EXISTS teams (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    team_name VARCHAR(150) NOT NULL,
    project_name VARCHAR(200) NOT NULL,
    idea TEXT NULL,
    display_order INT NOT NULL DEFAULT 0,
    active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_teams_display_order (display_order, active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 3. CRITERIA TABLE (Dynamic Rubrics)
CREATE TABLE IF NOT EXISTS criteria (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    description TEXT NULL,
    max_score INT NOT NULL,
    display_order INT NOT NULL DEFAULT 0,
    active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_criteria_display_order (display_order, active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 4. JUDGINGS TABLE (One Judge per Team session)
CREATE TABLE IF NOT EXISTS judgings (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    judge_id BIGINT NOT NULL,
    team_id BIGINT NOT NULL,
    status VARCHAR(30) NOT NULL DEFAULT 'NOT_STARTED',
    comment TEXT NULL,
    completed_at TIMESTAMP NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_judgings_judge FOREIGN KEY (judge_id) REFERENCES users (id) ON DELETE CASCADE,
    CONSTRAINT fk_judgings_team FOREIGN KEY (team_id) REFERENCES teams (id) ON DELETE CASCADE,
    CONSTRAINT uk_judge_team UNIQUE (judge_id, team_id),
    INDEX idx_judgings_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 5. SCORES TABLE (One score per criterion per judging session)
CREATE TABLE IF NOT EXISTS scores (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    judging_id BIGINT NOT NULL,
    criteria_id BIGINT NOT NULL,
    score INT NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_scores_judging FOREIGN KEY (judging_id) REFERENCES judgings (id) ON DELETE CASCADE,
    CONSTRAINT fk_scores_criteria FOREIGN KEY (criteria_id) REFERENCES criteria (id) ON DELETE RESTRICT,
    CONSTRAINT uk_judging_criteria UNIQUE (judging_id, criteria_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
