import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() async {
  print('🚀 Testing Supabase connection...');
  
  const supabaseUrl = 'https://gktvfldykmzhynqthbdn.supabase.co';
  const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdrdHZmbGR5a216aHlucXRoYmRuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTU5Nzg4NzAsImV4cCI6MjA3MTU1NDg3MH0.Nd2KdEGj8hQApxmTk8nkBM81R4ROJPhwRMtgPXadGVw';
  
  try {
    // Test basic connection
    print('📡 Testing basic REST API connection...');
    
    final response = await http.get(
      Uri.parse('$supabaseUrl/rest/v1/programs?select=count'),
      headers: {
        'apikey': supabaseKey,
        'Authorization': 'Bearer $supabaseKey',
        'Content-Type': 'application/json',
        'Prefer': 'count=exact',
      },
    );
    
    print('Response status: ${response.statusCode}');
    print('Response headers: ${response.headers}');
    print('Response body: ${response.body}');
    
    if (response.statusCode == 200) {
      print('✅ Connection successful!');
      
      // Try to get table count
      final countHeader = response.headers['content-range'];
      if (countHeader != null) {
        print('📊 Programs table count: $countHeader');
      }
    } else {
      print('❌ Connection failed with status: ${response.statusCode}');
      print('Error: ${response.body}');
    }
    
  } catch (e) {
    print('❌ Connection error: $e');
  }
  
  print('\nNext steps:');
  print('1. If connection failed, check if the schema has been created in Supabase dashboard');
  print('2. If successful, proceed with Flutter app testing');
  print('3. Dashboard: https://supabase.com/dashboard/project/gktvfldykmzhynqthbdn');
}