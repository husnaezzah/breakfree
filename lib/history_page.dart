import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({Key? key}) : super(key: key);

  // Fetch reports from drafts or submissions
  Stream<QuerySnapshot> fetchReports(String collection) {
    return FirebaseFirestore.instance
        .collection('reports')
        .doc(collection)
        .collection('all_cases')
        .snapshots();
  }

  // Delete a specific report
  Future<void> deleteReport(String collection, String docId) async {
    await FirebaseFirestore.instance
        .collection('reports')
        .doc(collection)
        .collection('all_cases')
        .doc(docId)
        .delete();
  }

  // Move draft to submissions upon completion
  Future<void> moveDraftToRecent(Map<String, dynamic> reportData, String docId) async {
    await FirebaseFirestore.instance
        .collection('reports')
        .doc('submissions')
        .collection('all_cases')
        .add(reportData);

    await deleteReport('drafts', docId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 251, 247, 247),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 96, 32, 109),
        title: Text(
          'BreakFree.',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: const Color.fromARGB(255, 251, 247, 247),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drafts Section
              Text(
                "Drafts",
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              StreamBuilder<QuerySnapshot>(
                stream: fetchReports('drafts'),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final drafts = snapshot.data?.docs ?? [];
                  return drafts.isEmpty
                      ? Text(
                          'No drafts available.',
                          style: GoogleFonts.poppins(fontSize: 14),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: drafts.length,
                          itemBuilder: (context, index) {
                            final draft = drafts[index];
                            final reportData = draft.data() as Map<String, dynamic>;

                            return GestureDetector(
                              onTap: () {
                                // Pass the stored report data and case ID to the capture page
                                Navigator.pushNamed(
                                  context,
                                  '/capture',
                                  arguments: {
                                    'reportData': reportData,
                                    'caseId': draft.id,
                                  },
                                );
                              },
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                    color: const Color.fromARGB(255, 96, 32, 109),
                                    width: 2,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Case Number: ${reportData['case_number'] ?? 'Unknown'}",
                                          style: GoogleFonts.poppins(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          "Status: In Progress",
                                          style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () => deleteReport('drafts', draft.id),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                },
              ),
              const SizedBox(height: 20),

              // Recent Submissions Section
              Text(
                "Recent Submissions",
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              StreamBuilder<QuerySnapshot>(
                stream: fetchReports('submissions'),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final submissions = snapshot.data?.docs ?? [];
                  return submissions.isEmpty
                      ? Text(
                          'No recent submissions available.',
                          style: GoogleFonts.poppins(fontSize: 14),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: submissions.length,
                          itemBuilder: (context, index) {
                            final submission = submissions[index];
                            final reportData = submission.data() as Map<String, dynamic>;

                            return Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color: const Color.fromARGB(255, 96, 32, 109),
                                  width: 2,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Case Number: ${reportData['case_number'] ?? 'Unknown'}",
                                        style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        "Status: Submitted",
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () =>
                                        deleteReport('submissions', submission.id),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
