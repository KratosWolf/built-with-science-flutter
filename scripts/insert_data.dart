import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() async {
  print('📝 Inserindo dados de exemplo...');
  
  const supabaseUrl = 'https://gktvfldykmzhynqthbdn.supabase.co';
  const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdrdHZmbGR5a216aHlucXRoYmRuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTU5Nzg4NzAsImV4cCI6MjA3MTU1NDg3MH0.Nd2KdEGj8hQApxmTk8nkBM81R4ROJPhwRMtgPXadGVw';
  
  final headers = {
    'apikey': supabaseKey,
    'Authorization': 'Bearer $supabaseKey',
    'Content-Type': 'application/json',
    'Prefer': 'return=representation'
  };
  
  // Insert programs
  print('📋 Inserindo programas...');
  final programs = [
    {
      'name': '3-Day Science-Based Full Body',
      'description': 'Optimal full-body routine for maximum muscle growth and strength. Perfect for beginners to intermediates.',
      'days_per_week': 3
    },
    {
      'name': '4-Day Upper/Lower Split',
      'description': 'Balanced upper and lower body split for intermediate to advanced trainees.',
      'days_per_week': 4
    }
  ];
  
  for (var program in programs) {
    try {
      final response = await http.post(
        Uri.parse('$supabaseUrl/rest/v1/programs'),
        headers: headers,
        body: json.encode(program),
      );
      
      if (response.statusCode == 201) {
        final result = json.decode(response.body)[0];
        print('✅ Programa criado: ${result['name']} (ID: ${result['id']})');
      } else {
        print('❌ Erro ao criar programa ${program['name']}: ${response.statusCode}');
        print('Response: ${response.body}');
      }
    } catch (e) {
      print('❌ Erro na inserção: $e');
    }
  }
  
  // Insert exercises  
  print('\n💪 Inserindo exercícios...');
  final exercises = [
    {
      'name': 'Barbell Back Squat',
      'muscle_groups': ['quadriceps', 'glutes', 'hamstrings'],
      'category': 'compound',
      'equipment': 'barbell'
    },
    {
      'name': 'Bench Press',
      'muscle_groups': ['chest', 'triceps', 'anterior_deltoids'],
      'category': 'compound', 
      'equipment': 'barbell'
    }
  ];
  
  for (var exercise in exercises) {
    try {
      final response = await http.post(
        Uri.parse('$supabaseUrl/rest/v1/exercises'),
        headers: headers,
        body: json.encode(exercise),
      );
      
      if (response.statusCode == 201) {
        final result = json.decode(response.body)[0];
        print('✅ Exercício criado: ${result['name']} (ID: ${result['id']})');
      } else {
        print('❌ Erro ao criar exercício ${exercise['name']}: ${response.statusCode}');
        print('Response: ${response.body}');
      }
    } catch (e) {
      print('❌ Erro na inserção: $e');
    }
  }
  
  print('\n🔍 Verificando dados inseridos...');
  
  // Verify programs
  final verifyResponse = await http.get(
    Uri.parse('$supabaseUrl/rest/v1/programs?select=*'),
    headers: headers,
  );
  
  if (verifyResponse.statusCode == 200) {
    final data = json.decode(verifyResponse.body);
    print('✅ Total programs na base: ${data.length}');
  }
}