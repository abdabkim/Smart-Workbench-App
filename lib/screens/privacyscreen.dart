// privacy_screen.dart
import 'package:flutter/material.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Privacy',
          style: TextStyle(
            color: Colors.brown.shade800,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.brown.shade800),
          onPressed: () => Navigator.pop(context),
        ),
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
                Text(
                  'Privacy Policy',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.brown.shade800,
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView(
                    children: [
                      _buildPrivacySection(
                        'Data Collection',
                        'Information about how we collect and use your data',
                        Icons.data_usage,
                      ),
                      const SizedBox(height: 8),
                      _buildPrivacySection(
                        'Data Security',
                        'How we protect your information',
                        Icons.security,
                      ),
                      const SizedBox(height: 8),
                      _buildPrivacySection(
                        'Your Rights',
                        'Understanding your privacy rights',
                        Icons.gavel,
                      ),
                      const SizedBox(height: 8),
                      _buildPrivacySection(
                        'Contact Us',
                        'Get in touch about privacy concerns',
                        Icons.contact_mail,
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

  Widget _buildPrivacySection(String title, String description, IconData icon) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        leading: Icon(icon, color: Colors.brown.shade800),
        title: Text(title),
        subtitle: Text(description),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Detailed information about $title will be displayed here. '
                  'This section can contain specific details, policies, and guidelines '
                  'related to this aspect of privacy.',
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
