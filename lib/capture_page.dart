import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_tflite/flutter_tflite.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:developer' as devtools;

class CapturePage extends StatefulWidget {
  final Map<String, dynamic>? reportData; // Added to handle editing existing reports
  final String? caseId;

  const CapturePage({super.key, this.reportData, this.caseId});

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
  bool isMounted = true; 
  bool agreeToPrivacy = false;
  bool showPrivacyDetails = false;


    Future<void> _generateCaseNumber() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('reports/drafts/all_cases')
        .get();
    final nextNumber = snapshot.size + 1;
    if (isMounted) {
      setState(() {
        caseNumber = 'C${nextNumber.toString().padLeft(2, '0')}';
      });
    }
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

   // Validate phone number (+60 followed by 8 or 9 digits)
  void validatePhoneNumber(String phoneNumber) {
    final phonePattern = RegExp(r'^\d{8,9}$');
    if (!phonePattern.hasMatch(phoneNumber)) {
      setState(() {
        phoneValidationMessage =
            'Invalid phone number format.';
      });
    } else {
      setState(() {
        phoneValidationMessage = null;
      });
    }
  }
  

  Future<void> saveReport(String status) async {

    // Ensure agreement to privacy and confidentiality before saving
    if (!agreeToPrivacy) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'You must agree to the privacy and confidentiality policy.',
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

    // Ensure phone number is valid before saving
    if (phoneValidationMessage != null || phoneNumberController.text.isEmpty ) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            phoneValidationMessage ?? 'Phone number is required.',
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
        (phoneNumberController.text.isEmpty || locationController.text.isEmpty || descriptionController.text.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Phone Number, Location and Description are required fields.',
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
        'phone_number': '+60 ${phoneNumberController.text}',
        'location': locationController.text,
        'description': descriptionController.text,
        'status': status,
        'timestamp': FieldValue.serverTimestamp(),
        'image_url': imageUrl,
      };

      if (widget.caseId != null) {
        // Update existing report
        await FirebaseFirestore.instance
            .collection('reports')
            .doc(collection)
            .collection('all_cases')
            .doc(widget.caseId)
            .set(reportData);
      } else {
        // Create new report
        await FirebaseFirestore.instance
            .collection('reports')
            .doc(collection)
            .collection('all_cases')
            .add(reportData);
      }

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
    isMounted = false;
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
                  ),
                  child: filePath != null
                      ? Image.file(
                          filePath!,
                          fit: BoxFit.cover,
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.cloud_upload_outlined,
                              size: 50,
                              color: Color.fromARGB(255, 96, 32, 109)
                            ),
                            const SizedBox(height: 5), // Add spacing between the icon and button
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.4,
                              child: ElevatedButton(
                                onPressed: pickImageGallery,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color.fromARGB(255, 96, 32, 109),
                                  padding: const EdgeInsets.symmetric(vertical: 5),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                ),
                                child: Text(
                                  "Browse Gallery",
                                  style: GoogleFonts.poppins(fontSize: 13, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                ),
                const SizedBox(height: 10), // Spacing after the container
              ],
              Row(
                children: [
                  Expanded(
                    child: SwitchListTile(
                      title: Text(
                        'Attach Image in the Report',
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
                      contentPadding: EdgeInsets.symmetric(horizontal: 8.0), 
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
                    prefixText: '+60 ',
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                    errorText: phoneValidationMessage,
                  ),
                  onChanged: (value) {
                     {
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
  children: [
    Checkbox(
      value: agreeToPrivacy,
      onChanged: (value) {
        setState(() {
          agreeToPrivacy = value ?? false;
        });
      },
      activeColor: const Color.fromARGB(255, 96, 32, 109),
    ),
    Expanded(
      child: RichText(
        text: TextSpan(
          style: GoogleFonts.poppins(fontSize: 13, color: Colors.black),
          children: [
            const TextSpan(text: 'I hereby agree to the '),
            TextSpan(
              text: 'Privacy Terms and Conditions',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: const Color.fromARGB(255, 30, 126, 205),
                decoration: TextDecoration.underline,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Center(
                          child: Text(
                            'Privacy Terms and Conditions',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        content: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '1. Information Collection\n',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'BreakFree collects phone numbers, location data, and images related to domestic violence cases. This data is provided voluntarily by users and stored securely.\n\n',
                                style: GoogleFonts.poppins(fontSize: 12),
                              ),
                              Text(
                                '2. Information Usage\n',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Collected data is used to create reports, assist investigations, and improve services. Anonymized data may be used for research purposes.\n\n',
                                style: GoogleFonts.poppins(fontSize: 12),
                              ),
                              Text(
                                '3. Information Sharing\n',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Data is not shared without user consent, except when required by law or to protect user safety.\n\n',
                                style: GoogleFonts.poppins(fontSize: 12),
                              ),
                              Text(
                                '4. Data Security\n',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'User data is protected with encryption and secure storage. Access is restricted to authorized personnel, and regular audits ensure compliance with privacy standards.',
                                style: GoogleFonts.poppins(fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        actions: [
                          Center(
                            child: TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text(
                                'Close',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: const Color.fromARGB(255, 96, 32, 109),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },); },),
          ],),),
            ),
            ],),
          const SizedBox(height: 20),
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
      floatingActionButton: SizedBox(
        width: 70,
        height: 70,
        child: FloatingActionButton(
          onPressed: () {
            Navigator.pushNamed(context, '/sos');
          },
          backgroundColor: Colors.red,
          shape: CircleBorder(),
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
        color: Colors.white, // Bottom navigation bar color changed to white
        shape: CircularNotchedRectangle(),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.home, color: Colors.black),
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
}