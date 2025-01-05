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
    // Check if "hit" is mentioned first
    if (RegExp(r'\b(hit)\b', caseSensitive: false).hasMatch(message)) {
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
    } else if (message.toLowerCase().contains("sign") || message.toLowerCase().contains("symptom")) {
      setState(() {
        _messages.add({
          "bot_image": Image.asset(
            "assets/sign.png",
            width: 450,
            height: 450,
          ),
        });
      });
    } else if (message.toLowerCase().contains("what") || message.toLowerCase().contains("do")) {
      _addTextResponse("Contact us and lodge your report now through our Capture feature.");
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
                          fontSize: screenWidth * 0.04,
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
