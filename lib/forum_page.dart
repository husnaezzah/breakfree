import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'discussion_page.dart';

class ForumPage extends StatelessWidget {
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
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
            // Forum Discussions title with Add button on the right
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Forum Discussions',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.add,
                     color: Color.fromARGB(255, 96, 32, 109),
                     size:30,
                  ),
                  onPressed: () {
                    _showCreateThreadDialog(context);
                  },
                ),
              ],
            ),
            SizedBox(height: 10),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('forums').orderBy('timestamp', descending: true).snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }
                  final forums = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: forums.length,
                    itemBuilder: (context, index) {
                      final forum = forums[index];
                      return DiscussionCard(
                        forumId: forum.id,
                        title: forum['title'],
                        description: forum['description'],
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      // SOS FloatingActionButton
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
      // Bottom Navigation Bar
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
                  color: ModalRoute.of(context)?.settings.name == '/home' ?  Color(0xFFAD8FC6) : Colors.black,
                ),
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
                },
              ),
              SizedBox(width: 40), // Space for the SOS button in the center
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

  void _showCreateThreadDialog(BuildContext context) {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
             title: Center(
            child: Text(
              'Create New Thread',
              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  labelStyle: GoogleFonts.poppins(fontSize: 14, color: Colors.black, fontWeight: FontWeight.bold)),
              ),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  labelStyle: GoogleFonts.poppins(fontSize: 14, color: Colors.black, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel',
              style: GoogleFonts.poppins(fontSize: 14, color: const Color.fromARGB(255, 96, 32, 109))),),
            TextButton(
          onPressed: () {
            final title = titleController.text.trim();
            final description = descriptionController.text.trim();
            if (title.isNotEmpty && description.isNotEmpty) {
              _createForumThread(title, description);
              Navigator.pop(context);
            }
          },
            style: TextButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 96, 32, 109), // Set your desired text color
            ),
              child: Text('Create',
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.white),
            ),
            ),
          ]
        );
      },
    );
  }

  Future<void> _createForumThread(String title, String description) async {
    await FirebaseFirestore.instance.collection('forums').add({
      'title': title,
      'description': description,
      'createdBy': 'Anonymous Penguin', // Replace with the actual user's ID or username
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}

class DiscussionCard extends StatefulWidget {
  final String forumId;
  final String title;
  final String description;

  const DiscussionCard({
    required this.forumId,
    required this.title,
    required this.description,
  });

  @override
  _DiscussionCardState createState() => _DiscussionCardState();
}

class _DiscussionCardState extends State<DiscussionCard> {
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
        // Assuming you track user IDs for likes:
        // isLiked = (data['likedBy'] as List).contains(currentUserId);
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
        // Unlike
        transaction.update(docRef, {'likes': currentLikes - 1});
        // Remove user ID from likedBy if needed
      } else {
        // Like
        transaction.update(docRef, {'likes': currentLikes + 1});
        // Add user ID to likedBy if needed
      }
    });

    setState(() {
      isLiked = !isLiked;
      likeCount += isLiked ? 1 : -1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DiscussionPage(forumId: widget.forumId),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 10),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: const Color.fromARGB(255, 96, 32, 109), width: 2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 5),
            Text(
              widget.description,
              style: GoogleFonts.poppins(
                fontSize: 10,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        isLiked ? Icons.favorite : Icons.favorite_border,
                        color: Colors.red,
                      ),
                      onPressed: _toggleLike,
                    ),
                    Text('$likeCount'),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DiscussionPage(forumId: widget.forumId),
                      ),
                    );
                  },
                  child: Text(
                    "View Discussion",
                    style: GoogleFonts.poppins(color: Colors.purple),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}