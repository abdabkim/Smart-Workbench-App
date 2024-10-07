import 'package:flutter/material.dart';
import 'package:smart_workbench_app/screens/welcomescreen.dart';

void main() {
  runApp(const SmartWorkBenchApp());
}

class SmartWorkBenchApp extends StatelessWidget {
  const SmartWorkBenchApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart WorkBench App',
      theme: ThemeData(
        primarySwatch: Colors.brown,
      ),
      // Start with WelcomeScreen first
      home: WelcomeScreen(),
    );
  }
}






// Make sure this is at the top













// Sign Up Screen








