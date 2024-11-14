import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_workbench_app/screens/loginscreen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController professionController = TextEditingController();
  File? _image;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  Future<void> _getImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> saveUserData(String name, String email, String profession) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', name);
    await prefs.setString('email', email);
    await prefs.setString('profession', profession);
    await prefs.setBool('isLoggedIn', true);
  }

  Future<void> signUpUser(BuildContext context) async {
    if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a profile photo'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      print('Starting registration process...');

      final uri = Uri.parse('http://192.168.0.9:8000/auth/signup');
      var request = http.MultipartRequest('POST', uri);

      // Add text fields
      request.fields['name'] = nameController.text.trim();
      request.fields['email'] = emailController.text.trim().toLowerCase();
      request.fields['password'] = passwordController.text;
      request.fields['profession'] = professionController.text.trim();

      print('Preparing file upload...');
      // Get file extension
      String extension = _image!.path.split('.').last.toLowerCase();
      if (!['jpg', 'jpeg', 'png'].contains(extension)) {
        extension = 'jpg'; // Default to jpg if unknown
      }

      // Create unique filename
      String filename = 'photo_${DateTime.now().millisecondsSinceEpoch}.$extension';

      // Add file with correct field name matching backend
      var photoStream = http.ByteStream(_image!.openRead());
      var length = await _image!.length();

      print('Adding photo to request...');
      print('Filename: $filename');
      print('File size: $length bytes');
      print('Content type: image/$extension');

      var multipartFile = http.MultipartFile(
        'photo',
        photoStream,
        length,
        filename: filename,
        contentType: MediaType('image', extension),
      );
      request.files.add(multipartFile);

      // Print out the entire request for debugging
      print('Request fields:');
      request.fields.forEach((key, value) {
        if (key != 'password') {
          print('$key: $value');
        }
      });
      print('Request files:');
      request.files.forEach((file) {
        print('Field name: ${file.field}');
        print('Filename: ${file.filename}');
        print('Content type: ${file.contentType}');
      });

      print('Sending request to server...');

      // Send request with timeout
      var streamedResponse = await request.send().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw TimeoutException('Request timed out');
        },
      );

      print('Response status code: ${streamedResponse.statusCode}');

      // Get response
      var response = await http.Response.fromStream(streamedResponse);
      print('Response headers: ${response.headers}');
      print('Response body: ${response.body}');

      try {
        final responseData = jsonDecode(response.body);
        print('Parsed response: $responseData');

        if (responseData['message'] is Map &&
            responseData['message']['storageErrors'] != null) {
          throw Exception('File storage error on server');
        }

        if (response.statusCode == 200 || response.statusCode == 201) {
          print('Registration successful!');
          await saveUserData(
              nameController.text,
              emailController.text,
              professionController.text
          );

          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Verification email sent. Please check your email.'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 5),
              ),
            );

            await Future.delayed(const Duration(seconds: 2));
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            );
          }
        } else {
          throw Exception(responseData['message'] ?? 'Registration failed');
        }
      } catch (e) {
        print('Error processing response: $e');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Registration failed: ${e.toString()}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      }
    } catch (error) {
      print('Error during registration: $error');
      String errorMessage = 'Connection error';

      if (error is TimeoutException) {
        errorMessage = 'Connection timed out. Please try again.';
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Image.asset(
            'assets/bg.jpg',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  flex: 2,
                  child: Center(
                    child: Text(
                      'Create Account',
                      style: TextStyle(
                        color: Colors.brown,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: ClipPath(
                    clipper: WaveClipper(),
                    child: Container(
                      color: Colors.white.withOpacity(0.7),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16.0, 50.0, 16.0, 16.0),
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              GestureDetector(
                                onTap: _getImage,
                                child: Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    shape: BoxShape.circle,
                                  ),
                                  child: _image != null
                                      ? ClipOval(
                                    child: Image.file(
                                      _image!,
                                      width: 120,
                                      height: 120,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                      : Icon(
                                    Icons.add_a_photo,
                                    size: 40,
                                    color: Colors.brown,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              buildTextField(nameController, Icons.person, 'Full Name'),
                              const SizedBox(height: 20),
                              buildTextField(emailController, Icons.email, 'Email'),
                              const SizedBox(height: 20),
                              buildTextField(passwordController, Icons.lock, 'Password', isPassword: true),
                              const SizedBox(height: 20),
                              buildTextField(professionController, Icons.work, 'Profession'),
                              const SizedBox(height: 30),
                              ElevatedButton(
                                onPressed: _isLoading
                                    ? null
                                    : () {
                                  if (nameController.text.trim().isEmpty ||
                                      emailController.text.trim().isEmpty ||
                                      passwordController.text.isEmpty ||
                                      professionController.text.trim().isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Please fill in all fields'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                    return;
                                  }

                                  if (!emailController.text.contains('@') ||
                                      !emailController.text.contains('.')) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Please enter a valid email address'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                    return;
                                  }

                                  if (passwordController.text.length < 8) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Password must be at least 8 characters'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                    return;
                                  }

                                  signUpUser(context);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.brown,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.zero,
                                  ),
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    strokeWidth: 2,
                                  ),
                                )
                                    : const Text(
                                  'Sign up',
                                  style: TextStyle(fontSize: 18, color: Colors.white),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    'Already have an account?',
                                    style: TextStyle(fontSize: 16, color: Colors.brown),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const LoginScreen(),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      'Log in',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.brown[800],
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
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

  Widget buildTextField(TextEditingController controller, IconData icon, String hintText, {bool isPassword = false}) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.brown),
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.brown),
        filled: false,
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.brown),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.brown),
        ),
      ),
    );
  }
}

class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, 40);

    var firstControlPoint = Offset(size.width / 4, 0);
    var firstEndPoint = Offset(size.width / 2, 30);

    var secondControlPoint = Offset(size.width * 3 / 4, 60);
    var secondEndPoint = Offset(size.width, 30);

    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
        firstEndPoint.dx, firstEndPoint.dy);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy,
        secondEndPoint.dx, secondEndPoint.dy);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}