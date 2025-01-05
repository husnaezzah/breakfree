import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class DiscussionPage extends StatefulWidget {
  final String forumId;

  const DiscussionPage({required this.forumId});

  @override
  _DiscussionPageState createState() => _DiscussionPageState();
}

class _DiscussionPageState extends State<DiscussionPage> {
  final TextEditingController commentController = TextEditingController();
  bool isLiked = false;
  int likeCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchLikeStatus();
  }

  void _fetchLikeStatus() async {
    final doc = await FirebaseFirestore.instance.collection('forums').doc(widget.forumId).get();
    if (doc.exists) {
      final data = doc.data()!;
      setState(() {
        likeCount = data['likes'] ?? 0;
      });
    }
  }

  void _toggleLike() async {
    final docRef = FirebaseFirestore.instance.collection('forums').doc(widget.forumId);
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) return;

      final data = snapshot.data()!;
      final currentLikes = data['likes'] ?? 0;

      if (isLiked) {
        transaction.update(docRef, {'likes': currentLikes - 1});
      } else {
        transaction.update(docRef, {'likes': currentLikes + 1});
      }
    });

    setState(() {
      isLiked = !isLiked;
      likeCount += isLiked ? 1 : -1;
    });
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
        future: FirebaseFirestore.instance.collection('forums').doc(widget.forumId).get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          var forumData = snapshot.data!;
          String threadTitle = forumData['title'] ?? 'No title';
          String threadDescription = forumData['description'] ?? 'No description available';
          Timestamp timestamp = forumData['timestamp'];
          String formattedTimestamp = _formatTimestamp(timestamp);

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Color.fromARGB(255, 96, 32, 109), width: 2),
                      borderRadius: BorderRadius.circular(8.0),
                      color: Colors.white,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          threadTitle,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          threadDescription,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Posted on: $formattedTimestamp',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.black54,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: Icon(
                                    isLiked ? Icons.favorite : Icons.favorite_border,
                                    color: Colors.red,
                                  ),
                                  onPressed: _toggleLike,
                                ),
                                Text(
                                  '$likeCount',
                                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.black),
                                ),
                              ],
                            ),
                          ],
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
                      .doc(widget.forumId)
                      .collection('comments')
                      .orderBy('timestamp', descending: false)
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
                        return Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
                          child: ListTile(
                            contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                            leading: CircleAvatar(
                              radius: 20,
                              backgroundColor: Colors.white,
                              child: Icon(Icons.person, color: const Color.fromARGB(255, 96, 32, 109)),
                            ),
                            title: Text(
                              comment['content'],
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: Colors.black,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 4),
                                Text(
                                  'By: ${comment['createdBy']}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: Colors.black54,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  _formatTimestamp(comment['timestamp']),
                                  style: GoogleFonts.poppins(
                                    fontSize: 10,
                                    color: Colors.black45,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.all(10.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: commentController,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsetsDirectional.symmetric(vertical: 8.0, horizontal: 16),
                          hintText: "Add a comment...",
                          hintStyle: GoogleFonts.poppins(
                            fontSize: MediaQuery.of(context).size.width * 0.035,
                            color: Colors.grey[500],
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.send,
                        color: const Color.fromARGB(255, 96, 32, 109),
                      ),
                      onPressed: () {
                        final content = commentController.text.trim();
                        if (content.isNotEmpty) {
                          _addComment(widget.forumId, content);
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

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) {
      return "Timestamp not available";
    }
    try {
      DateTime dateTime = (timestamp as Timestamp).toDate();
      return DateFormat('MMM d, yyyy h:mm a').format(dateTime);
    } catch (e) {
      return "Invalid timestamp";
    }
  }

  Future<void> _addComment(String forumId, String content) async {
    await FirebaseFirestore.instance
        .collection('forums')
        .doc(forumId)
        .collection('comments')
        .add({
      'content': content,
      'createdBy': 'Anonymous Penguin',
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
