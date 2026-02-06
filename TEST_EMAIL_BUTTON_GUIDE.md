# Test Email Digest Button - Quick Guide

## ✅ What I Created

A dedicated test page with **2 buttons** to test your 8-hour email digest system:

### Page URL:
```
http://localhost:5173/test-email-digest
```

Or on production:
```
https://primoboost.ai/test-email-digest
```

---

## 🎯 Two Test Buttons

### Button 1: "Test Full System" (Blue)
**What it does:**
- Triggers the complete `process-daily-job-digest` function
- Sends emails to **ALL subscribed users**
- Uses jobs from last 8 hours
- Same as the automated cron job

**When to use:**
- Test the full automated system
- See how many users will receive emails
- Check stats: emails sent, jobs included, errors

**Response shows:**
```json
{
  "stats": {
    "totalSubscribers": 10,
    "emailsSent": 8,
    "totalJobsSent": 50,
    "errors": 0
  }
}
```

---

### Button 2: "Send Test Email" (Green) ⭐ RECOMMENDED
**What it does:**
- Sends ONE test email to YOUR email address
- Includes latest 5 jobs from database
- Bypasses subscription check
- Fast and safe for testing

**When to use:**
- Quick testing without affecting other users
- Check if emails are working
- Verify company logos show correctly
- Test "Apply Now" URLs work

**Response shows:**
```json
{
  "success": true,
  "recipient": "your-email@gmail.com",
  "jobCount": 5
}
```

---

## 📋 How to Use

### Step 1: Access the Test Page

Navigate to:
```
http://localhost:5173/test-email-digest
```

### Step 2: Click Green Button (Quick Test)

1. Click **"Send Test Email"** (green button)
2. Wait 3-5 seconds
3. Check response on screen
4. **Check your email inbox** (or spam folder)

### Step 3: Verify Email

Your email should have:
- ✅ Subject: "5 New Jobs for You - PrimoBoost AI"
- ✅ Company logos (or gradient fallback letters)
- ✅ "Apply Now" button for each job
- ✅ "View Details" button
- ✅ Professional dark theme design
- ✅ Mobile-responsive layout

### Step 4: Test URLs

Click these in the email:
- ✅ "Apply Now" → Should go to application link
- ✅ "View Details" → Should go to job page
- ✅ "Browse All Jobs" → Should go to jobs page

---

## 🔍 What This Tests

The test page verifies:

1. **Email Sending Works**
   - SMTP configured correctly
   - Edge functions deployed
   - Email service operational

2. **Company Logos Display**
   - Logo URLs from database
   - Fallback gradient showing company initial
   - Images loading correctly

3. **Job URLs Included**
   - Application links working
   - Job detail pages accessible
   - All CTAs functional

4. **Anti-Spam Features**
   - Plain text version included
   - Proper email headers
   - Professional subject line

5. **8-Hour System Ready**
   - Database function returns jobs
   - Processor handles subscriptions
   - Emails sending correctly

---

## 🚨 Troubleshooting

### Error: "No active job listings in database"
**Solution:**
```sql
-- Check if jobs exist
SELECT COUNT(*) FROM job_listings WHERE is_active = true;

-- If no jobs, sync some
-- Run: npx supabase functions invoke sync-jobs
```

### Error: "SMTP credentials not configured"
**Solution:**
Set these in Supabase Dashboard → Settings → Functions → Environment Variables:
```
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=your-email@gmail.com
SMTP_PASS=your-app-password
SMTP_FROM=noreply@primoboost.ai
```

### Email Goes to Spam
**Solution:**
See [DEPLOY_SPAM_FIX.md](DEPLOY_SPAM_FIX.md) for complete spam prevention guide.

Quick fixes applied:
- ✅ Plain text version
- ✅ Anti-spam headers
- ✅ Professional subject line

For 95%+ inbox rate: Switch to Resend.com (FREE tier available)

### No Logo Showing
**Check:**
1. Database has `company_logo_url`:
   ```sql
   SELECT company_name, company_logo_url
   FROM job_listings
   WHERE company_logo_url IS NOT NULL
   LIMIT 5;
   ```

2. Email client may block external images (this is normal)

3. Gradient fallback should show company initial

---

## 📊 Understanding Results

### Success Response
```json
{
  "success": true,
  "message": "Test email sent successfully!",
  "recipient": "test@example.com",
  "jobCount": 5,
  "messageId": "abc123..."
}
```

**Meaning:** Email sent! Check inbox.

### Full System Stats
```json
{
  "stats": {
    "totalSubscribers": 10,    // Users with email notifications enabled
    "processedUsers": 10,       // Users we attempted to send to
    "emailsSent": 8,            // Successful sends
    "totalJobsSent": 50,        // Total jobs across all emails
    "errors": 2                 // Failed sends (check logs)
  }
}
```

**Meaning:** System working! 8 out of 10 users received emails.

---

## 🔄 Testing Workflow

### Before Deploying to Production:

1. **Test Single Email** (Green button)
   - Verify email arrives
   - Check logos display
   - Test all URLs work

2. **Check Database**
   ```sql
   -- Verify jobs exist
   SELECT COUNT(*) FROM job_listings
   WHERE is_active = true
   AND posted_date > NOW() - INTERVAL '8 hours';
   ```

3. **Test Full System** (Blue button)
   - See how many users will get emails
   - Check stats make sense
   - Verify no errors

4. **Deploy Functions**
   ```bash
   npx supabase functions deploy send-job-digest-email
   npx supabase functions deploy process-daily-job-digest
   ```

5. **Set Up Cron** (See [DEPLOY_CHECKLIST.md](DEPLOY_CHECKLIST.md))

---

## 📧 Email Template Features

Your test email includes:

✅ **Header:**
- Professional gradient banner
- Job count badge
- "Last 8 hours" or custom date range

✅ **Job Cards:**
- Company logo (80x80px)
- Role title
- Company name
- Domain, Location, Salary
- "Apply Now" button (green gradient)
- "View Details" button (blue outline)

✅ **Footer:**
- Unsubscribe link
- Update preferences link
- Company branding

✅ **Mobile-Responsive:**
- Stacks on small screens
- Readable on all devices
- Touch-friendly buttons

---

## 🎯 Next Steps After Testing

1. ✅ Verify email received and looks good
2. ✅ Test all URLs and buttons
3. ✅ Deploy functions if not already done
4. ✅ Set up 8-hour cron schedule
5. ✅ Monitor email logs in database
6. ✅ Switch to Resend for better deliverability

---

## 🔗 Related Documentation

- **[DEPLOY_CHECKLIST.md](DEPLOY_CHECKLIST.md)** - Complete deployment guide
- **[TEST_8HR_DIGEST.sql](TEST_8HR_DIGEST.sql)** - All SQL queries
- **[DEPLOY_SPAM_FIX.md](DEPLOY_SPAM_FIX.md)** - Fix spam issues
- **[FIX_EMAIL_SPAM_ISSUE.md](FIX_EMAIL_SPAM_ISSUE.md)** - Switch to Resend

---

## ✨ Summary

**Test Page:** `http://localhost:5173/test-email-digest`

**Two Buttons:**
1. 🔵 **Test Full System** - Send to all subscribers
2. 🟢 **Send Test Email** - Quick single test (RECOMMENDED)

**What to Check:**
- ✅ Email arrives (check spam if not in inbox)
- ✅ Company logos display
- ✅ All URLs work
- ✅ Looks professional on desktop and mobile

**After Testing:**
- Deploy functions
- Set up 8-hour cron
- Monitor and enjoy automated job emails! 🎉
