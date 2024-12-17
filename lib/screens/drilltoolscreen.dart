import 'package:flutter/material.dart';
import 'package:smart_workbench_app/screens/devicecategoryscreen.dart';

class DrillToolScreen extends StatefulWidget {
  const DrillToolScreen({Key? key}) : super(key: key);

  @override
  State<DrillToolScreen> createState() => _DrillToolScreenState();
}

class _DrillToolScreenState extends State<DrillToolScreen> {
  final TextEditingController _toolNameController = TextEditingController();

  // A Predefined list of drill tools
  final List<String> drillTools = [
    'Electric drill',
    'Hammer Drill',
    'Drill Press',
    'Right-Angle Drill (corded)',
    'Rotary Hammer',
    'Magnetic Drill',
  ];

  void _navigateToAreaScreen(String toolName) {
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
        title: const Text('Add Drill Tool'),
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
                  'Select a drill tool or add your own:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.brown,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: drillTools.length,
                    itemBuilder: (context, index) {
                      return Card(
                        child: ListTile(
                          title: Text(drillTools[index]),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () => _navigateToAreaScreen(drillTools[index]),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _toolNameController,
                  decoration: InputDecoration(
                    labelText: 'Other Drill Tool',
                    fillColor: Colors.white,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    if (_toolNameController.text.isNotEmpty) {
                      _navigateToAreaScreen(_toolNameController.text.trim());
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