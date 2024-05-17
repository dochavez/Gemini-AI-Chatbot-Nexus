import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gemini_ai_chatbot_nexus/TextToSpeech.dart';
import 'package:gemini_ai_chatbot_nexus/image_recognition_ui.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'message.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'dart:io';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  List<Message> messages = [];
  Color blueMainColor = const Color(0xFF151026);
  late Future<String?> data;
  late TextToSpeech tts;
  bool is_playing_audio_user_input=false;
  bool is_playing_audio_gemini_response=false;


  Future<String?> consumeGeminiAPI(String chatInput) async {
    ///This is just for text input and output
    final model = GenerativeModel(
        model: 'gemini-pro', apiKey: "API-KEY");

    final content = [
      Content.multi([
        TextPart(chatInput),
      ])
    ];

    final response = await model.generateContent(content);
    messages.add(Message(response.text!, false));
    return response.text;
  }

  void createPdfFile(String content) async {
    final PdfDocument document = PdfDocument();
    final PdfPageTemplateElement footerTemplate = PdfPageTemplateElement(const Rect.fromLTWH(0, 0, 515, 50));

    footerTemplate.graphics.drawString('By Gemini AI Chat-bot Nexus project',
        PdfStandardFont(PdfFontFamily.helvetica, 10),
        bounds: const Rect.fromLTWH(0, 15, 200, 20));
    document.template.bottom = footerTemplate;

    final PdfPage page = document.pages.add();

    final PdfLayoutResult layoutResult = PdfTextElement(
            text: content,
            font: PdfStandardFont(PdfFontFamily.helvetica, 12),
            brush: PdfSolidBrush(PdfColor(0, 0, 0)))
        .draw(
            page: page,
            bounds: Rect.fromLTWH(
                0, 0, page.getClientSize().width, page.getClientSize().height),
            format: PdfLayoutFormat(layoutType: PdfLayoutType.paginate))!;

    List<int> bytes = await document.save();
    document.dispose();

    final directory = await getApplicationSupportDirectory();
    final path = directory.path;
    File file = File('$path/chat-export.pdf');

    await file.writeAsBytes(bytes, flush: true);
    OpenFile.open('$path/chat-export.pdf');
  }

  @override
  void initState() {
    super.initState();
    tts = TextToSpeech();
    data = consumeGeminiAPI("Hello!");
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.red,
          leading: IconButton(
            icon: const Icon(Icons.chat, color: Colors.white), // Example icon
            onPressed: () => Navigator.pop(context), // Handle back button press
          ),
          title: const Text('Gemini ai chat-bot nexus',
              style: TextStyle(color: Colors.white)),
          centerTitle: true, // Optional: Center the title
          bottom: const TabBar(
            unselectedLabelColor: Colors.white,
            indicatorColor: Colors.green,
            tabs: [
              Tab(
                  icon: Icon(
                Icons.chat,
                color: Colors.white,
              )),
              Tab(
                  icon: Icon(
                Icons.image,
                color: Colors.white,
              )),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            chatUI(),
            ImageRecognitionUI(),
          ],
        ),
      ),
    );
  }

  Widget chatUI() {
    return Column(children: <Widget>[
      messageUI(),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0),
        child: Container(
          color: blueMainColor,
          child: Padding(
            padding: const EdgeInsets.all(5),
            child: _chatUserInputComponents(),
          ),
        ),
      ),
    ]); // Show UI with data
  }

  Widget messageUI() {
    return FutureBuilder<String?>(
      future: data,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Expanded(
              child: Center(
            child: CircularProgressIndicator(
              color: Colors.amber,
              strokeWidth: 2,
            ),
          )); // Show loading indicator
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}'); // Handle error
        } else {
          return Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                return ListTile(
                  title: Align(
                    alignment:
                        message.isUser ? Alignment.topRight : Alignment.topLeft,
                    child: Row(
                      // Use Row for icon and text
                      mainAxisSize: MainAxisSize.min, // Avoid excessive space
                      children: [
                        if (!message.isUser) // Show icon for blue messages
                          const Icon(Icons.people, color: Colors.blue),
                        const SizedBox(width: 8.0), // Add some spacing
                        Expanded(
                          // Flexible container for text
                          child: Container(
                            padding: const EdgeInsets.all(10.0),
                            margin: const EdgeInsets.symmetric(vertical: 4.0),
                            decoration: BoxDecoration(
                              color: message.isUser ? Colors.red : Colors.blue,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisSize:
                                  MainAxisSize.min, // Avoid excessive space
                              children: [
                                if (message
                                    .isUser) // Show flower icon for red messages (left-aligned)
                                  IconButton(
                                    onPressed: () {
                                      if(is_playing_audio_user_input==false){
                                        setState(() {
                                          is_playing_audio_user_input=true;
                                        });
                                         tts.speak(message.text.toString());

                                      }else{
                                        tts.stop();
                                        setState(() {
                                          is_playing_audio_user_input=false;
                                        });
                                      }
                                    },
                                    icon: Icon(
                                        is_playing_audio_user_input == false? CupertinoIcons.speaker_2_fill: CupertinoIcons.stop_circle,
                                        color: Colors.white),
                                  ),
                                const SizedBox(width: 8.0), // Add some spacing

                                // Flexible container for text, ensuring it expands first
                                Flexible(
                                  child: AutoSizeText(
                                    message.text,
                                    maxLines:
                                        50, // Adjust for single-line or multiline as needed
                                    //overflowReplacement: TextOverflow.ellipsis, // Truncate if too long
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),

                                if (!message
                                    .isUser) // Show flower icon for blue messages (right-aligned)
                                  Row(
                                    children: [
                                      IconButton(
                                        onPressed: () {
                                          if(is_playing_audio_gemini_response==false){
                                            setState(() {
                                              is_playing_audio_gemini_response=true;
                                            });
                                            tts.speak(message.text.toString());

                                          }else{
                                            tts.stop();
                                            setState(() {
                                              is_playing_audio_gemini_response=false;
                                            });
                                          }
                                        },
                                        icon:  Icon(
                                           is_playing_audio_gemini_response == false? CupertinoIcons.speaker_2_fill: CupertinoIcons.stop_circle,
                                            color: Colors.white),
                                      ),
                                      IconButton(
                                        onPressed: () => createPdfFile(
                                            message.text.toString()),
                                        icon: const Icon(Icons.print,
                                            color: Colors.white),
                                      ),
                                    ],
                                  )
                              ],
                            ),
                          ),
                        ),

                        if (message.isUser) // Show icon for red messages
                          const Flexible(
                            child:
                                Icon(Icons.directions_car, color: Colors.red),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        }
      },
    );
  }

  Row _chatUserInputComponents() {
    return Row(
      children: <Widget>[
        Expanded(
            child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.60,
          child: TextField(
            controller: _controller,
            decoration: const InputDecoration(
              hintText: 'Type a message here...',
              fillColor: Colors.white,
              filled: true,
              border: OutlineInputBorder(),
            ),
          ),
        )),
        Container(
          color: Colors.green,
          height: 62,
          child: IconButton(
            icon: const Icon(
              Icons.send,
              color: Colors.white,
            ),
            onPressed: () async {
              if (_controller.text.isNotEmpty) {
                setState(() {
                  messages.add(Message(_controller.text, true));
                });
                data = consumeGeminiAPI(_controller.text.trim()).then((value) {
                  _controller.clear();
                });
              }
            },
          ),
        ),
        Container(
          color: Colors.red,
          height: 62,
          child: IconButton(
            icon: const Icon(
              Icons.delete_forever_outlined,
              color: Colors.white,
            ),
            onPressed: () async {
              setState(() {
                messages.clear();
              });
            },
          ),
        )
      ],
    );
  }
}
