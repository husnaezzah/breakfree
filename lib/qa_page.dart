import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class QAPage extends StatefulWidget {
  @override
  _QAPageState createState() => _QAPageState();
}

class _QAPageState extends State<QAPage> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];

  // Simulate bot responses based on simple keywords or questions
  void _getBotResponse(String message) {
    // Check for specific keywords
    if (message.toLowerCase().contains("shelter") ||
        message.toLowerCase().contains("police") ||
        message.toLowerCase().contains("hospital") ||
        message.toLowerCase().contains("medical") ||
        message.toLowerCase().contains("assistance")) {
      _addTextResponse("Please don't hesitate to take action and reach out to these resources. Your safety is our top priority.");
      _addAssistanceButton();  // Add button to go to assistance page
    } else if (RegExp(r'\b(hit)\b', caseSensitive: false).hasMatch(message)) {
      _addTextResponse("No one should ever hit you. If you're in immediate danger, please activate the SOS button or contact emergency services.");
    } else if (message.toLowerCase().contains("hello") || message.toLowerCase().contains("hi")) {
      _addTextResponse("Hello! How can I assist you today?");
    } else if (message.toLowerCase().contains("domestic") || message.toLowerCase().contains("violence")) {
      setState(() {
        _messages.add({
          "bot_image": Image.asset(
            "assets/learn.png",
            width: 450,
            height: 450,
          ),
        });
        _messages.add({
          "bot_image": Image.asset(
            "assets/symptom.png",
            width: 450,
            height: 450,
          ),
        });
        _messages.add({
          "bot_image": Image.asset(
            "assets/sign.png",
            width: 450,
            height: 450,
          ),
        });
        _addTextResponse("Domestic violence is a serious issue, and BreakFree is here to provide support, resources, and information.");
      });
    } else if (message.toLowerCase().contains("resources")) {
      _addTextResponse("Our app provides local resources including nearby shelters, hospitals, and hotlines. You can find help close by anytime.");
    } else if (message.toLowerCase().contains("emergency")) {
      _addTextResponse("Activate SOS button now!");
    } else if (message.toLowerCase().contains("hurt")) {
      _addTextResponse("I'm sorry you're feeling hurt. If you're in danger, please use the SOS button for help or contact a trusted person or hotline.");
    } else if (message.toLowerCase().contains("confidentiality")) {
      _addTextResponse("Your privacy and safety are our top priorities. We offer data security to keep your information secure.");
    } else if (message.toLowerCase().contains("trauma")) {
      _addTextResponse("Our app is designed to be sensitive to trauma, avoiding potentially triggering content while offering support resources.");
    } else if (message.toLowerCase().contains("threat")) {
      _addTextResponse("Threats can be a form of emotional and psychological abuse, and your safety is the top priority. If you're in immediate danger, please contact emergency services or use the SOS button in the app for immediate assistance!");
    } else if (message.toLowerCase().contains("beat")) {
      _addTextResponse("Please try to get to a safe place for help. Navigate to the Assistance Page to view the nearest police stations and hospitals.");
    } else if (message.toLowerCase().contains("assault")) {
      _addTextResponse("If you are currently being assaulted or in immediate danger, please activate the SOS button now or contact emergency services right away. Your safety is the most important thing.");
    } else if (message.toLowerCase().contains("force")) {
      _addTextResponse("You have the right to make your own choices and take control of your situation. There are people who want to help you, and we can guide you to resources.");
    } else if (message.toLowerCase().contains("stigma")) {
      _addTextResponse("We understand the fear of stigma. Our app offers anonymous support, so you can access help privately and securely.");
    } else if (message.toLowerCase().contains("help")) {
      setState(() {
        _messages.add({
          "bot_image": Image.asset(
            "assets/sign.png",
            width: 450,
            height: 450,
          ),
        });
        _addTextResponse("OR Press the SOS button.");
      });
    } else {
      _addTextResponse("I'm here to help, but I didn't quite understand that. Could you please rephrase?");
    }
  }

  // Method to add a text response to the messages
  void _addTextResponse(String response) {
    setState(() {
      _messages.add({
        "bot": Text(
          response,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.normal,
          ),
        ),
      });
    });
  }

  // Method to add a button to navigate to the assistance page
  void _addAssistanceButton() {
    setState(() {
      _messages.add({
        "bot": TextButton(
          onPressed: () {
            Navigator.pushNamed(context, '/assistance');  // Navigate to the Assistance Page
          },
          style: TextButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 96, 32, 109), // Set your desired background color
          ),
          child: Text(
            'Go to Assistance Page',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.white,
            ),
          ),
        ),
      });
    });
  }

  // Send the user's message
  void _sendMessage(String message) {
    setState(() {
      _messages.add({"user": message});
    });
    _controller.clear();
    _getBotResponse(message);  // Generate bot response
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Color.fromARGB(255, 251, 247, 247),
      appBar: AppBar(
        title: Text(
          "BreakFree.",
          style: GoogleFonts.poppins(
            color: Color.fromARGB(255, 251, 247, 247),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: ModalRoute.of(context)?.settings.name == '/home'
        ? null 
        : IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
          },
        ),
        backgroundColor: const Color.fromARGB(255, 96, 32, 109),
      ),
      body: Column(
        children: [
          // Default message to guide users
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Center(  // Center the text horizontally
              child: Text(
                'Ask questions to learn about domestic violence, recognize signs, and find support resources available to you.',
                textAlign: TextAlign.center,  // Use textAlign here directly
                style: GoogleFonts.poppins(
                  fontSize: screenWidth * 0.035,  // Adjusted font size to make it smaller
                  fontStyle: FontStyle.italic,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];

                if (message.containsKey("bot_image")) {
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: message["bot_image"],
                    ),
                  );
                }

                // If the message is a button, return it without background color
                if (message.containsKey("bot") && message["bot"] is TextButton) {
                  return Align(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: message["bot"],
                    ),
                  );
                }

                // Otherwise, it's a regular message
                return ListTile(
                  title: Align(
                    alignment: message.containsKey("user")
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05, vertical: 12),
                      decoration: BoxDecoration(
                        color: message.containsKey("user")
                            ? Colors.grey[100]
                            : Colors.purple[100], // This applies only to user/bot messages
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: message.containsKey("user")
                          ? Text(
                              message["user"]!,
                              style: GoogleFonts.poppins(
                                fontSize: screenWidth * 0.04,
                                fontWeight: FontWeight.normal,
                              ),
                            )
                          : message["bot"]!,
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(10.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsetsDirectional.symmetric(vertical: 8.0, horizontal: 16),
                      hintText: "Ask a question...",
                      hintStyle: GoogleFonts.poppins(
                        fontSize: screenWidth * 0.035,
                        color: Colors.grey[500],
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.send,
                    color: const Color.fromARGB(255, 96, 32, 109)),
                  onPressed: () {
                    if (_controller.text.isNotEmpty) {
                      _sendMessage(_controller.text);
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
