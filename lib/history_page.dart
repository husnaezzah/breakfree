import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:developer' as devtools;

class HistoryPage extends StatelessWidget {
  const HistoryPage({Key? key}) : super(key: key);

  // Fetch reports from drafts or submissions
  Stream<QuerySnapshot> fetchReports(String collection) {
    return FirebaseFirestore.instance
        .collection('reports')
        .doc(collection)
        .collection('anon_penguin')
        .snapshots();
  }

  // Delete a specific report with confirmation dialog
  Future<void> deleteReport(BuildContext context, String collection, String docId) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Delete Report?',
            style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          content: Text(
            'This will delete the report case permanently. You cannot undo this action.',
            style: GoogleFonts.poppins(fontSize: 13),
          ),
          actions: [
           TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
            style: TextButton.styleFrom(
              foregroundColor: const Color.fromARGB(255, 96, 32, 109),  // Text color for 'Cancel' button
            ),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(fontSize: 13),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop(); // Close the dialog after deletion

              // Proceed with deletion if confirmed
              await FirebaseFirestore.instance
                  .collection('reports')
                  .doc(collection)
                  .collection('anon_penguin')
                  .doc(docId)
                  .delete();
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.white, backgroundColor: Colors.red, // Text color for 'Delete' button
            ) ,
            child: Text(
              'Delete',
              style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ),

          ],
        );
      },
    );
  }

  // Move draft to submissions upon completion with context parameter
Future<void> moveDraftToRecent(BuildContext context, Map<String, dynamic> reportData, String docId) async {
  // Move the report data to 'submissions' collection
  await FirebaseFirestore.instance
      .collection('reports')
      .doc('submissions')
      .collection('anon_penguin')
      .add(reportData);

  // Now delete the report from drafts using confirmation
  await deleteReport(context, 'drafts', docId);
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
                                devtools.log('Navigating to CapturePage with data: $reportData');
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
                                      onPressed: () => deleteReport(context, 'drafts', draft.id),
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
                                        deleteReport(context, 'submissions', submission.id),
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
