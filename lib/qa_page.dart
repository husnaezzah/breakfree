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
        message.toLowerCase().contains("nearby") ||
        message.toLowerCase().contains("aid") ||
        message.toLowerCase().contains("resources") ||
        message.toLowerCase().contains("assistance")) {
      _addTextResponse("Please don't hesitate to take action and reach out to these resources. Your safety is our top priority.");
      _addAssistanceButton();

    }  else if (message.toLowerCase().contains("report") ||
        message.toLowerCase().contains("evidence") ||
        message.toLowerCase().contains("capture") ||
        message.toLowerCase().contains("photo") ||
        message.toLowerCase().contains("file") ||
        message.toLowerCase().contains("upload")) {
      _addCaptureButton();  // Add button to go to capture page

    }  else if (message.toLowerCase().contains("forum") ||
        message.toLowerCase().contains("discussion") ||
        message.toLowerCase().contains("community") ||
        message.toLowerCase().contains("group") ||
        message.toLowerCase().contains("support") ||
        message.toLowerCase().contains("share") ||
        message.toLowerCase().contains("experience") ||
        message.toLowerCase().contains("post") ||
        message.toLowerCase().contains("find") ||
        message.toLowerCase().contains("online")) {
      _addForumButton();  // Add button to go to forum page

    }  else if (message.toLowerCase().contains("SOS") ||
        message.toLowerCase().contains("sos") ||
        message.toLowerCase().contains("emergency") ||
        message.toLowerCase().contains("alert") ||
        message.toLowerCase().contains("quick") ||
        message.toLowerCase().contains("panic") ||
        message.toLowerCase().contains("contact") ||
        message.toLowerCase().contains("notify") ||
        message.toLowerCase().contains("hotline") ||
        message.toLowerCase().contains("crisis") ||
        message.toLowerCase().contains("call")) {
      _addSOSButton();  // Add button to go to SOS page

        } else if (message.toLowerCase().contains("tired") ||
          message.toLowerCase().contains("down") ||
          message.toLowerCase().contains("exhaust") ||
          message.toLowerCase().contains("fatigue") ||
          message.toLowerCase().contains("drain") ||
          message.toLowerCase().contains("burn") ||
          message.toLowerCase().contains("low") ||
          message.toLowerCase().contains("down") ||
          message.toLowerCase().contains("unhappy") ||
          message.toLowerCase().contains("dispirit") ||
          message.toLowerCase().contains("sorrow") ||
          message.toLowerCase().contains("upset") ||
          message.toLowerCase().contains("mourn") ||
          message.toLowerCase().contains("sad")) {
        _addTextResponse("I'm sorry you're feeling this way. It's okay to have tough days. Remember, you're not alone, and it's important to take care of yourself. If you need someone to talk to, consider reaching out to a trusted person or a support hotline. You can also explore the resources in BreakFree for additional help :)");

    }  else if (message.toLowerCase().contains("history") ||
        message.toLowerCase().contains("delete") ||
        message.toLowerCase().contains("view")) {
      _addHistoryButton();  // Add button to go to history page

    } else if (RegExp(r'\b(hit)\b', caseSensitive: false).hasMatch(message)) {
      _addTextResponse("No one should ever hit you. If you're in immediate danger, please activate the SOS button or contact emergency services.");
    } else if (message.toLowerCase().contains("hello") || message.toLowerCase().contains("hi")) {
      _addTextResponse("Hello! How can I assist you today?");
    } else if (message.toLowerCase().contains("domestic") ||
        message.toLowerCase().contains("violence") ||
        message.toLowerCase().contains("abuse")) {
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

    } else if (message.toLowerCase().contains("signs") || message.toLowerCase().contains("symptoms")) {
      setState(() {
        _messages.add({
          "bot_image": Image.asset(
            "assets/physical_harm.png",
            width: 450,
            height: 450,
          ),
        });
        _messages.add({
          "bot_image": Image.asset(
            "assets/verbal_threat.png",
            width: 450,
            height: 450,
          ),
        });
        _messages.add({
          "bot_image": Image.asset(
            "assets/behavior_control.png",
            width: 450,
            height: 450,
          ),
          
        });
         _messages.add({
          "bot_image": Image.asset(
            "assets/isolation.png",
            width: 450,
            height: 450,
          ),
        });
        _addTextResponse("These are the most common signs in domestic violence.");
      });

        } else if (message.toLowerCase().contains("physical harm") || message.toLowerCase().contains("physical") || message.toLowerCase().contains("harm")) {
        setState(() {
        _messages.add({
          "bot_image": Image.asset(
            "assets/physical_harm.png",
            width: 450,
            height: 450,
          ),
        });
        _addTextResponse("Physical harm often starts subtly, like pushing or grabbing, and can escalate to severe violence. This is a clear violation of safety and boundaries.");
      });
      } else if (message.toLowerCase().contains("verbal threats") || message.toLowerCase().contains("verbal") || message.toLowerCase().contains("threats")) {
        setState(() {
          _messages.add({
            "bot_image": Image.asset(
              "assets/verbal_threats.png",
              width: 450,
              height: 450,
            ),
          });
          _addTextResponse("Verbal threats can involve insults, humiliation, or frightening statements that make you feel worthless or afraid to speak up. They aim to instill fear and maintain control over the victim.");
        });
        } else if (message.toLowerCase().contains("behavior control") || message.toLowerCase().contains("controlling behavior") || message.toLowerCase().contains("control")) {
          setState(() {
            _messages.add({
              "bot_image": Image.asset(
                "assets/behavior_control.png",
                width: 450,
                height: 450,
              ),
            });
            _addTextResponse("Controlling behavior can look like constant checking of your location, deciding what you can or can't do, or using guilt to manipulate decisions.");
          });
        } else if (message.toLowerCase().contains("isolation") || message.toLowerCase().contains("isolating")) {
          setState(() {
            _messages.add({
              "bot_image": Image.asset(
                "assets/isolation.png",
                width: 450,
                height: 450,
              ),
            });
            _addTextResponse("Isolation doesn't just mean keeping you away from people—it can also mean discouraging you from sharing your feelings or seeking outside help.");
          });
            
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
        _addTextResponse("OR directly");
        _addSOSButton();
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

  // Method to add a button to navigate to the capture page
  void _addCaptureButton() {
    setState(() {
      _messages.add({
        "bot": TextButton(
          onPressed: () {
            Navigator.pushNamed(context, '/capture');  // Navigate to the Capture Page
          },
          style: TextButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 96, 32, 109), // Set your desired background color
          ),
          child: Text(
            'Go to Capture Page',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.white,
            ),
          ),
        ),
      });
    });
  }

  // Method to add a button to navigate to the history page
  void _addHistoryButton() {
    setState(() {
      _messages.add({
        "bot": TextButton(
          onPressed: () {
            Navigator.pushNamed(context, '/history');  // Navigate to the Capture Page
          },
          style: TextButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 96, 32, 109), // Set your desired background color
          ),
          child: Text(
            'Go to History Page',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.white,
            ),
          ),
        ),
      });
    });
  }

  // Method to add a button to navigate to the forum page
  void _addForumButton() {
    setState(() {
      _messages.add({
        "bot": TextButton(
          onPressed: () {
            Navigator.pushNamed(context, '/forum');  // Navigate to the Capture Page
          },
          style: TextButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 96, 32, 109), // Set your desired background color
          ),
          child: Text(
            'Go to Forum Page',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.white,
            ),
          ),
        ),
      });
    });
  }

  // Method to add a button to navigate to the assistance page
  void _addSOSButton() {
    setState(() {
      _messages.add({
        "bot": TextButton(
          onPressed: () {
            Navigator.pushNamed(context, '/sos');  // Navigate to the Assistance Page
          },
          style: TextButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 96, 32, 109), // Set your desired background color
          ),
          child: Text(
            'Go to SOS Page',
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
