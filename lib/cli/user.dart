import 'package:mutter_cli/db/database_crud.dart';
import 'package:mutter_cli/cli/message.dart';
import 'package:bcrypt/bcrypt.dart';

class User {
  late String username;
  late String password;
  var loggedIn = false;
  late List<DirectMessage> directMessages;
  User(
      this.username,
      password,
      this.loggedIn,
      this.directMessages) {
        var salt = BCrypt.gensalt();
    this.password = BCrypt.hashpw(password, salt);
  }
  //to be called upon object creation
  Map<String, dynamic> toMap() {
    var mappedMessages =
        directMessages.map((message) => message.toMap()).toList();
    return {
      'username': username,
      'password': password,
      'loggedIn': loggedIn,
      'directMessages': mappedMessages,
      'finder': "finder",
    };
  }

  static User fromMap(Map<String, dynamic> map) {
    var unmappedMessages = (map['directMessages'] as List)
        .map((dm) => DirectMessage.fromMap(dm))
        .toList();
    return User(
      map['username'],
      map['password'],
      map['loggedIn'],
      unmappedMessages,
    );
  }

  Future<void> login(String password) async {
    //abhi ke liye no checks
    // var h = Crypt(this.password);
    // if(!h.match(password))
    bool authed = BCrypt.checkpw(password, this.password);
    if (!(authed)) {
      throw Exception("Error : Incorrect password");
    }
    this.loggedIn = true;
    await UserIO.updateDB(
        User(
            this.username,
            this.password,
            true,
            this.directMessages),
        "users");
  }

  Future<void> register() async {
    await DatabaseIO.addToDB(this, "users");
  }

  Future<void> logout() async {
    //abhi ke liye no checks
    await UserIO.updateDB(
        User(
            this.username,
            this.password,
            false,
            directMessages),
        "users");
  }

  Future<void> DM(User receiver, String content) async {
    receiver.directMessages.add(DirectMessage(content, this, DateTime.now()));
    await UserIO.updateDB(receiver, "users");
  }

  void showDMs(User sender) {
    // List<DirectMessage> senderToReceiver = this.getDMs(sender);
    // List<DirectMessage> receiverToSender = sender.getDMs(this);
    //needs refactoring, maybe better patterns for this
    // int sTrLen = senderToReceiver.length;
    // int rTsLen = receiverToSender.length;
    // int i = 0;
    // int j = 0;
    // while (i < sTrLen && j < rTsLen) {
    //   if (senderToReceiver[i].ts.isAfter(receiverToSender[j].ts)) {
    //     print("${this.username} : ${receiverToSender[j].content}");
    //     j++;
    //   } else {
    //     print("${sender.username} : ${senderToReceiver[i].content}");
    //     i++;
    //   }
    // }
    // while (i < sTrLen) {
    //   print("${sender.username} : ${senderToReceiver[i].content}");
    //   i++;
    // }
    // while (j < rTsLen) {
    //   print("${this.username} : ${receiverToSender[j].content}");
    //   j++;
    // }
    List<DirectMessage> dms = getDMs(sender);
    for (DirectMessage dm in dms) {
      print("${dm.ts.toString()}  ${dm.sender.username} : ${dm.content}");
    }
  }

  List<DirectMessage> getDMs(User sender) {
    List<DirectMessage> dms = [];
    for (DirectMessage message in directMessages) {
      if (message.sender.username == sender.username) {
        dms.add(message);
      }
    }
    return dms;
  }
}
