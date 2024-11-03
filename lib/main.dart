import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'game_screen.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Two-Player Marble Game',
      theme: ThemeData(
        primaryColor: Colors.teal[700],
        hintColor: Colors.amber[600],
        textTheme: TextTheme(
          displayLarge: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold, color: Colors.teal[900]),
          bodyLarge: const TextStyle(fontSize: 16.0, color: Colors.black87),
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const ProviderScope(
            child: GameScreen(),
          ),
        ),
      );
    });


    return Scaffold(
      backgroundColor: Colors.teal[600],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.gamepad, size: 100, color: Colors.amber[200]),
            const SizedBox(height: 20),
            Text(
              'Welcome to Marble Game!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.amber[100]),
            ),
          ],
        ),
      ),
    );
  }
}
