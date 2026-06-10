@echo off
title Backend Server
echo Step 1: Setting JAVA_HOME
set JAVA_HOME=C:\Program Files\Amazon Corretto\jdk25.0.3_9

echo Step 2: Checking Oracle DB
sc query OracleServiceFREE | find "RUNNING" >nul 2>&1
if %errorlevel% neq 0 (
    echo Starting OracleServiceFREE...
    net start OracleServiceFREE
    timeout /t 5 /nobreak >nul
) else (
    echo Oracle already running.
)

echo Step 3: Moving to backend folder
cd /d "%~dp0"
echo Current dir: %cd%

echo Step 3.5: Loading .env file
for /f "usebackq tokens=1,* delims==" %%A in ("%~dp0.env") do (
    if not "%%A"=="" if not "%%A:~0,1%"=="#" set "%%A=%%B"
)

echo Step 4: Starting Spring Boot (clean build)
"C:\3b_project\maven\apache-maven-3.9.14\bin\mvn.cmd" clean spring-boot:run

pause
