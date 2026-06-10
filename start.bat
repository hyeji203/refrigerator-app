@echo off
set JAVA_HOME=C:\Program Files\Amazon Corretto\jdk25.0.3_9

echo Loading .env...
for /f "usebackq tokens=*" %%A in (`powershell -NoProfile -Command "Get-Content '%~dp0server\.env' | Where-Object { $_ -match '^[^#].+=.' }"`) do set "%%A"

cd /d %~dp0server
"C:\maven\apache-maven-3.9.6\bin\mvn.cmd" spring-boot:run
pause
