# Database Setup Instructions

## Quick Setup (Required for App to Function)

Your StudySync app is now running with Supabase credentials, but you need to set up the database schema.

### Step 1: Access Supabase SQL Editor
1. Go to your Supabase dashboard: https://supabase.com/dashboard
2. Select your project
3. Click on "SQL Editor" in the left sidebar

### Step 2: Run the Database Schema
1. Copy the entire contents of `lib/supabase/database.sql`
2. Paste it into the SQL Editor
3. Click "Run" to execute

This will create all necessary tables with proper Row Level Security (RLS) policies.

### What Gets Created:
- ✅ **profiles** - User profiles with XP, levels, and streaks
- ✅ **study_sessions** - Track study history and progress
- ✅ **achievements** - Gamification badges and rewards
- ✅ **study_rooms** - Group study spaces
- ✅ **tutor_profiles** - Teacher marketplace profiles
- ✅ **tutor_bookings** - Session booking system
- ✅ **messages** - Real-time chat
- ✅ **RLS Policies** - Secure data access rules

### Step 3: Verify Setup
After running the schema, try:
1. Register a new account at `/auth/register`
2. Choose "Student" or "Teacher" role
3. Access your dashboard

## Troubleshooting

### Issue: "relation does not exist"
**Solution**: Run the database.sql script in Supabase SQL Editor

### Issue: "permission denied"
**Solution**: Check that RLS policies were created correctly

### Issue: Profile not created after registration
**Solution**: Check Supabase logs for any constraint violations

## Optional: Seed Data
To add sample achievements and study rooms, you can run the seed sections from `database.sql`.

## Security Notes
- All tables have Row Level Security (RLS) enabled
- Users can only access their own data
- Authentication is handled through Supabase Auth
- Passwords are hashed and never stored in plain text
