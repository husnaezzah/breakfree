import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class ViewPage extends StatelessWidget {
  final String caseId;

  const ViewPage({Key? key, required this.caseId}) : super(key: key);

  Future<Map<String, dynamic>?> fetchReport(String caseId) async {
    try {
      final document = await FirebaseFirestore.instance
          .collection('reports')
          .doc('submissions')
          .collection('anon_penguin')
          .doc(caseId)
          .get();

      return document.data();
    } catch (e) {
      debugPrint('Error fetching report: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 96, 32, 109),
        title: Text(
          'View Report',
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
      body: FutureBuilder<Map<String, dynamic>?>(
        future: fetchReport(caseId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return Center(
              child: Text(
                'Report not found.',
                style: GoogleFonts.poppins(fontSize: 16),
              ),
            );
          }

          final report = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Case Number: ${report['case_number'] ?? 'Unknown'}',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                if (report['image_url'] != null && report['image_url'] != '')
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Image.network(
                      report['image_url'],
                      fit: BoxFit.cover,
                    ),
                  ),
                const SizedBox(height: 20),
                Text(
                  'Phone Number:',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  report['phone_number'] ?? 'Not Provided',
                  style: GoogleFonts.poppins(fontSize: 14),
                ),
                const SizedBox(height: 20),
                Text(
                  'Location:',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  report['location'] ?? 'Not Provided',
                  style: GoogleFonts.poppins(fontSize: 14),
                ),
                const SizedBox(height: 20),
                Text(
                  'Description:',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  report['description'] ?? 'Not Provided',
                  style: GoogleFonts.poppins(fontSize: 14),
                ),
                const SizedBox(height: 20),
                Text(
                  'Label:',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  report['label'] ?? 'Other Potential Forms of Violence',
                  style: GoogleFonts.poppins(fontSize: 14),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Factory method for generating the `ViewPage` from route arguments.
  static ViewPage fromRouteSettings(RouteSettings settings) {
    final args = settings.arguments as Map<String, dynamic>;
    return ViewPage(caseId: args['caseId']);
  }
}
