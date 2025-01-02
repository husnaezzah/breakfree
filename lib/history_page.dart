import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({Key? key}) : super(key: key);

  // Fetch reports based on their status (In Progress or Submitted)
  Stream<List<Map<String, dynamic>>> fetchReports(String status) async* {
    final categories = ['drafts', 'submissions']; // Adjusted for drafts and submissions
    List<Map<String, dynamic>> reports = [];

    for (String category in categories) {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('reports') // Root collection
          .doc(category) // Reference to 'drafts' or 'submissions'
          .collection('all_cases') // Subcollection for case reports
          .get();

      for (var doc in snapshot.docs) {
        reports.add({
          ...doc.data() as Map<String, dynamic>,
          'id': doc.id, // Include document ID
        });
      }
    }

    yield reports;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 251, 247, 247),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 96, 32, 109),
        title: Text(
          'BreakFree.',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 251, 247, 247),
          ),
        ),
        leading: ModalRoute.of(context)?.settings.name == '/profile'
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(context, '/profile', (route) => false);
                },
              ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Draft Section
              Text(
                "Draft",
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              StreamBuilder<List<Map<String, dynamic>>>(  // Fetch drafts here
                stream: fetchReports('drafts'),
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
                        caseNumber: report['case_number'] ?? 'Unknown Case Number', // Display case number
                        description: 'In Progress', // Display status
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/capture',
                            arguments: {'id': report['id']}, // Pass report data
                          );
                        },
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 20),
              // Recent Section
              Text(
                "Recent",
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              StreamBuilder<List<Map<String, dynamic>>>(  // Fetch submitted reports
                stream: fetchReports('submissions'),
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
                        caseNumber: report['case_number'] ?? 'Unknown Case Number', // Display case number
                        description: 'Submitted', // Display status
                        onTap: () {}, // No action for submitted reports
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
        color: Colors.white,
        shape: CircularNotchedRectangle(),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(
                  Icons.home,
                  color: ModalRoute.of(context)?.settings.name == '/home' ? Color(0xFFAD8FC6) : Colors.black,
                ),
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
                },
              ),
              SizedBox(width: 40),
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

  // Reusable widget for displaying reports
  Widget _buildHistoryBox({
    required String caseNumber,
    required String description,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.purple, width: 2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Case Number: $caseNumber",
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
    );
  }
}
