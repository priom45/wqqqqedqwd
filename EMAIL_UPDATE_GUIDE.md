# Job Email Notification System - Company Logo Integration

## Changes Required:

### 1. Update Database Query (process-daily-job-digest)

The RPC function `get_jobs_for_daily_digest` needs to include `company_logo_url`:

```sql
-- In Supabase SQL Editor, update the function:
CREATE OR REPLACE FUNCTION get_jobs_for_daily_digest(p_user_id uuid)
RETURNS TABLE (
  job_id uuid,
  company_name text,
  company_logo_url text,  -- ADD THIS LINE
  role_title text,
  domain text,
  application_link text,
  location_type text,
  package_amount numeric
)
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN QUERY
  SELECT 
    jl.id as job_id,
    jl.company_name,
    jl.company_logo_url,  -- ADD THIS LINE
    jl.role_title,
    jl.domain,
    jl.application_link,
    jl.location_type,
    jl.package_amount
  FROM job_listings jl
  WHERE jl.is_active = true
    AND jl.created_at > NOW() - INTERVAL '24 hours'
  ORDER BY jl.created_at DESC
  LIMIT 10;
END;
$$;
```

### 2. Update Email Template CSS

Add these styles to the email HTML (around line 106):

```css
.job-header-with-logo {
  display: flex;
  align-items: center;
  gap: 15px;
  margin-bottom: 15px;
}
.logo-container {
  flex-shrink: 0;
  width: 60px;
  height: 60px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: #f3f4f6;
  border-radius: 12px;
  overflow: hidden;
}
.company-logo {
  max-width: 100%;
  max-height: 100%;
  object-fit: contain;
}
.company-logo-placeholder {
  width: 100%;
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 24px;
  font-weight: bold;
  color: #ffffff;
  background: linear-gradient(135deg, #3b82f6 0%, #8b5cf6 100%);
}
.job-info {
  flex: 1;
}
```

### 3. Update Job Cards HTML (around line 64)

Replace the jobCardsHtml generation with this:

```javascript
const jobCardsHtml = emailData.jobs.map((job, index) => {
  const companyLogoHtml = job.company_logo_url
    ? `<img src="${job.company_logo_url}" alt="${job.company_name}" class="company-logo" onerror="this.style.display='none';this.parentElement.innerHTML='<div class=\\"company-logo-placeholder\\">${job.company_name.charAt(0)}</div>';" />`
    : `<div class="company-logo-placeholder">${job.company_name.charAt(0)}</div>`;

  return `
    <div class="job-card">
      <div class="job-header-with-logo">
        <div class="logo-container">
          ${companyLogoHtml}
        </div>
        <div class="job-info">
          <h3 class="job-title">${job.role_title}</h3>
          <span class="job-company">${job.company_name}</span>
        </div>
      </div>
      <div class="job-details">
        <div class="job-detail-item">
          <span class="detail-icon">🎯</span>
          <span>${job.domain}</span>
        </div>
        ${job.location_type ? `
        <div class="job-detail-item">
          <span class="detail-icon">📍</span>
          <span>${job.location_type}</span>
        </div>
        ` : ''}
        ${job.package_amount ? `
        <div class="job-detail-item">
          <span class="detail-icon">💰</span>
          <span>₹${job.package_amount.toLocaleString()}</span>
        </div>
        ` : ''}
      </div>
      <div class="job-actions">
        <a href="${job.application_link}" class="apply-button" target="_blank">
          Apply Now →
        </a>
        <a href="${siteUrl}/jobs/${job.job_id}" class="view-details" target="_blank">
          View Details
        </a>
      </div>
    </div>
  `;
}).join('');
```

### 4. Change to 8-Hour Schedule

Update the cron scheduler to run every 8 hours instead of daily.

**Create new file:** `supabase/functions/apify-cron-scheduler/index.ts`

Or update existing scheduler to call `process-daily-job-digest` every 8 hours.

**Using pg_cron in Supabase:**

```sql
-- Run this in Supabase SQL Editor
SELECT cron.schedule(
  'job-digest-8-hours',
  '0 */8 * * *',  -- Every 8 hours
  $$
  SELECT net.http_post(
    url := 'https://rixmudvtbfkjpwjoefon.supabase.co/functions/v1/process-daily-job-digest',
    headers := '{"Content-Type": "application/json", "Authorization": "Bearer YOUR_SERVICE_ROLE_KEY"}'::jsonb,
    body := '{}'::jsonb
  )
  $$
);
```

## Deployment Steps:

1. Update database function (run SQL above)
2. Deploy updated `send-job-digest-email` function
3. Set up 8-hour cron job
4. Test by calling the function manually

## Testing:

```bash
# Test the email function
curl -X POST https://rixmudvtbfkjpwjoefon.supabase.co/functions/v1/process-daily-job-digest \
  -H "Authorization: Bearer YOUR_SERVICE_ROLE_KEY" \
  -H "Content-Type: application/json"
```

