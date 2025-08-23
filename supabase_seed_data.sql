-- Built With Science App - Seed Data
-- Run this AFTER running supabase_schema.sql

-- Insert all exercises from user's CSV data
INSERT INTO public.exercises (id, name, muscle_group) VALUES
(1, 'Barbell Bench Press', 'Chest'),
(2, 'Flat Dumbbell Press', 'Chest'),
(3, 'Flat Machine Chest Press', 'Chest'),
(4, 'Flat Smith Machine Chest Press', 'Chest'),
(5, 'Seated Flat Cable Press', 'Chest'),
(6, 'Neutral Grip DB Press*', 'Chest'),
(7, 'Barbell Romanian Deadlift', 'Posterior Chain'),
(8, 'Dumbbell Romanian Deadlift', 'Posterior Chain'),
(9, 'Hyperextensions (back/hamstring)', 'Posterior Chain'),
(10, '(Weighted) Pull-Ups', 'Back'),
(11, '(Weighted) Chin-Ups', 'Back'),
(12, 'Banded Pull-Ups', 'Back'),
(13, 'Pull-Up Negatives', 'Back'),
(14, 'Kneeling Lat Pulldown', 'Back'),
(15, 'Lat Pulldown', 'Back'),
(16, 'Inverted Row', 'Back'),
(17, 'Walking Lunges (quad focus)', 'Legs'),
(18, 'Heel Elevated Split Squat', 'Legs'),
(19, 'Bulgarian Split Squat (quad focus)', 'Legs'),
(20, 'Reverse Lunges*', 'Legs'),
(21, 'Weighted Step-Ups*', 'Legs'),
(22, 'Standing Mid-Chest Cable Fly', 'Chest'),
(23, 'Seated Mid-Chest Cable Fly', 'Chest'),
(24, 'Pec-Deck Machine Fly', 'Chest'),
(25, 'Dumbbell Fly', 'Chest'),
(26, 'Banded Push-Ups', 'Chest'),
(27, 'Dumbbell Lateral Raise', 'Shoulders'),
(28, 'Cable Lateral Raise', 'Shoulders'),
(29, 'Lying Incline Lateral Raise', 'Shoulders'),
(30, 'Lean In Lateral Raise', 'Shoulders'),
(31, 'Wide Grip BB Upright Row (last resort)', 'Shoulders'),
(32, 'Single Leg Weighted Calf Raise', 'Calves'),
(33, 'Toes-Elevated Smith Machine Calf Raise', 'Calves'),
(34, 'Standing Weighted Calf Raise', 'Calves'),
(35, 'Leg Press Calf Raise', 'Calves'),
(36, 'Standing Face Pulls', 'Rear Delts'),
(37, 'Bent Over Dumbbell Face Pulls', 'Rear Delts'),
(38, '(Weighted) Prone Arm Circles', 'Rear Delts'),
(39, 'Wall Slides', 'Rear Delts')
ON CONFLICT (id) DO UPDATE SET 
  name = EXCLUDED.name,
  muscle_group = EXCLUDED.muscle_group;

-- Insert exercise variations with YouTube URLs from user's program
INSERT INTO public.exercise_variations (id, exercise_id, variation_index, variation_name, youtube_url, is_primary) VALUES
-- BARBELL BENCH PRESS (id: 1) - 6 variations
(1, 1, 1, 'Barbell Bench Press', 'https://youtu.be/pCGVSBk0bIQ', true),
(2, 1, 2, 'Flat Dumbbell Press', 'https://youtu.be/g14dhC5KYBM', false),
(3, 1, 3, 'Flat Machine Chest Press', 'https://youtu.be/sO8lFa9CidE', false),
(4, 1, 4, 'Flat Smith Machine Chest Press', 'https://youtu.be/3Z3C44SXSQE', false),
(5, 1, 5, 'Seated Flat Cable Press', 'https://youtu.be/hPpNTAEDnxM', false),
(6, 1, 6, 'Neutral Grip DB Press*', 'https://youtu.be/N-kUwH1uf9c', false),

-- BARBELL ROMANIAN DEADLIFT (id: 7) - 3 variations
(7, 7, 1, 'Barbell Romanian Deadlift', 'https://youtu.be/Q-2telZDPRw', true),
(8, 7, 2, 'Dumbbell Romanian Deadlift', 'https://youtu.be/Xu4DxwKWzl4', false),
(9, 7, 3, 'Hyperextensions (back/hamstring)', 'https://youtu.be/RU5d2H_OmSc', false),

-- (WEIGHTED) PULL-UPS (id: 10) - 7 variations  
(11, 10, 1, '(Weighted) Pull-Ups', 'https://youtu.be/w_yuTRQd6HA', true),
(12, 10, 2, '(Weighted) Chin-Ups', 'https://youtu.be/-TZRdvUS7Qo', false),
(13, 10, 3, 'Banded Pull-Ups', 'https://youtu.be/VGm-f5-T5no', false),
(14, 10, 4, 'Pull-Up Negatives', 'https://youtu.be/SyMSay4zrsA', false),
(15, 10, 5, 'Kneeling Lat Pulldown', 'https://youtu.be/4LxKeTqlpZA', false),
(16, 10, 6, 'Lat Pulldown', 'https://youtu.be/AvYZZhEl7Xk', false),
(17, 10, 7, 'Inverted Row', 'https://youtu.be/SyMSay4zrsA', false),

-- WALKING LUNGES (id: 17) - 5 variations
(18, 17, 1, 'Walking Lunges (quad focus)', 'https://youtu.be/JB20RuTOaFc', true),
(19, 17, 2, 'Heel Elevated Split Squat', 'https://youtu.be/bJE0-eZLa6E', false),
(20, 17, 3, 'Bulgarian Split Squat (quad focus)', 'https://youtu.be/r9XtxWSTlcg', false),
(21, 17, 4, 'Reverse Lunges*', 'https://youtu.be/AUEGDvCrQJA', false),
(22, 17, 5, 'Weighted Step-Ups*', 'https://youtu.be/Cjc3AgmdtlA', false),

-- STANDING MID-CHEST CABLE FLY (id: 22) - 5 variations
(23, 22, 1, 'Standing Mid-Chest Cable Fly', 'https://youtu.be/fyFVaCP9J-8', true),
(24, 22, 2, 'Seated Mid-Chest Cable Fly', 'https://youtu.be/Y8E3dHNsSTU', false),
(25, 22, 3, 'Pec-Deck Machine Fly', 'https://youtu.be/rnV3y1P7894', false),
(26, 22, 4, 'Dumbbell Fly', 'https://youtu.be/WRn2hqy0gXU', false),
(27, 22, 5, 'Banded Push-Ups', 'https://youtu.be/dI7LVElfMOg', false),

-- DUMBBELL LATERAL RAISE (id: 27) - 5 variations
(28, 27, 1, 'Dumbbell Lateral Raise', 'https://youtu.be/zcO3sgAeLA0', true),
(29, 27, 2, 'Cable Lateral Raise', 'https://youtu.be/1muit9qEctY', false),
(30, 27, 3, 'Lying Incline Lateral Raise', 'https://youtu.be/upEqeI0F73M', false),
(31, 27, 4, 'Lean In Lateral Raise', 'https://youtu.be/2q4kjTDg-vs', false),
(32, 27, 5, 'Wide Grip BB Upright Row (last resort)', 'https://youtu.be/6BTMVh9AnCw', false),

-- SINGLE LEG WEIGHTED CALF RAISE (id: 32) - 4 variations
(33, 32, 1, 'Single Leg Weighted Calf Raise', 'https://youtu.be/cRKA_Qdut7I', true),
(34, 32, 2, 'Toes-Elevated Smith Machine Calf Raise', 'https://youtu.be/_ChZv2iluM8', false),
(35, 32, 3, 'Standing Weighted Calf Raise', 'https://youtu.be/q2Eigaa9dKU', false),
(36, 32, 4, 'Leg Press Calf Raise', 'https://youtu.be/s8yUXsZrgE0', false),

-- STANDING FACE PULLS (id: 36) - 4 variations
(37, 36, 1, 'Standing Face Pulls', 'https://youtu.be/02g7XtSRXug', true),
(38, 36, 2, 'Bent Over Dumbbell Face Pulls', 'https://youtu.be/kA415Unr-_E', false),
(39, 36, 3, '(Weighted) Prone Arm Circles', 'https://youtu.be/6D-4V_M8RJA', false),
(40, 36, 4, 'Wall Slides', 'https://youtu.be/x4zjfuLXHVk', false)
ON CONFLICT (id) DO UPDATE SET 
  exercise_id = EXCLUDED.exercise_id,
  variation_index = EXCLUDED.variation_index,
  variation_name = EXCLUDED.variation_name,
  youtube_url = EXCLUDED.youtube_url,
  is_primary = EXCLUDED.is_primary;

-- Insert program days
INSERT INTO public.program_days (id, program_id, day_index, day_name) VALUES
(1, 1, 1, 'Full Body A'),
(2, 1, 2, 'Full Body B'),
(3, 1, 3, 'Full Body C'),
(4, 2, 1, 'Upper 1'),
(5, 2, 2, 'Lower 1 (Quad Focus)'),
(6, 2, 3, 'Upper 2'),
(7, 2, 4, 'Lower 2 (Glute Focus)'),
(8, 3, 1, 'Upper'),
(9, 3, 2, 'Lower 1 (Quad Focus)'),
(10, 3, 3, 'Push'),
(11, 3, 4, 'Pull'),
(12, 3, 5, 'Lower 2 (Glute Focus)')
ON CONFLICT (id) DO UPDATE SET 
  program_id = EXCLUDED.program_id,
  day_index = EXCLUDED.day_index,
  day_name = EXCLUDED.day_name;

-- Insert day exercises for Full Body A (program_day_id = 1)
INSERT INTO public.day_exercises (program_day_id, exercise_id, order_pos, sets, reps_target, is_superset, superset_label, superset_exercise_label) VALUES
-- Main exercises
(1, 1, 1, 3, '8-10', false, null, null), -- Barbell Bench Press
(1, 7, 2, 3, '8-10', false, null, null), -- Barbell Romanian Deadlift  
(1, 10, 3, 3, '6-12', false, null, null), -- (Weighted) Pull-Ups
(1, 17, 4, 3, '8-10 per leg', false, null, null), -- Walking Lunges

-- Superset A
(1, 22, 5, 3, '10-15', true, 'A', 'A1'), -- Standing Mid-Chest Cable Fly
(1, 27, 6, 3, '15-20', true, 'A', 'A2'), -- Dumbbell Lateral Raise

-- Superset B
(1, 32, 7, 3, '10-15', true, 'B', 'B1'), -- Single Leg Weighted Calf Raise
(1, 36, 8, 3, '10', true, 'B', 'B2') -- Standing Face Pulls
ON CONFLICT DO NOTHING;

-- Reset sequences to ensure proper auto-increment
SELECT setval(pg_get_serial_sequence('exercises', 'id'), (SELECT MAX(id) FROM exercises));
SELECT setval(pg_get_serial_sequence('exercise_variations', 'id'), (SELECT MAX(id) FROM exercise_variations));
SELECT setval(pg_get_serial_sequence('program_days', 'id'), (SELECT MAX(id) FROM program_days));

-- Verify data insertion
SELECT 'Exercises' as table_name, count(*) as count FROM exercises
UNION ALL
SELECT 'Exercise Variations' as table_name, count(*) as count FROM exercise_variations
UNION ALL
SELECT 'Program Days' as table_name, count(*) as count FROM program_days
UNION ALL
SELECT 'Day Exercises' as table_name, count(*) as count FROM day_exercises;