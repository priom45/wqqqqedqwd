# ✅ Inactive Jobs - Show with "Expired" Button

## 🎯 Requirement

When an admin deactivates a job in the admin panel, instead of hiding it completely:
- **Keep showing the job** in the latest jobs list
- **Replace "Apply Now" button** with "Expired" button (disabled/grayed out)

---

## 🔧 Changes Made

### 1. Updated JobCard Component
**File:** [src/components/jobs/JobCard.tsx:247-280](src/components/jobs/JobCard.tsx#L247-L280)

**Before:**
```tsx
<button>Manual Apply</button>
```

**After:**
```tsx
{job.is_active ? (
  <>
    <button>Auto Apply</button>
    <button>Manual Apply</button>
  </>
) : (
  <button disabled className="bg-slate-700/50 text-slate-400 cursor-not-allowed">
    Expired
  </button>
)}
```

**Visual Result:**
- **Active Jobs**: Show "Auto Apply" + "Manual Apply" buttons
- **Inactive Jobs**: Show grayed out "Expired" button

---

### 2. Removed is_active Filter from Service
**File:** [src/services/jobsService.ts:275-277](src/services/jobsService.ts#L275-L277)

**Before:**
```typescript
let query = supabase
  .from('job_listings')
  .select('*', { count: 'exact' })
  .eq('is_active', true); // ❌ This filtered out inactive jobs
```

**After:**
```typescript
let query = supabase
  .from('job_listings')
  .select('*', { count: 'exact' });
// ✅ Now shows both active and inactive jobs
```

---

## 🎨 UI Design

### Active Job Card:
```
┌─────────────────────────────────────────┐
│ [Logo] Software Engineer                │
│        Groww                             │
│        SDE • Onsite • ₹8L CTC           │
│                                          │
│ [Auto Apply] [Manual Apply]             │ ← Both buttons active
└─────────────────────────────────────────┘
```

### Inactive/Expired Job Card:
```
┌─────────────────────────────────────────┐
│ [Logo] Software Engineer                │
│        Groww                             │
│        SDE • Onsite • ₹8L CTC           │
│                                          │
│           [Expired]                      │ ← Grayed out, disabled
└─────────────────────────────────────────┘
```

---

## 📋 Button Styles

### Expired Button Styling:
```tsx
className="
  px-4 py-2
  bg-slate-700/50        // Dark gray background
  text-slate-400         // Light gray text
  rounded-lg
  text-sm
  font-semibold
  cursor-not-allowed     // Shows "not allowed" cursor
  border
  border-slate-600/50    // Subtle border
  w-full sm:w-auto
"
```

---

## 🔍 How It Works

### Admin Workflow:
1. Admin goes to **Manage Jobs** page
2. Clicks **"Deactivate"** on a job
3. Job's `is_active` field set to `false` in database

### User Experience:
1. User visits **Jobs** page
2. Sees ALL jobs (active + inactive)
3. **Active jobs**: Can apply normally
4. **Inactive jobs**: See "Expired" button (can't click)

---

## ✅ Benefits

### For Users:
- **Transparency**: Users can see which jobs are no longer available
- **Context**: Helps understand market trends (what jobs were available)
- **No confusion**: Clear "Expired" label explains why they can't apply

### For Admins:
- **No data loss**: Jobs stay in system for analytics
- **Reversible**: Can reactivate jobs later if needed
- **Better tracking**: See history of all posted jobs

---

## 🧪 Testing

### Test Active Jobs:
1. Go to jobs page
2. Find an active job (green badge)
3. Should see: **"Auto Apply"** + **"Manual Apply"** buttons
4. Both buttons should be clickable

### Test Inactive Jobs:
1. Admin: Deactivate a job
2. Refresh jobs page
3. Find the deactivated job
4. Should see: **"Expired"** button (grayed out)
5. Button should NOT be clickable
6. Cursor should show "not allowed" icon

### Test Reactivation:
1. Admin: Reactivate a job
2. Refresh jobs page
3. Job should now show normal apply buttons again

---

## 🎯 Database Schema

The `job_listings` table has an `is_active` boolean field:
- `true` = Active job, show apply buttons
- `false` = Inactive job, show "Expired" button

**No database changes needed** - just using existing field differently.

---

## 🚀 Deployment Status

- ✅ JobCard component updated
- ✅ jobsService filter removed
- ✅ Ready to test
- ✅ No database migrations required

**Status: LIVE!**

---

## 📝 Future Enhancements (Optional)

### Could Add:
1. **Expired badge**: Add a red "Expired" badge next to job title
2. **Gray overlay**: Dim the entire card for expired jobs
3. **Tooltip**: "This job is no longer accepting applications"
4. **Archive section**: Separate tab for expired jobs
5. **Expiration date**: Show when job was deactivated
6. **Notification**: Email users who saved the job

### Example Enhanced Card:
```
┌─────────────────────────────────────────┐
│ [Logo] Software Engineer      [Expired] │ ← Badge
│        Groww                             │
│        SDE • Onsite • ₹8L CTC           │
│        Deactivated on Jan 5, 2026       │ ← Date
│                                          │
│           [Expired]                      │
└─────────────────────────────────────────┘
```

---

## ✅ Summary

**What changed:**
- Inactive jobs now visible in job listings
- "Apply Now" replaced with "Expired" for inactive jobs
- No more hiding of deactivated jobs

**Why it's better:**
- Users see full picture of job market
- Admins maintain full control
- Better transparency and trust
- No data loss

**Ready to use!** Deactivate any job in admin panel and users will see it with "Expired" button.
