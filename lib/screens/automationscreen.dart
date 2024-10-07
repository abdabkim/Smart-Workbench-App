import 'package:flutter/material.dart';


import 'package:smart_workbench_app/widget/automationcard.dart';



class AutomationScreen extends StatelessWidget {
  const AutomationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Automation',
                style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.brown),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView(
                  children: const [
                    AutomationCard(
                        title: 'Morning Routine',
                        subtitle: 'Weekdays, 7:00 AM',
                        icon: Icons.wb_sunny),
                    AutomationCard(
                        title: 'Evening Shutdown',
                        subtitle: 'Daily, 8:00 PM',
                        icon: Icons.nights_stay),
                    AutomationCard(
                        title: 'Lunch Break',
                        subtitle: 'Weekdays, 12:00 PM',
                        icon: Icons.restaurant),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.brown,
        child: const Icon(Icons.add),
        onPressed: () {
          // Add new automation logic here
        },
      ),
    );
  }
}