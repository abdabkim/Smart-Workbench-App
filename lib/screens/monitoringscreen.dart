import 'package:flutter/material.dart';
import 'package:smart_workbench_app/widget/monitoringcard.dart';



class MonitoringScreen extends StatelessWidget {
  const MonitoringScreen({Key? key}) : super(key: key);

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
                  color: Colors.brown),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: const [
                  MonitoringCard(
                      title: 'Temperature',
                      value: '22°C',
                      icon: Icons.thermostat),
                  MonitoringCard(
                      title: 'Humidity', value: '45%', icon: Icons.water_drop),
                  MonitoringCard(
                      title: 'Power Usage',
                      value: '120W',
                      icon: Icons.electric_bolt),
                  MonitoringCard(
                      title: 'Motion',
                      value: 'No motion detected',
                      icon: Icons.motion_photos_on),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}