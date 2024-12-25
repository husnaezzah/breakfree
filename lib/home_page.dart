import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'qa_page.dart'; // Import the Q&A page

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Color.fromARGB(255, 251, 247, 247), // Background app color changed to white
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 96, 32, 109), // AppBar remains purple
        title: Center( // Center the title
          child: Text(
            'BreakFree.',
            style: GoogleFonts.poppins(
              fontSize: 24, 
              fontWeight: FontWeight.bold, 
              color: Color.fromARGB(255, 251, 247, 247),
            ),
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Report Section
              Text(
                'Report',
                style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              Text(
                'File evidence to support your report',
                style: GoogleFonts.poppins(fontSize: 12),
              ),
              SizedBox(height: screenHeight * 0.02),

              // Capture Button with Responsive Width and Height
              Container(
                width: screenWidth * 0.8,
                height: screenHeight * 0.25,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/capture');
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: const Color.fromARGB(255, 96, 32, 109),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: EdgeInsets.all(10),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.camera_alt,
                        size: screenWidth * 0.1,
                        color: Colors.black,
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Capture',
                        style: GoogleFonts.roboto(
                          fontSize: 16,
                          color: Color.fromARGB(255, 114, 37, 129),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.03),

              // Resources Section
              Text(
                'Resources',
                style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              Text(
                'Get immediate help and support',
                style: GoogleFonts.poppins(fontSize: 12),
              ),
              SizedBox(height: screenHeight * 0.02),

              // Row for Q&A and Assistance Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildOptionButton(
                    context,
                    Icons.security,
                    'Q&A',
                    '/qa',
                    screenWidth,
                  ),
                  _buildOptionButton(
                    context,
                    Icons.medical_services,
                    'Assistance',
                    '/assistance', // Make sure to use '/assistance' route
                    screenWidth,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),

      // Centered SOS button with Text instead of Icon
      floatingActionButton: SizedBox(
        width: 70,
        height: 70,
        child: FloatingActionButton(
          onPressed: () {
            Navigator.pushNamed(context, '/sos');
          },
          backgroundColor: Colors.red,
          shape: CircleBorder(),
          child: Text(
            'SOS',
            style: GoogleFonts.poppins(
              fontSize: 20,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: BottomAppBar(
        color: Colors.white, // Bottom navigation bar color changed to white
        shape: CircularNotchedRectangle(),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.home, color: Color.fromARGB(255, 114, 37, 129)),
                onPressed: () {
                  Navigator.pushNamed(context, '/home');
                },
              ),
              SizedBox(width: 40), // Space for the SOS button in the center
              IconButton(
                icon: Icon(
                  Icons.person,
                  color: ModalRoute.of(context)?.settings.name == '/profile' ? Color(0xFFAD8FC6) : Colors.black,
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/profile');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionButton(BuildContext context, IconData icon, String label, String route, double screenWidth) {
    return Container(
      width: screenWidth * 0.35,
      height: screenWidth * 0.35,
      child: ElevatedButton(
        onPressed: () {
          if (route == '/qa') {
            Navigator.push(context, MaterialPageRoute(builder: (context) => QAPage()));
          } else if (route == '/assistance') {
            // Add the navigation logic for Assistance page here
            Navigator.pushNamed(context, '/assistance'); // Navigating to the Assistance page
          } else {
            Navigator.pushNamed(context, route);
          }
        },
        style: ElevatedButton.styleFrom(
          foregroundColor: const Color.fromARGB(255, 96, 32, 109), // Text and icon color
          backgroundColor: Colors.white, // Button background color
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30), // Rounded corners
          ),
          padding: EdgeInsets.all(10), // Padding inside the button
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: screenWidth * 0.1,
              color: Colors.black, // Icon color
            ),
            SizedBox(height: 10),
            Text(
              label,
              style: GoogleFonts.roboto(
                fontSize: 16,
                color: Color.fromARGB(255, 96, 32, 109), // Label color
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
