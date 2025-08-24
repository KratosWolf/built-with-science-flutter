import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() async {
  print('🔍 Verificando dados na base...');
  
  const supabaseUrl = 'https://gktvfldykmzhynqthbdn.supabase.co';
  const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdrdHZmbGR5a216aHlucXRoYmRuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTU5Nzg4NzAsImV4cCI6MjA3MTU1NDg3MH0.Nd2KdEGj8hQApxmTk8nkBM81R4ROJPhwRMtgPXadGVw';
  
  final headers = {
    'apikey': supabaseKey,
    'Authorization': 'Bearer $supabaseKey',
    'Content-Type': 'application/json',
  };
  
  // Test programs
  try {
    print('📋 Testando tabela programs...');
    final response = await http.get(
      Uri.parse('$supabaseUrl/rest/v1/programs?select=*'),
      headers: headers,
    );
    
    if (response.statusCode == 200) {
      final programs = json.decode(response.body);
      print('✅ Programs encontrados: ${programs.length}');
      for (var program in programs) {
        print('   - ${program['name']} (${program['days_per_week']} dias)');
      }
    } else {
      print('❌ Erro ao buscar programs: ${response.statusCode}');
      print('Response: ${response.body}');
    }
  } catch (e) {
    print('❌ Erro na conexão programs: $e');
  }
  
  // Test exercises
  try {
    print('\n💪 Testando tabela exercises...');
    final response = await http.get(
      Uri.parse('$supabaseUrl/rest/v1/exercises?select=*'),
      headers: headers,
    );
    
    if (response.statusCode == 200) {
      final exercises = json.decode(response.body);
      print('✅ Exercises encontrados: ${exercises.length}');
      for (var exercise in exercises) {
        print('   - ${exercise['name']} (${exercise['category']})');
      }
    } else {
      print('❌ Erro ao buscar exercises: ${response.statusCode}');
      print('Response: ${response.body}');
    }
  } catch (e) {
    print('❌ Erro na conexão exercises: $e');
  }
  
  // Test program_days
  try {
    print('\n📅 Testando tabela program_days...');
    final response = await http.get(
      Uri.parse('$supabaseUrl/rest/v1/program_days?select=*'),
      headers: headers,
    );
    
    if (response.statusCode == 200) {
      final days = json.decode(response.body);
      print('✅ Program days encontrados: ${days.length}');
      for (var day in days) {
        print('   - Program ${day['program_id']}: ${day['day_name']} (Dia ${day['day_index']})');
      }
    } else {
      print('❌ Erro ao buscar program_days: ${response.statusCode}');
      print('Response: ${response.body}');
    }
  } catch (e) {
    print('❌ Erro na conexão program_days: $e');
  }
}