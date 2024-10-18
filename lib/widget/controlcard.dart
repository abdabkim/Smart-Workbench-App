import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;




class ControlCard extends StatelessWidget {
  final String title;
  final IconData icon;

  const ControlCard({Key? key, required this.title, required this.icon})
      : super(key: key);

  // Function to trigger IFTTT event
  Future<void> triggerKasaSmartPlug(
      String eventName, String iftttKey, BuildContext context) async {
    final url = 'https://maker.ifttt.com/trigger/$eventName/with/key/2ZySHZZprglWIony9x0DF';
    final response = await http.get(Uri.parse(url));
    print(response.body);
    if (response.statusCode == 200) {
      print('Triggered successfully!');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('$title successful!')));
    } else {
      print('Failed to trigger.');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to trigger $title.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    // IFTTT key and event names (You can configure these based on your app logic)
    final String iftttKey =
        'https://maker.ifttt.com/trigger/smart_plug_on/with/key/2ZySHZZprglWIony9x0DF'; // Replace with your IFTTT key
    final String eventNameOn =
        'smart_plug_on'; // Event name to turn the plug on
    final String eventNameOff =
        'smart_plug_off'; // Event name to turn the plug off

    return Card(
      color: Colors.brown,
      child: InkWell(
        onTap: () async {
          await triggerKasaSmartPlug(
              eventNameOff, iftttKey, context); // Turn on plug print('Working');// Determine which action to perform based on the title
          // if (title.toLowerCase().contains("on")) {
          //   triggerKasaSmartPlug(
          //       eventNameOn, iftttKey, context); // Turn on plug
          // } else if (title.toLowerCase().contains("off")) {
          //   triggerKasaSmartPlug(
          //       eventNameOff, iftttKey, context); // Turn off plug
          // }
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: Colors.white),
            const SizedBox(height: 8),
            Text(title,
                style: const TextStyle(fontSize: 18, color: Colors.white)),
          ],
        ),
      ),
    );
  }
}
