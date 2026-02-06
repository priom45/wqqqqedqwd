-- Check what logo URLs look like
SELECT 
  company_name,
  company_logo_url,
  source_api,
  LENGTH(company_logo_url) as url_length,
  SUBSTRING(company_logo_url, 1, 50) as url_preview
FROM job_listings
WHERE company_logo_url IS NOT NULL
ORDER BY created_at DESC
LIMIT 10;
