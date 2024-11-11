import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class QAPage extends StatefulWidget {
  @override
  _QAPageState createState() => _QAPageState();
}

class _QAPageState extends State<QAPage> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = []; // Use dynamic type to store Image widgets

  // Simulate bot responses based on simple keywords or questions
  void _getBotResponse(String message) {
    if (message.toLowerCase().contains("hello") || message.toLowerCase().contains("hi")) {
      _addTextResponse("Hello! How can I assist you today?");

    } else if (message.toLowerCase().contains("domestic") || message.toLowerCase().contains("violence")) {
      setState(() {
        _messages.add({
          "bot_image": Image.asset(
            "assets/sign.png",
            width: 450, // Set desired width
            height: 450, // Set desired height
          ),
        });
        _messages.add({
          "bot_image": Image.asset(
            "assets/help.png",
            width: 450, // Set desired width
            height: 450, // Set desired height
          ),
        });
        _addTextResponse("Domestic violence is a serious issue, and BreakFree is here to provide support, resources, and information.");
      });

    } else if (message.toLowerCase().contains("sign") || message.toLowerCase().contains("symptom")) {
      setState(() {
        _messages.add({
          "bot_image": Image.asset(
            "assets/sign.png",
            width: 450, // Set desired width
            height: 450, // Set desired height
          ),
        });
      });

    } else if (message.toLowerCase().contains("what") || message.toLowerCase().contains("do")) {
      _addTextResponse("Contact us and lodge your report now through our Capture feature.");

    } else if (message.toLowerCase().contains("resources")) {
      _addTextResponse("Our app provides local resources including nearby shelters, hospitals, and hotlines. You can find help close by anytime.");

    } else if (message.toLowerCase().contains("emergency")) {
      _addTextResponse("Activate SOS button now!");

    } else if (message.toLowerCase().contains("help")) {
      // Add an image response for help or emergency
      setState(() {
        _messages.add({
          "bot_image": Image.asset(
            "assets/help.png",
            width: 450, // Set desired width
            height: 450, // Set desired height
          ),
        });
        _addTextResponse("OR Press the SOS button.");
      });

    } else if (message.toLowerCase().contains("confidentiality")) {
      _addTextResponse("Your privacy and safety are our top priorities. We offer data security to keep your information secure.");

    } else if (message.toLowerCase().contains("trauma")) {
      _addTextResponse("Our app is designed to be sensitive to trauma, avoiding potentially triggering content while offering support resources.");
      
    } else if (message.toLowerCase().contains("stigma")) {
      _addTextResponse("We understand the fear of stigma. Our app offers anonymous support, so you can access help privately and securely.");
      
    } else {
      _addTextResponse("I'm here to help, but I didn't quite understand that. Could you please rephrase?");
    }
  }

  // Helper method to add a text response to the messages
  void _addTextResponse(String response) {
    setState(() {
      _messages.add({"bot": response});
    });
  }

  void _sendMessage(String message) {
    setState(() {
      _messages.add({"user": message});
    });
    _controller.clear();
    _getBotResponse(message); // Generate bot response
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "BreakFree Chatbot",
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.purple[100],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];

                // Check if the message contains an image widget
                if (message.containsKey("bot_image")) {
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: message["bot_image"], // Directly use the Image widget
                    ),
                  );
                }

                // Handle text messages
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
                            : Colors.purple[100],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        message.containsKey("user")
                            ? message["user"]!
                            : message["bot"]!,
                        style: GoogleFonts.poppins(
                          fontSize: screenWidth * 0.04,  // Dynamic font size
                          fontWeight: FontWeight.normal,
                        ),
                      ),
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
                      hintText: "Ask a question...",
                      hintStyle: GoogleFonts.poppins(
                        fontSize: screenWidth * 0.04,  // Dynamic hint text size
                        color: Colors.grey[500],
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
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