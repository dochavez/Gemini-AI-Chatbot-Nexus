import 'dart:io';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'TextToSpeech.dart';

class ImageRecognitionUI extends StatefulWidget {
  @override
  _ImageRecognitionUIState createState() => _ImageRecognitionUIState();
}

class _ImageRecognitionUIState extends State<ImageRecognitionUI> {
  File? _imageFile;
  String default_text_desciption =
      "here you will see the description of the images you have indicated";
  final TextToSpeech tts = TextToSpeech();
  bool is_playing = false;

  Future<void> _captureImage(int opc) async {
    final picker = ImagePicker();
    late final pickedFile;
    if (opc == 1) {
      pickedFile = await picker.pickImage(source: ImageSource.camera);
    } else {
      pickedFile = await picker.pickMedia();
    }
    setState(() {
      _imageFile = File(pickedFile!.path);
    });
  }

  void _clearImage() {
    setState(() {
      _imageFile = null;
    });
  }

  Future<String> consumeGeminiAPI() async {
    final model = GenerativeModel(
        model: 'gemini-pro-vision',
        apiKey: "API-KEY");
    const prompt =
        "describe the image and if you don't understand it, tell me you don't understand it.";
    final imageBytes = await _imageFile!.readAsBytes();
    final content = [
      Content.multi([
        TextPart(prompt),
        DataPart('image/png', imageBytes),
      ])
    ];
    final response = await model.generateContent(content);
    return response.text.toString();
  }

  Widget mainView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * 0.50,
          decoration: BoxDecoration(
            color: _imageFile != null ? null : Colors.grey,
            border: Border.all(color: Colors.black),
          ),
          child: _imageFile != null
              ? Image.file(
                  _imageFile!,
                  fit: BoxFit.cover,
                )
              : const Icon(
                  Icons.camera_alt,
                  size: 50,
                ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ElevatedButton(
              onPressed: _showMyDialog,
              child: const Text('Upload an image'),
            ),
            ElevatedButton(
              onPressed: () {
                consumeGeminiAPI().then((value) {
                  setState(() {
                    default_text_desciption = value.toString();
                  });
                });
              },
              child: const Text('Get the description'),
            ),
            ElevatedButton(
              onPressed: _clearImage,
              child: const Text('Clean'),
            ),
          ],
        ),
        Expanded(
          child: AutoSizeText(
            default_text_desciption,
            maxLines: 50, // Adjust for single-line or multiline as needed
            //overflowReplacement: TextOverflow.ellipsis, // Truncate if too long
            style: const TextStyle(color: Colors.black),
          ),
        ),
        _listenExportImageDescriptionComponents(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: mainView(),
    );
  }

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            "Where do you want your image from?",
            style: TextStyle(fontSize: 16),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                InkWell(
                  onTap: () {
                    _captureImage(1).then((value) {
                      Navigator.of(context).pop();
                    });
                  },
                  child: Container(
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                      color: Colors.blue,
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Icon(
                            Icons.camera,
                            size: 30,
                            color: Colors.white,
                          ),
                          Text("From Camera",
                              style:
                                  TextStyle(fontSize: 22, color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                InkWell(
                  onTap: () {
                    _captureImage(2).then((value) {
                      Navigator.of(context).pop();
                    });
                  },
                  child: Container(
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                      color: Colors.blue,
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Icon(Icons.perm_media, size: 30, color: Colors.white),
                          Text("From files",
                              style:
                                  TextStyle(fontSize: 22, color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void createPdfFile(String content) async {
    final PdfDocument document = PdfDocument();
    final PdfPageTemplateElement footerTemplate =
        PdfPageTemplateElement(const Rect.fromLTWH(0, 0, 515, 50));
    footerTemplate.graphics.drawString('By Gemini AI Chat-bot Nexus project',
        PdfStandardFont(PdfFontFamily.helvetica, 10),
        bounds: const Rect.fromLTWH(0, 15, 200, 20));
    //Set footer in the document.
    document.template.bottom = footerTemplate;

    final PdfPage page = document.pages.add();
    // Create a new PDF text element class and draw the flow layout text.
    final PdfLayoutResult layoutResult = PdfTextElement(
            text: content,
            font: PdfStandardFont(PdfFontFamily.helvetica, 12),
            brush: PdfSolidBrush(PdfColor(0, 0, 0)))
        .draw(
            page: page,
            bounds: Rect.fromLTWH(
                0, 0, page.getClientSize().width, page.getClientSize().height),
            format: PdfLayoutFormat(layoutType: PdfLayoutType.paginate))!;

    //Save the document
    List<int> bytes = await document.save();
    //Dispose the document
    document.dispose();
    //Get external storage directory
    final directory = await getApplicationSupportDirectory();
    final path = directory.path;
    File file = File('$path/export-document.pdf');

//Write PDF data
    await file.writeAsBytes(bytes, flush: true);

//Open the PDF document in mobile
    OpenFile.open('$path/export-document.pdf');
  }

  Widget _listenExportImageDescriptionComponents() {
    return Container(
      color: const Color(0xFF151026),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            IconButton(
                onPressed: () {
                  if (is_playing == false) {
                    setState(() {
                      is_playing = true;
                      tts.speak(default_text_desciption);
                    });
                  } else {
                    setState(() {
                      is_playing = false;
                      tts.stop();
                    });
                  }
                },
                icon: Icon(
                  is_playing == false
                      ? CupertinoIcons.speaker_2_fill
                      : CupertinoIcons.stop_circle,
                  size: 30,
                  color: Colors.white,
                )),
            IconButton(
                onPressed: () {
                  createPdfFile(default_text_desciption);
                },
                icon: const Icon(
                  Icons.print,
                  color: Colors.white,
                  size: 30,
                )),
          ],
        ),
      ),
    );
  }
}
