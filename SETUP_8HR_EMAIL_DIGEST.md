# Setup 8-Hour Email Digest - Complete Guide

## 🔍 Current Issues Found

1. ❌ Processor still says "Last 24 hours" (should be "Last 8 hours")
2. ❌ Database function missing `company_logo_url` field
3. ❌ No 8-hour cron job set up yet
4. ❌ Processor looks for 'daily' frequency (should support 8-hour)

## ✅ Complete Setup Steps

### Step 1: Update Database Function (Add Logo URL)

Run this SQL in Supabase SQL Editor:

```sql
-- Drop old function
DROP FUNCTION IF EXISTS get_jobs_for_daily_digest(uuid);

-- Create new function with company_logo_url
CREATE OR REPLACE FUNCTION get_jobs_for_daily_digest(p_user_id uuid)
RETURNS TABLE (
  job_id text,
  company_name text,
  company_logo_url text,
  role_title text,
  domain text,
  application_link text,
  posted_date timestamp with time zone,
  location_type text,
  package_amount numeric
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_last_sent_at timestamp with time zone;
  v_preferred_domains text[];
BEGIN
  -- Get user's subscription settings
  SELECT last_sent_at, preferred_domains
  INTO v_last_sent_at, v_preferred_domains
  FROM job_notification_subscriptions
  WHERE user_id = p_user_id
    AND is_subscribed = true;

  -- If no subscription found, return empty
  IF NOT FOUND THEN
    RETURN;
  END IF;

  -- Default to last 8 hours if never sent before
  IF v_last_sent_at IS NULL THEN
    v_last_sent_at := NOW() - INTERVAL '8 hours';
  END IF;

  -- Return jobs posted since last sent
  RETURN QUERY
  SELECT
    jl.id::text,
    jl.company_name,
    jl.company_logo_url,
    jl.role_title,
    jl.domain,
    jl.application_link,
    jl.posted_date,
    jl.location_type,
    jl.package_amount
  FROM job_listings jl
  WHERE jl.is_active = true
    AND jl.posted_date > v_last_sent_at
    AND (
      v_preferred_domains IS NULL
      OR array_length(v_preferred_domains, 1) IS NULL
      OR jl.domain = ANY(v_preferred_domains)
    )
  ORDER BY jl.posted_date DESC
  LIMIT 10;
END;
$$;
```

### Step 2: Update Subscription Table (Add 8-hour Frequency)

```sql
-- Check current notification_frequency options
SELECT DISTINCT notification_frequency
FROM job_notification_subscriptions;

-- If you want to keep 'daily' and add '8-hour' support,
-- update existing daily users OR create new frequency type

-- Option A: Keep daily, make it work with 8-hour cron
-- (No change needed, cron will just run more frequently)

-- Option B: Add new frequency type (if you want users to choose)
ALTER TABLE job_notification_subscriptions
DROP CONSTRAINT IF EXISTS job_notification_subscriptions_notification_frequency_check;

ALTER TABLE job_notification_subscriptions
ADD CONSTRAINT job_notification_subscriptions_notification_frequency_check
CHECK (notification_frequency IN ('instant', 'daily', '8-hour', 'weekly'));

-- Update existing daily users to 8-hour
UPDATE job_notification_subscriptions
SET notification_frequency = '8-hour'
WHERE notification_frequency = 'daily';
```

### Step 3: Update Processor for 8-Hour Schedule

The processor needs to:
1. Change "Last 24 hours" to "Last 8 hours"
2. Support both 'daily' and '8-hour' frequency

Update `process-daily-job-digest/index.ts`:

Line 52 - Change frequency filter:
```typescript
// OLD:
.eq('notification_frequency', 'daily');

// NEW: Support both daily and 8-hour
.in('notification_frequency', ['daily', '8-hour']);
```

Line 135 - Change date range:
```typescript
// OLD:
dateRange: 'Last 24 hours'

// NEW:
dateRange: 'Last 8 hours'
```

### Step 4: Set Up 8-Hour Cron Job

Run this SQL to create the cron schedule:

```sql
-- Enable pg_cron extension
CREATE EXTENSION IF NOT EXISTS pg_cron;

-- Set configuration (replace with your actual values)
ALTER DATABASE postgres
SET app.settings.supabase_url = 'https://YOUR-PROJECT-REF.supabase.co';

ALTER DATABASE postgres
SET app.settings.supabase_service_role_key = 'YOUR-SERVICE-ROLE-KEY';

-- Create cron job (runs every 8 hours: 12am, 8am, 4pm)
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

-- Verify cron job was created
SELECT * FROM cron.job WHERE jobname = 'job-digest-every-8-hours';
```

### Step 5: Deploy Updated Functions

```bash
# Deploy processor with 8-hour updates
npx supabase functions deploy process-daily-job-digest

# Deploy email function (already has logo support)
npx supabase functions deploy send-job-digest-email
```

## 🧪 Test the 8-Hour System

### Test 1: Verify Database Function Returns Logos

```sql
-- Test the function (replace with real user ID)
SELECT * FROM get_jobs_for_daily_digest('YOUR-USER-UUID-HERE');

-- Check if company_logo_url is populated
-- Should return 10 jobs with logo URLs
```

### Test 2: Manual Trigger Email Digest

```bash
curl -X POST https://YOUR-PROJECT-REF.supabase.co/functions/v1/process-daily-job-digest \
  -H "Authorization: Bearer YOUR-SERVICE-ROLE-KEY" \
  -H "Content-Type: application/json"
```

Expected response:
```json
{
  "success": true,
  "message": "Daily digest processing completed",
  "stats": {
    "totalSubscribers": 5,
    "processedUsers": 5,
    "emailsSent": 3,
    "totalJobsSent": 15,
    "errors": 0
  }
}
```

### Test 3: Verify Email Has Company Logos

Check your email inbox:
- ✅ Subject: "10 New Jobs for You - PrimoBoost AI"
- ✅ Email shows company logos (or gradient fallback)
- ✅ "Apply Now" buttons work
- ✅ Job links go to correct URLs

### Test 4: Check Cron Job Status

```sql
-- See if cron job exists
SELECT jobid, jobname, schedule, active
FROM cron.job
WHERE jobname = 'job-digest-every-8-hours';

-- Check last run (wait for next scheduled time)
SELECT * FROM cron.job_run_details
WHERE jobid = (SELECT jobid FROM cron.job WHERE jobname = 'job-digest-every-8-hours')
ORDER BY start_time DESC
LIMIT 5;
```

## 📊 Verify URLs Are Added to Emails

The emails already include job URLs in 3 places:

1. **Apply Now Button**: Direct application link
   ```html
   <a href="${job.application_link}">Apply Now →</a>
   ```

2. **View Details Button**: Job details page on your site
   ```html
   <a href="${siteUrl}/jobs/${job.job_id}">View Details</a>
   ```

3. **Browse All Jobs**: Main jobs page
   ```html
   <a href="${siteUrl}/jobs">Browse All Jobs</a>
   ```

All URLs are already in the template! ✅

## 🔍 Debug Checklist

If jobs aren't showing in emails:

1. **Check subscriptions exist:**
   ```sql
   SELECT * FROM job_notification_subscriptions
   WHERE is_subscribed = true;
   ```

2. **Check jobs exist in time window:**
   ```sql
   SELECT COUNT(*) FROM job_listings
   WHERE posted_date > NOW() - INTERVAL '8 hours'
   AND is_active = true;
   ```

3. **Check function returns data:**
   ```sql
   SELECT * FROM get_jobs_for_daily_digest('user-uuid-here');
   ```

4. **Check email logs:**
   ```sql
   SELECT * FROM email_logs
   ORDER BY created_at DESC
   LIMIT 10;
   ```

5. **Check processor logs:**
   ```bash
   npx supabase functions logs process-daily-job-digest --tail
   ```

## ⏰ Cron Schedule Explained

`'0 0,8,16 * * *'` means:
- **0**: At minute 0 (top of the hour)
- **0,8,16**: At hours 0 (12am), 8 (8am), 16 (4pm)
- **\* \* \***: Every day, every month, every day of week

So emails send at:
- 12:00 AM (midnight)
- 8:00 AM (morning)
- 4:00 PM (afternoon)

### Change Schedule (Optional)

Want different times? Change the cron expression:

```sql
-- Every 6 hours (12am, 6am, 12pm, 6pm)
'0 0,6,12,18 * * *'

-- Every 4 hours
'0 0,4,8,12,16,20 * * *'

-- Specific times (9am, 2pm, 8pm)
'0 9,14,20 * * *'

-- Update existing cron job
SELECT cron.unschedule('job-digest-every-8-hours');
SELECT cron.schedule('job-digest-every-8-hours', 'NEW-SCHEDULE-HERE', $$...$$);
```

## 📈 Monitor Performance

### Track Email Deliverability

```sql
-- Email success rate
SELECT
  status,
  COUNT(*) as count,
  ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) as percentage
FROM email_logs
WHERE email_type = 'job_digest'
GROUP BY status;

-- Recent emails
SELECT
  recipient_email,
  subject,
  status,
  sent_at,
  error_message
FROM email_logs
WHERE email_type = 'job_digest'
ORDER BY created_at DESC
LIMIT 20;
```

### Track Cron Execution

```sql
-- Last 10 cron runs
SELECT
  start_time,
  end_time,
  status,
  return_message,
  (end_time - start_time) as duration
FROM cron.job_run_details
WHERE jobid = (SELECT jobid FROM cron.job WHERE jobname = 'job-digest-every-8-hours')
ORDER BY start_time DESC
LIMIT 10;
```

## ✅ Summary Checklist

- [ ] Database function updated with `company_logo_url`
- [ ] Processor updated to "Last 8 hours"
- [ ] Cron job created (runs every 8 hours)
- [ ] Functions deployed to Supabase
- [ ] Test manual trigger works
- [ ] Verify emails have company logos
- [ ] Verify job URLs work in emails
- [ ] Monitor cron execution
- [ ] Check spam rate improved

## 🎯 Expected Results

After setup:
- ✅ Emails sent every 8 hours (12am, 8am, 4pm)
- ✅ Latest 10 jobs included
- ✅ Company logos displayed (or gradient fallback)
- ✅ 3 types of URLs: Apply Now, View Details, Browse All
- ✅ 60-75% inbox rate (with spam fixes applied)
- ✅ Plain text version for better deliverability

Your 8-hour job digest system is ready! 🚀
