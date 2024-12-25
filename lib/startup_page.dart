import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Import Google Fonts

class StartupPage extends StatefulWidget {
  @override
  _StartupPageState createState() => _StartupPageState();
}

class _StartupPageState extends State<StartupPage> {
  @override
  void initState() {
    super.initState();

    // Navigate to the HomePage after 3 seconds
    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, '/home');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFD8CFE8), // Light purple background color
      body: Center(
        child: Container(
          // Container holding all elements
          child: Padding(
            padding: const EdgeInsets.all(20), // Padding around the content inside the container
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start, // Align text to the left
              children: [
                // Logo Image
                Image.asset(
                  'assets/logo.png', // Path to the logo image
                  width: 200, // Logo size to match the image
                  height: 200,
                ),

                // "Break" Text
                Text(
                  'Break',
                  style: GoogleFonts.poppins(
                    fontSize: 55, // Font size for "Break"
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.0, // Adjust the line height to eliminate gap
                  ),
                ),

                // "Free." Text
                Text(
                  'Free.',
                  style: GoogleFonts.poppins(
                    fontSize: 55, // Font size for "Free."
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.0, // Adjust the line height to eliminate gap
                  ),
                ),

                SizedBox(height: 10), // Small gap between the title and subtitle

                // Subtitle Text
                Text(
                  'BUILDING BONDS, BREAKING CHAINS.',
                  style: GoogleFonts.poppins(
                    fontSize: 9, // Font size for the tagline
                    color: Colors.white70, // Subtle color
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}