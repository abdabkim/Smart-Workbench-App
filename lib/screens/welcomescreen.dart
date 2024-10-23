import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:smart_workbench_app/screens/loginscreen.dart';
import 'dart:convert';
import 'package:smart_workbench_app/screens/signupscreen.dart';

class WelcomeScreen extends StatelessWidget {
  // Function to make an API call
  Future<void> fetchData() async {
    // Replace with your actual API URL
    final response =
    await http.get(Uri.parse('http://192.168.0.6:8000/auth/login'));

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      print('Data received: $data');
      // Handle the data here
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/bg.jpg'), // Replace with actual path
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Content: logo, text, buttons
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App logo
                Image.asset('assets/logo.png',
                    height: 100), // Replace with your app's logo

                const SizedBox(height: 20),

                // Welcome text
                const Text(
                  'Welcome Home to Smart Workbench',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.brown,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'This is all you need to get up and running, Smart Workbench that helps you enjoy the convenience and peace of mind of a fully connected smart workspace.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 40),

                // Create Account Button
                SizedBox(
                  width: 250,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      backgroundColor: Colors.white,
                    ),
                    onPressed: () {
                      // Navigate to SignUpScreen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SignUpScreen()),
                      );
                    },
                    child: const Text(
                      'Create Account',
                      style: TextStyle(color: Colors.brown),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Fetch Data Button (This will trigger the API call)
                SizedBox(
                  width: 250,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      backgroundColor: Colors.brown,
                    ),
                    onPressed: (){
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LoginScreen()),
                      );
                    }, // This triggers the API call
                    child: const Text(
                      'Login',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}