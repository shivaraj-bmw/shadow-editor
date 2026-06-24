import 'package:flutter/material.dart';
import 'screens/branding_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        useMaterial3: true,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),

      home: BrandingScreen(),
    );
  }
}