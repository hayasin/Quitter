import 'package:flutter/material.dart';
import 'package:quitter/pages/auth_page.dart';
import 'package:quitter/pages/graph_page.dart';
import 'package:quitter/pages/home_page.dart';
import 'package:quitter/pages/root_page.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '', 
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',     
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quitter',
      theme: ThemeData.dark(), 
      home: const AuthPage(),  
    );
  }
}
