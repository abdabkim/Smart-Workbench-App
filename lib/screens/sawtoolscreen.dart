import 'package:flutter/material.dart';
import 'package:smart_workbench_app/screens/devicestatusscreen.dart';


class SawToolScreen extends StatefulWidget {
  @override
  _SawToolScreenState createState() => _SawToolScreenState();
}

class _SawToolScreenState extends State<SawToolScreen> {
  final TextEditingController _toolNameController = TextEditingController();
  final List<String> sawTools = [
    'Table Saw',
    'Miter Saw',
    'Circular Saw',
    'Jigsaw',
    'Band Saw',
  ];

  @override
  void dispose() {
    _toolNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Saw Tool'),
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
                Text(
                  'Select a pre-defined saw tool or add your own:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: sawTools.length,
                    itemBuilder: (context, index) {
                      return Card(
                        child: ListTile(
                          title: Text(sawTools[index]),
                          onTap: () => _navigateToDeviceStatus(context, sawTools[index]),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: _toolNameController,
                  decoration: InputDecoration(
                    labelText: 'Custom Saw Tool Name',
                    fillColor: Colors.white,
                    filled: true,
                  ),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  child: Text('Add Custom Saw Tool'),
                  onPressed: () {
                    if (_toolNameController.text.isNotEmpty) {
                      _navigateToDeviceStatus(context, _toolNameController.text);
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

  void _navigateToDeviceStatus(BuildContext context, String toolName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DeviceStatusScreen(
          deviceType: toolName,
          category: 'Saw Tool',
          area: 'Workshop', // You might want to allow users to select or input this
        ),
      ),
    );
  }
}