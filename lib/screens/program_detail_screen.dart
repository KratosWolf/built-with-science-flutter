import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/workout_models.dart';
// import "supabase_service.dart";
import 'workout_tracking_screen.dart';

class ProgramDetailScreen extends StatefulWidget {
  final Program program;
  
  const ProgramDetailScreen({
    Key? key, 
    required this.program,
  }) : super(key: key);

  @override
  State<ProgramDetailScreen> createState() => _ProgramDetailScreenState();
}

class _ProgramDetailScreenState extends State<ProgramDetailScreen> {
  List<ProgramDay> _programDays = [];
  bool _isLoading = true;
  String? _error;
  int _nextWorkoutDay = 1; // 1=A, 2=B, 3=C

  @override
  void initState() {
    super.initState();
    _loadProgramDays();
    _loadNextWorkoutDay();
  }

  Future<void> _loadProgramDays() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Mock data for program days
      await Future.delayed(const Duration(milliseconds: 800));
      
      List<ProgramDay> mockDays = [];
      
      if (widget.program.daysPerWeek == 3) {
        // Beginner - Full Body
        mockDays = [
          ProgramDay(id: 1, programId: widget.program.id, dayIndex: 1, dayName: 'Full Body A'),
          ProgramDay(id: 2, programId: widget.program.id, dayIndex: 2, dayName: 'Full Body B'), 
          ProgramDay(id: 3, programId: widget.program.id, dayIndex: 3, dayName: 'Full Body C'),
        ];
      } else if (widget.program.daysPerWeek == 4) {
        // Intermediate - Upper/Lower
        mockDays = [
          ProgramDay(id: 4, programId: widget.program.id, dayIndex: 1, dayName: 'Upper Body'),
          ProgramDay(id: 5, programId: widget.program.id, dayIndex: 2, dayName: 'Lower Body'),
          ProgramDay(id: 6, programId: widget.program.id, dayIndex: 3, dayName: 'Upper Body'),
          ProgramDay(id: 7, programId: widget.program.id, dayIndex: 4, dayName: 'Lower Body'),
        ];
      } else if (widget.program.daysPerWeek == 5) {
        // Advanced - PPL
        mockDays = [
          ProgramDay(id: 8, programId: widget.program.id, dayIndex: 1, dayName: 'Push'),
          ProgramDay(id: 9, programId: widget.program.id, dayIndex: 2, dayName: 'Pull'),
          ProgramDay(id: 10, programId: widget.program.id, dayIndex: 3, dayName: 'Legs'),
          ProgramDay(id: 11, programId: widget.program.id, dayIndex: 4, dayName: 'Push'),
          ProgramDay(id: 12, programId: widget.program.id, dayIndex: 5, dayName: 'Pull'),
        ];
      }
      
      setState(() {
        _programDays = mockDays;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadNextWorkoutDay() async {
    final prefs = await SharedPreferences.getInstance();
    final nextDay = prefs.getInt('next_workout_day_${widget.program.id}') ?? 1;
    setState(() {
      _nextWorkoutDay = nextDay;
    });
  }

  Future<void> _updateNextWorkoutDay(int completedDay) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Progressão A→B→C→A
    int nextDay;
    if (completedDay == 1) { // A → B
      nextDay = 2;
    } else if (completedDay == 2) { // B → C
      nextDay = 3;
    } else { // C → A
      nextDay = 1;
    }
    
    await prefs.setInt('next_workout_day_${widget.program.id}', nextDay);
    setState(() {
      _nextWorkoutDay = nextDay;
    });
  }

  void _startWorkout(ProgramDay day) {
    HapticFeedback.mediumImpact();
    
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => WorkoutTrackingScreen(
          programId: widget.program.id,
          dayId: day.id,
          dayName: day.dayName,
          onWorkoutCompleted: () {
            // Atualizar progressão quando completar treino
            _updateNextWorkoutDay(day.dayIndex);
          },
        ),
      ),
    );
  }

  void _startRecommendedWorkout() {
    if (_programDays.isNotEmpty && _nextWorkoutDay <= _programDays.length) {
      final recommendedDay = _programDays.firstWhere(
        (day) => day.dayIndex == _nextWorkoutDay,
        orElse: () => _programDays.first,
      );
      _startWorkout(recommendedDay);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.program.name),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Program info
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.program.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.program.description ?? 'Science-based workout program',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.calendar_today, size: 16, color: Colors.blue),
                          const SizedBox(width: 4),
                          Text('${widget.program.daysPerWeek} days per week'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Program days
              Expanded(
                child: _buildContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
            const SizedBox(height: 16),
            Text('Error loading program days', 
                 style: TextStyle(fontSize: 18, color: Colors.red.shade600)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadProgramDays,
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    if (_programDays.isEmpty) {
      return const Center(
        child: Text('No program days found'),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Workout Days',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        
        Expanded(
          child: ListView.builder(
            itemCount: _programDays.length,
            itemBuilder: (context, index) {
              final day = _programDays[index];
              final isRecommended = day.dayIndex == _nextWorkoutDay;
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                color: isRecommended 
                  ? Theme.of(context).colorScheme.secondary.withOpacity(0.1)
                  : null,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isRecommended 
                      ? Theme.of(context).colorScheme.secondary
                      : Colors.blue,
                    child: Text(
                      '${day.dayIndex}',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          day.dayName, 
                          style: const TextStyle(fontWeight: FontWeight.w600)
                        ),
                      ),
                      if (isRecommended)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.secondary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'PRÓXIMO',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  subtitle: Text(isRecommended 
                    ? 'Recomendado - Tap para iniciar' 
                    : 'Tap para iniciar treino'),
                  trailing: Icon(
                    Icons.play_arrow, 
                    color: isRecommended ? Theme.of(context).colorScheme.secondary : Colors.green
                  ),
                  onTap: () => _startWorkout(day),
                ),
              );
            },
          ),
        ),
        
        // Quick start button - Próximo treino recomendado
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _programDays.isNotEmpty 
              ? _startRecommendedWorkout
              : null,
            icon: const Icon(Icons.play_arrow),
            label: Text(_programDays.isNotEmpty && _nextWorkoutDay <= _programDays.length
              ? 'Iniciar ${_programDays.firstWhere((d) => d.dayIndex == _nextWorkoutDay, orElse: () => _programDays.first).dayName} (Recomendado)'
              : 'Iniciar Treino'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.secondary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }
}