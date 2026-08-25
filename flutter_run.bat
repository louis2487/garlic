@echo off
chcp 65001 >nul
setlocal EnableExtensions

cd /d "%~dp0"

REM --- garlic 전용 Gradle 홈 (다른 프로젝트의 GRADLE_USER_HOME / 과대 Xmx 설정 차단) ---
set "GRADLE_USER_HOME=%~dp0.gradle"
if not exist "%GRADLE_USER_HOME%" mkdir "%GRADLE_USER_HOME%"

REM --- Android SDK 경로 보정 ---
if defined ANDROID_HOME if not exist "%ANDROID_HOME%\platform-tools\adb.exe" (
  echo [warn] ANDROID_HOME 이 SDK가 아닙니다: %ANDROID_HOME%
  set "ANDROID_HOME="
  set "ANDROID_SDK_ROOT="
)

if not defined ANDROID_HOME if exist "%LOCALAPPDATA%\Android\Sdk\platform-tools\adb.exe" (
  set "ANDROID_HOME=%LOCALAPPDATA%\Android\Sdk"
)
if not defined ANDROID_HOME if exist "%USERPROFILE%\AppData\Local\Android\Sdk\platform-tools\adb.exe" (
  set "ANDROID_HOME=%USERPROFILE%\AppData\Local\Android\Sdk"
)
if not defined ANDROID_HOME if exist "C:\Android\Sdk\platform-tools\adb.exe" (
  set "ANDROID_HOME=C:\Android\Sdk"
)
if not defined ANDROID_HOME if exist "C:\Android\sdk\platform-tools\adb.exe" (
  set "ANDROID_HOME=C:\Android\sdk"
)

if defined ANDROID_HOME (
  set "ANDROID_SDK_ROOT=%ANDROID_HOME%"
  echo [garlic] ANDROID_HOME=%ANDROID_HOME%
) else (
  echo.
  echo [!] Android SDK 를 찾을 수 없습니다.
  echo     local.properties 의 sdk.dir 또는 ANDROID_HOME 을 확인하세요.
  echo.
  exit /b 1
)

echo [garlic] GRADLE_USER_HOME=%GRADLE_USER_HOME%
echo [garlic] stopping old Gradle daemons...
call "%~dp0android\gradlew.bat" --stop >nul 2>&1

echo [garlic] flutter build apk --release
echo.

if "%~1"=="" (
  flutter build apk --release
) else (
  flutter %*
)

if errorlevel 1 (
  echo.
  echo build failed
  echo.
  echo RAM이 부족하면 android\gradle.properties 의 -Xmx 를 더 줄이세요 ^(예: -Xmx768m^).
  exit /b %ERRORLEVEL%
)

echo.
echo APK: %~dp0build\app\outputs\flutter-apk\
dir /b "%~dp0build\app\outputs\flutter-apk\*.apk" 2>nul
echo.
echo done
exit /b 0
