import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_workbench_app/widget/workspacecontrolcard.dart';
import 'package:smart_workbench_app/widget/paper_js_visualization.dart';
import 'package:smart_workbench_app/widget/two_js_visualization.dart';
import 'dart:async';

class SmartWorkspaceScreen extends StatefulWidget {
  const SmartWorkspaceScreen({super.key});

  @override
  State<SmartWorkspaceScreen> createState() => _SmartWorkspaceScreenState();
}

class _SmartWorkspaceScreenState extends State<SmartWorkspaceScreen> {
  bool _isAutomationEnabled = false;
  List<Map<String, dynamic>> connectedDevices = [];
  final String baseUrl = 'http://192.168.0.11:8000/device';
  final String webhookUrlOn = 'https://maker.ifttt.com/trigger/turn_on_devices/with/key/2ZySHZZprglWIony9x0DF';
  final String webhookUrlOff = 'https://maker.ifttt.com/trigger/turn_off_device/with/key/2ZySHZZprglWIony9x0DF';
  String? authToken;

  @override
  void initState() {
    super.initState();
    _loadDevices();
  }

  Future<void> _loadDevices() async {
    final prefs = await SharedPreferences.getInstance();
    authToken = prefs.getString('token');
    if (authToken != null) {
      try {
        final response = await http.get(
          Uri.parse('$baseUrl/retrieveall'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $authToken',
          },
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          setState(() {
            connectedDevices = List<Map<String, dynamic>>.from(data['devices']);
            _isAutomationEnabled = connectedDevices.isNotEmpty &&
                connectedDevices.every((device) => device['status'] == true);
          });
        }
      } catch (e) {
        print('Error loading devices: $e');
      }
    }
  }

  Future<void> _toggleAllDevices(bool turnOn) async {
    // First update all devices in backend
    for (var device in connectedDevices) {
      try {
        final response = await http.put(
          Uri.parse('$baseUrl/update/${device['_id']}'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $authToken',
          },
          body: json.encode({'status': turnOn}),
        );

        if (response.statusCode == 200) {
          device['status'] = turnOn;
        }
      } catch (e) {
        print('Error updating device: $e');
      }
    }

    // Then trigger IFTTT
    try {
      await http.post(Uri.parse(turnOn ? webhookUrlOn : webhookUrlOff));
    } catch (e) {
      print('IFTTT Error: $e');
    }

    // Update local state
    if (mounted) {
      setState(() {
        _isAutomationEnabled = turnOn;
      });
    }
    await _loadDevices();
  }

  void _showPaperJsVisualization() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const PaperJsVisualization(),
      ),
    );
  }

  void _showTwoJsVisualization() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const TwoJsVisualization(),
      ),
    );
  }

  void _showAutomationRuleDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Connected Devices'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SwitchListTile(
                      title: const Text('All Devices'),
                      subtitle: Text('Control all devices (${connectedDevices.length})'),
                      value: _isAutomationEnabled,
                      onChanged: (bool value) async {
                        setDialogState(() {
                          _isAutomationEnabled = value;
                        });
                        await _toggleAllDevices(value);
                      },
                    ),
                    const Divider(),
                    ...connectedDevices.map((device) => SwitchListTile(
                      title: Text(device['deviceName'] ?? ''),
                      subtitle: Text(device['area'] ?? ''),
                      value: device['status'] ?? false,
                      onChanged: (bool value) async {
                        try {
                          await http.post(
                            Uri.parse(value ? webhookUrlOn : webhookUrlOff),
                          );

                          await http.put(
                            Uri.parse('$baseUrl/update/${device['_id']}'),
                            headers: {
                              'Content-Type': 'application/json',
                              'Authorization': 'Bearer $authToken',
                            },
                            body: json.encode({'status': value}),
                          );

                          setDialogState(() {
                            device['status'] = value;
                            _isAutomationEnabled = connectedDevices.every((d) => d['status'] == true);
                          });

                          await _loadDevices();
                        } catch (e) {
                          print('Error toggling device: $e');
                        }
                      },
                    )).toList(),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Workspace'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/bg.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FittedBox(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Workspace Controls',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.brown,
                        ),
                      ),
                      if (_isAutomationEnabled)
                        const Icon(Icons.auto_awesome, color: Colors.amber),
                    ],
                  ),
                ),
                if (_isAutomationEnabled && connectedDevices.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Connected Devices: ${connectedDevices.length}',
                    style: const TextStyle(color: Colors.brown),
                  ),
                ],
                const SizedBox(height: 16),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    childAspectRatio: 1.5,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    children: [
                      InkWell(
                        onTap: _showPaperJsVisualization,
                        child: const WorkspaceControlCard(
                          title: 'Paper.js Design',
                          icon: Icons.design_services,
                        ),
                      ),
                      InkWell(
                        onTap: _showTwoJsVisualization,
                        child: const WorkspaceControlCard(
                          title: 'Two.js Layout',
                          icon: Icons.view_in_ar,
                        ),
                      ),
                      InkWell(
                        onTap: _showAutomationRuleDialog,
                        child: WorkspaceControlCard(
                          title: 'Automation',
                          icon: Icons.auto_fix_high,
                          isEnabled: _isAutomationEnabled,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}