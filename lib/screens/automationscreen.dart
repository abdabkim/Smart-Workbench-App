// automationscreen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';
import 'package:smart_workbench_app/models/automation_schedule.dart';
import 'package:smart_workbench_app/services/automation_service.dart';
import 'package:http/http.dart' as http;

class AutomationScreen extends StatefulWidget {
  const AutomationScreen({Key? key}) : super(key: key);

  @override
  State<AutomationScreen> createState() => _AutomationScreenState();
}

class _AutomationScreenState extends State<AutomationScreen> {
  final List<AutomationSchedule> _schedules = [];
  List<dynamic> allDevices = [];
  bool isLoading = true;
  String? authToken;
  @override
  void initState() {
    super.initState();
    _loadSchedules();
    _loadDevices();
  }

  Future<void> _loadDevices() async {
    final prefs = await SharedPreferences.getInstance();
    authToken = prefs.getString('token');

    if (authToken == null) {
      setState(() => isLoading = false);
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('http://192.168.0.10:8000/device/retrieveall'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          allDevices = List.from(data['devices'] ?? []);
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading devices: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> _loadSchedules() async {
    final prefs = await SharedPreferences.getInstance();
    final schedulesJson = prefs.getStringList('schedules') ?? [];
    setState(() {
      _schedules.clear();
      _schedules.addAll(
        schedulesJson.map((json) => AutomationSchedule.fromJson(jsonDecode(json))),
      );
    });
  }

  Future<void> _saveSchedules() async {
    final prefs = await SharedPreferences.getInstance();
    final schedulesJson = _schedules
        .map((schedule) => jsonEncode(schedule.toJson()))
        .toList();
    await prefs.setStringList('schedules', schedulesJson);
  }

  void _deleteSchedule(AutomationSchedule schedule) {
    setState(() {
      _schedules.remove(schedule);
    });
    _saveSchedules();
  }

  void _editSchedule(AutomationSchedule schedule) {
    showDialog(
      context: context,
      builder: (context) => ScheduleDialog(
        schedule: schedule,
        devices: allDevices.map((device) =>
        "${device['deviceName']} (${device['area']})").toList(),
      ),
    ).then((updatedSchedule) {
      if (updatedSchedule != null) {
        final index = _schedules.indexOf(schedule);
        setState(() {
          _schedules[index] = updatedSchedule;
        });
        _saveSchedules();
        AutomationService.scheduleAutomation(updatedSchedule);
      }
    });
  }

  void _addSchedule() {
    if (allDevices.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No devices available. Please add devices first.')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => ScheduleDialog(
        devices: allDevices.map((device) =>
        "${device['deviceName']} (${device['area']})").toList(),
      ),
    ).then((schedule) {
      if (schedule != null) {
        setState(() {
          _schedules.add(schedule);
        });
        _saveSchedules();
        AutomationService.scheduleAutomation(schedule);
      }
    });
  }

  void _toggleSchedule(AutomationSchedule schedule) {
    final index = _schedules.indexOf(schedule);
    final updatedSchedule = schedule.copyWith(action: !schedule.action);
    setState(() {
      _schedules[index] = updatedSchedule;
    });
    _saveSchedules();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
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
                const Text(
                  'Schedules',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.brown,
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView.builder(
                    itemCount: _schedules.length,
                    itemBuilder: (context, index) {
                      final schedule = _schedules[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          color: Colors.brown,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      schedule.name,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Switch(
                                          value: schedule.action,
                                          onChanged: (_) => _toggleSchedule(schedule),
                                          activeColor: Colors.white,
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.edit, color: Colors.white70),
                                          onPressed: () => _editSchedule(schedule),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete, color: Colors.white70),
                                          onPressed: () => _deleteSchedule(schedule),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Device: ${schedule.device}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.white70,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${schedule.getFormattedTime()} - ${schedule.getFormattedDays()}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: Container(
        width: MediaQuery.of(context).size.width - 32,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        child: ElevatedButton(
          onPressed: _addSchedule,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.brown,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'ADD SCHEDULE',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
// schedule_dialog.dart

class ScheduleDialog extends StatefulWidget {
  final List<String> devices;
  final AutomationSchedule? schedule;

  const ScheduleDialog({
    Key? key,
    required this.devices,
    this.schedule,
  }) : super(key: key);

  @override
  _ScheduleDialogState createState() => _ScheduleDialogState();
}

class _ScheduleDialogState extends State<ScheduleDialog> {
  late TextEditingController _nameController;
  late String _selectedDevice;
  late Set<DayOfWeek> _selectedDays;
  late TimeOfDay _selectedTime;
  late bool _action;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.schedule?.name ?? '');
    _selectedDevice = widget.schedule?.device ?? (widget.devices.isNotEmpty ? widget.devices.first : '');
    _selectedDays = widget.schedule?.days ?? {DayOfWeek.monday};
    _selectedTime = widget.schedule?.timeOfDay ?? TimeOfDay.now();
    _action = widget.schedule?.action ?? true;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.schedule == null ? 'Add Schedule' : 'Edit Schedule'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Schedule Name'),
            ),
            const SizedBox(height: 16),
            if (widget.devices.isNotEmpty) DropdownButtonFormField<String>(
              value: _selectedDevice,
              items: widget.devices.map((device) {
                return DropdownMenuItem(
                  value: device,
                  child: Text(device),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedDevice = value;
                  });
                }
              },
              decoration: const InputDecoration(labelText: 'Device'),
            ),
            const SizedBox(height: 16),
            const Text('Days'),
            Wrap(
              spacing: 8,
              children: DayOfWeek.values.map((day) {
                return FilterChip(
                  label: Text(day.toString().split('.').last.substring(0, 3)),
                  selected: _selectedDays.contains(day),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedDays.add(day);
                      } else if (_selectedDays.length > 1) {
                        _selectedDays.remove(day);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            ListTile(
              title: Text('Time: ${_selectedTime.format(context)}'),
              trailing: const Icon(Icons.access_time),
              onTap: () async {
                final TimeOfDay? time = await showTimePicker(
                  context: context,
                  initialTime: _selectedTime,
                );
                if (time != null) {
                  setState(() {
                    _selectedTime = time;
                  });
                }
              },
            ),
            SwitchListTile(
              title: Text(_action ? 'Turn On' : 'Turn Off'),
              value: _action,
              onChanged: (value) {
                setState(() {
                  _action = value;
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_nameController.text.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please enter a schedule name')),
              );
              return;
            }

            final schedule = AutomationSchedule(
              name: _nameController.text,
              device: _selectedDevice,
              days: _selectedDays,
              timeOfDay: _selectedTime,
              action: _action,
            );
            Navigator.of(context).pop(schedule);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}


// extensions.dart
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}

