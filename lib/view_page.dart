import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Make sure Firestore is correctly imported

class ViewPage extends StatelessWidget {
  final Map<String, dynamic> reportData;
  final String caseId;

  const ViewPage({Key? key, required this.reportData, required this.caseId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 251, 247, 247),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 96, 32, 109),
        title: Text(
          'View Submission',
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
              // Case Number
              Text(
                "Case Number: ${reportData['case_number'] ?? 'Unknown'}",
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 10),

              // Image Section (if image URL exists)
              if (reportData['image_url'] != null && reportData['image_url'].isNotEmpty) ...[
                Image.network(
                  reportData['image_url'],
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: MediaQuery.of(context).size.height * 0.3,
                  fit: BoxFit.cover,
                ),
                const SizedBox(height: 10),
              ],

              // Status
              Text(
                "Status: ${reportData['status'] ?? 'Unknown'}",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 20),

              // Description
              Text(
                "Description: ${reportData['description'] ?? 'No description provided.'}",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 20),

              // Phone Number
              Text(
                "Phone Number: ${reportData['phone_number'] ?? 'Unknown'}",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 10),

              // Location
              Text(
                "Location: ${reportData['location'] ?? 'Unknown'}",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 10),

              // Label (Type of Violence)
              Text(
                "Label: ${reportData['label'] ?? 'Not specified'}",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 10),

              // Timestamp (Formatted to Date)
              Text(
                "Submitted On: ${reportData['timestamp'] != null ? (reportData['timestamp'] as Timestamp).toDate().toLocal().toString() : 'Unknown'}",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
