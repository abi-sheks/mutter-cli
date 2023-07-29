import 'package:mutter_cli/cli/user.dart';

class Message {
  final String content;
  final User sender;
  Message(this.content, this.sender);

  Map<String, dynamic> toMap() {
    return {
      'content' : content,
      'sender' : sender.toMap(),
      "finder" : "finder",
    };
  }
  static Message fromMap(Map<String, dynamic> map) {
    return Message(map['content'], User.fromMap(map['sender']));
  }
}
class DirectMessage extends Message {
  final DateTime ts;
  DirectMessage(content, sender, this.ts) : super(content, sender);
  @override
  Map<String, dynamic> toMap() {
    return {
      'content' : content,
      'sender' : sender.toMap(),
      'ts' : ts.toString(),
      "finder" : "finder",
    };
  }
  static DirectMessage fromMap(Map<String, dynamic> map) {
    return DirectMessage(map['content'], User.fromMap(map['sender']), DateTime.parse(map['ts']));
  }
}