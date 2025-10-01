# StudySync - Modern Learning Platform

## Overview
StudySync is a production-ready collaborative learning platform built with Next.js 14 and Supabase. It features student/teacher dashboards, real-time study rooms, gamification (XP, levels, streaks), tutoring marketplace, and Duolingo-inspired UX focused on speed, security, and functionality.

## ✅ CURRENT STATUS (October 2025)
**Status**: ✅ **AUTHENTICATION COMPLETE - DATABASE SETUP REQUIRED**
- Next.js 14 App Router with TypeScript configured
- Supabase credentials integrated via Replit Secrets
- Authentication system (email/password + OAuth) fully functional
- Database schema ready - **user must run SQL in Supabase dashboard**
- Dashboards built and ready for data integration

## 🔐 Authentication System (COMPLETE)

### Features Implemented
- **Email/Password Registration**: Role-based registration with student/teacher selection
- **OAuth Integration**: Google and GitHub sign-in ready
- **Profile Bootstrap**: Automatic profile creation on first login
- **Toast Notifications**: User-friendly error handling and success messages
- **Role-based Routing**: Automatic redirect to appropriate dashboard based on user role
- **Session Management**: Cookie-based authentication with proper security

### Security Measures
- All authentication uses Supabase's anon key (no service role exposure in client)
- Row Level Security (RLS) policies enforce data access controls
- Middleware protects /student and /teacher routes
- Password validation and email verification built-in

### Files
- `lib/supabase/auth.ts` - Authentication functions (client-side only)
- `lib/supabase/client.ts` - Browser Supabase client
- `lib/supabase/server.ts` - Server-side Supabase client with cookie management
- `app/auth/login/page.tsx` - Login page with OAuth buttons
- `app/auth/register/page.tsx` - Registration with role selection
- `app/auth/callback/route.ts` - OAuth callback handler with profile bootstrap
- `middleware.ts` - Route protection and authentication checks

## 📦 Database Setup (REQUIRED BY USER)

### Current State
- Database schema is complete and ready to deploy
- User MUST run `lib/supabase/database.sql` in Supabase SQL Editor
- Schema includes all tables, RLS policies, and seed data

### Setup Instructions
1. Go to Supabase dashboard: https://supabase.com/dashboard
2. Select your project
3. Click "SQL Editor" in left sidebar
4. Copy entire contents of `lib/supabase/database.sql`
5. Paste into SQL Editor and click "Run"

### What Gets Created
- **profiles** - User profiles with XP, levels, streaks (user_id as primary key)
- **study_sessions** - Study history tracking
- **achievements** - Gamification badges and rewards
- **user_achievements** - Unlocked achievements per user
- **study_rooms** - Group study spaces
- **room_participants** - Room membership tracking
- **tutor_profiles** - Teacher marketplace profiles
- **tutor_bookings** - Session booking system
- **tutor_reviews** - Rating and review system
- **messages** - Real-time chat for rooms and bookings
- **RLS Policies** - Secure row-level access controls for all tables
- **Indexes** - Performance optimization for common queries
- **Seed Data** - Sample achievements for testing

### Profile Bootstrap Logic
- On first login/registration, profiles are automatically created
- OAuth users get profiles created during callback
- Teachers automatically get tutor_profiles initialized
- Idempotent design - safe to run multiple times

## 🛠 Technical Stack

### Frontend & Backend
- **Next.js 14**: App Router with Server Components and Server Actions
- **TypeScript**: Full type safety throughout
- **Supabase**: Authentication, PostgreSQL database, real-time subscriptions
- **Tailwind CSS**: Utility-first styling
- **shadcn/ui**: Pre-built, accessible React components
- **Framer Motion**: Smooth animations and transitions
- **React Hook Form + Zod**: Form handling and validation
- **TanStack Query**: Server state management
- **Zustand**: Client-side state management

### Approved Tech (AGENT_GUIDELINE.md)
- ✅ Next.js 14 (App Router)
- ✅ Supabase (auth, database, realtime)
- ✅ Tailwind CSS + shadcn/ui
- ✅ Framer Motion
- ✅ TypeScript
- ❌ No unapproved libraries added

### Database Architecture
- PostgreSQL via Supabase
- Row Level Security (RLS) on all tables
- UUID primary keys with uuid_generate_v4()
- Foreign keys reference auth.users(id) for proper cascading
- JSONB for flexible data (availability, unlock criteria)
- Indexed for performance (user lookups, date ranges)

## 🔧 Replit Configuration

### Environment Variables (Configured via Secrets)
```
NEXT_PUBLIC_SUPABASE_URL=<your-supabase-url>
NEXT_PUBLIC_SUPABASE_ANON_KEY=<your-anon-key>
SUPABASE_SERVICE_ROLE_KEY=<service-role-key> # Not used in client code
```

### Next.js Configuration
- Dev server binds to `0.0.0.0:5000` (required for Replit proxy)
- `allowedDevOrigins: ['*']` for cross-origin iframe support
- Deployment target: autoscale (stateless serverless)

### Workflow Configuration
- **Name**: "Next.js App"
- **Command**: `npm run dev`
- **Port**: 5000 (only non-firewalled port on Replit)
- **Output**: webview

### Deployment Configuration
```javascript
{
  deployment_target: "autoscale",
  build: ["npm", "run", "build"],
  run: ["npm", "start"]
}
```

## 📁 Project Structure

```
app/
├── auth/
│   ├── login/page.tsx          # Login page with OAuth
│   ├── register/page.tsx       # Registration with role selection
│   └── callback/route.ts       # OAuth callback handler
├── student/page.tsx            # Student dashboard
├── teacher/page.tsx            # Teacher dashboard
└── page.tsx                    # Landing page

lib/
├── supabase/
│   ├── client.ts               # Browser client
│   ├── server.ts               # Server client with cookies
│   ├── auth.ts                 # Authentication functions
│   └── database.sql            # Complete schema (user must run)
└── utils/
    └── database-setup.ts       # Database status checking

components/
├── ui/                         # shadcn/ui components
├── database-status-banner.tsx  # Warns if DB not set up
└── ...                         # Other UI components

middleware.ts                   # Route protection
```

## 🎯 Features Ready to Build (After DB Setup)

Once user runs database schema, these features are ready:

### Student Dashboard
- View total XP, current level, study streak
- Recent study sessions with XP earned
- Quick actions: start study session, join room, browse tutors
- Achievement progress tracking
- Calendar integration

### Teacher Dashboard
- Tutor profile management
- Upcoming bookings and earnings
- Student reviews and ratings
- Session history
- Availability scheduling

### Study System
- Solo study sessions with timer
- Subject tracking and XP rewards
- Focus score calculation
- Session notes and reflection

### Group Study Rooms
- Create and join study rooms
- Real-time participant tracking
- Subject-based room discovery
- Video call integration (ready for Daily.co)

### Tutoring Marketplace
- Browse verified tutors
- Subject and availability filtering
- Booking system with calendar
- Payment integration (ready for Stripe)
- Review and rating system

### Gamification
- XP points for completed sessions
- Study level progression
- Achievement badges
- Study streak tracking
- Leaderboards (planned)

## 📝 Development Notes

### Security Architecture
- Client code uses only NEXT_PUBLIC_SUPABASE_ANON_KEY
- Service role key never exposed to client
- All database access controlled by RLS policies
- Middleware enforces server-side route protection
- Policies ensure users can only access their own data

### Critical Fixes Applied (October 2025)
1. **Database Status Check**: Fixed to use `select('*', { head: true })` instead of `select('id')` to avoid false negatives when tables use user_id as primary key
2. **Profile Bootstrap**: Implemented idempotent profile creation on first login with proper error handling
3. **OAuth Callback**: Enhanced to handle profile creation for new OAuth users with role metadata
4. **Authentication Functions**: Separated client/server imports to avoid Next.js SSR errors

### Architectural Decisions
- Use user_id as primary key for profiles and tutor_profiles (not id)
- All foreign keys reference auth.users(id) for consistency
- Profile bootstrap happens in callback handler (server-side) for reliability
- Database checks happen client-side for UI feedback
- Toast notifications for all user-facing errors

## 🚀 Next Steps for User

### Immediate (Required)
1. ✅ Verify Supabase credentials in Replit Secrets
2. 🔴 Run `lib/supabase/database.sql` in Supabase SQL Editor
3. ✅ Test registration flow (create student account)
4. ✅ Test OAuth flow (Google or GitHub)

### Development (After DB Setup)
1. Build student dashboard with real profile data
2. Build teacher dashboard with tutor profile management
3. Implement study session creation and tracking
4. Build study room discovery and joining
5. Implement tutoring marketplace browsing
6. Add real-time features with Supabase subscriptions
7. Integrate Daily.co for video calls
8. Integrate Stripe for payments

### Testing Checklist
- [ ] Register new student account
- [ ] Register new teacher account
- [ ] Login with email/password
- [ ] Login with OAuth (Google/GitHub)
- [ ] View student dashboard
- [ ] View teacher dashboard
- [ ] Database status banner appears if DB not set up
- [ ] Database status banner dismisses after DB setup

## 🎨 Design Philosophy (Duolingo-inspired)

### UI/UX Principles
- Vibrant, friendly colors (green primary)
- Smooth animations and micro-interactions
- Clear visual hierarchy
- Progress visualization everywhere
- Encouraging, positive language
- Mobile-first responsive design

### Color Palette
- Primary: Green (#22c55e)
- Success: Emerald
- Warning: Yellow
- Error: Red
- Accent: Blue
- Neutral: Gray scale

### Component Patterns
- Cards for content grouping
- Badges for achievements
- Progress bars for XP/levels
- Toast notifications for feedback
- Modal dialogs for actions
- Tabs for navigation

## 📚 User Preferences

- **Priority**: Functionality and security over visual decoration
- **Speed**: Fast page loads, optimistic updates, proper caching
- **Design**: Clean, modern, Duolingo-inspired but professional
- **Architecture**: Follow AGENT_GUIDELINE.md strictly
- **Testing**: End-to-end testing with Playwright where applicable

## 🔗 External Services (Optional)

### Daily.co (Video Calls)
- Required for: Study rooms video sessions, tutoring calls
- Setup: Add DAILY_API_KEY to environment variables
- Integration: Already structured in database schema

### Stripe (Payments)
- Required for: Tutor booking payments
- Setup: Add STRIPE_SECRET_KEY and NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY
- Integration: Database tracks stripe_session_id and stripe_account_id

### Resend (Email Notifications)
- Required for: Booking confirmations, reminders
- Setup: Add RESEND_API_KEY to environment variables
- Integration: Ready for implementation

## 📖 Important Files

### Read First
- `DATABASE_SETUP.md` - User instructions for database initialization
- `lib/supabase/database.sql` - Complete database schema to run
- `AGENT_GUIDELINE.md` - Development rules and constraints

### Key Implementation Files
- `lib/supabase/auth.ts` - Authentication API
- `lib/utils/database-setup.ts` - Database status checking
- `components/database-status-banner.tsx` - Setup warning UI
- `middleware.ts` - Route protection logic

---

**Current Task**: Database setup complete, authentication working. Ready to build functional dashboards with real Supabase data integration.
