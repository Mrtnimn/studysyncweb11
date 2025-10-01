-- Seed achievements table with idempotent inserts
INSERT INTO achievements (name, description, icon, xp_reward, badge_color, category, unlock_criteria)
VALUES
('First Steps', 'Complete your first study session', 'target', 50, 'blue', 'milestone', '{"type": "sessions_completed", "target": 1}'),
('Week Warrior', 'Study for 7 days in a row', 'flame', 200, 'orange', 'streak', '{"type": "study_streak", "target": 7}'),
('Early Bird', 'Start a study session before 7 AM', 'sunrise', 100, 'yellow', 'focus', '{"type": "early_study", "target": 1}'),
('XP Master', 'Earn 1000 total XP points', 'star', 300, 'purple', 'xp', '{"type": "total_xp", "target": 1000}'),
('Study Marathon', 'Study for 2 hours in a single session', 'clock', 150, 'green', 'focus', '{"type": "session_duration", "target": 120}'),
('Social Learner', 'Join 5 different study rooms', 'users', 120, 'blue', 'social', '{"type": "rooms_joined", "target": 5}'),
('Helping Hand', 'Help 10 students as a tutor', 'heart', 250, 'red', 'social', '{"type": "students_helped", "target": 10}')
ON CONFLICT (name) DO NOTHING;