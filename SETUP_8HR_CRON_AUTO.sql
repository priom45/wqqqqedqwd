-- ============================================
-- Setup 8-Hour Automated Job Digest
-- Project: karthikl
-- Project ID: rixmudvtbfkjpwjoefon
-- ============================================
-- Run this in Supabase SQL Editor:
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
-- IMPORTANT: You need to get your Service Role Key from:
-- https://supabase.com/dashboard/project/rixmudvtbfkjpwjoefon/settings/api
-- Then replace YOUR-SERVICE-ROLE-KEY below with the actual key

ALTER DATABASE postgres
SET app.settings.supabase_service_role_key = 'YOUR-SERVICE-ROLE-KEY';

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

-- STEP 5: Verify Cron Job Created
-- ============================================
SELECT * FROM cron.job WHERE jobname = 'job-digest-every-8-hours';

-- STEP 6: Check Cron Job History (after it runs)
-- ============================================
-- Run this after the next scheduled time to see if it worked
SELECT * FROM cron.job_run_details
WHERE jobid = (SELECT jobid FROM cron.job WHERE jobname = 'job-digest-every-8-hours')
ORDER BY start_time DESC
LIMIT 5;

-- ============================================
-- DONE! Your 8-hour digest is now automated!
-- ============================================
-- Next automatic run times:
-- - Today at 12:00 AM, 8:00 AM, or 4:00 PM (whichever comes next)
-- - Then every 8 hours after that
-- ============================================
