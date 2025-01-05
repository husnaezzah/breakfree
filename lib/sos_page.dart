import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';

class SOSPage extends StatefulWidget {
  @override
  _SOSPageState createState() => _SOSPageState();
}

class _SOSPageState extends State<SOSPage> {
  int countdown = 10; // Countdown timer in seconds
  Timer? timer;

  @override
  void initState() {
    super.initState();
    // Automatically display the dialog and start the countdown when the page loads
    WidgetsBinding.instance.addPostFrameCallback((_) => startCountdown(context));
  }

  void startCountdown(BuildContext context) {
    countdown = 15; // Reset countdown to 15 seconds

    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (countdown > 0) {
        setState(() {
          countdown--; // Decrease countdown
        });
      } else {
        timer.cancel(); // Stop timer
        Navigator.of(context).pop(); // Close dialog
        initiateCall(); // Call once countdown hits 0
      }

      // Show the dialog again with the updated countdown
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(
                'Activate the SOS button?',
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center, // Center the title
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'The SOS button will automatically activate when the time is up.',
                    style: GoogleFonts.poppins(),
                    textAlign: TextAlign.center, // Center the message
                  ),
                  SizedBox(height: 20),
                  // Countdown text centered
                  Text(
                    '$countdown seconds remaining',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                    textAlign: TextAlign.center, // Center the countdown
                  ),
                  SizedBox(height: 20),
                  // Progress bar to visually show countdown
                  LinearProgressIndicator(
                    value: countdown / 15, // Value reduces as countdown progresses
                    color: Colors.red,
                    backgroundColor: Colors.grey[300],
                  ),
                ],
              ),
              actions: [
                // Center the buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {
                        timer.cancel(); // Stop the timer
                        Navigator.of(context).pop(); // Close the dialog
                        Navigator.pushNamedAndRemoveUntil(
                            context, '/home', (route) => false); // Navigate to home and remove history
                      },
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.poppins(color: Colors.black),
                      ),
                    ),
                    SizedBox(width: 10), // Spacing between buttons
                    ElevatedButton(
                      onPressed: () {
                        timer.cancel(); // Stop the timer
                        Navigator.of(context).pop(); // Close the dialog
                        initiateCall(); // Initiate the call
                      },
                      child: Text(
                        'Activate',
                        style: GoogleFonts.poppins(color: Colors.black),
                      ),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      }
    });
  }

  Future<void> initiateCall() async {
    final Uri phoneNumber = Uri(scheme: 'tel', path: '15999'); // Correct phone number format
    if (await canLaunchUrl(phoneNumber)) {
      await launchUrl(phoneNumber);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Could not activate SOS functionality")),
      );
    }
  }

  @override
  void dispose() {
    timer?.cancel(); // Cancel the timer if the widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple[50],
      body: Stack(
        children: [
          // Background SOS logo
          Center(
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  'SOS',
                  style: GoogleFonts.poppins(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
