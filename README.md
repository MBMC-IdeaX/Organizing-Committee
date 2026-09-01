# IdeaX Judging System

Production-ready mobile judging application and REST backend for the **IdeaX Hackathon**.

---

## 🚀 Project Overview

The **IdeaX Judging System** is engineered to deliver a fast, reliable, and secure evaluation workflow during live hackathon judging sessions.

### Core Roles:
- **ADMIN**: Manages teams, defines dynamic criteria rubrics, provisions judges, and oversees progress.
- **JUDGE**: Evaluates assigned teams in deterministic order, scores criteria, and provides feedback.

---

## 🛠️ Technology Stack

- **Mobile Client**: Flutter 3.38+ / Dart 3.10+ (BLoC/Cubit state management, Dio, FlutterSecureStorage)
- **Backend API**: Spring Boot 3.3.3 / Java 21 LTS (Spring Security, Spring Data JPA, Jakarta Validation)
- **Database**: MySQL 8.0 with Flyway schema migrations
- **Authentication**: Stateless JWT (`jjwt 0.12.5`) with BCrypt password hashing
- **UI Design System**: Light Glassmorphism with Google Fonts (Inter)

---

## 📁 Repository Structure

```
.
├── backend/                      # Spring Boot 3.3.x Backend Application
│   ├── pom.xml
│   ├── src/main/java/com/ideax/judging/
│   │   ├── config/               # Security, CORS, OpenAPI, App Properties
│   │   ├── controller/           # AuthController, HealthController, AdminController, JudgeController
│   │   ├── dto/                  # Request & Response DTOs, ApiResponse wrapper
│   │   ├── entity/               # JPA Entities (User, Team, Criteria, Judging, Score)
│   │   ├── exception/            # GlobalExceptionHandler & AppException hierarchy
│   │   ├── mapper/               # Entity <-> DTO Mappers
│   │   ├── repository/           # Spring Data JPA Repositories
│   │   ├── security/             # JwtService, JwtAuthFilter, CustomUserDetails
│   │   ├── service/              # AuthService
│   │   └── util/                 # DatabaseSeeder (safe admin initialization)
│   └── src/main/resources/
│       ├── application.yml
│       ├── application-dev.yml
│       └── db/migration/V1__init_schema.sql
│
├── mobile/                       # Flutter Mobile Client Application
│   ├── pubspec.yaml
│   ├── assets/images/            # Official IdeaX Logo & Assets
│   └── lib/
│       ├── app/                  # Theme, Colors, Typography, Routes, Config
│       ├── core/                 # ApiClient, SecureStorageService, Errors, Validators
│       ├── features/
│       │   ├── auth/             # Login, Splash, AuthCubit, Repository, RemoteDataSource
│       │   ├── admin/            # Admin Placeholder Screen
│       │   └── judge/            # Judge Placeholder Screen
│       └── shared/               # Reusable Light Glassmorphism Widgets (GlassCard, Buttons, etc.)
│
└── docs/
    └── ARCHITECTURE.md           # Comprehensive Architecture & Design Specifications
```

---

## ⚡ Quickstart Guide

### 1. Prerequisites
- **Java**: OpenJDK 21 LTS
- **Maven**: 3.9+
- **Flutter**: 3.24+ / 3.38+
- **MySQL**: 8.0+ running on port 3306

---

### 2. Backend Setup & Startup

#### Configure Environment / Database:
By default, `application-dev.yml` connects to:
- Database: `jdbc:mysql://localhost:3306/ideax_judging?createDatabaseIfNotExist=true`
- Username: `root`
- Password: `root` (override with `DB_PASSWORD` env var if needed)

#### Run Migrations & Start Backend:
```bash
cd backend
mvn spring-boot:run
```

The server starts on `http://localhost:8080`.
- **Health Check**: `GET http://localhost:8080/api/v1/health`
- **Swagger / OpenAPI UI**: `http://localhost:8080/swagger-ui.html`

#### Key Architectural Features (Phase 1 & Phase 2)
1. **Decoupled Session Lifecycle**: Network errors (401 Unauthorized) trigger a lightweight, decoupled `SessionEventBus` that automatically signals `AuthCubit` without tight coupling between Dio and UI navigation.
2. **Stateless JWT Security**: Spring Security 6 with HMAC-SHA256 tokens (`userId`, `username`, `role`), rejecting expired, malformed, or deactivated accounts (`active = false`).
3. **Role Authorization Matrix**: Strict separation between `ROLE_ADMIN` and `ROLE_JUDGE` on both backend controllers (`/api/v1/admin/**` vs `/api/v1/judge/**`) and mobile routing.
4. **Secure Token Storage**: Encrypted token persistence using `flutter_secure_storage` (`SecureStorageService`).
5. **Light Glassmorphism Theme**: Custom design tokens, glass cards, high-contrast typography, and official IdeaX branding.

---

## 🛠️ Testing & Verification

### Backend Verification
```bash
cd backend
mvn clean test
```
*Executes 16 tests covering JWT generation, active/inactive login, bad credentials, role authorization ping endpoints, and Spring context validation.*

### Mobile Verification
```bash
cd mobile
flutter analyze
flutter test
```
*Executes 16 tests covering AuthCubit state transitions, session restoration, session expired stream events, widget rendering, and route protection.*

---

## 📋 Deliverables Summary (Phase 1, Phase 2, & Phase 3)

- [x] **Spring Boot 3.3.x layered REST architecture** with JPA and Flyway migrations
- [x] **Stateless JWT authentication & role-based security** (`ADMIN`, `JUDGE`)
- [x] **Decoupled Session Lifecycle** with `SessionEventBus` (401 triggers clean logout)
- [x] **Team Management (Admin)**: Create, edit, status toggle, and batch queue reordering (`PUT /api/v1/admin/teams/reorder`)
- [x] **Criteria Engine (Admin)**: Dynamic rubric definition, point caps, active total max score calculation (`PUT /api/v1/admin/criteria/reorder`)
- [x] **Judge Account Management (Admin)**: Provision judge credentials, reset passwords, and toggle evaluator access
- [x] **Event Readiness Concept**: Real-time evaluation readiness dashboard checks (`activeTeams > 0`, `activeCriteria > 0`, `activeJudges > 0`)
- [x] **Flutter Clean Architecture**: Dedicated BLoC/Cubits for Dashboard, Teams, Criteria, and Judges
- [x] **Light Glassmorphism UI**: Beautiful cards, badges, dialogs, and responsive layouts
- [x] **31 Backend Integration & Unit Tests** passing
- [x] **27 Flutter Unit & Widget Tests** passing with **0 `flutter analyze` issues**
