# 🚀 Quick Start - Test 8-Hour Email Digest NOW!

## ⚡ Fastest Way to Test (2 Minutes)

### Step 1: Open Test Page
```
http://localhost:5173/test-email-digest
```

### Step 2: Click Green Button
Click **"Send Test Email (Quick Test)"**

### Step 3: Check Email
Open your email inbox (check spam if not there)

**That's it!** ✅

---

## 📧 What You'll See in Email

**Subject:** "5 New Jobs for You - PrimoBoost AI"

**Content:**
- 5 latest jobs from your database
- Company logos with each job
- "Apply Now" buttons
- Professional dark theme design
- Mobile-responsive layout

---

## 🔧 If Test Fails

### Error: "No active jobs"
**Quick Fix:**
```bash
# Sync some jobs first
npx supabase functions invoke sync-jobs
```

### Error: "SMTP not configured"
**Quick Fix:**
Add these to Supabase → Settings → Edge Functions → Environment Variables:
```
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=your-email@gmail.com
SMTP_PASS=your-gmail-app-password
```

### Email in Spam Folder
**Normal!** See [DEPLOY_SPAM_FIX.md](DEPLOY_SPAM_FIX.md) to fix.

---

## ✅ After Successful Test

### Deploy the System (5 minutes)

1. **Deploy Functions:**
   ```bash
   npx supabase functions deploy send-job-digest-email
   npx supabase functions deploy process-daily-job-digest
   ```

2. **Run Setup SQL:**
   Open [TEST_8HR_DIGEST.sql](TEST_8HR_DIGEST.sql)
   - Copy Section 1 (Database Function)
   - Copy Section 5 (Cron Job)
   - Run in Supabase SQL Editor

3. **Done!**
   Emails will now send automatically every 8 hours:
   - 12:00 AM (midnight)
   - 8:00 AM (morning)
   - 4:00 PM (afternoon)

---

## 📊 Monitor System

### Check Email Logs
```sql
SELECT * FROM email_logs
WHERE email_type = 'job_digest'
ORDER BY created_at DESC
LIMIT 10;
```

### Check Cron Status
```sql
SELECT * FROM cron.job
WHERE jobname = 'job-digest-every-8-hours';
```

---

## 🎯 Key Features Included

✅ **Company Logos** - Displays company logos from database
✅ **Job URLs** - Apply Now, View Details, Browse All
✅ **8-Hour Updates** - Fresh jobs every 8 hours
✅ **Anti-Spam** - Plain text, proper headers
✅ **Mobile-Friendly** - Responsive email design
✅ **Professional** - Dark theme, gradient styling

---

## 📞 Need Help?

See complete guides:
- [TEST_EMAIL_BUTTON_GUIDE.md](TEST_EMAIL_BUTTON_GUIDE.md) - How to use test buttons
- [DEPLOY_CHECKLIST.md](DEPLOY_CHECKLIST.md) - Full deployment steps
- [TEST_8HR_DIGEST.sql](TEST_8HR_DIGEST.sql) - All SQL commands
- [DEPLOY_SPAM_FIX.md](DEPLOY_SPAM_FIX.md) - Fix spam issues

---

## 🎉 You're Done!

**Test URL:** http://localhost:5173/test-email-digest

**Test Time:** ~30 seconds

**Setup Time:** ~5 minutes (after successful test)

**Result:** Automated job emails every 8 hours with company logos! 🚀
