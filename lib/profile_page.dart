import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';  // To work with File type (local image storage)

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  File? _image;  // To store the selected image from the gallery
  int _selectedIndex = 2; // Initialize the selected index to the Profile page

  // Function to pick an image from the gallery
  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple[50],
      appBar: AppBar(
        backgroundColor: Colors.purple[100],
        title: Text(
          'BreakFree.',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            // Navigate back to the previous page (Home)
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.chat_bubble_outline),
            onPressed: () {
              // Handle chat icon press
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profile Picture with tap to upload functionality
            GestureDetector(
              onTap: _pickImage,  // Open the gallery when the profile picture is tapped
              child: CircleAvatar(
                radius: 50,
                backgroundImage: _image != null
                    ? FileImage(_image!)  // Display the selected image
                    : AssetImage('assets/images/profile_pic.png') as ImageProvider, // Default image
              ),
            ),
            SizedBox(height: 10),
            // Name and Role
            Text(
              'Khadijah Ibrahim',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Victim',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 30),

            // Personal Section
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Personal',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildProfileButton(Icons.person_outline, 'About Me'),
                _buildProfileButton(Icons.favorite_border, 'Health'),
                _buildProfileButton(Icons.settings_outlined, 'Settings'),
              ],
            ),
            SizedBox(height: 30),

            // Others Section
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Others',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 10),
            _buildOptionCard(Icons.history, 'History', 'My Documentation'),
            SizedBox(height: 10),
            _buildOptionCard(Icons.phone, 'Emergency', 'My Contacts'),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.purple[100],
        selectedItemColor: Colors.purple, // Set the selected item color
        unselectedItemColor: Colors.black, // Set the unselected item color
        currentIndex: _selectedIndex, // Keep track of the current index
        onTap: (int index) {
          setState(() {
            _selectedIndex = index; // Update the index when an icon is tapped
            if (index == 0) {
              Navigator.pop(context);  // Navigate back to Home if the Home icon is tapped
            }
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, color: _selectedIndex == 0 ? Colors.black : Colors.black),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Text(
              'SOS',
              style: TextStyle(
                color: Colors.red,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, color: _selectedIndex == 2 ? Colors.purple : Colors.black), // Profile icon color
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  // Function to build profile buttons
  Widget _buildProfileButton(IconData icon, String label) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () {
            // Handle button press
          },
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.purple,
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            padding: EdgeInsets.all(20),
          ),
          child: Icon(
            icon,
            size: 40,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 10),
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.purple,
          ),
        ),
      ],
    );
  }

  // Function to build option cards for History and Emergency
  Widget _buildOptionCard(IconData icon, String title, String subtitle) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.purple, width: 2),
        color: Colors.white,
      ),
      child: Row(
        children: [
          Icon(icon, size: 40, color: Colors.black),
          SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 5),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
