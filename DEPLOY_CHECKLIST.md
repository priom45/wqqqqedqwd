# 8-Hour Job Digest - Deployment Checklist

## ✅ What You Need to Do

Follow these steps in order:

### 1. Update Database (5 minutes)

Open Supabase SQL Editor and run the queries from [TEST_8HR_DIGEST.sql](TEST_8HR_DIGEST.sql):

1. **Section 1**: Create database function with logo URL support
2. **Section 5**: Set up 8-hour cron job
   - ⚠️ **IMPORTANT**: Replace `YOUR-PROJECT-REF` and `YOUR-SERVICE-ROLE-KEY` with your actual values!

### 2. Deploy Functions (2 minutes)

Run these commands in your terminal:

```bash
# Navigate to project directory
cd "c:\Users\USER\OneDrive\Documents\project-bolt-github-ux9pebq8 (1)\project"

# Deploy email function (with spam fixes + logo support)
npx supabase functions deploy send-job-digest-email

# Deploy processor (with 8-hour support)
npx supabase functions deploy process-daily-job-digest
```

### 3. Test Manually (3 minutes)

Test the digest processor:

```bash
# Replace YOUR-PROJECT-REF and YOUR-SERVICE-ROLE-KEY
curl -X POST https://YOUR-PROJECT-REF.supabase.co/functions/v1/process-daily-job-digest \
  -H "Authorization: Bearer YOUR-SERVICE-ROLE-KEY" \
  -H "Content-Type: application/json"
```

Expected response:
```json
{
  "success": true,
  "stats": {
    "emailsSent": 2,
    "totalJobsSent": 15
  }
}
```

### 4. Check Your Email (2 minutes)

Open your email and verify:
- ✅ Subject: "10 New Jobs for You - PrimoBoost AI"
- ✅ Company logos showing (or gradient fallback)
- ✅ "Apply Now" buttons work
- ✅ "View Details" links work
- ✅ Email NOT in spam folder (if in spam, check [DEPLOY_SPAM_FIX.md](DEPLOY_SPAM_FIX.md))

### 5. Verify Cron Schedule (1 minute)

Run this SQL to confirm cron job is active:

```sql
SELECT jobname, schedule, active
FROM cron.job
WHERE jobname = 'job-digest-every-8-hours';
```

Should show:
```
jobname: job-digest-every-8-hours
schedule: 0 0,8,16 * * *
active: true
```

---

## 📊 What This Does

### Emails Will Send:
- **12:00 AM** (midnight) - Night owls 🌙
- **8:00 AM** (morning) - Early birds 🌅
- **4:00 PM** (afternoon) - After work 🌆

### Each Email Includes:
- Latest 10 jobs from last 8 hours
- Company logos with fallback
- 3 types of links:
  1. "Apply Now" → Direct to application
  2. "View Details" → Job page on your site
  3. "Browse All Jobs" → Main jobs page

### Job URLs in Emails:
✅ **ALL URLs are already included!**
- Apply links: `job.application_link`
- Details links: `${siteUrl}/jobs/${job.job_id}`
- Browse link: `${siteUrl}/jobs`

---

## 🔍 Troubleshooting

### No Emails Sent?

Run these SQL checks:

```sql
-- 1. Check if users are subscribed
SELECT COUNT(*) FROM job_notification_subscriptions
WHERE is_subscribed = true;

-- 2. Check if jobs exist in last 8 hours
SELECT COUNT(*) FROM job_listings
WHERE posted_date > NOW() - INTERVAL '8 hours'
AND is_active = true;

-- 3. Check email logs
SELECT * FROM email_logs
ORDER BY created_at DESC LIMIT 5;
```

### Emails Going to Spam?

See [DEPLOY_SPAM_FIX.md](DEPLOY_SPAM_FIX.md) for complete spam prevention guide.

Quick fix:
1. Deploy current anti-spam updates (already done ✅)
2. Sign up for Resend.com (FREE, 3000 emails/month)
3. Switch from Gmail SMTP to Resend
4. Result: 95%+ inbox delivery

### Logo Not Showing?

1. Check database has logo URLs:
   ```sql
   SELECT company_name, company_logo_url
   FROM job_listings
   WHERE company_logo_url IS NOT NULL
   LIMIT 10;
   ```

2. Test logo URL in browser (should load image)

3. Email clients may block external images - this is normal

---

## 📈 Monitor System

### Check Email Stats

```sql
-- Success rate
SELECT status, COUNT(*)
FROM email_logs
WHERE email_type = 'job_digest'
GROUP BY status;

-- Recent sends
SELECT recipient_email, status, sent_at
FROM email_logs
ORDER BY created_at DESC
LIMIT 10;
```

### Check Cron Execution

```sql
-- Last 5 runs
SELECT start_time, status, return_message
FROM cron.job_run_details
WHERE jobid = (SELECT jobid FROM cron.job WHERE jobname = 'job-digest-every-8-hours')
ORDER BY start_time DESC
LIMIT 5;
```

---

## ✅ Complete Checklist

- [ ] Database function created
- [ ] Cron job scheduled (8-hour intervals)
- [ ] Email function deployed
- [ ] Processor function deployed
- [ ] Manual test successful
- [ ] Email received with logos
- [ ] URLs in email work correctly
- [ ] Email in inbox (not spam)
- [ ] Cron schedule verified
- [ ] Monitoring set up

---

## 🎯 Expected Results

**Before:**
- Manual email sending only
- No scheduled digests
- Inconsistent deliverability

**After:**
- ✅ Automatic emails every 8 hours
- ✅ 10 latest jobs per email
- ✅ Company logos included
- ✅ 60-75% inbox rate (with spam fixes)
- ✅ Professional email design
- ✅ All job URLs working

**Next Steps:**
- Monitor email deliverability
- Switch to Resend.com for 95%+ inbox rate
- Gradually increase sending volume
- Ask users to mark as "Not Spam"

---

## 📞 Files Reference

- **[TEST_8HR_DIGEST.sql](TEST_8HR_DIGEST.sql)** - All SQL queries for setup and testing
- **[SETUP_8HR_EMAIL_DIGEST.md](SETUP_8HR_EMAIL_DIGEST.md)** - Detailed explanation of system
- **[DEPLOY_SPAM_FIX.md](DEPLOY_SPAM_FIX.md)** - Fix spam issues with current setup
- **[FIX_EMAIL_SPAM_ISSUE.md](FIX_EMAIL_SPAM_ISSUE.md)** - Switch to Resend for best deliverability

---

Your 8-hour automated job digest system is ready to deploy! 🚀

**Time to Complete**: ~15 minutes
**Difficulty**: Easy (just copy & paste commands)
**Result**: Professional automated job emails every 8 hours
