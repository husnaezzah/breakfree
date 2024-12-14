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
        '/login': (context) => LoginPage(),
        '/home': (context) => HomePage(),
        '/profile': (context) => ProfilePage(),
        '/capture': (context) => CapturePage(),
        '/qa': (context) => QAPage(),
        '/assistance': (context) => AssistancePage(),
        '/history': (context) => HistoryPage(),
      },
    );
  }
}

//test
