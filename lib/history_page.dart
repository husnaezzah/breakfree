import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HistoryPage extends StatelessWidget {
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
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'History',
              style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              'Drafts',
              style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 10),
            _buildHistoryCard(
              context,
              imageUrl: 'assets/images/draft_image.png',
              title: 'Physical Abuse',
              date: '30 May 2024',
              status: 'In Progress',
            ),
            SizedBox(height: 20),
            Text(
              'Recents',
              style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 10),
            _buildHistoryCard(
              context,
              imageUrl: 'assets/images/recent_image.png',
              title: 'Physical Abuse',
              date: '17 February 2024',
              status: 'Submitted',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryCard(
    BuildContext context, {
    required String imageUrl,
    required String title,
    required String date,
    required String status,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
            imageUrl,
            fit: BoxFit.cover,
            width: 60,
            height: 60,
          ),
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              date,
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
            ),
            Text(
              status,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: status == 'Submitted' ? Colors.green : Colors.orange,
              ),
            ),
          ],
        ),
        trailing: Icon(Icons.arrow_forward),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('View details of $title')),
          );
        },
      ),
    );
  }
}