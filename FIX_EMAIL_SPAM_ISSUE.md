# Fix Email Going to Spam - Complete Guide

## 🚨 Problem
Job digest emails are going to spam folder instead of inbox.

## ✅ Solutions (Apply ALL of these)

### Solution 1: Use Professional Email Service (RECOMMENDED)

**Stop using Gmail SMTP**. Gmail marks bulk emails as spam. Switch to a professional service:

#### Option A: Resend (Easiest - FREE for 3,000 emails/month)

1. Sign up at https://resend.com
2. Get your API key
3. Verify your domain (primoboost.ai)
4. Update your email service:

Create new file: `supabase/functions/_shared/resendEmailService.ts`

```typescript
export class ResendEmailService {
  private apiKey: string;

  constructor() {
    this.apiKey = Deno.env.get('RESEND_API_KEY') || '';
  }

  async sendEmail(options: {
    to: string;
    subject: string;
    html: string;
  }): Promise<{ success: boolean; messageId?: string; error?: string }> {
    try {
      const response = await fetch('https://api.resend.com/emails', {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${this.apiKey}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          from: 'PrimoBoost AI <noreply@primoboost.ai>',
          to: options.to,
          subject: options.subject,
          html: options.html,
        }),
      });

      const data = await response.json();

      if (!response.ok) {
        return {
          success: false,
          error: data.message || 'Failed to send email'
        };
      }

      return {
        success: true,
        messageId: data.id
      };
    } catch (error) {
      return {
        success: false,
        error: error.message
      };
    }
  }
}
```

Then update `send-job-digest-email/index.ts` line 321:

```typescript
// OLD:
const emailService = new EmailService();

// NEW:
import { ResendEmailService } from '../_shared/resendEmailService.ts';
const emailService = new ResendEmailService();
```

Set environment variable in Supabase:
```bash
RESEND_API_KEY=your_api_key_here
```

#### Option B: SendGrid (Good for scaling)

Similar setup, use SendGrid API instead.

#### Option C: AWS SES (Cheapest for high volume)

$0.10 per 1,000 emails after free tier.

---

### Solution 2: Add Plain Text Version (CRITICAL)

Email providers trust emails with both HTML and plain text versions. Update the email service to include text:

Edit `send-job-digest-email/index.ts` around line 324:

```typescript
const result = await emailService.sendEmail({
  to: emailData.recipientEmail,
  subject: subject,
  html: emailHtml,
  text: generatePlainTextVersion(emailData)  // ADD THIS
});

// Add this function before the Deno.serve call:
function generatePlainTextVersion(emailData: JobDigestRequest): string {
  const jobsText = emailData.jobs.map((job, index) => `
${index + 1}. ${job.role_title} at ${job.company_name}
   Domain: ${job.domain}
   ${job.location_type ? `Location: ${job.location_type}` : ''}
   ${job.package_amount ? `Package: ₹${job.package_amount.toLocaleString()}` : ''}
   Apply: ${job.application_link}
  `).join('\n');

  return `
Hi ${emailData.recipientName},

We found ${emailData.jobs.length} exciting opportunities that match your preferences!

${jobsText}

Apply early to increase your chances!

Browse all jobs: ${Deno.env.get('SITE_URL') || 'https://primoboost.ai'}/jobs

---
PrimoBoost AI - Your Intelligent Career Companion
Manage notifications: ${Deno.env.get('SITE_URL') || 'https://primoboost.ai'}/settings
  `.trim();
}
```

---

### Solution 3: Add Proper Email Headers

Update `emailService.ts` to add anti-spam headers. Edit line 72:

```typescript
const info = await this.transporter.sendMail({
  from: `"PrimoBoost AI" <${this.config.from}>`,
  to: options.to,
  subject: options.subject,
  html: options.html,
  text: options.text || this.stripHtml(options.html),
  // ADD THESE HEADERS:
  headers: {
    'X-Entity-Ref-ID': `job-digest-${Date.now()}`,
    'List-Unsubscribe': `<${Deno.env.get('SITE_URL')}/unsubscribe>`,
    'List-Unsubscribe-Post': 'List-Unsubscribe=One-Click',
    'Precedence': 'bulk',
    'X-Auto-Response-Suppress': 'OOF, DR, RN, NRN, AutoReply',
  }
});
```

---

### Solution 4: Reduce Spam Trigger Words

The current email has some spam triggers. Update the email content:

**Change these phrases in `send-job-digest-email/index.ts`:**

```typescript
// Line 135 - Change subject
const subject = `${jobCount} New ${jobCount === 1 ? 'Job' : 'Jobs'} for You`;
// Remove emojis from subject line - they trigger spam filters

// Line 135 in HTML - Change header
<h1 style="margin:0 0 10px 0;font-size:28px;color:#ffffff;font-weight:bold;">Your Job Digest</h1>
// Remove 🔔 emoji

// Line 175 - Change browse button text
Browse All Opportunities
// Instead of "Browse All Jobs"
```

---

### Solution 5: Set Up Domain Authentication (If using custom domain)

If you own primoboost.ai domain, add these DNS records:

#### For Resend:
1. Go to Resend dashboard > Domains
2. Add primoboost.ai
3. Add the DNS records they provide (SPF, DKIM, DMARC)

Example DNS records you'll need to add:

```
TXT  @  v=spf1 include:_spf.resend.com ~all
TXT  resend._domainkey  [DKIM value from Resend]
TXT  _dmarc  v=DMARC1; p=none; rua=mailto:dmarc@primoboost.ai
```

#### For Gmail SMTP (Current setup):
Add these to your domain DNS:

```
TXT  @  v=spf1 include:_spf.google.com ~all
TXT  _dmarc  v=DMARC1; p=quarantine; rua=mailto:dmarc@primoboost.ai
```

---

### Solution 6: Warm Up Your Email Sending

Don't send to all users immediately. Gradually increase:

**Day 1**: Send to 10 users
**Day 2**: Send to 25 users
**Day 3**: Send to 50 users
**Day 4**: Send to 100 users
**Week 2**: Full volume

Update `process-daily-job-digest/index.ts` to add a limit:

```typescript
// Line 44 - Add limit
const { data: subscriptions, error: subsError } = await supabase
  .from('job_notification_subscriptions')
  .select(`
    user_id,
    preferred_domains,
    last_sent_at
  `)
  .eq('is_subscribed', true)
  .eq('notification_frequency', 'daily')
  .limit(50);  // ADD THIS - Start with 50, increase gradually
```

---

### Solution 7: Add Unsubscribe Link (Already done ✅)

Your email already has this - good!

---

### Solution 8: Monitor Email Reputation

Use these tools to check if your emails are marked as spam:

1. **Mail-Tester**: https://www.mail-tester.com
   - Send a test email to the address they provide
   - They'll give you a spam score

2. **Google Postmaster Tools**: https://postmaster.google.com
   - Monitor Gmail delivery
   - See spam rates
   - Check domain reputation

---

## 🎯 Quick Action Plan (Do This Now)

**Immediate (Today):**
1. ✅ Add plain text version (Solution 2)
2. ✅ Add email headers (Solution 3)
3. ✅ Remove emoji from subject line (Solution 4)
4. ✅ Test with mail-tester.com

**This Week:**
1. ✅ Sign up for Resend.com (FREE)
2. ✅ Verify your domain
3. ✅ Switch to Resend API (Solution 1)
4. ✅ Set up email warm-up (Solution 6)

**This Month:**
1. ✅ Monitor with Google Postmaster
2. ✅ Gradually increase sending volume
3. ✅ Ask users to mark as "Not Spam"

---

## 📊 Test Your Fixes

After applying fixes, test with:

```bash
# Send test email
curl -X POST https://YOUR-PROJECT-REF.supabase.co/functions/v1/send-job-digest-email \
  -H "Authorization: Bearer YOUR-SERVICE-ROLE-KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "userId": "test-user",
    "recipientEmail": "YOUR-EMAIL@gmail.com",
    "recipientName": "Test User",
    "jobs": [...],
    "dateRange": "Test"
  }'
```

Then:
1. Check if it went to inbox or spam
2. Check email headers (View > Show Original in Gmail)
3. Look for SPF, DKIM, DMARC pass/fail
4. Send to mail-tester.com for spam score

---

## 🎯 Expected Results

After implementing ALL solutions:

- **Spam Score**: 8/10 or higher on mail-tester.com
- **Inbox Delivery**: 90%+ to inbox (not spam)
- **SPF/DKIM/DMARC**: All PASS
- **User Engagement**: Higher open rates

---

## ⚠️ Why Gmail SMTP Fails

Gmail SMTP is NOT designed for bulk emails:
- Marks your own emails as spam
- Daily sending limit (500-2000/day)
- Poor deliverability for newsletters
- Can get your account suspended

**Switch to Resend/SendGrid/AWS SES for production!**
