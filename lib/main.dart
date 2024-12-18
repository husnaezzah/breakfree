import 'package:flutter/material.dart';
import 'signup_page.dart';
import 'login_page.dart';
import 'home_page.dart';
import 'profile_page.dart';
import 'capture_page.dart';
import 'qa_page.dart';
import 'assistance_page.dart';
import 'history_page.dart';

void main() {
  runApp(MyApp());
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
        '/': (context) => HomePage(), //this is homepage
        '/signup': (context) => SignUpPage(), // this is sign up page
        '/login': (context) => LoginPage(), // this is login page
        '/home': (context) => HomePage(), // this is home page
        '/profile': (context) => ProfilePage(), // this is profile page
        '/capture': (context) => CapturePage(), // this is capture page
        '/qa': (context) => QAPage(), // this is qa page
        '/assistance': (context) => AssistancePage(), // this is assistance page
        '/history': (context) => HistoryPage(), // this is history page
      },
    );
  }
}

