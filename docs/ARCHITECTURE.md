# IdeaX Judging System - Architecture & Technical Design Document

## 1. Executive Summary
The **IdeaX Judging System** is a mobile application and REST API backend built specifically for the high-intensity, live evaluation environment of the **IdeaX Hackathon**.

The system is architected around two core roles:
- **ADMIN**: Manages teams, configures dynamic criteria rubrics, provisions judge accounts, and oversees evaluation progress.
- **JUDGE**: Evaluates projects in deterministic Admin-configured order, scores criteria dynamically, and records optional commentary with strict data integrity guarantees.

---

## 2. Technical Stack
| Layer | Technology | Key Libraries & Standards |
|---|---|---|
| **Mobile Client** | Flutter 3.x / Dart 3.x | `flutter_bloc` (BLoC/Cubit), `dio`, `flutter_secure_storage`, `equatable`, `google_fonts` |
| **Backend API** | Spring Boot 3.3.x / Java 21 | Spring Data JPA, Spring Security 6, Jakarta Bean Validation, Springdoc OpenAPI 3 |
| **Authentication & Auth** | Stateless JWT | `jjwt 0.12.5`, BCrypt Password Hashing, Role-Based Access Control (`ADMIN`, `JUDGE`) |
| **Database & ORM** | MySQL 8.x + Hibernate | Flyway Versioned Migrations, UTF-8 MB4 |
| **Build & Tooling** | Maven & Flutter CLI | JUnit 5, Mockito, H2 (Test), `bloc_test`, `mocktail` |

---

## 3. System Architecture Diagram

```
+-----------------------------------------------------------------------------------+
|                            MOBILE CLIENT (Flutter)                                |
|                                                                                   |
|  +-----------------------------------------------------------------------------+  |
|  |                     Light Glassmorphism Presentation                        |  |
|  |   [SplashScreen]      [LoginScreen]      [AdminPlaceholder] [JudgePlaceholder] |
|  |   [GlassCard]         [PrimaryButton]    [AppTextField]     [StatusBadge]     |  |
|  +-----------------------------------------------------------------------------+  |
|                                       │                                           |
|                                       ▼                                           |
|  +-----------------------------------------------------------------------------+  |
|  |                   State Management & Domain (BLoC / Cubit)                  |  |
|  |   [AuthCubit]  ───►  [AuthRepository]  ───►  [UserEntity]                   |  |
|  +-----------------------------------------------------------------------------+  |
|                         │                                  │                      |
|                         ▼                                  ▼                      |
|  +──────────────────────────────+           +──────────────────────────────────+  |
|  | ApiClient (Dio REST)         |           | SecureStorageService             |  |
|  | • JWT AuthInterceptor        |           | • FlutterSecureStorage           |  |
|  | • Global Error Translation   |           | • Keychain / EncryptedPrefs      |  |
|  +──────────────────────────────+           +──────────────────────────────────+  |
+─────────────────────────────────┼─────────────────────────────────────────────────+
                                  │ HTTPS / REST (Bearer JWT)
                                  ▼
+───────────────────────────────────────────────────────────────────────────────────+
|                            BACKEND API (Spring Boot)                              |
|                                                                                   |
|  +─────────────────────────────────────────────────────────────────────────────+  |
|  | Security Filter Chain: JwtAuthenticationFilter + Role Authorization          |  |
|  |  • /api/v1/auth/login (Public)                                              |  |
|  |  • /api/v1/auth/me (Authenticated)                                          |  |
|  |  • /api/v1/admin/** (ROLE_ADMIN only)                                        |  |
|  |  • /api/v1/judge/** (ROLE_JUDGE only)                                        |  |
|  +─────────────────────────────────────────────────────────────────────────────+  |
|                                       │                                           |
|                                       ▼                                           |
|  +─────────────────────────────────────────────────────────────────────────────+  |
|  | REST Controllers: AuthController, HealthController, AdminController, etc.  |  |
|  +─────────────────────────────────────────────────────────────────────────────+  |
|                                       │                                           |
|                                       ▼                                           |
|  +─────────────────────────────────────────────────────────────────────────────+  |
|  | Service Layer: AuthService, JwtService, CustomUserDetailsService            |  |
|  | Exception Handling: GlobalExceptionHandler -> Unified ApiResponse<T>        |  |
|  +─────────────────────────────────────────────────────────────────────────────+  |
|                                       │                                           |
|                                       ▼                                           |
|  +─────────────────────────────────────────────────────────────────────────────+  |
|  | Repositories (Spring Data JPA): User, Team, Criteria, Judging, Score        |  |
|  +─────────────────────────────────────────────────────────────────────────────+  |
+───────────────────────────────────────┼───────────────────────────────────────────+
                                        │ JDBC / Hibernate
                                        ▼
+───────────────────────────────────────────────────────────────────────────────────+
|                             DATABASE (MySQL 8.x)                                  |
|   Flyway Migrations (V1__init_schema.sql)                                         |
|   Tables: users, teams, criteria, judgings, scores                                 |
+───────────────────────────────────────────────────────────────────────────────────+
```

---

## 4. Database Schema & Constraints

### Entity-Relationship Structure
```
[ USERS ] (id, username, password_hash, role, active, created_at, updated_at)
   ▲  └── CONSTRAINT uk_users_username UNIQUE (username)
   │
   │ 1:N (Judge)
   │
[ JUDGINGS ] (id, judge_id, team_id, status, comment, completed_at, created_at, updated_at)
   │  ├── CONSTRAINT fk_judgings_judge FOREIGN KEY (judge_id) REFERENCES users(id)
   │  ├── CONSTRAINT fk_judgings_team FOREIGN KEY (team_id) REFERENCES teams(id)
   │  └── CONSTRAINT uk_judge_team UNIQUE (judge_id, team_id)
   │
   │ 1:N
   ▼
[ SCORES ] (id, judging_id, criteria_id, score, created_at, updated_at)
   ├── CONSTRAINT fk_scores_judging FOREIGN KEY (judging_id) REFERENCES judgings(id)
   ├── CONSTRAINT fk_scores_criteria FOREIGN KEY (criteria_id) REFERENCES criteria(id)
   └── CONSTRAINT uk_judging_criteria UNIQUE (judging_id, criteria_id)
   ▲
   │ N:1
[ CRITERIA ] (id, name, description, max_score, display_order, active, created_at, updated_at)
   └── INDEX idx_criteria_display_order (display_order, active)

[ TEAMS ] (id, team_name, project_name, idea, display_order, active, created_at, updated_at)
   └── INDEX idx_teams_display_order (display_order, active)
```

### Deterministic Ordering Guarantee
Both `teams` and `criteria` enforce deterministic sorting via `display_order`:
```sql
SELECT * FROM teams WHERE active = true ORDER BY display_order ASC;
SELECT * FROM criteria WHERE active = true ORDER BY display_order ASC;
```

---

## 5. Security & Authentication Model
## 5. Admin Management Subsystem (Phase 3)

### 5.1 Team Management
- **Deterministic Queue Ordering**: Teams are ordered by `displayOrder ASC`. Admin can swap or reorder queue positions using `PUT /api/v1/admin/teams/reorder`.
- **Status Lifecycle**: Teams can be toggled `active: true/false`. Inactive teams are excluded from active judging workflows while historical score records remain preserved.

### 5.2 Criteria & Rubric Engine
- **Configurable Point Caps**: Each criterion defines a `maxScore >= 1`.
- **Dynamic Total Score Preview**: Real-time aggregation of active criteria points:
  $$\text{Total Max Score} = \sum_{c \in \text{Criteria}} c.\text{maxScore} \quad \text{where } c.\text{active} = \text{true}$$

### 5.3 Judge Account Provisioning
- **Strict Role Enforcement**: All judge accounts created via `POST /api/v1/admin/judges` or updated via `PUT /api/v1/admin/judges/{id}` are strictly constrained to `ROLE_JUDGE`.
- **Password Security**: Passwords hashed with BCrypt ($2a$ format). Updates allow optional credential resets without exposing hashes.
- **Immediate Access Revocation**: Deactivating a judge account immediately marks `active = false`, causing subsequent authentication or token validation to reject further access.

### 5.4 Configuration Readiness Checklist
The Admin Dashboard monitors 3 conditions required before evaluation can begin:
1. `activeTeams > 0`
2. `activeCriteria > 0`
3. `activeJudges > 0`

When all 3 conditions hold, `readyForJudging: true` is displayed.

---

## 6. Verification Status
- **Backend**: 31/31 automated tests passing (`AdminTeamControllerIntegrationTests`, `AdminCriteriaControllerIntegrationTests`, `AdminJudgeControllerIntegrationTests`, `AuthControllerIntegrationTests`, `JwtServiceTests`, `AuthServiceTests`).
- **Mobile**: 27/27 automated unit/widget tests passing (`flutter analyze` with 0 issues).

### Unified API Response Contract
All REST endpoints return a standardized payload:
```json
{
  "success": true,
  "message": "Operation successful",
  "data": { ... }
}
```
Errors return safe messages without stack traces:
```json
{
  "success": false,
  "message": "Invalid username or password",
  "errorCode": "INVALID_CREDENTIALS",
  "data": null
}
```

---

## 6. Frontend UI System: Light Glassmorphism
The visual system strictly avoids dark/cyberpunk themes in favor of a clean, premium hackathon design:
- **Canvas Background**: `#F5F9FF` with subtle soft gradients.
- **Glass Surface**: Pure white `rgba(255, 255, 255, 0.80)` with 10px backdrop blur and `#DCE6F5` border.
- **Typography Hierarchy**: Inter font in Deep Navy `#0B1F4B` for primary titles and Royal Blue `#2563EB` for actions.
- **Assets**: Official IdeaX branding preserved in `assets/images/ideax_logo.png`.
