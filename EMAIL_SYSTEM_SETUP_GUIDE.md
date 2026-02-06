# Email Notification System Setup Guide

This guide will help you set up the 8-hour automated job notification system with company logos.

## ✅ What's Already Done

1. **Email Template Updated** - Professional responsive design with:
   - Company logos with gradient fallback
   - Table-based layout for email client compatibility
   - Mobile-responsive CSS
   - Dark mode support
   - Modern PrimoBoost branding

2. **Interface Updated** - `company_logo_url` field added to email job data

## 📋 Setup Steps

### Step 1: Update Database Function

Run this SQL in your Supabase SQL Editor to add `company_logo_url` to the email digest function:

```sql
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
BEGIN
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
  INNER JOIN job_notification_subscriptions jns ON jns.user_id = p_user_id
  WHERE jl.is_active = true
    AND jl.posted_date > COALESCE(jns.last_sent_at, NOW() - INTERVAL '24 hours')
    AND (
      array_length(jns.preferred_domains, 1) IS NULL
      OR jl.domain = ANY(jns.preferred_domains)
    )
  ORDER BY jl.posted_date DESC
  LIMIT 10;
END;
$$;
```

### Step 2: Deploy Updated Email Function

Run this command in your terminal from the project root:

```bash
npx supabase functions deploy send-job-digest-email
```

### Step 3: Set Up 8-Hour Cron Schedule

Run this SQL to create an 8-hour cron job (runs at 12am, 8am, 4pm daily):

```sql
-- First, enable pg_cron extension if not already enabled
CREATE EXTENSION IF NOT EXISTS pg_cron;

-- Create the 8-hour schedule
SELECT cron.schedule(
  'job-digest-every-8-hours',
  '0 0,8,16 * * *',  -- Runs at 12am, 8am, 4pm
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
```

**Note**: Before running the cron schedule, you need to set the configuration variables:

```sql
-- Set your Supabase URL (replace with your actual URL)
ALTER DATABASE postgres SET app.settings.supabase_url = 'https://YOUR-PROJECT-REF.supabase.co';

-- Set your service role key (replace with your actual key)
ALTER DATABASE postgres SET app.settings.supabase_service_role_key = 'YOUR-SERVICE-ROLE-KEY';
```

### Step 4: Verify Cron Job

Check if the cron job was created successfully:

```sql
SELECT * FROM cron.job WHERE jobname = 'job-digest-every-8-hours';
```

To see cron job execution history:

```sql
SELECT * FROM cron.job_run_details
WHERE jobid = (SELECT jobid FROM cron.job WHERE jobname = 'job-digest-every-8-hours')
ORDER BY start_time DESC
LIMIT 10;
```

## 🧪 Testing

### Test Email Function Manually

You can test the email function with sample data:

```bash
curl -X POST https://YOUR-PROJECT-REF.supabase.co/functions/v1/send-job-digest-email \
  -H "Authorization: Bearer YOUR-SERVICE-ROLE-KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "userId": "USER-UUID-HERE",
    "recipientEmail": "test@example.com",
    "recipientName": "Test User",
    "jobs": [
      {
        "job_id": "test-job-1",
        "company_name": "Google",
        "company_logo_url": "https://logo.clearbit.com/google.com",
        "role_title": "Software Engineer",
        "domain": "Technology",
        "application_link": "https://careers.google.com",
        "location_type": "Remote",
        "package_amount": 150000
      }
    ],
    "dateRange": "Last 8 hours"
  }'
```

### Test Full Digest Process

Run the digest processor manually:

```bash
curl -X POST https://YOUR-PROJECT-REF.supabase.co/functions/v1/process-daily-job-digest \
  -H "Authorization: Bearer YOUR-SERVICE-ROLE-KEY" \
  -H "Content-Type: application/json"
```

## 📊 Email Template Features

Your new email template includes:

✅ **Company Logos**:
- Displays actual company logos from `company_logo_url`
- Gradient fallback with company initial if logo fails to load
- 80x80px professional size

✅ **Responsive Design**:
- Mobile-optimized with media queries
- Stack layout on small screens
- Readable on all devices

✅ **Professional Styling**:
- Dark theme matching PrimoBoost brand
- Gradient headers (#4F46E5 to #7C3AED)
- Clean job cards with company info

✅ **Email Client Compatibility**:
- Table-based layout (not div-based)
- Inline styles for maximum compatibility
- MSO conditional comments for Outlook
- Works in Gmail, Outlook, Apple Mail, etc.

✅ **Call-to-Action Buttons**:
- "Apply Now" - Direct to application link
- "View Details" - Job details page
- "Browse All Jobs" - Main jobs page

## 🔧 Customization Options

### Change Email Frequency

To change from 8 hours to a different frequency, modify the cron schedule:

- **Every 4 hours**: `'0 0,4,8,12,16,20 * * *'`
- **Every 12 hours**: `'0 0,12 * * *'`
- **Daily at 9am**: `'0 9 * * *'`

### Adjust Number of Jobs

Edit line 11 in the SQL function to change from 10 jobs:

```sql
LIMIT 20;  -- Send 20 jobs instead of 10
```

### Update Date Range Label

Change "Last 8 hours" in `process-daily-job-digest/index.ts` line 135:

```typescript
dateRange: 'Last 8 hours'  // Change to your preferred text
```

## 🚨 Troubleshooting

### Emails Not Sending

1. Check Supabase function logs:
   ```bash
   npx supabase functions logs send-job-digest-email
   ```

2. Verify email service environment variables are set in Supabase dashboard

3. Check if users have `is_subscribed = true` in `job_notification_subscriptions`

### Logos Not Showing

1. Verify `company_logo_url` exists in database:
   ```sql
   SELECT company_name, company_logo_url FROM job_listings WHERE company_logo_url IS NOT NULL LIMIT 10;
   ```

2. Check if logo URLs are accessible (try opening in browser)

3. Email clients may block external images - this is normal behavior

### Cron Not Running

1. Ensure pg_cron extension is enabled
2. Check cron job status with the verification query above
3. Verify configuration variables are set correctly

## 📝 Next Steps

After setup, you should:

1. ✅ Monitor first few email sends for issues
2. ✅ Ask users for feedback on email design
3. ✅ Check email open rates and click-through rates
4. ✅ Consider adding unsubscribe tracking
5. ✅ Set up email analytics with your email provider

## 🎉 Done!

Your 8-hour job notification system is now ready. Users will receive professionally designed emails with company logos every 8 hours, featuring the latest 10 jobs matching their preferences.
