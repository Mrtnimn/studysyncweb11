-- StudySync Database Schema for Supabase
-- This file contains the complete database schema with Row Level Security (RLS)

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- PROFILES TABLE (Core user profiles with role-based access)
CREATE TABLE IF NOT EXISTS profiles (
  user_id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  role TEXT CHECK (role IN ('student', 'teacher')) NOT NULL,
  display_name TEXT,
  bio TEXT,
  avatar_url TEXT,
  study_level INTEGER DEFAULT 1,
  total_xp INTEGER DEFAULT 0,
  study_streak INTEGER DEFAULT 0,
  longest_streak INTEGER DEFAULT 0,
  last_study_date TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- STUDY SESSIONS TABLE
CREATE TABLE IF NOT EXISTS study_sessions (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  subject TEXT NOT NULL,
  duration_minutes INTEGER NOT NULL,
  xp_earned INTEGER DEFAULT 0,
  session_type TEXT CHECK (session_type IN ('solo', 'group', 'tutoring')) NOT NULL,
  focus_score INTEGER CHECK (focus_score >= 0 AND focus_score <= 100),
  notes TEXT,
  completed_at TIMESTAMPTZ DEFAULT NOW(),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ACHIEVEMENTS TABLE
CREATE TABLE IF NOT EXISTS achievements (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT NOT NULL,
  icon TEXT NOT NULL,
  xp_reward INTEGER DEFAULT 0,
  badge_color TEXT DEFAULT 'blue',
  category TEXT CHECK (category IN ('streak', 'xp', 'social', 'focus', 'milestone')) NOT NULL,
  unlock_criteria JSONB NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- USER ACHIEVEMENTS TABLE
CREATE TABLE IF NOT EXISTS user_achievements (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  achievement_id UUID REFERENCES achievements(id) ON DELETE CASCADE NOT NULL,
  unlocked_at TIMESTAMPTZ DEFAULT NOW(),
  is_featured BOOLEAN DEFAULT FALSE,
  UNIQUE(user_id, achievement_id)
);

-- STUDY ROOMS TABLE (For group study sessions)
CREATE TABLE IF NOT EXISTS study_rooms (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  name TEXT NOT NULL,
  subject TEXT NOT NULL,
  description TEXT,
  host_user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  max_participants INTEGER DEFAULT 8,
  current_participants INTEGER DEFAULT 0,
  is_active BOOLEAN DEFAULT TRUE,
  level_requirement TEXT DEFAULT 'Beginner',
  daily_room_name TEXT UNIQUE, -- Daily.co room name
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ROOM PARTICIPANTS TABLE
CREATE TABLE IF NOT EXISTS room_participants (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  room_id UUID REFERENCES study_rooms(id) ON DELETE CASCADE NOT NULL,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  joined_at TIMESTAMPTZ DEFAULT NOW(),
  left_at TIMESTAMPTZ,
  is_active BOOLEAN DEFAULT TRUE,
  UNIQUE(room_id, user_id)
);

-- TUTOR PROFILES TABLE
CREATE TABLE IF NOT EXISTS tutor_profiles (
  user_id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  bio TEXT NOT NULL,
  hourly_rate INTEGER NOT NULL, -- in cents
  subjects TEXT[] NOT NULL,
  languages TEXT[] DEFAULT '{}',
  education TEXT,
  experience_years INTEGER DEFAULT 0,
  availability JSONB NOT NULL,
  timezone TEXT DEFAULT 'UTC',
  is_verified BOOLEAN DEFAULT FALSE,
  is_active BOOLEAN DEFAULT TRUE,
  total_sessions INTEGER DEFAULT 0,
  average_rating DECIMAL(3,2) DEFAULT 0.00, -- 0.00 to 5.00
  total_reviews INTEGER DEFAULT 0,
  response_time_hours INTEGER DEFAULT 24,
  stripe_account_id TEXT, -- For Stripe Connect
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- TUTOR BOOKINGS TABLE
CREATE TABLE IF NOT EXISTS tutor_bookings (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  student_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  tutor_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  subject TEXT NOT NULL,
  session_date TIMESTAMPTZ NOT NULL,
  duration_minutes INTEGER NOT NULL,
  hourly_rate INTEGER NOT NULL, -- rate at time of booking
  total_cost INTEGER NOT NULL, -- in cents
  status TEXT CHECK (status IN ('pending', 'confirmed', 'completed', 'cancelled')) DEFAULT 'pending',
  session_notes TEXT,
  daily_room_name TEXT, -- Daily.co room name
  stripe_session_id TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- TUTOR REVIEWS TABLE
CREATE TABLE IF NOT EXISTS tutor_reviews (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  booking_id UUID REFERENCES tutor_bookings(id) ON DELETE CASCADE UNIQUE NOT NULL,
  student_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  tutor_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  rating INTEGER CHECK (rating >= 1 AND rating <= 5) NOT NULL,
  review_text TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- MESSAGES TABLE (For real-time chat)
CREATE TABLE IF NOT EXISTS messages (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  room_id UUID REFERENCES study_rooms(id) ON DELETE CASCADE,
  booking_id UUID REFERENCES tutor_bookings(id) ON DELETE CASCADE,
  sender_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  content TEXT NOT NULL,
  message_type TEXT CHECK (message_type IN ('text', 'file', 'system')) DEFAULT 'text',
  file_url TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  CONSTRAINT message_context_check CHECK (
    (room_id IS NOT NULL AND booking_id IS NULL) OR
    (room_id IS NULL AND booking_id IS NOT NULL)
  )
);

-- ROW LEVEL SECURITY (RLS) POLICIES
-- Enable RLS on all tables
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE study_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE achievements ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_achievements ENABLE ROW LEVEL SECURITY;
ALTER TABLE study_rooms ENABLE ROW LEVEL SECURITY;
ALTER TABLE room_participants ENABLE ROW LEVEL SECURITY;
ALTER TABLE tutor_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE tutor_bookings ENABLE ROW LEVEL SECURITY;
ALTER TABLE tutor_reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;

-- PROFILES POLICIES
CREATE POLICY "Users can view own profile" ON profiles
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can update own profile" ON profiles
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own profile" ON profiles
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- STUDY SESSIONS POLICIES
CREATE POLICY "Users can view own sessions" ON study_sessions
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own sessions" ON study_sessions
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- ACHIEVEMENTS POLICIES (Public read, admin write)
CREATE POLICY "Everyone can view achievements" ON achievements
  FOR SELECT TO authenticated USING (true);

-- USER ACHIEVEMENTS POLICIES
CREATE POLICY "Users can view own achievements" ON user_achievements
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can unlock own achievements" ON user_achievements
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- STUDY ROOMS POLICIES
CREATE POLICY "Authenticated users can view active rooms" ON study_rooms
  FOR SELECT TO authenticated USING (is_active = true);

CREATE POLICY "Users can create rooms" ON study_rooms
  FOR INSERT WITH CHECK (auth.uid() = host_user_id);

CREATE POLICY "Room hosts can update their rooms" ON study_rooms
  FOR UPDATE USING (auth.uid() = host_user_id);

-- ROOM PARTICIPANTS POLICIES
CREATE POLICY "Participants can view room membership" ON room_participants
  FOR SELECT USING (
    auth.uid() = user_id OR 
    EXISTS (
      SELECT 1 FROM study_rooms 
      WHERE study_rooms.id = room_participants.room_id 
      AND study_rooms.host_user_id = auth.uid()
    )
  );

CREATE POLICY "Users can join rooms" ON room_participants
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- TUTOR PROFILES POLICIES
CREATE POLICY "Everyone can view active tutor profiles" ON tutor_profiles
  FOR SELECT TO authenticated USING (is_active = true);

CREATE POLICY "Tutors can update own profile" ON tutor_profiles
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can create tutor profile" ON tutor_profiles
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- TUTOR BOOKINGS POLICIES
CREATE POLICY "Users can view their bookings" ON tutor_bookings
  FOR SELECT USING (
    auth.uid() = student_id OR 
    auth.uid() = tutor_id
  );

CREATE POLICY "Students can create bookings" ON tutor_bookings
  FOR INSERT WITH CHECK (auth.uid() = student_id);

CREATE POLICY "Participants can update bookings" ON tutor_bookings
  FOR UPDATE USING (
    auth.uid() = student_id OR 
    auth.uid() = tutor_id
  );

-- MESSAGES POLICIES
CREATE POLICY "Participants can view room messages" ON messages
  FOR SELECT USING (
    (room_id IS NOT NULL AND EXISTS (
      SELECT 1 FROM room_participants 
      WHERE room_participants.room_id = messages.room_id 
      AND room_participants.user_id = auth.uid()
      AND room_participants.is_active = true
    )) OR
    (booking_id IS NOT NULL AND EXISTS (
      SELECT 1 FROM tutor_bookings 
      WHERE tutor_bookings.id = messages.booking_id 
      AND (tutor_bookings.student_id = auth.uid() OR tutor_bookings.tutor_id = auth.uid())
    ))
  );

CREATE POLICY "Participants can send messages" ON messages
  FOR INSERT WITH CHECK (
    auth.uid() = sender_id AND (
      (room_id IS NOT NULL AND EXISTS (
        SELECT 1 FROM room_participants 
        WHERE room_participants.room_id = messages.room_id 
        AND room_participants.user_id = auth.uid()
        AND room_participants.is_active = true
      )) OR
      (booking_id IS NOT NULL AND EXISTS (
        SELECT 1 FROM tutor_bookings 
        WHERE tutor_bookings.id = messages.booking_id 
        AND (tutor_bookings.student_id = auth.uid() OR tutor_bookings.tutor_id = auth.uid())
      ))
    )
  );

-- FUNCTIONS AND TRIGGERS
-- Update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_profiles_updated_at BEFORE UPDATE ON profiles FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();
CREATE TRIGGER update_tutor_profiles_updated_at BEFORE UPDATE ON tutor_profiles FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();
CREATE TRIGGER update_tutor_bookings_updated_at BEFORE UPDATE ON tutor_bookings FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();

-- Insert initial achievements
INSERT INTO achievements (name, description, icon, xp_reward, badge_color, category, unlock_criteria) VALUES
('First Steps', 'Complete your first study session', 'target', 50, 'blue', 'milestone', '{"type": "sessions_completed", "target": 1}'),
('Week Warrior', 'Study for 7 days in a row', 'flame', 200, 'orange', 'streak', '{"type": "study_streak", "target": 7}'),
('Early Bird', 'Start a study session before 7 AM', 'sunrise', 100, 'yellow', 'focus', '{"type": "early_study", "target": 1}'),
('XP Master', 'Earn 1000 total XP points', 'star', 300, 'purple', 'xp', '{"type": "total_xp", "target": 1000}'),
('Study Marathon', 'Study for 2 hours in a single session', 'clock', 150, 'green', 'focus', '{"type": "session_duration", "target": 120}'),
('Social Learner', 'Join 5 different study rooms', 'users', 120, 'blue', 'social', '{"type": "rooms_joined", "target": 5}'),
('Helping Hand', 'Help 10 students as a tutor', 'heart', 250, 'red', 'social', '{"type": "students_helped", "target": 10}');

-- In case it's needed, here are the migration files:
-- canonical migrations live in lib/supabase/db/migrations
-- If you prefer a single-file deploy, generate a combined SQL from the files in db/migrations.
-- Keep this file only as a reference to avoid confusion.