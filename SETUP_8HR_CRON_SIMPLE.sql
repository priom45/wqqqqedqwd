-- ============================================
-- Setup 8-Hour Automated Job Digest - SIMPLIFIED VERSION
-- Project: karthikl
-- Project ID: rixmudvtbfkjpwjoefon
-- ============================================
-- Run this in Supabase SQL Editor (Dashboard -> SQL Editor)
-- ============================================

-- STEP 1: Enable pg_cron extension
-- ============================================
CREATE EXTENSION IF NOT EXISTS pg_cron;

-- STEP 2: Create 8-Hour Cron Schedule
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
      url := 'https://rixmudvtbfkjpwjoefon.supabase.co/functions/v1/process-daily-job-digest',
      headers := jsonb_build_object(
        'Content-Type', 'application/json',
        'Authorization', 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJpeG11ZHZ0YmZranB3am9lZm9uIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1MDU4OTg3MiwiZXhwIjoyMDY2MTY1ODcyfQ.6NIFXhO03vHAv3j8lL8A1dYtaNLMRYeE8v12MLsW4bg'
      ),
      body := '{}'::jsonb
    ) AS request_id;
  $$
);

-- STEP 3: Verify Cron Job Created Successfully
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
-- ============================================
