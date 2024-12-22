import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({Key? key}) : super(key: key);

  // Fetch reports from Firestore based on status
  Stream<List<Map<String, dynamic>>> fetchReports(String status) async* {
    final categories = ['potential_physical_abuse', 'potential_psychological_abuse', 'other_potential_forms_of_violence'];
    List<Map<String, dynamic>> reports = [];

    for (String category in categories) {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('reports')
          .doc(category)
          .collection(status == 'In Progress' ? 'drafts' : 'submissions') // Updated collection
          .get();

      for (var doc in snapshot.docs) {
        reports.add(doc.data() as Map<String, dynamic>);
      }
    }

    yield reports;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple[50],
      appBar: AppBar(
        backgroundColor: Colors.purple[100],
        centerTitle: true,
        title: Text(
          'BreakFree.',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // History Title
              Text(
                "History",
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 20),

              // In Progress Section
              Text(
                "Draft",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
              ),
            ),
              const SizedBox(height: 10),
              StreamBuilder<List<Map<String, dynamic>>>(
                stream: fetchReports('In Progress'), // Fetch "In Progress" reports
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final inProgressReports = snapshot.data ?? [];
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: inProgressReports.length,
                    itemBuilder: (context, index) {
                      final report = inProgressReports[index];
                      return _buildHistoryBox(
                        imageUrl: report['image_url'], // Retrieve image URL from Firestore
                        title: report['label'] ?? 'Other Potential Forms of Violence',
                        description: report['status'] ?? '',
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 20),

              // Recents Section
              Text(
                "Recent",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 10),
              StreamBuilder<List<Map<String, dynamic>>>(
                stream: fetchReports('Submitted'), // Fetch "Submitted" reports
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final recentReports = snapshot.data ?? [];
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: recentReports.length,
                    itemBuilder: (context, index) {
                      final report = recentReports[index];
                      return _buildHistoryBox(
                        imageUrl: report['image_url'], // Retrieve image URL from Firestore
                        title: report['label'] ?? 'Other Potential Forms of Violence',
                        description: report['status'] ?? '',
                      );
                    },
                  );
                },
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
          shape: const CircleBorder(),
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
        shape: const CircularNotchedRectangle(),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(
                Icons.home,
                color: Colors.black),
                onPressed: () {
                  Navigator.pushNamed(context, '/home');
                },
              ),
              const SizedBox(width: 40),
              IconButton(
                icon: const Icon(
                Icons.person,
                color: Colors.black),
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

  // Reusable Widget for History Boxes
  Widget _buildHistoryBox({
    required String? imageUrl,
    required String title,
    required String description,
  }) {
    final String imageToDisplay = imageUrl ?? 'https://example.com/default-image.png';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.purple, width: 2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image section
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: imageUrl != null
                ? Image.network(imageToDisplay, fit: BoxFit.cover)
                : Icon(
                    Icons.image_outlined,
                    size: 35,
                    color: Colors.purple[300],
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
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
                const SizedBox(height: 5),
                Text(
                  description,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}