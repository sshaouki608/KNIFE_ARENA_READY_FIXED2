@echo off
setlocal
set APP_HOME=%~dp0
set DIST_URL=https://services.gradle.org/distributions/gradle-8.11.1-all.zip
set DIST_NAME=gradle-8.11.1-all
set GRADLE_HOME=%USERPROFILE%\.gradle\wrapper\dists\%DIST_NAME%\manual
set GRADLE_BIN=%GRADLE_HOME%\gradle-8.11.1\bin\gradle.bat
if not exist "%GRADLE_BIN%" (
  echo Please install Gradle 8.11.1 or use a Flutter IDE that provisions Gradle automatically.
  exit /b 1
)
call "%GRADLE_BIN%" -p "%APP_HOME%" %*
endlocal
