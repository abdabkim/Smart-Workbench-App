import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';
import 'package:smart_workbench_app/models/automation_schedule.dart';
import 'package:http/http.dart' as http;

class AutomationScreen extends StatefulWidget {
  const AutomationScreen({Key? key}) : super(key: key);

  @override
  State<AutomationScreen> createState() => _AutomationScreenState();
}

class _AutomationScreenState extends State<AutomationScreen> {
  final String baseUrl = 'http://192.168.0.11:8000/device';
  List<AutomationSchedule> _schedules = [];
  List<dynamic> allDevices = [];
  bool isLoading = true;
  String? authToken;
  Timer? _deviceRefreshTimer;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _deviceRefreshTimer = Timer.periodic(
      const Duration(seconds: 5),
          (_) => _refreshDevices(),
    );
  }

  @override
  void dispose() {
    _deviceRefreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    try {
      // Get token first
      final prefs = await SharedPreferences.getInstance();
      authToken = prefs.getString('token');

      if (authToken == null) {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
          _showError('Authentication token not found');
        }
        return;
      }
      await Future.wait([
        _refreshDevices(),
        _loadSchedules(),
      ]);

      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error in initial load: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        _showError('Failed to load data');
      }
    }
  }

  Future<void> _refreshDevices() async {
    if (!mounted || authToken == null) return;

    try {
      print('Refreshing devices...'); // Debug print
      final response = await http.get(
        Uri.parse('$baseUrl/retrieveall'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      );

      print('Response status: ${response.statusCode}'); // Debug print
      print('Response body: ${response.body}'); // Debug print

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final devices = List.from(data['devices'] ?? []);

        if (mounted) {
          setState(() {
            allDevices = devices;
          });
        }
        print('Devices loaded: ${devices.length}'); // Debug print
      } else {
        print('Error loading devices: ${response.statusCode}');
      }
    } catch (e) {
      print('Error refreshing devices: $e');
    }
  }

  Future<void> _loadSchedules() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final schedulesJson = prefs.getStringList('schedules') ?? [];

      if (mounted) {
        setState(() {
          _schedules = schedulesJson
              .map((json) => AutomationSchedule.fromJson(jsonDecode(json)))
              .toList();
        });
      }
    } catch (e) {
      print('Error loading schedules: $e');
    }
  }

  Future<void> _saveSchedules() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final schedulesJson = _schedules
          .map((schedule) => jsonEncode(schedule.toJson()))
          .toList();
      await prefs.setStringList('schedules', schedulesJson);
    } catch (e) {
      print('Error saving schedules: $e');
      _showError('Failed to save schedule');
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _addSchedule() {
    if (allDevices.isEmpty) {
      _showError('No devices available. Please check your connection.');
      _refreshDevices(); // Try to refresh devices when adding schedule
      return;
    }

    showDialog(
      context: context,
      builder: (context) => _ScheduleDialog(
        devices: allDevices
            .map((device) => "${device['deviceName']} (${device['area']})")
            .toList(),
      ),
    ).then((schedule) async {
      if (schedule != null && mounted) {
        setState(() {
          _schedules.add(schedule);
        });
        await _saveSchedules();
      }
    });
  }

  Future<void> _deleteSchedule(AutomationSchedule schedule) async {
    setState(() {
      _schedules.remove(schedule);
    });
    await _saveSchedules();
  }

  void _editSchedule(AutomationSchedule schedule) {
    if (allDevices.isEmpty) {
      _showError('No devices available. Please check your connection.');
      _refreshDevices(); // Try to refresh devices when editing schedule
      return;
    }

    showDialog(
      context: context,
      builder: (context) => _ScheduleDialog(
        schedule: schedule,
        devices: allDevices
            .map((device) => "${device['deviceName']} (${device['area']})")
            .toList(),
      ),
    ).then((updatedSchedule) async {
      if (updatedSchedule != null && mounted) {
        final index = _schedules.indexOf(schedule);
        setState(() {
          _schedules[index] = updatedSchedule;
        });
        await _saveSchedules();
      }
    });
  }

  void _toggleSchedule(AutomationSchedule schedule) async {
    final index = _schedules.indexOf(schedule);
    final updatedSchedule = schedule.copyWith(action: !schedule.action);
    setState(() {
      _schedules[index] = updatedSchedule;
    });
    await _saveSchedules();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Schedule',
          style: TextStyle(
            color: Colors.brown,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
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
            child: isLoading
                ? const Center(child: CircularProgressIndicator(color: Colors.brown))
                : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Schedules',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.brown,
                      ),
                    ),
                    Text(
                      'Devices: ${allDevices.length}',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.brown,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: _schedules.isEmpty
                      ? const Center(
                    child: Text(
                      'No schedules yet',
                      style: TextStyle(
                        color: Colors.brown,
                        fontSize: 18,
                      ),
                    ),
                  )
                      : ListView.builder(
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
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        schedule.name,
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                        overflow:
                                        TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Switch(
                                          value: schedule.action,
                                          onChanged: (_) =>
                                              _toggleSchedule(
                                                  schedule),
                                          activeColor: Colors.white,
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                              Icons.edit,
                                              color: Colors.white70),
                                          onPressed: () =>
                                              _editSchedule(schedule),
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                              Icons.delete,
                                              color: Colors.white70),
                                          onPressed: () =>
                                              _deleteSchedule(
                                                  schedule),
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
class _ScheduleDialog extends StatefulWidget {
  final List<String> devices;
  final AutomationSchedule? schedule;

  const _ScheduleDialog({
    Key? key,
    required this.devices,
    this.schedule,
  }) : super(key: key);

  @override
  State<_ScheduleDialog> createState() => _ScheduleDialogState();
}

class _ScheduleDialogState extends State<_ScheduleDialog> {
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
  void dispose() {
    _nameController.dispose();
    super.dispose();
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
}