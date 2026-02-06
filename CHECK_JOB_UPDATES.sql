-- ============================================
-- Check if Job Updates are Being Sent
-- ============================================

-- 1. Check recent job digest emails sent
-- ============================================
SELECT
  id,
  recipient,
  subject,
  status,
  created_at,
  metadata
FROM email_logs
WHERE email_type = 'job_digest'
ORDER BY created_at DESC
LIMIT 10;

-- 2. Check jobs from last 8 hours (what will be sent)
-- ============================================
SELECT
  id,
  company_name,
  company_logo_url,
  role_title,
  domain,
  application_link,
  posted_date,
  NOW() - posted_date as job_age,
  is_active
FROM job_listings
WHERE is_active = true
  AND posted_date > NOW() - INTERVAL '8 hours'
ORDER BY posted_date DESC
LIMIT 20;

-- 3. Check how many jobs with logos
-- ============================================
SELECT
  COUNT(*) as total_active_jobs,
  COUNT(CASE WHEN posted_date > NOW() - INTERVAL '8 hours' THEN 1 END) as jobs_last_8hrs,
  COUNT(CASE WHEN company_logo_url IS NOT NULL THEN 1 END) as jobs_with_logos,
  ROUND(COUNT(CASE WHEN company_logo_url IS NOT NULL THEN 1 END) * 100.0 / COUNT(*), 2) as logo_percentage
FROM job_listings
WHERE is_active = true;

-- 4. Check active subscribers
-- ============================================
SELECT
  COUNT(*) as total_subscribers,
  notification_frequency,
  COUNT(CASE WHEN last_sent_at > NOW() - INTERVAL '8 hours' THEN 1 END) as sent_recently
FROM job_notification_subscriptions
WHERE is_subscribed = true
GROUP BY notification_frequency;

-- 5. Check next cron job run time
-- ============================================
SELECT
  jobname,
  schedule,
  active,
  database,
  -- Next run times (approximate)
  CASE
    WHEN EXTRACT(HOUR FROM NOW()) < 8 THEN 'Today at 8:00 AM'
    WHEN EXTRACT(HOUR FROM NOW()) < 16 THEN 'Today at 4:00 PM'
    ELSE 'Tomorrow at 12:00 AM'
  END as next_run
FROM cron.job
WHERE jobname = 'job-digest-every-8-hours';

-- ============================================
-- Quick Test Summary
-- ============================================
-- Run this to get a quick overview:
SELECT
  'Job Digest Emails (Last 24hrs)' as metric,
  COUNT(*) as count
FROM email_logs
WHERE email_type = 'job_digest'
  AND created_at > NOW() - INTERVAL '24 hours'
UNION ALL
SELECT
  'Active Jobs (Last 8hrs)',
  COUNT(*)
FROM job_listings
WHERE is_active = true
  AND posted_date > NOW() - INTERVAL '8 hours'
UNION ALL
SELECT
  'Active Subscribers',
  COUNT(*)
FROM job_notification_subscriptions
WHERE is_subscribed = true
UNION ALL
SELECT
  'Jobs with Logos',
  COUNT(*)
FROM job_listings
WHERE is_active = true
  AND company_logo_url IS NOT NULL;
