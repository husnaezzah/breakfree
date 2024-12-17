import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfilePage extends StatelessWidget {
  void _showHealthDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Health Details'),
          content: Text('Here, users can add weight, height, and health-related data.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _toggleSoundSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Settings'),
          content: Text('Sound settings toggled (Mute/Unmute).'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple[50],
      appBar: AppBar(
        backgroundColor: Colors.purple[100],
        title: Text(
          'BreakFree.',
          style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Features',
                style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // History Button
                  _buildProfileButton(
                    Icons.history,
                    'History',
                    () {
                      Navigator.pushNamed(context, '/history');
                    },
                  ),

                  // Health Button
                  _buildProfileButton(
                    Icons.favorite,
                    'Health',
                    () {
                      _showHealthDialog(context);
                    },
                  ),

                  // Settings Button
                  _buildProfileButton(
                    Icons.settings,
                    'Settings',
                    () {
                      _toggleSoundSettings(context);
                    },
                  ),
                ],
              ),
              SizedBox(height: 20),
              Text(
                'Information',
                style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              // Talian Kasih Card
              InformationCard(
                title: 'Talian Kasih 15999',
                description:
                    'Talian Kasih provides a 24-hour helpline for counseling and support for domestic violence survivors. Call 15999 or WhatsApp +6019-261 5999 for assistance.',
              ),
              SizedBox(height: 10),
              // WAO Card
              InformationCard(
                title: 'Women’s Aid Organization (WAO)',
                description:
                    'WAO provides shelter, counseling, and support for domestic violence survivors in Malaysia. Visit wao.org.my or call +603-7956 3488.',
              ),
              SizedBox(height: 10),
              // Police Emergency Assistance
              InformationCard(
                title: 'Police Emergency Assistance',
                description:
                    'Contact the nearest police station or call 999 in case of immediate danger or threat.',
              ),
              SizedBox(height: 10),
              // LPPKN Counseling Services
              InformationCard(
                title: 'LPPKN Counseling Services',
                description:
                    'The National Population and Family Development Board (LPPKN) offers free counseling services for those affected by domestic violence. Call 03-2693 7555 for help.',
              ),
            ],
          ),
        ),
      ),
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
        color: Colors.purple[100],
        shape: CircularNotchedRectangle(),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.home, color: Colors.purple),
                onPressed: () {
                  Navigator.pushNamed(context, '/home');
                },
              ),
              SizedBox(width: 40), // Space for the SOS button in the center
              IconButton(
                icon: Icon(Icons.person),
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

  Widget _buildProfileButton(IconData icon, String label, Function onPressed) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () => onPressed(),
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.purple,
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            padding: EdgeInsets.all(20),
          ),
          child: Icon(
            icon,
            size: 40,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 10),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.purple,
          ),
        ),
      ],
    );
  }
}

class InformationCard extends StatelessWidget {
  final String title;
  final String description;

  const InformationCard({
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.purple, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 5),
          Text(
            description,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
