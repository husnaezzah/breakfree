import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_tflite/flutter_tflite.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:developer' as devtools;

class CapturePage extends StatefulWidget {
  const CapturePage({super.key});

  @override
  _CapturePageState createState() => _CapturePageState();
}

class _CapturePageState extends State<CapturePage> {
  File? filePath;
  String label = '';
  bool isImageEnabled = true; // Track whether image functionality is enabled
  final ImagePicker _picker = ImagePicker();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();

  Future<void> _tfliteInit() async {
    await Tflite.loadModel(
      model: "assets/model_unquant.tflite",
      labels: "assets/labels.txt",
      numThreads: 1,
      isAsset: true,
      useGpuDelegate: false,
    );
  }

  Future<void> pickImageGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;
    var imageMap = File(image.path);
    setState(() {
      filePath = imageMap;
    });

    var recognitions = await Tflite.runModelOnImage(
      path: image.path,
      imageMean: 0.0,
      imageStd: 255.0,
      numResults: 2,
      threshold: 0.2,
      asynch: true,
    );

    if (recognitions != null && recognitions.isNotEmpty) {
      setState(() {
        label = recognitions[0]['label'].toString();
      });
    } else {
      devtools.log("Recognition failed");
    }
  }

Future<void> saveReport(String status) async {
  try {
    String? imageUrl;

    // Determine the category based on the label
    final String category = isImageEnabled
        ? (label.contains('physical')
            ? 'potential_physical_abuse'
            : label.contains('psychological')
                ? 'potential_psychological_abuse'
                : 'general')
        : 'general';
    final String collection = status == 'Draft' ? 'drafts' : 'submissions';

    // Upload image if applicable
    if (filePath != null && isImageEnabled && category != 'general') {
      final String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final Reference storageRef = FirebaseStorage.instance.ref().child('images/$fileName');
      final UploadTask uploadTask = storageRef.putFile(filePath!);
      final TaskSnapshot snapshot = await uploadTask.whenComplete(() {});
      imageUrl = await snapshot.ref.getDownloadURL();  // Get the image URL
    }

    // Prepare report data
    final reportData = {
      'name': nameController.text,
      'phone_number': phoneNumberController.text,
      'location': locationController.text,
      'description': descriptionController.text,
      'label': isImageEnabled ? label : 'general',
      'image_url': imageUrl ?? 'https://example.com/default-image.png', // Add default image URL if no image is uploaded
      'status': status,
      'timestamp': FieldValue.serverTimestamp(),
    };

    // Save to Firestore
    await FirebaseFirestore.instance
        .collection('reports')
        .doc(category)
        .collection(collection)
        .add(reportData);

    devtools.log('$status report saved successfully');

    // Clear fields after saving
    setState(() {
      filePath = null;
      label = '';
      nameController.clear();
      phoneNumberController.clear();
      locationController.clear();
      descriptionController.clear();
    });
  } catch (e) {
    devtools.log('Error saving report: $e');
  }
}

  @override
  void dispose() {
    Tflite.close();
    locationController.dispose();
    descriptionController.dispose();
    nameController.dispose();
    phoneNumberController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _tfliteInit();
  }

  // Toggle the image functionality (On/Off)
  void toggleImageFunctionality() {
    setState(() {
      isImageEnabled = !isImageEnabled;
      if (!isImageEnabled) {
        filePath = null; // Clear the filePath if images are disabled
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple[50],
      appBar: AppBar(
        backgroundColor: Colors.purple[100],
        title: Text(
          'BreakFree. ',
          style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Capture',
                style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              Text(
                'Report A Case',
                style: GoogleFonts.poppins(fontSize: 12),
              ),
              const SizedBox(height: 20),

              // Image-related UI if enabled
              if (isImageEnabled) ...[
                Container(
                  width: 280,
                  height: 210,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(0),
                    image: const DecorationImage(image: AssetImage('assets/picture.png')),
                  ),
                  child: filePath != null
                      ? Image.file(
                          filePath!,
                          fit: BoxFit.cover,
                        )
                      : const Center(child: Text('')),
                ),
                const SizedBox(height: 10),

                // Browse Gallery button with defined width
                SizedBox(
                  width: 200,
                  child: ElevatedButton(
                    onPressed: pickImageGallery,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 45, 15, 51),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    child: Text(
                      "Browse Gallery",
                      style: GoogleFonts.poppins(fontSize: 14, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],

              // Checkbox and Label with reduced spacing
              Row(
                children: [
                  Expanded(
                    child: CheckboxListTile(
                      title: Text(
                        'Attach image in the report?',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                          color: const Color.fromARGB(255, 96, 32, 109),
                        ),
                      ),
                      value: isImageEnabled,
                      onChanged: (value) {
                        toggleImageFunctionality();
                      },
                      activeColor: const Color.fromARGB(255, 45, 15, 51),
                      controlAffinity: ListTileControlAffinity.leading, // Position the checkbox to the left of the text
                    ),
                  ),
                ],
              ),

              // Label with reduced spacing from the checkbox
              Text(
                label,
                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
              ),

              // Name Input
              const SizedBox(height: 10),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
              ),

              // Phone Number Input
              const SizedBox(height: 10),
              TextField(
                controller: phoneNumberController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                ),
              ),

              // Location Input
              const SizedBox(height: 10),
              TextField(
                controller: locationController,
                decoration: const InputDecoration(
                  labelText: 'Location',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),

              // Description Input
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
              ),
              const SizedBox(height: 10),

              // Draft and Submit Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () => saveReport('Draft'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 45, 15, 51),
                    ),
                    child: Text('Draft', style: GoogleFonts.poppins(color: Colors.white)),
                  ),
                  ElevatedButton(
                    onPressed: () => saveReport('Submitted'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 45, 15, 51),
                    ),
                    child: Text('Submit', style: GoogleFonts.poppins(fontSize: 14, color: Colors.white)),
                  ),
                ],
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
        color: Colors.purple[100],
        shape: const CircularNotchedRectangle(),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.home),
                onPressed: () {
                  Navigator.pushNamed(context, '/home');
                },
              ),
              const SizedBox(width: 40),
              IconButton(
                icon: const Icon(Icons.person),
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
}