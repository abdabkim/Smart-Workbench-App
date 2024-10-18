import 'package:flutter/material.dart';
import 'drilltoolscreen.dart';
import 'sawtoolscreen.dart';
import 'otherinputscreen.dart';

class CategorySelectionScreen extends StatelessWidget {
  const CategorySelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Tool Category'),
        backgroundColor: Colors.brown.shade50,
      ),
      body: Stack(
        children: [
          Image.asset(
            'assets/bg.jpg',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildCategoryButton(
                  context,
                  'Drill Tools',
                  Icons.build,
                      () => Navigator.push(context, MaterialPageRoute(builder: (context) => DrillToolScreen())),
                ),
                SizedBox(height: 16),
                _buildCategoryButton(
                  context,
                  'Saw Tools',
                  Icons.content_cut,
                      () => Navigator.push(context, MaterialPageRoute(builder: (context) => SawToolScreen())),
                ),
                SizedBox(height: 16),
                _buildCategoryButton(
                  context,
                  'Other Tools',
                  Icons.more_horiz,
                      () => Navigator.push(context, MaterialPageRoute(builder: (context) => OtherToolScreen())),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryButton(BuildContext context, String title, IconData icon, VoidCallback onPressed) {
    return ElevatedButton.icon(
      icon: Icon(icon, color: Colors.white),
      label: Text(title),
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.brown,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(vertical: 16),
        textStyle: TextStyle(fontSize: 18),
      ),
    );
  }
}