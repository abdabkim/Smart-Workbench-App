import 'package:flutter/material.dart';
import 'package:smart_workbench_app/widget/monitoringcard.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class MonitoringScreen extends StatefulWidget {
  const MonitoringScreen({Key? key}) : super(key: key);

  @override
  State<MonitoringScreen> createState() => _MonitoringScreenState();
}

class _MonitoringScreenState extends State<MonitoringScreen> {
  Map<String, dynamic> sensorData = {
    'temperature': '22°C',
    'humidity': '45%',
    'powerConsumption': '120W',
    'motion': 'No motion detected'
  };
  Timer? _timer;
  final String baseUrl = 'http://192.168.0.6:8000/deiceStatus';

  @override
  void initState() {
    super.initState();
    fetchSensorData();
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      fetchSensorData();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> fetchSensorData() async {
    try {
      final Uri uri = Uri.parse('$baseUrl/device/devicestatus');
      final response = await http.get(uri).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('Request timed out');
        },
      );

      if (response.statusCode == 200) {
        final decodedData = json.decode(response.body);
        setState(() {
          sensorData = decodedData;
        });
      } else {
        print('Error: Server returned status code ${response.statusCode}');
      }
    } on TimeoutException catch (e) {
      print('Request timed out: $e');
    } catch (e) {
      print('Error fetching sensor data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Monitoring',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.brown,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  MonitoringCard(
                    title: 'Temperature',
                    value: sensorData['temperature'] ?? '22°C',
                    icon: Icons.thermostat,
                  ),
                  MonitoringCard(
                    title: 'Humidity',
                    value: sensorData['humidity'] ?? '45%',
                    icon: Icons.water_drop,
                  ),
                  MonitoringCard(
                    title: 'Power Usage',
                    value: sensorData['powerConsumption'] ?? '120W',
                    icon: Icons.electric_bolt,
                  ),
                  MonitoringCard(
                    title: 'Motion',
                    value: sensorData['motion'] ?? 'No motion detected',
                    icon: Icons.motion_photos_on,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}