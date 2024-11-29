import 'package:flutter/material.dart';
import 'dart:async';
import 'package:smart_workbench_app/widget/workspacecontrolcard.dart';
import 'package:smart_workbench_app/widget/paper_js_visualization.dart';
import 'package:smart_workbench_app/widget/two_js_visualization.dart';

class SmartWorkspaceScreen extends StatefulWidget {
  const SmartWorkspaceScreen({super.key});

  @override
  State<SmartWorkspaceScreen> createState() => _SmartWorkspaceScreenState();
}

class _SmartWorkspaceScreenState extends State<SmartWorkspaceScreen> {
  double _currentHeight = 0.0; // Starting height in cm
  bool _isAutomationEnabled = false;
  bool _isHeightAdjustmentEnabled = false;
  bool _isPowerManagementEnabled = false;
  bool _isLightingControlEnabled = false;
  Timer? _heightAdjustmentTimer;
  Timer? _powerTimer;
  Timer? _lightingTimer;
  double _lightingLevel = 50;
  bool _isPowerOn = true;
  String _lastAutomationAction = '';

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

  void _startAutomation() {
    // Height adjustment automation
    if (_isHeightAdjustmentEnabled) {
      _heightAdjustmentTimer?.cancel();
      _heightAdjustmentTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
        if (!_isAutomationEnabled || !_isHeightAdjustmentEnabled) {
          timer.cancel();
          return;
        }
        _adjustHeight();
      });
    }

    // Power management automation
    if (_isPowerManagementEnabled) {
      _powerTimer?.cancel();
      _powerTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
        if (!_isAutomationEnabled || !_isPowerManagementEnabled) {
          timer.cancel();
          return;
        }
        _managePower();
      });
    }

    // Lighting automation
    if (_isLightingControlEnabled) {
      _lightingTimer?.cancel();
      _lightingTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
        if (!_isAutomationEnabled || !_isLightingControlEnabled) {
          timer.cancel();
          return;
        }
        _adjustLighting();
      });
    }
  }

  void _stopAutomation() {
    _heightAdjustmentTimer?.cancel();
    _powerTimer?.cancel();
    _lightingTimer?.cancel();
  }

  void _adjustHeight() {
    final hour = DateTime.now().hour;
    setState(() {
      // Simulate height adjustment based on time
      if (hour >= 9 && hour < 12) {
        _currentHeight = 110; // Standing height
        _showAutomationNotification('Adjusted to standing height for morning work');
      } else if (hour >= 14 && hour < 17) {
        _currentHeight = 110; // Standing height
        _showAutomationNotification('Adjusted to standing height for afternoon work');
      } else {
        _currentHeight = 65; // Sitting height
        _showAutomationNotification('Adjusted to sitting height');
      }
    });
  }

  void _managePower() {
    final hour = DateTime.now().hour;
    setState(() {
      // Simulate power management
      if (hour >= 18 || hour < 7) {
        _isPowerOn = false;
        _showAutomationNotification('Power saving mode activated');
      } else {
        _isPowerOn = true;
        _showAutomationNotification('Power restored to normal mode');
      }
    });
  }

  void _adjustLighting() {
    final hour = DateTime.now().hour;
    setState(() {
      // Simulate lighting adjustment
      if (hour >= 17 || hour < 6) {
        _lightingLevel = 80;
        _showAutomationNotification('Adjusted lighting for evening work');
      } else if (hour >= 12 && hour < 14) {
        _lightingLevel = 40;
        _showAutomationNotification('Reduced lighting for midday');
      } else {
        _lightingLevel = 60;
        _showAutomationNotification('Set standard lighting levels');
      }
    });
  }

  void _showAutomationNotification(String message) {
    setState(() {
      _lastAutomationAction = message;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showAutomationRuleDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Automation Rules'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SwitchListTile(
                      title: const Text('Enable All Automation'),
                      subtitle: const Text('Master control for all automation rules'),
                      value: _isAutomationEnabled,
                      onChanged: (bool value) {
                        setState(() {
                          _isAutomationEnabled = value;
                          if (value) {
                            _startAutomation();
                          } else {
                            _stopAutomation();
                          }
                        });
                        this.setState(() {});
                      },
                    ),
                    const Divider(),
                    SwitchListTile(
                      title: const Text('Height Adjustment'),
                      subtitle: const Text('Auto-adjust between sitting and standing'),
                      value: _isHeightAdjustmentEnabled,
                      onChanged: _isAutomationEnabled ? (bool value) {
                        setState(() {
                          _isHeightAdjustmentEnabled = value;
                          if (value && _isAutomationEnabled) {
                            _startAutomation();
                          }
                        });
                      } : null,
                    ),
                    SwitchListTile(
                      title: const Text('Power Management'),
                      subtitle: const Text('Auto power management system'),
                      value: _isPowerManagementEnabled,
                      onChanged: _isAutomationEnabled ? (bool value) {
                        setState(() {
                          _isPowerManagementEnabled = value;
                          if (value && _isAutomationEnabled) {
                            _startAutomation();
                          }
                        });
                      } : null,
                    ),
                    SwitchListTile(
                      title: const Text('Lighting Control'),
                      subtitle: const Text('Auto-adjust workspace lighting'),
                      value: _isLightingControlEnabled,
                      onChanged: _isAutomationEnabled ? (bool value) {
                        setState(() {
                          _isLightingControlEnabled = value;
                          if (value && _isAutomationEnabled) {
                            _startAutomation();
                          }
                        });
                      } : null,
                    ),
                    const Divider(),
                    if (_lastAutomationAction.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Last Action: $_lastAutomationAction',
                          style: const TextStyle(
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
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

  void _showHeightControl() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Height Control'),
          content: SingleChildScrollView(  // Added ScrollView
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Current Height: ${_currentHeight.toStringAsFixed(1)} cm',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Slider(
                  value: _currentHeight,
                  min: 0.0,
                  max: 250.0,
                  divisions: 250,
                  label: '${_currentHeight.round()} cm',
                  onChanged: (double value) {
                    setState(() {
                      _currentHeight = value;
                    });
                  },
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Min\n(0cm)',
                          style: TextStyle(fontSize: 12),
                          textAlign: TextAlign.center
                      ),
                      Text('Max\n(250cm)',
                          style: TextStyle(fontSize: 12),
                          textAlign: TextAlign.center
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Wrap(  // Changed from Row to Wrap
                  spacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    SizedBox(
                      width: 120,  // Fixed width for buttons
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _currentHeight = 65;
                          });
                        },
                        child: const Text('Sitting Preset'),
                      ),
                    ),
                    SizedBox(
                      width: 120,  // Fixed width for buttons
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _currentHeight = 110;
                          });
                        },
                        child: const Text('Standing Preset'),
                      ),
                    ),
                  ],
                ),
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
  }
  @override
  void dispose() {
    _stopAutomation();
    super.dispose();
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
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
              if (_isAutomationEnabled) ...[
                const SizedBox(height: 8),
                Text(
                  'Height: ${_currentHeight.toStringAsFixed(1)} cm | '
                      'Light: ${_lightingLevel.toStringAsFixed(0)}% | '
                      'Power: ${_isPowerOn ? "On" : "Off"}',
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
                      child: const WorkspaceControlCard(
                        title: 'Automation Rules',
                        icon: Icons.auto_fix_high,
                      ),
                    ),
                    InkWell(
                      onTap: _showHeightControl,
                      child: const WorkspaceControlCard(
                        title: 'Height Control',
                        icon: Icons.height,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}