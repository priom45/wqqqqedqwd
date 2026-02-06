-- Check if jobs have company_logo_url populated
SELECT 
  company_name,
  company_logo_url,
  source_api,
  source_platform,
  created_at
FROM job_listings
ORDER BY created_at DESC
LIMIT 10;
