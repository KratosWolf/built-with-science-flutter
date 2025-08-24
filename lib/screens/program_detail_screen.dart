import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/workout_models.dart';
import '../services/supabase_service.dart';
import 'workout_session_screen.dart';

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

  @override
  void initState() {
    super.initState();
    _loadProgramDays();
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

  void _startWorkout(ProgramDay day) {
    HapticFeedback.mediumImpact();
    
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => WorkoutSessionScreen(
          programId: widget.program.id,
          programDayId: day.id,
          dayName: day.dayName,
        ),
      ),
    );
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
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: Text(
                      '${day.dayIndex}',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(day.dayName, style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Tap to start workout'),
                  trailing: const Icon(Icons.play_arrow, color: Colors.green),
                  onTap: () => _startWorkout(day),
                ),
              );
            },
          ),
        ),
        
        // Quick start button
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _programDays.isNotEmpty 
              ? () => _startWorkout(_programDays.first)
              : null,
            icon: const Icon(Icons.play_arrow),
            label: const Text('Start First Workout'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }
}