import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_tflite/flutter_tflite.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:developer' as devtools;

class CapturePage extends StatefulWidget {
  final Map<String, dynamic>? reportData; // Added to handle editing existing reports

  const CapturePage({super.key, this.reportData});

  @override
  _CapturePageState createState() => _CapturePageState();
}

class _CapturePageState extends State<CapturePage> {
  File? filePath;
  String label = '';
  bool isImageEnabled = true;
  final ImagePicker _picker = ImagePicker();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  String caseNumber = '';
  String? phoneValidationMessage;

  Future<void> _generateCaseNumber() async {
    final snapshot = await FirebaseFirestore.instance.collection('reports/drafts/all_cases').get();
    final nextNumber = snapshot.size + 1;
    setState(() {
      caseNumber = 'C${nextNumber.toString().padLeft(2, '0')}';
    });
  }

  Future<void> _tfliteInit() async {
    await Tflite.loadModel(
      model: "assets/model_unquant.tflite",
      labels: "assets/labels.txt",
      numThreads: 1,
      isAsset: true,
      useGpuDelegate: false,
    );
  }

  Future<void> _getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final placeMarks = await placemarkFromCoordinates(
        position.latitude, position.longitude,
      );

      if (placeMarks.isNotEmpty) {
        final place = placeMarks[0];
        setState(() {
          locationController.text = "${place.locality}, ${place.administrativeArea}";
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to get location: $e', style: GoogleFonts.poppins(color: Colors.red))),
      );
    }
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

  // Phone number validation
  void validatePhoneNumber(String phoneNumber) {
    if (phoneNumber.isEmpty) {
      setState(() {
        phoneValidationMessage = 'Phone number is required.';
      });
    } else if (!phoneNumber.startsWith('+60') || phoneNumber.length < 13 || phoneNumber.length > 14) {
      setState(() {
        phoneValidationMessage = 'Invalid phone number format. Please use +60 followed by your number.';
      });
    } else {
      setState(() {
        phoneValidationMessage = null;
      });
    }
  }

  Future<void> saveReport(String status) async {
    if (phoneValidationMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            phoneValidationMessage!,
            style: GoogleFonts.poppins(color: Colors.red),
          ),
          backgroundColor: Colors.white,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        ),
      );
      return;
    }

    if (status == 'Submitted' &&
        (phoneNumberController.text.isEmpty || locationController.text.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Phone Number and Location are required fields.',
              style: GoogleFonts.poppins(color: Colors.red)),
          backgroundColor: Colors.white,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        ),
      );
      return;
    }

    if (caseNumber.isEmpty) {
      await _generateCaseNumber();
    }

    try {
      String? imageUrl;

      final String collection = status == 'In Progress' ? 'drafts' : 'submissions';

      if (filePath != null && isImageEnabled) {
        final String fileName = DateTime.now().millisecondsSinceEpoch.toString();
        final Reference storageRef = FirebaseStorage.instance.ref().child('images/$fileName');

        final UploadTask uploadTask = storageRef.putFile(filePath!);

        final TaskSnapshot snapshot = await uploadTask.whenComplete(() {});
        imageUrl = await snapshot.ref.getDownloadURL();
      } else {
        imageUrl = 'https://example.com/default-image.png';
      }

      final reportData = {
        'case_number': caseNumber,
        'phone_number': phoneNumberController.text,
        'location': locationController.text,
        'description': descriptionController.text,
        'status': status,
        'timestamp': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance
          .collection('reports')
          .doc(collection)
          .collection('all_cases')
          .add(reportData);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            status == 'In Progress' ? 'Report saved as Draft' : 'Report submitted successfully!',
            style: GoogleFonts.poppins(color: Colors.white),
          ),
          backgroundColor: Colors.black,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        ),
      );

      setState(() {
        filePath = null;
        label = '';
        caseNumber = '';
        phoneNumberController.clear();
        locationController.clear();
        descriptionController.clear();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error saving report. Please try again!',
            style: GoogleFonts.poppins(color: Colors.red),
          ),
          backgroundColor: Colors.black,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        ),
      );
    }
  }

  @override
  void dispose() {
    Tflite.close();
    locationController.dispose();
    descriptionController.dispose();
    phoneNumberController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (widget.reportData != null) {
      final report = widget.reportData!;
      caseNumber = report['case_number'];
      phoneNumberController.text = report['phone_number'];
      locationController.text = report['location'];
      descriptionController.text = report['description'];
    } else {
      _tfliteInit();
      _generateCaseNumber();
    }
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
              color: const Color.fromARGB(255, 251, 247, 247)),
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
              Text(
                'Case Number: $caseNumber',
                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              if (isImageEnabled) ...[
                Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: MediaQuery.of(context).size.height * 0.3,
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
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.6,
                  child: ElevatedButton(
                    onPressed: pickImageGallery,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 96, 32, 109),
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
              Row(
                children: [
                  Expanded(
                    child: CheckboxListTile(
                      title: Text(
                        'Attach image in the report?',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                          color: const Color.fromARGB(255, 96, 32, 109),
                        ),
                      ),
                      value: isImageEnabled,
                      onChanged: (value) {
                        setState(() {
                          isImageEnabled = value ?? true;
                          if (!isImageEnabled) {
                            filePath = null;
                            label = 'Other Potential Forms of Violence';
                          } else {
                            label = '';
                          }
                        });
                      },
                      activeColor: const Color.fromARGB(255, 96, 32, 109),
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                  ),
                ],
              ),
              Text(
                label,
                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0), // Increased gap
                child: TextField(
                  controller: phoneNumberController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    labelStyle: GoogleFonts.poppins(fontSize: 18, color: Colors.black),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                    prefixText: '+60 ',
                    errorText: phoneValidationMessage,
                  ),
                  onChanged: (value) {
                    if (value.startsWith('+60') && value.length > 3 && (value.length == 13 || value.length == 14)) {
                      validatePhoneNumber(value);
                    }
                  },
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Flexible(
                    flex: 1,
                    child: IconButton(
                      icon: const Icon(
                        Icons.location_on,
                        color: Color.fromARGB(255, 96, 32, 109),
                      ),
                      onPressed: _getCurrentLocation,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    flex: 6,
                    child: TextField(
                      controller: locationController,
                      decoration: InputDecoration(
                        labelText: 'Location',
                        labelStyle: GoogleFonts.poppins(
                          fontSize: 18, 
                          color: Colors.black),
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        )
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: TextField(
                  controller: descriptionController,
                  maxLines: 5,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    labelStyle: GoogleFonts.poppins(fontSize: 18, color: Colors.black),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.35,
                    child: ElevatedButton(
                      onPressed: () => saveReport('In Progress'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 96, 32, 109),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      child: Text(
                        "Draft",
                        style: GoogleFonts.poppins(fontSize: 14, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.35,
                    child: ElevatedButton(
                      onPressed: () => saveReport('Submitted'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 96, 32, 109),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      child: Text(
                        "Submit",
                        style: GoogleFonts.poppins(fontSize: 14, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}