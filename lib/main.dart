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
import 'forum_page.dart';
import 'view_page.dart';

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
        '/startup': (context) => StartupPage(),
        '/signup': (context) => SignUpPage(),
        '/login': (context) => LoginPage(),
        '/home': (context) => HomePage(),
        '/profile': (context) => ProfilePage(),
        '/capture': (context) => CapturePage(),
        '/qa': (context) => QAPage(),
        '/assistance': (context) => AssistancePage(),
        '/history': (context) => HistoryPage(),
        '/sos': (context) => SOSPage(),
        '/forum': (context) => ForumPage(),
      },
      // Handle dynamic routes here
      onGenerateRoute: (RouteSettings settings) {
    if (settings.name == '/view') {
      final args = settings.arguments as Map<String, dynamic>;
      return MaterialPageRoute(
        builder: (context) => ViewPage(caseId: args['caseId']),
      );
    }
        return null; // Return null if no matching route is found
      },
    );
  }
}
