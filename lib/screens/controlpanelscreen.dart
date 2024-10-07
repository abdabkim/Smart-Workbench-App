import 'package:flutter/material.dart';
import 'package:smart_workbench_app/widget/controlcard.dart';


class ControlPanelScreen extends StatelessWidget {
  const ControlPanelScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Control Panel',
              style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                childAspectRatio: 1.5,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: const [
                  ControlCard(title: 'Power', icon: Icons.power_settings_new),
                  ControlCard(title: 'Lighting', icon: Icons.lightbulb_outline),
                  ControlCard(title: 'Temperature', icon: Icons.thermostat),
                  ControlCard(title: 'Fans', icon: Icons.air),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}