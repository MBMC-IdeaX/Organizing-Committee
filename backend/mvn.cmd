@REM Maven launcher redirect to IntelliJ Maven installation
@echo off
set "MAVEN_CMD=C:\Program Files\JetBrains\IntelliJ IDEA 2025.2.4\plugins\maven\lib\maven3\bin\mvn.cmd"
if exist "%MAVEN_CMD%" (
    call "%MAVEN_CMD%" %*
) else (
    where mvn >nul 2>nul
    if %ERRORLEVEL% equ 0 (
        call mvn %*
    ) else (
        echo Error: Maven executable not found.
        exit /b 1
    )
)
