import 'package:flutter/material.dart';
import 'package:smart_workbench_app/screens/controlpanelscreen.dart';
import 'package:smart_workbench_app/screens/smartplugsetupscreen.dart';
import 'package:smart_workbench_app/screens/smartworkspacescreen.dart';
import 'package:smart_workbench_app/widget/devicecard.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:permission_handler/permission_handler.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  String _lastWords = '';
  bool _isListening = false;
  double _confidence = 0;

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    final status = await Permission.microphone.request();
    if (status.isGranted) {
      try {
        _speechEnabled = await _speechToText.initialize(
          onError: (error) {
            print('Speech recognition error: $error');
            if (error.errorMsg == 'error_speech_timeout') {
              _handleTimeout();
            }
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${error.errorMsg}'),
                backgroundColor: Colors.red,
              ),
            );
          },
          debugLogging: true,
        );
        setState(() {});
      } catch (e) {
        print('Failed to initialize speech recognition: $e');
        _speechEnabled = false;
        setState(() {});
      }
    } else {
      print('Microphone permission denied');
      _speechEnabled = false;
      setState(() {});
    }
  }

  void _startListening() async {
    if (!_speechEnabled) {
      await _initSpeech();
    }

    if (_speechEnabled) {
      try {
        await _speechToText.listen(
          onResult: _onSpeechResult,
          listenFor: const Duration(seconds: 30),  // Increased listening time
          pauseFor: const Duration(seconds: 5),    // Increased pause threshold
          localeId: "en_US",
          cancelOnError: false,
          partialResults: true,
          onSoundLevelChange: (level) {
            // Update UI based on sound level if needed
            setState(() {
              // Add visual feedback that sound is being detected
              print('Sound level detected: $level');
            });
          },
        );

        setState(() {
          _isListening = true;
          _lastWords = ''; // Clear previous results when starting new listening session
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Listening... Speak clearly into the microphone'),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        print('Error starting speech recognition: $e');
        setState(() {
          _isListening = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error starting voice recognition: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      // Speech recognition is not enabled
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Speech recognition is not available. Please check permissions.'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }
  void _handleTimeout() {
    _stopListening();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('No speech detected. Please try again.'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _stopListening() async {
    try {
      await _speechToText.stop();
      setState(() {
        _isListening = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Stopped listening'),
          duration: Duration(seconds: 1),
        ),
      );
    } catch (e) {
      print('Error stopping speech recognition: $e');
    }
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _lastWords = result.recognizedWords.toLowerCase();
      _confidence = result.confidence;
      _processCommand(_lastWords);
    });
  }

  void _processCommand(String command) {
    print('Processing command: $command');

    if (command.contains('workspace') || command.contains('smart workspace')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Opening Smart Workspace...')),
      );
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const SmartWorkspaceScreen(),
        ),
      );
    } else if (command.contains('control panel') || command.contains('panel')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Opening Control Panel...')),
      );
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ControlPanelScreen(
            deviceType: 'Control Panel',
            category: 'Power Device',
            area: 'Workshop',
          ),
        ),
      );
    } else if (command.contains('add device') || command.contains('new device')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Opening Add Device...')),
      );
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const PlugInScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/bg.jpg"),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Welcome Home!',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.brown.shade800,
                          ),
                        ),
                        Column(
                          children: [
                            IconButton(
                              icon: Icon(_isListening ? Icons.mic : Icons.mic_none),
                              onPressed: _speechEnabled
                                  ? (_isListening ? _stopListening : _startListening)
                                  : null,
                              color: _isListening ? Colors.red : Colors.brown.shade800,
                              iconSize: 28,
                            ),
                            if (_isListening)
                              Text(
                                'Listening...',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                    if (_lastWords.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.only(top: 10),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.brown.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Heard: $_lastWords',
                              style: TextStyle(
                                color: Colors.brown.shade800,
                                fontSize: 14,
                              ),
                            ),
                            if (_confidence > 0)
                              Text(
                                'Confidence: ${(_confidence * 100).toStringAsFixed(1)}%',
                                style: TextStyle(
                                  color: Colors.brown.shade600,
                                  fontSize: 12,
                                ),
                              ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: ListView(
                        children: [
                          DeviceCard(
                            title: 'Smart Workspace',
                            icon: Icons.work_outline,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SmartWorkspaceScreen(),
                                ),
                              );
                            },
                          ),
                          DeviceCard(
                            title: 'Control Panel',
                            icon: Icons.dashboard_outlined,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ControlPanelScreen(
                                    deviceType: 'Control Panel',
                                    category: 'Power Device',
                                    area: 'Workshop',
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.brown,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
          tooltip: 'Add New Device',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const PlugInScreen(),
              ),
            );
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}