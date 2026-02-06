@echo off
echo ====================================
echo  Deploy 8-Hour Digest Functions
echo ====================================
echo.

REM Check if Supabase CLI is installed
where npx >nul 2>nul
if %errorlevel% neq 0 (
    echo ERROR: npx not found. Please install Node.js first.
    pause
    exit /b 1
)

echo Step 1: Login to Supabase
echo.
echo Please provide your Supabase Access Token
echo Get it from: https://supabase.com/dashboard/account/tokens
echo.
set /p SUPABASE_TOKEN="Enter your Supabase Access Token: "
echo.

if "%SUPABASE_TOKEN%"=="" (
    echo ERROR: No token provided!
    pause
    exit /b 1
)

REM Set the environment variable
set SUPABASE_ACCESS_TOKEN=%SUPABASE_TOKEN%

echo Step 2: Get Project Reference
echo.
echo Go to your Supabase project settings to find your Project Reference ID
echo It looks like: abc-def-123456789
echo.
set /p PROJECT_REF="Enter your Project Reference: "
echo.

if "%PROJECT_REF%"=="" (
    echo ERROR: No project reference provided!
    pause
    exit /b 1
)

echo.
echo ====================================
echo  Deploying Functions...
echo ====================================
echo.

echo Deploying process-daily-job-digest...
npx supabase functions deploy process-daily-job-digest --project-ref %PROJECT_REF%
if %errorlevel% neq 0 (
    echo ERROR: Failed to deploy process-daily-job-digest
    pause
    exit /b 1
)

echo.
echo Deploying send-job-digest-email...
npx supabase functions deploy send-job-digest-email --project-ref %PROJECT_REF%
if %errorlevel% neq 0 (
    echo ERROR: Failed to deploy send-job-digest-email
    pause
    exit /b 1
)

echo.
echo ====================================
echo  SUCCESS! Both functions deployed
echo ====================================
echo.
echo Next Steps:
echo 1. Go to http://localhost:5173/admin/email-testing
echo 2. Click "Test 8-Hour Digest" button
echo 3. Check your email!
echo.
pause
