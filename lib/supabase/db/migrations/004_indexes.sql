-- Create indexes for optimizing query performance

-- Index for profiles table on user_id for faster lookups
CREATE INDEX IF NOT EXISTS idx_profiles_user_id ON profiles(user_id);

-- Index for study_sessions table on user_id for faster lookups
CREATE INDEX IF NOT EXISTS idx_study_sessions_user_id ON study_sessions(user_id);

-- Index for achievements table on category for faster filtering
CREATE INDEX IF NOT EXISTS idx_achievements_category ON achievements(category);

-- Index for user_achievements table on user_id for faster lookups
CREATE INDEX IF NOT EXISTS idx_user_achievements_user_id ON user_achievements(user_id);

-- Index for study_rooms table on host_user_id for faster lookups
CREATE INDEX IF NOT EXISTS idx_study_rooms_host_user_id ON study_rooms(host_user_id);

-- Index for room_participants table on room_id for faster lookups
CREATE INDEX IF NOT EXISTS idx_room_participants_room_id ON room_participants(room_id);

-- Index for tutor_profiles table on user_id for faster lookups
CREATE INDEX IF NOT EXISTS idx_tutor_profiles_user_id ON tutor_profiles(user_id);

-- Index for tutor_bookings table on student_id and tutor_id for faster lookups
CREATE INDEX IF NOT EXISTS idx_tutor_bookings_student_id ON tutor_bookings(student_id);
CREATE INDEX IF NOT EXISTS idx_tutor_bookings_tutor_id ON tutor_bookings(tutor_id);

-- Index for tutor_reviews table on tutor_id for faster lookups
CREATE INDEX IF NOT EXISTS idx_tutor_reviews_tutor_id ON tutor_reviews(tutor_id);

-- Index for messages table on room_id for faster lookups
CREATE INDEX IF NOT EXISTS idx_messages_room_id ON messages(room_id);
CREATE INDEX IF NOT EXISTS idx_messages_booking_id ON messages(booking_id);