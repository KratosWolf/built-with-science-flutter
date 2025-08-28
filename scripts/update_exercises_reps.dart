// Script para atualizar o arquivo mock_data.dart com sets e reps corretos do CSV

void main() {
  // Mapeamento baseado no CSV analysis
  final exerciseRepsMap = {
    // Full Body A
    1: "8-10",   // Barbell Bench Press - Set 1: 8-10
    7: "8-10",   // Barbell Romanian Deadlift - Set 1: 8-10  
    10: "6-12",  // (Weighted) Pull-Ups - Set 1: 6-12
    17: "8-10 per leg", // Walking Lunges - Set 1: 8-10 per leg
    22: "10-15", // Standing Mid-Chest Cable Fly - Set 1: 10-15
    27: "15-20", // Dumbbell Lateral Raise - Set 1: 15-20
    32: "10-15", // Single Leg Weighted Calf Raise - Set 2: 10-15
    36: "10",    // Standing Face Pulls - Set 1: 10
    
    // Full Body B
    40: "8-10",  // Barbell Back Squat - Set 1: 8-10
    41: "6-8",   // Standing Barbell Overhead Press - Set 1: 6-8
    42: "10-15", // Seated Leg Curls - Set 1: 10-15
    43: "10-12", // DB Chest Supported Row - Set 1: 10-12
    5: "10+",    // Banded Push-Ups - Set 1: 10+ (close grip push ups set 3: 10+ to failure)
    44: "10-15", // Incline DB Overhead Extensions - Set 1: 10-15
    45: "10-15", // Seated Weighted Calf Raise - Set 1: 10-15
    46: "30-60s hold", // Side Plank - Set 1: 30-60s hold
    
    // Full Body C
    47: "6-8",   // Barbell Deadlift - Set 1: 6-8
    48: "10-12", // Low Incline Dumbbell Press - Set 1: 10-12
    49: "10-15", // Seated Leg Extensions - Set 1: 10-15
    28: "15-20", // Cable Lateral Raise - Set 1: 15-20
    50: "10-15", // Seated Dumbbell Curls - Set 1: 10-15
    
    // Outros exercícios baseados no padrão do CSV
    2: "8-10",   // Flat Dumbbell Press - Set 2: 8-10
    3: "8-10",   // Flat Machine Chest Press - Set 3: 8-10
    4: "8-10",   // Flat Smith Machine Chest Press
    6: "8-10",   // Neutral Grip DB Press*
    8: "8-10",   // Dumbbell Romanian Deadlift - Set 2: 8-10
    9: "8-10",   // Hyperextensions - Set 3: 8-10
    11: "6-12",  // (Weighted) Chin-Ups - Set 2: 6-12
    12: "6-12",  // Banded Pull-Ups - Set 3: 6-12
    13: "6-12",  // Pull-Up Negatives
    14: "6-12",  // Kneeling Lat Pulldown
    15: "6-12",  // Lat Pulldown
    16: "6-12",  // Inverted Row
    18: "8-10 per leg", // Heel Elevated Split Squat - Set 2: 8-10 per leg
    19: "8-10 per leg", // Bulgarian Split Squat - Set 3: 8-10 per leg
    20: "8-10 per leg", // Reverse Lunges*
    21: "8-10 per leg", // Weighted Step-Ups*
    23: "10-15", // Seated Mid-Chest Cable Fly - Set 2: 10-15
    24: "10-15", // Pec-Deck Machine Fly - Set 3: 10-15
    25: "10-15", // Dumbbell Fly
    26: "10-15", // Banded Push-Ups (variations)
    29: "15-20", // Lying Incline Lateral Raise - Set 3: 15-20
    30: "15-20", // Lean In Lateral Raise
    31: "15-20", // Wide Grip BB Upright Row
    33: "10-15", // Toes-Elevated Smith Machine Calf Raise - Set 2: 10-15
    34: "10-15", // Standing Weighted Calf Raise - Set 2: 10-15
    35: "10-15", // Leg Press Calf Raise
    37: "10",    // Bent Over Dumbbell Face Pulls - Set 2: 10
    38: "10",    // (Weighted) Prone Arm Circles - Set 3: 10
    39: "10",    // Wall Slides
  };

  print("Map created with ${exerciseRepsMap.length} exercises");
  
  // Print the map for verification
  exerciseRepsMap.forEach((id, reps) {
    print("Exercise ID $id: $reps reps");
  });
}