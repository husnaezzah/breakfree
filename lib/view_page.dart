import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class ViewPage extends StatefulWidget {
  final String caseId;

  const ViewPage({Key? key, required this.caseId}) : super(key: key);

  @override
  _ViewPageState createState() => _ViewPageState();
}

class _ViewPageState extends State<ViewPage> {
  Map<String, dynamic>? reportData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchReport();
  }

  Future<void> fetchReport() async {
    try {
      final document = await FirebaseFirestore.instance
          .collection('reports')
          .doc('submissions')
          .collection('anon_penguin')
          .doc(widget.caseId)
          .get();

      setState(() {
        reportData = document.data();
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching report: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 251, 247, 247),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 96, 32, 109),
        title: Text(
          'View Case Report',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: const Color.fromARGB(255, 251, 247, 247),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context); // Navigate back to the HistoryPage
          },
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : reportData == null
              ? Center(
                  child: Text(
                    'Report not found.',
                    style: GoogleFonts.poppins(fontSize: 16),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Center(
                        child: Text(
                          'Case Report',
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Center(
                        child: Text(
                          'Case Number: ${reportData!['case_number'] ?? 'Unknown'}',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildImageField(reportData!['image_url']),
                      const SizedBox(height: 20),
                      _buildReadOnlyField(
                        label: 'Label',
                        value: reportData!['label'] ??
                            'Other Potential Forms of Violence',
                      ),
                      const SizedBox(height: 20),
                      _buildReadOnlyField(
                        label: 'Phone Number',
                        value: reportData!['phone_number'] ?? 'Not Provided',
                      ),
                      const SizedBox(height: 20),
                      _buildReadOnlyField(
                        label: 'Location',
                        value: reportData!['location'] ?? 'Not Provided',
                      ),
                      const SizedBox(height: 20),
                      _buildDynamicDescriptionField(
                        label: 'Description',
                        value: reportData!['description'] ?? 'Not Provided',
                      ),
                    ],
                  ),
                ),
    );
  }

  /// Image Field Widget
  Widget _buildImageField(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return Container(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.3,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            'No Image Uploaded',
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.black),
          ),
        ),
      );
    }
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      height: MediaQuery.of(context).size.height * 0.3,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Image.network(
        imageUrl,
        fit: BoxFit.cover,
      ),
    );
  }

  /// Helper function to create read-only text fields
  Widget _buildReadOnlyField({
    required String label,
    required String value,
  }) {
    return TextField(
      controller: TextEditingController(text: value),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(
          fontSize: 18,
          color: Colors.black,
        ),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      readOnly: true,
    );
  }

  /// Dynamic TextField for the Description Field
  Widget _buildDynamicDescriptionField({
    required String label,
    required String value,
  }) {
    final lineCount = '\n'.allMatches(value).length + 1; // Count the lines dynamically
    return TextField(
      controller: TextEditingController(text: value),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(
          fontSize: 18,
          color: Colors.black,
        ),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      readOnly: true,
      maxLines: lineCount > 5 ? lineCount : null, // Adjust max lines dynamically
    );
  }
}
