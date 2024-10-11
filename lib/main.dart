import 'package:flutter/material.dart';
import 'package:smart_workbench_app/screens/welcomescreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_workbench_app/screens/homescreen.dart';


Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String token = prefs.getString('token') ?? '';
  Widget startscreen = (token == "") ? WelcomeScreen() : HomeScreen();
  runApp(SmartWorkBenchApp(startscreen: startscreen,));
}

class SmartWorkBenchApp extends StatelessWidget {
  Widget startscreen;
  SmartWorkBenchApp({Key? key, required this.startscreen}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart WorkBench App',
      theme: ThemeData(
        primarySwatch: Colors.brown,
      ),
      // Start with WelcomeScreen first
      home: this.startscreen,
    );
  }
}


















// Sign Up Screen








