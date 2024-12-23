import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';  // Import Firebase core
import 'signup_page.dart';
import 'login_page.dart';
import 'home_page.dart';
import 'profile_page.dart';
import 'capture_page.dart';
import 'qa_page.dart';
import 'assistance_page.dart';
import 'history_page.dart';
import 'sos_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();  // Ensure Flutter is initialized before Firebase
  await Firebase.initializeApp();  // Initialize Firebase
  runApp(MyApp());  // Run your app
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BreakFree',
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => HomePage(), // this is homepage
        '/signup': (context) => SignUpPage(), // this is sign up page
        '/login': (context) => LoginPage(), // this is login page
        '/home': (context) => HomePage(), // this is home page
        '/profile': (context) => ProfilePage(), // this is profile page
        '/capture': (context) => CapturePage(), // this is capture page
        '/qa': (context) => QAPage(), // this is qa page
        '/assistance': (context) => AssistancePage(), // this is assistance page
        '/history': (context) => HistoryPage(), // this is history page
        '/sos': (context) => SOSPage(), // this is sos page 
      },
    );
  }
}