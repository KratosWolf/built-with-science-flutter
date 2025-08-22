import 'package:flutter/material.dart';
import '../models/workout_models.dart';
import '../data/mock_data.dart';

class ProgramDetailScreen extends StatelessWidget {
  const ProgramDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final programId = ModalRoute.of(context)!.settings.arguments as int;
    final program = MockData.getProgramById(programId);
    final programDays = MockData.getProgramDays(programId);

    if (program == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Program Not Found')),
        body: const Center(
          child: Text('Program not found'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(program.name),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${programDays.length} workout days designed for optimal muscle development and strength gains.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 24),
              
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.2,
                  ),
                  itemCount: programDays.length,
                  itemBuilder: (context, index) {
                    final day = programDays[index];
                    
                    return Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: InkWell(
                        onTap: () {
                          // TODO: Navegar para detalhes do dia
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Iniciando ${day.dayName}'),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Day ${day.dayIndex}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.green.shade100,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      'Ready',
                                      style: TextStyle(
                                        color: Colors.green.shade800,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              
                              const SizedBox(height: 8),
                              
                              Text(
                                day.dayName,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              
                              const SizedBox(height: 8),
                              
                              Expanded(
                                child: Text(
                                  _getDayDescription(day.dayName),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ),
                              
                              const SizedBox(height: 12),
                              
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () {
                                    // TODO: Implementar início do treino
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Iniciando ${day.dayName}'),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text(
                                    'Start Workout',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              
              // Program Overview
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Text(
                        'Program Overview',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _StatWidget(
                            value: '${programDays.length}',
                            label: 'Workout Days',
                            color: Colors.blue,
                          ),
                          _StatWidget(
                            value: '36',
                            label: 'Total Exercises',
                            color: Colors.green,
                          ),
                          _StatWidget(
                            value: '78',
                            label: 'Exercise Variations',
                            color: Colors.purple,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getDayDescription(String dayName) {
    if (dayName.contains('Full Body')) {
      return "Complete full body workout targeting all major muscle groups";
    } else if (dayName.contains('Upper')) {
      return "Upper body focus: chest, back, shoulders, and arms";
    } else if (dayName.contains('Lower')) {
      return "Lower body focus with emphasis on specified muscle groups";
    } else if (dayName.contains('Push')) {
      return "Push movements: chest, shoulders, triceps";
    } else if (dayName.contains('Pull')) {
      return "Pull movements: back, biceps, rear delts";
    }
    return "Science-based workout session";
  }
}

class _StatWidget extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _StatWidget({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

