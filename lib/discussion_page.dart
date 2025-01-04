import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // For formatting the timestamp

class DiscussionPage extends StatelessWidget {
  final String forumId;

  const DiscussionPage({required this.forumId});

  @override
  Widget build(BuildContext context) {
    final TextEditingController commentController = TextEditingController();

    return Scaffold(
      backgroundColor: Color.fromARGB(255, 251, 247, 247), 
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 96, 32, 109),
        title: Text(
          'BreakFree.', // Updated title
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 251, 247, 247),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('forums')
            .doc(forumId)
            .get(), // Fetching the forum's document
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          var forumData = snapshot.data!;
          String threadTitle = forumData['title'] ?? 'No title';
          String threadDescription = forumData['description'] ?? 'No description available';
          Timestamp timestamp = forumData['timestamp']; // Get timestamp from the forum document
          String formattedTimestamp = _formatTimestamp(timestamp);

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center( // Center the container
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.9, // Set width to 90% of screen width
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Color.fromARGB(255, 96, 32, 109), width: 2), // Purple outline
                      borderRadius: BorderRadius.circular(8.0),
                      color: Colors.white, // Background color for the container
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title Text
                        Text(
                          threadTitle,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 8),
                        // Description Text
                        Text(
                          threadDescription,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 8),
                        // Timestamp Text
                        Text(
                          'Posted on: $formattedTimestamp',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.black54,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('forums')
                      .doc(forumId)
                      .collection('comments')
                      .orderBy('timestamp', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Center(child: CircularProgressIndicator());
                    }
                    final comments = snapshot.data!.docs;
                    return ListView.builder(
                      itemCount: comments.length,
                      itemBuilder: (context, index) {
                        final comment = comments[index];
                        return ListTile(
                          title: Text(comment['content']),
                          subtitle: Text('By: ${comment['createdBy']}'),
                        );
                      },
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: commentController,
                        decoration: InputDecoration(labelText: 'Add a comment'),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.send, color: const Color.fromARGB(255, 96, 32, 109)),
                      onPressed: () {
                        final content = commentController.text.trim();
                        if (content.isNotEmpty) {
                          _addComment(forumId, content);
                          commentController.clear();
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Function to format the timestamp
  String _formatTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return DateFormat('MMM d, yyyy h:mm a').format(dateTime); // Format to 'Jan 1, 2025 2:30 PM'
  }

  Future<void> _addComment(String forumId, String content) async {
    await FirebaseFirestore.instance
        .collection('forums')
        .doc(forumId)
        .collection('comments')
        .add({
      'content': content,
      'createdBy': 'Anonymous Penguin', // Replace with actual user info
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
