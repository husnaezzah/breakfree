import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'login_page.dart';
import 'home_page.dart';
import 'signup_page.dart';
import 'profile_page.dart';
import 'capture_page.dart';
import 'qa_page.dart';
import 'assistance_page.dart';
import 'history_page.dart';
import 'sos_page.dart';
import 'startup_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure Flutter is initialized before Firebase
  await Firebase.initializeApp(); // Initialize Firebase
  runApp(MyApp()); // Run your app
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BreakFree',
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      initialRoute: '/startup', // Set the initial route to the StartupPage
      routes: {
        '/startup': (context) => StartupPage(), // Startup page
        '/signup': (context) => SignUpPage(), // Sign up page
        '/login': (context) => LoginPage(), // Login page
        '/home': (context) => HomePage(), // Home page
        '/profile': (context) => ProfilePage(), // Profile page
        '/capture': (context) => CapturePage(), // Capture page
        '/qa': (context) => QAPage(), // Q&A page
        '/assistance': (context) => AssistancePage(), // Assistance page
        '/history': (context) => HistoryPage(), // History page
        '/sos': (context) => SOSPage(), // SOS page
      },
    );
  }
}