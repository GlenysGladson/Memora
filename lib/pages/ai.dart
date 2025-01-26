import 'package:flutter/material.dart';

class LearnWithAIPage extends StatefulWidget {
  // Constructor (if you need to pass data)
  const LearnWithAIPage({super.key});

  @override
  _LearnWithAIPageState createState() => _LearnWithAIPageState();
}

class _LearnWithAIPageState extends State<LearnWithAIPage> {
  // Define variables (state) here
  String _displayText = "Hello, Stateful World!";

  // Example function to modify state
  void _updateText() {
    setState(() {
      _displayText = "You updated the text!";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Stateful Widget Example"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _displayText,
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateText,
              child: Text("Update Text"),
            ),
          ],
        ),
      ),
    );
  }
}
