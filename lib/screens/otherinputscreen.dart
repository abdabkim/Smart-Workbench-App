import 'package:flutter/material.dart';
import 'package:smart_workbench_app/screens/devicecategoryscreen.dart';

class OtherToolScreen extends StatefulWidget {
  const OtherToolScreen({Key? key}) : super(key: key);

  @override
  State<OtherToolScreen> createState() => _OtherToolScreenState();
}

class _OtherToolScreenState extends State<OtherToolScreen> {
  final TextEditingController _toolNameController = TextEditingController();

  // Predefined list of other common workshop tools
  final List<String> otherTools = [
    'Hammer',
    'Screwdriver',
    'Wrench',
    'Pliers',
    'Chisel',
    'Level',
    'Measuring Tape',
    'Clamps',
    'Workbench',
    'Air Compressor',
  ];

  void _navigateToDeviceArea(String toolName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DeviceAreaInputScreen(
          deviceType: toolName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Other Tool'),
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
                const Text(
                  'Select a common tool or add your own:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.brown,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: otherTools.length,
                    itemBuilder: (context, index) {
                      return Card(
                        child: ListTile(
                          title: Text(otherTools[index]),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () => _navigateToDeviceArea(otherTools[index]),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _toolNameController,
                  decoration: InputDecoration(
                    labelText: 'Other Tool Name',
                    fillColor: Colors.white,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onSubmitted: (value) {
                    if (value.isNotEmpty) {
                      _navigateToDeviceArea(value.trim());
                      _toolNameController.clear();
                    }
                  },
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    if (_toolNameController.text.isNotEmpty) {
                      _navigateToDeviceArea(_toolNameController.text.trim());
                      _toolNameController.clear();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please enter a tool name')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Add Custom Tool'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _toolNameController.dispose();
    super.dispose();
  }
}