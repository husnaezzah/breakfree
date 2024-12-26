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
  const CapturePage({super.key});

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

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Location services are disabled.', style: GoogleFonts.poppins(color: Colors.red))),
      );
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Location permissions are denied.', style: GoogleFonts.poppins(color: Colors.red))),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Location permissions are permanently denied.', style: GoogleFonts.poppins(color: Colors.red))),
      );
      return;
    }

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

  Future<void> saveReport(String status) async {
    if (nameController.text.isEmpty || phoneNumberController.text.isEmpty || locationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Name, Phone Number, and Location are required fields.', style: GoogleFonts.poppins(color: Colors.red)),
          backgroundColor: Colors.white,
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    try {
      String? imageUrl;

      final String category = isImageEnabled
          ? (label.contains('physical')
              ? 'potential_physical_abuse'
              : label.contains('psychological')
                  ? 'potential_psychological_abuse'
                  : 'other_potential_forms_of_violence')
          : 'other_potential_forms_of_violence';
      final String collection = status == 'In Progress' ? 'drafts' : 'submissions';

      if (filePath != null && isImageEnabled && category != 'other_potential_forms_of_violence') {
        final String fileName = DateTime.now().millisecondsSinceEpoch.toString();
        final Reference storageRef = FirebaseStorage.instance.ref().child('images/$fileName');

        // Upload the image file
        final UploadTask uploadTask = storageRef.putFile(filePath!);

        // Wait for the upload to complete and get the download URL
        final TaskSnapshot snapshot = await uploadTask.whenComplete(() {});
        imageUrl = await snapshot.ref.getDownloadURL();
      } else {
        imageUrl = 'https://example.com/default-image.png'; // Default image if no file is uploaded
      }

      final reportData = {
        'name': nameController.text,
        'phone_number': phoneNumberController.text,
        'location': locationController.text,
        'description': descriptionController.text,
        'label': isImageEnabled ? label : 'other_potential_forms_of_violence',
        'image_url': imageUrl,
        'status': status,
        'timestamp': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance
          .collection('reports')
          .doc(category)
          .collection(collection)
          .add(reportData);

      devtools.log('$status report saved successfully');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            status == 'In Progress' ? 'Report saved as Draft' : 'Report submitted successfully!',
            style: GoogleFonts.poppins(color: Colors.red),
          ),
          backgroundColor: Colors.white,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        ),
      );

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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error saving report. Please try again!',
            style: GoogleFonts.poppins(color: Colors.red),
          ),
          backgroundColor: Colors.white,
          duration: const Duration(seconds: 3),
        ),
      );
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

  void toggleImageFunctionality() {
    setState(() {
      isImageEnabled = !isImageEnabled;
      if (!isImageEnabled) {
        filePath = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 251, 247, 247),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 96, 32, 109),
        title: Text(
          'BreakFree. ',
          style: GoogleFonts.poppins(
            fontSize: 24, 
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 251, 247, 247)),
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

                SizedBox(
                  width: 200,
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
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                          color: const Color.fromARGB(255, 96, 32, 109),
                        ),
                      ),
                      value: isImageEnabled,
                      onChanged: (value) {
                        toggleImageFunctionality();
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
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 10),
              TextField(
                controller: phoneNumberController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 10),
            Row(
              children: [
                Flexible(
                  flex: 1, // Adjust this value to control the width of the icon
                  child: IconButton(
                    icon: Icon(Icons.location_on, color: const Color.fromARGB(255, 96, 32, 109),),
                    onPressed: _getCurrentLocation,
                  ),
                ),
                const SizedBox(width: 5), // Reduce the gap here
                Expanded(
                  flex: 6, // Let the TextField take the remaining space
                  child: TextField(
                    controller: locationController,
                    decoration: const InputDecoration(
                      labelText: 'Location',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),

              const SizedBox(height: 10),

              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
              ),
              const SizedBox(height: 10),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () => saveReport('In Progress'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 96, 32, 109),
                    ),
                    child: Text('Draft', style: GoogleFonts.poppins(color: Colors.white)),
                  ),
                  ElevatedButton(
                    onPressed: () => saveReport('Submitted'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 96, 32, 109),
                    ),
                    child: Text('Submit', style: GoogleFonts.poppins(fontSize: 14, color: Colors.white)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      // Navigation bar addition
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
        color: Colors.white, // Bottom navigation bar color changed to white
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
