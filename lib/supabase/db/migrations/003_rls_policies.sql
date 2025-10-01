-- Enable Row Level Security (RLS) on all tables
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
DROP POLICY IF EXISTS profiles_select_own ON profiles;
CREATE POLICY profiles_select_own ON profiles
  FOR SELECT USING (auth.uid() = user_id OR EXISTS (SELECT 1 FROM admins WHERE user_id = auth.uid()));

DROP POLICY IF EXISTS profiles_update_own ON profiles;
CREATE POLICY profiles_update_own ON profiles
  FOR UPDATE USING (auth.uid() = user_id OR EXISTS (SELECT 1 FROM admins WHERE user_id = auth.uid()));

DROP POLICY IF EXISTS profiles_insert_own ON profiles;
CREATE POLICY profiles_insert_own ON profiles
  FOR INSERT WITH CHECK (auth.uid() = user_id OR EXISTS (SELECT 1 FROM admins WHERE user_id = auth.uid()));

-- STUDY SESSIONS POLICIES
DROP POLICY IF EXISTS study_sessions_select_own ON study_sessions;
CREATE POLICY study_sessions_select_own ON study_sessions
  FOR SELECT USING (auth.uid() = user_id OR EXISTS (SELECT 1 FROM admins WHERE user_id = auth.uid()));

DROP POLICY IF EXISTS study_sessions_insert_own ON study_sessions;
CREATE POLICY study_sessions_insert_own ON study_sessions
  FOR INSERT WITH CHECK (auth.uid() = user_id OR EXISTS (SELECT 1 FROM admins WHERE user_id = auth.uid()));

-- ACHIEVEMENTS POLICIES (Public read, admin write)
DROP POLICY IF EXISTS achievements_public_read ON achievements;
CREATE POLICY achievements_public_read ON achievements
  FOR SELECT TO authenticated USING (true);

-- Admins (controlled by admins table) may manage achievements
DROP POLICY IF EXISTS achievements_manage_admin ON achievements;
CREATE POLICY achievements_manage_admin ON achievements
  FOR ALL USING (EXISTS (SELECT 1 FROM admins WHERE user_id = auth.uid()));

-- USER ACHIEVEMENTS POLICIES
DROP POLICY IF EXISTS user_achievements_select_own ON user_achievements;
CREATE POLICY user_achievements_select_own ON user_achievements
  FOR SELECT USING (auth.uid() = user_id OR EXISTS (SELECT 1 FROM admins WHERE user_id = auth.uid()));

DROP POLICY IF EXISTS user_achievements_insert_own ON user_achievements;
CREATE POLICY user_achievements_insert_own ON user_achievements
  FOR INSERT WITH CHECK (auth.uid() = user_id OR EXISTS (SELECT 1 FROM admins WHERE user_id = auth.uid()));

-- STUDY ROOMS POLICIES
DROP POLICY IF EXISTS study_rooms_public_active ON study_rooms;
CREATE POLICY study_rooms_public_active ON study_rooms
  FOR SELECT TO authenticated USING (is_active = true OR EXISTS (SELECT 1 FROM admins WHERE user_id = auth.uid()));

DROP POLICY IF EXISTS study_rooms_insert_host ON study_rooms;
CREATE POLICY study_rooms_insert_host ON study_rooms
  FOR INSERT WITH CHECK (auth.uid() = host_user_id OR EXISTS (SELECT 1 FROM admins WHERE user_id = auth.uid()));

DROP POLICY IF EXISTS study_rooms_update_host ON study_rooms;
CREATE POLICY study_rooms_update_host ON study_rooms
  FOR UPDATE USING (auth.uid() = host_user_id OR EXISTS (SELECT 1 FROM admins WHERE user_id = auth.uid()));

-- ROOM PARTICIPANTS POLICIES
DROP POLICY IF EXISTS room_participants_select_participant ON room_participants;
CREATE POLICY room_participants_select_participant ON room_participants
  FOR SELECT USING (
    auth.uid() = user_id OR 
    EXISTS (
      SELECT 1 FROM study_rooms sr
      WHERE sr.id = room_participants.room_id AND sr.host_user_id = auth.uid()
    ) OR
    EXISTS (SELECT 1 FROM admins WHERE user_id = auth.uid())
  );

DROP POLICY IF EXISTS room_participants_insert_join ON room_participants;
CREATE POLICY room_participants_insert_join ON room_participants
  FOR INSERT WITH CHECK (auth.uid() = user_id OR EXISTS (SELECT 1 FROM admins WHERE user_id = auth.uid()));

-- TUTOR PROFILES POLICIES
DROP POLICY IF EXISTS tutor_profiles_public_active ON tutor_profiles;
CREATE POLICY tutor_profiles_public_active ON tutor_profiles
  FOR SELECT TO authenticated USING (is_active = true OR EXISTS (SELECT 1 FROM admins WHERE user_id = auth.uid()));

DROP POLICY IF EXISTS tutor_profiles_update_own ON tutor_profiles;
CREATE POLICY tutor_profiles_update_own ON tutor_profiles
  FOR UPDATE USING (auth.uid() = user_id OR EXISTS (SELECT 1 FROM admins WHERE user_id = auth.uid()));

DROP POLICY IF EXISTS tutor_profiles_insert_own ON tutor_profiles;
CREATE POLICY tutor_profiles_insert_own ON tutor_profiles
  FOR INSERT WITH CHECK (auth.uid() = user_id OR EXISTS (SELECT 1 FROM admins WHERE user_id = auth.uid()));

-- Admins may also manage tutor profiles via the admins table
DROP POLICY IF EXISTS tutor_profiles_manage_admin ON tutor_profiles;
CREATE POLICY tutor_profiles_manage_admin ON tutor_profiles
  FOR DELETE USING (EXISTS (SELECT 1 FROM admins WHERE user_id = auth.uid()));

-- TUTOR BOOKINGS POLICIES
DROP POLICY IF EXISTS tutor_bookings_select_participant ON tutor_bookings;
CREATE POLICY tutor_bookings_select_participant ON tutor_bookings
  FOR SELECT USING (
    auth.uid() = student_id OR 
    auth.uid() = tutor_id OR
    EXISTS (SELECT 1 FROM admins WHERE user_id = auth.uid())
  );

DROP POLICY IF EXISTS tutor_bookings_insert_student ON tutor_bookings;
CREATE POLICY tutor_bookings_insert_student ON tutor_bookings
  FOR INSERT WITH CHECK (auth.uid() = student_id OR EXISTS (SELECT 1 FROM admins WHERE user_id = auth.uid()));

DROP POLICY IF EXISTS tutor_bookings_update_participant ON tutor_bookings;
CREATE POLICY tutor_bookings_update_participant ON tutor_bookings
  FOR UPDATE USING (
    auth.uid() = student_id OR 
    auth.uid() = tutor_id OR
    EXISTS (SELECT 1 FROM admins WHERE user_id = auth.uid())
  );

-- MESSAGES POLICIES
DROP POLICY IF EXISTS messages_select_participant ON messages;
CREATE POLICY messages_select_participant ON messages
  FOR SELECT USING (
    (
      room_id IS NOT NULL AND EXISTS (
        SELECT 1 FROM room_participants rp
        WHERE rp.room_id = messages.room_id
          AND rp.user_id = auth.uid()
          AND rp.is_active = true
      )
    ) OR
    (
      booking_id IS NOT NULL AND EXISTS (
        SELECT 1 FROM tutor_bookings tb
        WHERE tb.id = messages.booking_id
          AND (tb.student_id = auth.uid() OR tb.tutor_id = auth.uid())
      )
    ) OR
    EXISTS (SELECT 1 FROM admins WHERE user_id = auth.uid())
  );

DROP POLICY IF EXISTS messages_insert_participant ON messages;
CREATE POLICY messages_insert_participant ON messages
  FOR INSERT WITH CHECK (
    auth.uid() = NEW.sender_id AND (
      (
        NEW.room_id IS NOT NULL AND EXISTS (
          SELECT 1 FROM room_participants rp
          WHERE rp.room_id = NEW.room_id
            AND rp.user_id = auth.uid()
            AND rp.is_active = true
        )
      ) OR
      (
        NEW.booking_id IS NOT NULL AND EXISTS (
          SELECT 1 FROM tutor_bookings tb
          WHERE tb.id = NEW.booking_id
            AND (tb.student_id = auth.uid() OR tb.tutor_id = auth.uid())
        )
      ) OR
      EXISTS (SELECT 1 FROM admins WHERE user_id = auth.uid())
    )
  );