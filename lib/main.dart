import 'package:flutter/material.dart';
import 'package:pl2_kasir/dashboard.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pl2_kasir/login_page.dart';

Future<void> main() async {
  await Supabase.initialize(
    url: 'https://kqcgmnzgryawkdbkfpyn.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtxY2dtbnpncnlhd2tkYmtmcHluIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzYxMzIwNjgsImV4cCI6MjA1MTcwODA2OH0.2CC1hFsfGjYs3q1L0GkfHPHyeAp6FSjq2t2ZhyxgWb0',
  );
  runApp(const MyApp());
}
        

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: false,
      ),
      debugShowCheckedModeBanner: false,
      home: const Dashboard(),
    );
  }
}


