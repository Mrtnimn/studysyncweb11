-- PROFILES TABLE (Core user profiles with role-based access)
CREATE TABLE profiles (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE UNIQUE NOT NULL,
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
CREATE TABLE study_sessions (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES profiles(user_id) ON DELETE CASCADE NOT NULL,
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
CREATE TABLE achievements (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
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
CREATE TABLE user_achievements (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES profiles(user_id) ON DELETE CASCADE NOT NULL,
  achievement_id UUID REFERENCES achievements(id) ON DELETE CASCADE NOT NULL,
  unlocked_at TIMESTAMPTZ DEFAULT NOW(),
  is_featured BOOLEAN DEFAULT FALSE,
  UNIQUE(user_id, achievement_id)
);

-- STUDY ROOMS TABLE (For group study sessions)
CREATE TABLE study_rooms (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  subject TEXT NOT NULL,
  description TEXT,
  host_user_id UUID REFERENCES profiles(user_id) ON DELETE CASCADE NOT NULL,
  max_participants INTEGER DEFAULT 8,
  current_participants INTEGER DEFAULT 0,
  is_active BOOLEAN DEFAULT TRUE,
  level_requirement TEXT DEFAULT 'Beginner',
  daily_room_name TEXT UNIQUE, -- Daily.co room name
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ROOM PARTICIPANTS TABLE
CREATE TABLE room_participants (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  room_id UUID REFERENCES study_rooms(id) ON DELETE CASCADE NOT NULL,
  user_id UUID REFERENCES profiles(user_id) ON DELETE CASCADE NOT NULL,
  joined_at TIMESTAMPTZ DEFAULT NOW(),
  left_at TIMESTAMPTZ,
  is_active BOOLEAN DEFAULT TRUE,
  UNIQUE(room_id, user_id)
);

-- TUTOR PROFILES TABLE
CREATE TABLE tutor_profiles (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES profiles(user_id) ON DELETE CASCADE UNIQUE NOT NULL,
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
CREATE TABLE tutor_bookings (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  student_id UUID REFERENCES profiles(user_id) ON DELETE CASCADE NOT NULL,
  tutor_id UUID REFERENCES tutor_profiles(user_id) ON DELETE CASCADE NOT NULL,
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
CREATE TABLE tutor_reviews (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  booking_id UUID REFERENCES tutor_bookings(id) ON DELETE CASCADE UNIQUE NOT NULL,
  student_id UUID REFERENCES profiles(user_id) ON DELETE CASCADE NOT NULL,
  tutor_id UUID REFERENCES tutor_profiles(user_id) ON DELETE CASCADE NOT NULL,
  rating INTEGER CHECK (rating >= 1 AND rating <= 5) NOT NULL,
  review_text TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- MESSAGES TABLE (For real-time chat)
CREATE TABLE messages (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  room_id UUID REFERENCES study_rooms(id) ON DELETE CASCADE,
  booking_id UUID REFERENCES tutor_bookings(id) ON DELETE CASCADE,
  sender_id UUID REFERENCES profiles(user_id) ON DELETE CASCADE NOT NULL,
  content TEXT NOT NULL,
  message_type TEXT CHECK (message_type IN ('text', 'file', 'system')) DEFAULT 'text',
  file_url TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  CONSTRAINT message_context_check CHECK (
    (room_id IS NOT NULL AND booking_id IS NULL) OR
    (room_id IS NULL AND booking_id IS NOT NULL)
  )
);

-- Recommended indexes for performance
CREATE INDEX idx_profiles_user_id ON profiles(user_id);
CREATE INDEX idx_study_sessions_user_id ON study_sessions(user_id);
CREATE INDEX idx_user_achievements_user_id ON user_achievements(user_id);
CREATE INDEX idx_study_rooms_host_user_id ON study_rooms(host_user_id);
CREATE INDEX idx_room_participants_room_id ON room_participants(room_id);
CREATE INDEX idx_tutor_profiles_user_id ON tutor_profiles(user_id);
CREATE INDEX idx_tutor_bookings_student_id ON tutor_bookings(student_id);
CREATE INDEX idx_tutor_bookings_tutor_id ON tutor_bookings(tutor_id);
CREATE INDEX idx_tutor_reviews_booking_id ON tutor_reviews(booking_id);
CREATE INDEX idx_messages_room_id ON messages(room_id);
CREATE INDEX idx_messages_booking_id ON messages(booking_id);

-- Idempotent seed inserts for achievements
INSERT INTO achievements (name, description, icon, xp_reward, badge_color, category, unlock_criteria)
VALUES
('First Steps', 'Complete your first study session', 'target', 50, 'blue', 'milestone', '{"type": "sessions_completed", "target": 1}')
ON CONFLICT (name) DO NOTHING;

INSERT INTO achievements (name, description, icon, xp_reward, badge_color, category, unlock_criteria)
VALUES
('Week Warrior', 'Study for 7 days in a row', 'flame', 200, 'orange', 'streak', '{"type": "study_streak", "target": 7}')
ON CONFLICT (name) DO NOTHING;

INSERT INTO achievements (name, description, icon, xp_reward, badge_color, category, unlock_criteria)
VALUES
('Early Bird', 'Start a study session before 7 AM', 'sunrise', 100, 'yellow', 'focus', '{"type": "early_study", "target": 1}')
ON CONFLICT (name) DO NOTHING;

INSERT INTO achievements (name, description, icon, xp_reward, badge_color, category, unlock_criteria)
VALUES
('XP Master', 'Earn 1000 total XP points', 'star', 300, 'purple', 'xp', '{"type": "total_xp", "target": 1000}')
ON CONFLICT (name) DO NOTHING;

INSERT INTO achievements (name, description, icon, xp_reward, badge_color, category, unlock_criteria)
VALUES
('Study Marathon', 'Study for 2 hours in a single session', 'clock', 150, 'green', 'focus', '{"type": "session_duration", "target": 120}')
ON CONFLICT (name) DO NOTHING;

INSERT INTO achievements (name, description, icon, xp_reward, badge_color, category, unlock_criteria)
VALUES
('Social Learner', 'Join 5 different study rooms', 'users', 120, 'blue', 'social', '{"type": "rooms_joined", "target": 5}')
ON CONFLICT (name) DO NOTHING;

INSERT INTO achievements (name, description, icon, xp_reward, badge_color, category, unlock_criteria)
VALUES
('Helping Hand', 'Help 10 students as a tutor', 'heart', 250, 'red', 'social', '{"type": "students_helped", "target": 10}')
ON CONFLICT (name) DO NOTHING;

/*
IN CASE THE ABOVE CODE FAILS AT FIRST, FALLBACK TO THIS:

-- PROFILES TABLE (Core user profiles with role-based access)
CREATE TABLE profiles (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE UNIQUE NOT NULL,
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
CREATE TABLE study_sessions (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES profiles(user_id) ON DELETE CASCADE NOT NULL,
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
CREATE TABLE achievements (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
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
CREATE TABLE user_achievements (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES profiles(user_id) ON DELETE CASCADE NOT NULL,
  achievement_id UUID REFERENCES achievements(id) ON DELETE CASCADE NOT NULL,
  unlocked_at TIMESTAMPTZ DEFAULT NOW(),
  is_featured BOOLEAN DEFAULT FALSE,
  UNIQUE(user_id, achievement_id)
);

-- STUDY ROOMS TABLE (For group study sessions)
CREATE TABLE study_rooms (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  subject TEXT NOT NULL,
  description TEXT,
  host_user_id UUID REFERENCES profiles(user_id) ON DELETE CASCADE NOT NULL,
  max_participants INTEGER DEFAULT 8,
  current_participants INTEGER DEFAULT 0,
  is_active BOOLEAN DEFAULT TRUE,
  level_requirement TEXT DEFAULT 'Beginner',
  daily_room_name TEXT UNIQUE, -- Daily.co room name
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ROOM PARTICIPANTS TABLE
CREATE TABLE room_participants (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  room_id UUID REFERENCES study_rooms(id) ON DELETE CASCADE NOT NULL,
  user_id UUID REFERENCES profiles(user_id) ON DELETE CASCADE NOT NULL,
  joined_at TIMESTAMPTZ DEFAULT NOW(),
  left_at TIMESTAMPTZ,
  is_active BOOLEAN DEFAULT TRUE,
  UNIQUE(room_id, user_id)
);

-- TUTOR PROFILES TABLE
CREATE TABLE tutor_profiles (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES profiles(user_id) ON DELETE CASCADE UNIQUE NOT NULL,
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
CREATE TABLE tutor_bookings (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  student_id UUID REFERENCES profiles(user_id) ON DELETE CASCADE NOT NULL,
  tutor_id UUID REFERENCES tutor_profiles(user_id) ON DELETE CASCADE NOT NULL,
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
CREATE TABLE tutor_reviews (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  booking_id UUID REFERENCES tutor_bookings(id) ON DELETE CASCADE UNIQUE NOT NULL,
  student_id UUID REFERENCES profiles(user_id) ON DELETE CASCADE NOT NULL,
  tutor_id UUID REFERENCES tutor_profiles(user_id) ON DELETE CASCADE NOT NULL,
  rating INTEGER CHECK (rating >= 1 AND rating <= 5) NOT NULL,
  review_text TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- MESSAGES TABLE (For real-time chat)
CREATE TABLE messages (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  room_id UUID REFERENCES study_rooms(id) ON DELETE CASCADE,
  booking_id UUID REFERENCES tutor_bookings(id) ON DELETE CASCADE,
  sender_id UUID REFERENCES profiles(user_id) ON DELETE CASCADE NOT NULL,
  content TEXT NOT NULL,
  message_type TEXT CHECK (message_type IN ('text', 'file', 'system')) DEFAULT 'text',
  file_url TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  CONSTRAINT message_context_check CHECK (
    (room_id IS NOT NULL AND booking_id IS NULL) OR
    (room_id IS NULL AND booking_id IS NOT NULL)
  )
);

-- Recommended indexes for performance
CREATE INDEX idx_profiles_user_id ON profiles(user_id);
CREATE INDEX idx_study_sessions_user_id ON study_sessions(user_id);
CREATE INDEX idx_user_achievements_user_id ON user_achievements(user_id);
CREATE INDEX idx_study_rooms_host_user_id ON study_rooms(host_user_id);
CREATE INDEX idx_room_participants_room_id ON room_participants(room_id);
CREATE INDEX idx_tutor_profiles_user_id ON tutor_profiles(user_id);
CREATE INDEX idx_tutor_bookings_student_id ON tutor_bookings(student_id);
CREATE INDEX idx_tutor_bookings_tutor_id ON tutor_bookings(tutor_id);
CREATE INDEX idx_tutor_reviews_booking_id ON tutor_reviews(booking_id);
CREATE INDEX idx_messages_room_id ON messages(room_id);
CREATE INDEX idx_messages_booking_id ON messages(booking_id);

-- Idempotent seed inserts for achievements
INSERT INTO achievements (name, description, icon, xp_reward, badge_color, category, unlock_criteria)
VALUES
('First Steps', 'Complete your first study session', 'target', 50, 'blue', 'milestone', '{"type": "sessions_completed", "target": 1}')
;

INSERT INTO achievements (name, description, icon, xp_reward, badge_color, category, unlock_criteria)
VALUES
('Week Warrior', 'Study for 7 days in a row', 'flame', 200, 'orange', 'streak', '{"type": "study_streak", "target": 7}')
;

INSERT INTO achievements (name, description, icon, xp_reward, badge_color, category, unlock_criteria)
VALUES
('Early Bird', 'Start a study session before 7 AM', 'sunrise', 100, 'yellow', 'focus', '{"type": "early_study", "target": 1}')
;

INSERT INTO achievements (name, description, icon, xp_reward, badge_color, category, unlock_criteria)
VALUES
('XP Master', 'Earn 1000 total XP points', 'star', 300, 'purple', 'xp', '{"type": "total_xp", "target": 1000}')
;

INSERT INTO achievements (name, description, icon, xp_reward, badge_color, category, unlock_criteria)
VALUES
('Study Marathon', 'Study for 2 hours in a single session', 'clock', 150, 'green', 'focus', '{"type": "session_duration", "target": 120}')
;

INSERT INTO achievements (name, description, icon, xp_reward, badge_color, category, unlock_criteria)
VALUES
('Social Learner', 'Join 5 different study rooms', 'users', 120, 'blue', 'social', '{"type": "rooms_joined", "target": 5}')
;

INSERT INTO achievements (name, description, icon, xp_reward, badge_color, category, unlock_criteria)
VALUES
('Helping Hand', 'Help 10 students as a tutor', 'heart', 250, 'red', 'social', '{"type": "students_helped", "target": 10}')
;
*/