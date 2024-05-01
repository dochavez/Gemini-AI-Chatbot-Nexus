import 'package:flutter/material.dart';
import 'package:gemini_ai_chatbot_nexus/chat_screen.dart';

class FirstScreen extends StatelessWidget {

  final icons_dict = {
    "0": [Icons.mic, "Voice response"],
    "1": [Icons.text_fields, "Prompt Text"],
    "2": [Icons.image, "Images"],
    "3": [Icons.chat, "Use chat-bot"],
    "4": [Icons.download, "Export your conversation"],
    "5": [Icons.label, "Share your experience"],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('What can i do?', style: TextStyle(color: Colors.white, fontSize: 24),),
        backgroundColor: Colors.red,
      ),
      backgroundColor: Colors.white70,
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
              itemCount: icons_dict.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
              ),
              itemBuilder: (context, index) {
                return GridTile(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Container(
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(40.0), // Set desired radius
                          bottomRight: Radius.circular(40.0), // Set desired radius
                        ),
                        color: Colors.white
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(icons_dict["$index"]?[0] as IconData?, size: 40, color: Colors.blue,),
                            const SizedBox(height: 22),
                            Text(icons_dict["$index"]![1].toString()),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Container(
              padding: const EdgeInsets.all(16),
              width: MediaQuery.of(context).size.width,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(12)),
                color: Colors.blue,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    "Be respectful, don't be rude, don't be offensive and maintain proper conduct when using the application.",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                      color: Colors.red,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextButton(
                        onPressed: () {

                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const ChatScreen()),
                          );
                        },
                        child: const Text(
                          'CONTINUE >>',
                          style: TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}