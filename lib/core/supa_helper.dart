import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseHelper {
  static final SupabaseClient client = Supabase.instance.client;

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: 'https://fvalacbmubcqjicseves.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZ2YWxhY2JtdWJjcWppY3NldmVzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDc3ODQwNjYsImV4cCI6MjA2MzM2MDA2Nn0.EhmiEL8Dze-TMo7IV6VXV6bG1CntJY9l1u_5iBuZel8',
    );
  }
}
