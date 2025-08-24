-- Quick setup for Built With Science database
-- Execute this in Supabase SQL Editor after running the main schema

-- Insert sample programs
INSERT INTO programs (name, description, days_per_week) VALUES 
('3-Day Science-Based Full Body', 'Optimal full-body routine for maximum muscle growth and strength. Perfect for beginners to intermediates.', 3),
('4-Day Upper/Lower Split', 'Balanced upper and lower body split for intermediate to advanced trainees.', 4),
('5-Day Push/Pull/Legs', 'High-frequency training for advanced lifters seeking maximum muscle development.', 5)
ON CONFLICT DO NOTHING;

-- Insert program days
INSERT INTO program_days (program_id, day_index, day_name) VALUES 
-- 3-Day Program (program_id = 1)
(1, 1, 'Full Body A'),
(1, 2, 'Full Body B'), 
(1, 3, 'Full Body C'),
-- 4-Day Program (program_id = 2)
(2, 1, 'Upper Body'),
(2, 2, 'Lower Body'),
(2, 3, 'Upper Body'),
(2, 4, 'Lower Body'),
-- 5-Day Program (program_id = 3)
(3, 1, 'Push'),
(3, 2, 'Pull'),
(3, 3, 'Legs'),
(3, 4, 'Push'),
(3, 5, 'Pull')
ON CONFLICT DO NOTHING;

-- Insert core exercises
INSERT INTO exercises (name, muscle_groups, category, equipment) VALUES 
('Barbell Back Squat', ARRAY['quadriceps', 'glutes', 'hamstrings', 'core'], 'compound', 'barbell'),
('Deadlift', ARRAY['hamstrings', 'glutes', 'erector_spinae', 'traps'], 'compound', 'barbell'),
('Bench Press', ARRAY['chest', 'triceps', 'anterior_deltoids'], 'compound', 'barbell'),
('Pull-ups', ARRAY['latissimus_dorsi', 'biceps', 'rear_deltoids'], 'compound', 'bodyweight'),
('Overhead Press', ARRAY['shoulders', 'triceps', 'core'], 'compound', 'barbell'),
('Dumbbell Bicep Curls', ARRAY['biceps'], 'isolation', 'dumbbells'),
('Tricep Dips', ARRAY['triceps'], 'isolation', 'bodyweight'),
('Lateral Raises', ARRAY['lateral_deltoids'], 'isolation', 'dumbbells'),
('Calf Raises', ARRAY['calves'], 'isolation', 'bodyweight'),
('Plank', ARRAY['core', 'shoulders'], 'isolation', 'bodyweight')
ON CONFLICT DO NOTHING;

-- Insert exercise variations
INSERT INTO exercise_variations (exercise_id, variation_index, variation_name, youtube_url, is_primary, difficulty_level) VALUES 
-- Barbell Back Squat variations (exercise_id = 1)
(1, 1, 'High Bar Back Squat', 'https://www.youtube.com/watch?v=ultWZbUMPL8', true, 'intermediate'),
(1, 2, 'Low Bar Back Squat', 'https://www.youtube.com/watch?v=vmNPOjaGrVE', false, 'advanced'),
(1, 3, 'Goblet Squat', 'https://www.youtube.com/watch?v=MeIiIdhvXT4', false, 'beginner'),
-- Deadlift variations (exercise_id = 2)  
(2, 1, 'Conventional Deadlift', 'https://www.youtube.com/watch?v=op9kVnSso6Q', true, 'intermediate'),
(2, 2, 'Sumo Deadlift', 'https://www.youtube.com/watch?v=6ucdKlZkZCU', false, 'intermediate'),
(2, 3, 'Romanian Deadlift', 'https://www.youtube.com/watch?v=jEy_czb3RKA', false, 'beginner'),
-- Bench Press variations (exercise_id = 3)
(3, 1, 'Flat Barbell Bench Press', 'https://www.youtube.com/watch?v=gRVjAtPip0Y', true, 'intermediate'),
(3, 2, 'Incline Barbell Bench Press', 'https://www.youtube.com/watch?v=DbFgADa2PL8', false, 'intermediate'),
(3, 3, 'Dumbbell Bench Press', 'https://www.youtube.com/watch?v=QsYre__-aro', false, 'beginner'),
-- Pull-ups variations (exercise_id = 4)
(4, 1, 'Standard Pull-up', 'https://www.youtube.com/watch?v=eGo4IYlbE5g', true, 'intermediate'),
(4, 2, 'Chin-ups', 'https://www.youtube.com/watch?v=jfzjti-f2ME', false, 'beginner'),
(4, 3, 'Wide Grip Pull-ups', 'https://www.youtube.com/watch?v=iU3LfJWNBgA', false, 'advanced')
ON CONFLICT DO NOTHING;

-- Create sample day exercises (what exercises to do on each day)
INSERT INTO day_exercises (program_day_id, exercise_id, order_pos, set_target, rest_sec) VALUES
-- Full Body A (program_day_id = 1)
(1, 1, 1, 3, 180), -- High Bar Back Squat
(1, 3, 2, 3, 180), -- Flat Barbell Bench Press  
(1, 4, 3, 3, 180), -- Standard Pull-up
(1, 5, 4, 3, 120), -- Overhead Press
(1, 10, 5, 3, 60), -- Plank
-- Full Body B (program_day_id = 2)  
(2, 2, 1, 3, 240), -- Conventional Deadlift
(2, 3, 2, 3, 180), -- Incline Barbell Bench Press
(2, 4, 3, 3, 120), -- Chin-ups
(2, 6, 4, 3, 90),  -- Dumbbell Bicep Curls
(2, 7, 5, 3, 90)   -- Tricep Dips
ON CONFLICT DO NOTHING;

-- Create sample set targets for each exercise
INSERT INTO day_exercise_sets (day_exercise_id, set_number, reps_target) VALUES
-- Full Body A sets
(1, 1, '8-10'), (1, 2, '8-10'), (1, 3, '8-10'), -- Squat
(2, 1, '8-10'), (2, 2, '8-10'), (2, 3, '8-10'), -- Bench
(3, 1, '6-8'), (3, 2, '6-8'), (3, 3, '6-8'),    -- Pull-ups
(4, 1, '8-10'), (4, 2, '8-10'), (4, 3, '8-10'), -- OHP
(5, 1, '30-60s'), (5, 2, '30-60s'), (5, 3, '30-60s'), -- Plank
-- Full Body B sets  
(6, 1, '5-6'), (6, 2, '5-6'), (6, 3, '5-6'),    -- Deadlift
(7, 1, '8-10'), (7, 2, '8-10'), (7, 3, '8-10'), -- Incline Bench
(8, 1, '8-10'), (8, 2, '8-10'), (8, 3, '8-10'), -- Chin-ups
(9, 1, '10-12'), (9, 2, '10-12'), (9, 3, '10-12'), -- Bicep Curls
(10, 1, '8-12'), (10, 2, '8-12'), (10, 3, '8-12') -- Tricep Dips
ON CONFLICT DO NOTHING;

-- Insert a test user
INSERT INTO workout_users (id, email, display_name) VALUES 
(uuid_generate_v4(), 'test@builtwithscience.com', 'Test User')
ON CONFLICT DO NOTHING;