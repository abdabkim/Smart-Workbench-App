import 'package:flutter/material.dart';
import 'package:smart_workbench_app/screens/devicestatusscreen.dart';


class OtherToolScreen extends StatefulWidget {
  @override
  _OtherToolScreenState createState() => _OtherToolScreenState();
}

class _OtherToolScreenState extends State<OtherToolScreen> {
  final TextEditingController _toolNameController = TextEditingController();

  @override
  void dispose() {
    _toolNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Enter Tool Name'),
        backgroundColor: Colors.brown.shade50,
      ),
      body: Stack(
        children: [
          Image.asset(
            'assets/bg.jpg',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _toolNameController,
                  decoration: InputDecoration(
                    labelText: 'Tool Name',
                    fillColor: Colors.white,
                    filled: true,
                  ),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  child: Text('Add Tool'),
                  onPressed: () {
                    if (_toolNameController.text.isNotEmpty) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DeviceStatusScreen(
                            deviceType: _toolNameController.text,
                            area: 'Workshop', category: '', // You might want to allow users to select or input this
                          ),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Please enter a tool name')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown,
                    foregroundColor: Colors.white,
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