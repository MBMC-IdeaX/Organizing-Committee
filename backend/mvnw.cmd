@REM Maven wrapper redirect to system / IntelliJ Maven installation
@echo off
where mvn >nul 2>nul
if %ERRORLEVEL% equ 0 (
    call mvn %*
    exit /b %ERRORLEVEL%
)

set "MAVEN_CMD=C:\Program Files\JetBrains\IntelliJ IDEA 2025.2.4\plugins\maven\lib\maven3\bin\mvn.cmd"
if exist "%MAVEN_CMD%" (
    call "%MAVEN_CMD%" %*
    exit /b %ERRORLEVEL%
)

echo Error: Maven executable not found on PATH or standard IntelliJ location.
exit /b 1
