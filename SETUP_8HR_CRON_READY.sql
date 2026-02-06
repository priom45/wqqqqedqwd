-- ============================================
-- Setup 8-Hour Automated Job Digest - READY TO RUN
-- Project: karthikl
-- Project ID: rixmudvtbfkjpwjoefon
-- ============================================
-- Copy ALL of this and run in Supabase SQL Editor:
-- https://supabase.com/dashboard/project/rixmudvtbfkjpwjoefon/sql
-- ============================================

-- STEP 1: Enable pg_cron extension
-- ============================================
CREATE EXTENSION IF NOT EXISTS pg_cron;

-- STEP 2: Configure Supabase URL
-- ============================================
ALTER DATABASE postgres
SET app.settings.supabase_url = 'https://rixmudvtbfkjpwjoefon.supabase.co';

-- STEP 3: Set Service Role Key
-- ============================================
ALTER DATABASE postgres
SET app.settings.supabase_service_role_key = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJpeG11ZHZ0YmZranB3am9lZm9uIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1MDU4OTg3MiwiZXhwIjoyMDY2MTY1ODcyfQ.6NIFXhO03vHAv3j8lL8A1dYtaNLMRYeE8v12MLsW4bg';

-- STEP 4: Create 8-Hour Cron Schedule
-- ============================================
-- This will send job digest emails automatically at:
-- - 12:00 AM (midnight)
-- - 8:00 AM (morning)
-- - 4:00 PM (afternoon)
-- ============================================

SELECT cron.schedule(
  'job-digest-every-8-hours',
  '0 0,8,16 * * *',
  $$
  SELECT
    net.http_post(
      url := current_setting('app.settings.supabase_url') || '/functions/v1/process-daily-job-digest',
      headers := jsonb_build_object(
        'Content-Type', 'application/json',
        'Authorization', 'Bearer ' || current_setting('app.settings.supabase_service_role_key')
      ),
      body := '{}'::jsonb
    ) AS request_id;
  $$
);

-- STEP 5: Verify Cron Job Created Successfully
-- ============================================
SELECT
  jobid,
  jobname,
  schedule,
  active,
  database
FROM cron.job
WHERE jobname = 'job-digest-every-8-hours';

-- ============================================
-- DONE! Your 8-hour digest is now automated!
-- ============================================
--
-- The system will now automatically send job digest emails:
-- - Every day at 12:00 AM (midnight)
-- - Every day at 8:00 AM (morning)
-- - Every day at 4:00 PM (afternoon)
--
-- To check if the cron job ran successfully, use this query:
-- ============================================

-- Check recent cron job runs (run this after scheduled times)
SELECT
  job_run_details.runid,
  job_run_details.job_pid,
  job_run_details.status,
  job_run_details.return_message,
  job_run_details.start_time,
  job_run_details.end_time
FROM cron.job_run_details
WHERE jobid = (SELECT jobid FROM cron.job WHERE jobname = 'job-digest-every-8-hours')
ORDER BY start_time DESC
LIMIT 10;

-- ============================================
-- To manually trigger the cron job for testing:
-- ============================================
-- SELECT cron.schedule_in_database('job-digest-every-8-hours', '* * * * *', 'SELECT 1', 'postgres');
-- (This would run every minute for testing - don't use in production!)

-- ============================================
-- To stop/remove the cron job if needed:
-- ============================================
-- SELECT cron.unschedule('job-digest-every-8-hours');

-- ============================================
-- CONGRATULATIONS!
-- Your 8-hour job digest system is fully automated!
-- ============================================
