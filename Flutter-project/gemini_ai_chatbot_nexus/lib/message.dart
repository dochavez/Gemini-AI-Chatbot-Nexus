///this class is the structure of the messages, as a defined template
class Message {
  String text;
  bool isUser; // True if this message was sent by the user or not, in the ui color change if the user send the message or not
  Message(this.text, this.isUser);
}
