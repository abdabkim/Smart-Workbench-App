import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_workbench_app/providers/user_provider.dart';
import 'package:smart_workbench_app/screens/welcomescreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_workbench_app/screens/homescreen.dart';
import 'package:smart_workbench_app/services/automation_service.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AutomationService.initialize();  // Added this single line
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String token = prefs.getString('token') ?? '';
  Widget startscreen = (token == "") ? WelcomeScreen() : HomeScreen();
  runApp(
      MultiProvider(
          providers: [ChangeNotifierProvider(create: (context)=>User())],
          child: SmartWorkBenchApp(startscreen: startscreen,
          )
      )
  );
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
      home: this.startscreen,
    );
  }
}