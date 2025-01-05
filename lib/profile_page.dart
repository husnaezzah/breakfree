import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _firestore = FirebaseFirestore.instance;

  String _anonName = "Penguin";
  String? _gender;
  String? _ageRange;
  String? _contactMethod;

  Future<void> _saveDetails() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      await _firestore.collection('profile').doc('userDetails').set({
        'anon_name': _anonName,
        'gender': _gender,
        'age_range': _ageRange,
        'contact_method': _contactMethod,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Details saved successfully!')),
      );
    }
  }

  Future<void> _showHealthDialog(BuildContext context) async {
    final docSnapshot = await _firestore.collection('profile').doc('userDetails').get();
    if (docSnapshot.exists) {
      final data = docSnapshot.data()!;
      _anonName = data['anon_name'] ?? "Penguin";
      _gender = data['gender'];
      _ageRange = data['age_range'];
      _contactMethod = data['contact_method'];
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
         title: Center(
            child: Text(
              'Personal Details',
              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                TextFormField(
                  initialValue: _anonName,
                  decoration: InputDecoration(
                    labelText: 'Anonymous Name',
                    labelStyle: GoogleFonts.poppins(fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                  readOnly: true,
                  style: GoogleFonts.poppins(fontSize: 13, color: Colors.black),
                ),
                DropdownButtonFormField<String>(
                  value: _gender,
                  items: ['Male', 'Female']
                      .map((gender) => DropdownMenuItem(
                            value: gender,
                            child: Text(
                              gender,
                              style: GoogleFonts.poppins(fontSize: 13, color: Colors.black),
                            ),
                          ))
                      .toList(),
                  decoration: InputDecoration(
                    labelText: 'Gender',
                    labelStyle: GoogleFonts.poppins(fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _gender = value;
                    });
                  },
                  validator: (value) =>
                      value == null ? 'Please select a gender' : null,
                  style: GoogleFonts.poppins(fontSize: 16), // Optional: Applies to the selected value
                ),
                DropdownButtonFormField<String>(
                  value: _ageRange,
                  items: ['13-19', '20-29', '30-39', '40-49', '50-59', '60-69']
                      .map((range) => DropdownMenuItem(
                            value: range,
                            child: Text(
                              range,
                              style: GoogleFonts.poppins(fontSize: 13, color: Colors.black),
                            ),
                          ))
                      .toList(),
                  decoration: InputDecoration(
                    labelText: 'Age Range',
                    labelStyle: GoogleFonts.poppins(fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _ageRange = value;
                    });
                  },
                  validator: (value) =>
                      value == null ? 'Please select an age range' : null,
                  style: GoogleFonts.poppins(fontSize: 14), // Optional
                ),
                DropdownButtonFormField<String>(
                  value: _contactMethod,
                  items: ['Text', 'Call']
                      .map((method) => DropdownMenuItem(
                            value: method,
                            child: Text(
                              method,
                              style: GoogleFonts.poppins(fontSize: 13, color: Colors.black),
                            ),
                          ))
                      .toList(),
                  decoration: InputDecoration(
                    labelText: 'Contact Method',
                    labelStyle: GoogleFonts.poppins(fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _contactMethod = value;
                    });
                  },
                  validator: (value) =>
                      value == null ? 'Please select a contact method' : null,
                  style: GoogleFonts.poppins(fontSize: 16), // Optional
                ),

                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel',
              style: GoogleFonts.poppins(fontSize: 14, color: const Color.fromARGB(255, 96, 32, 109))),
            ),
            ElevatedButton(
              onPressed: () async {
                await _saveDetails();
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 96, 32, 109),
              ),
              child: Text('Save',
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.white))
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = GoogleFonts.roboto(
      fontSize: 16,
      color: Color.fromARGB(255, 114, 37, 129),
      fontWeight: FontWeight.bold,
    );

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
        leading: ModalRoute.of(context)?.settings.name == '/home'
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
                },
              ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Features',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildProfileButton(
                    Icons.history,
                    'History',
                    textStyle,
                    () {
                      Navigator.pushNamed(context, '/history');
                    },
                  ),
                  _buildProfileButton(
                    Icons.medical_information_outlined,
                    'Details',
                    textStyle,
                    () {
                      _showHealthDialog(context);
                    },
                  ),
                ],
              ),
              SizedBox(height: 20),
              Text(
                'Helpline Resources',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              InformationCard(
                title: 'Talian Kasih 15999',
                description:
                    'Talian Kasih provides a 24-hour helpline for counseling and support for domestic violence survivors. Call 15999 or WhatsApp +6019-261 5999 for assistance.',
              ),
              SizedBox(height: 10),
              InformationCard(
                title: 'Women’s Aid Organization (WAO)',
                description:
                    'WAO provides shelter, counseling, and support for domestic violence survivors in Malaysia. Visit wao.org.my or call +603-7956 3488.',
              ),
              SizedBox(height: 10),
              InformationCard(
                title: 'Police Emergency Assistance',
                description:
                    'Contact the nearest police station or call 999 in case of immediate danger or threat.',
              ),
              SizedBox(height: 10),
              InformationCard(
                title: 'LPPKN Counseling Services',
                description:
                    'The National Population and Family Development Board (LPPKN) offers free counseling services for those affected by domestic violence. Call 03-2693 7555 for help.',
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
                  color: Color.fromARGB(255, 114, 37, 129),
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

  Widget _buildProfileButton(IconData icon, String label, TextStyle style, VoidCallback onPressed) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.black,
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
          style: style,
        ),
      ],
    );
  }
}

class InformationCard extends StatelessWidget {
  final String title;
  final String description;

  const InformationCard({
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
            title,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 5),
          Text(
            description,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
