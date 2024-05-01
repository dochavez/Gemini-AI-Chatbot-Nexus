import 'package:flutter_tts/flutter_tts.dart';

class TextToSpeech {
  late FlutterTts flutterTts;

  TextToSpeech() {
    flutterTts = FlutterTts();
   flutterTts.setLanguage("en-es");//set the default language

  }

  Future speak(String text) async {
    var result = await flutterTts.speak(text);
    if (result == 1) print("Speaking .....");
  }

  Future stop() async {
    var result = await flutterTts.stop();
    if (result == 1) print("audio playback has ended");
  }
}
