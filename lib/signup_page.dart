// lib/signup_page.dart
import 'package:flutter/material.dart';
import 'login_page.dart';

class SignUpPage extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple[100],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              SizedBox(height: 50),
              Text(
                'BreakFree.',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              Text(
                'Register now',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 30),
              // First Name
              TextFormField(
                decoration: InputDecoration(labelText: 'First Name*'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your first name';
                  }
                  return null;
                },
              ),
              // Last Name
              TextFormField(
                decoration: InputDecoration(labelText: 'Last Name*'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your last name';
                  }
                  return null;
                },
              ),
              // Contact Number
              TextFormField(
                decoration: InputDecoration(labelText: 'Contact Number*'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your contact number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              // Emergency Contact 1
              Text('Emergency Contact 1', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              TextFormField(
                decoration: InputDecoration(labelText: 'First Name*'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter first name of emergency contact 1';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Last Name*'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter last name of emergency contact 1';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Contact Number 1*'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter contact number of emergency contact 1';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              // Emergency Contact 2
              Text('Emergency Contact 2', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              TextFormField(
                decoration: InputDecoration(labelText: 'First Name*'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter first name of emergency contact 2';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Last Name*'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter last name of emergency contact 2';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Contact Number 2*'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter contact number of emergency contact 2';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              // Email
              TextFormField(
                decoration: InputDecoration(labelText: 'Email*'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
              ),
              // Password
              TextFormField(
                decoration: InputDecoration(labelText: 'Password*'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              SizedBox(height: 30),
             ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    Navigator.pushReplacementNamed(context, '/login');
                  }
                },
                child: Text('Sign Up'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
