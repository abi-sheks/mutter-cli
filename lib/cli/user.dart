import 'package:mutter_cli/db/database_crud.dart';
import 'package:mutter_cli/cli/message.dart';

class User {
  late String username;
  late String password;
  var loggedIn = false;
  late List<DirectMessage> directMessages;
  User({required this.username, required this.password, required this.loggedIn, required this.directMessages});

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
      username : map['username'],
      password : map['password'],
      loggedIn : map['loggedIn'],
      directMessages : unmappedMessages,
    );
  }

  Future<void> login(String password) async {
    //abhi ke liye no checks
    // var h = Crypt(this.password);
    // if(!h.match(password))
    if (!(this.password == password)) {
      throw Exception("Error : Incorrect password");
    }
    print("Idhr toh aa rhi?");
    this.loggedIn = true;
    await UserIO.updateDB(
        User(username : this.username, password : this.password,loggedIn :  true, directMessages : this.directMessages), "users");
  }

  Future<void> register() async {
    print("hehehe");
    await DatabaseIO.addToDB(this, "users");
    print("done");
  }

  Future<void> logout() async {
    //abhi ke liye no checks
    await UserIO.updateDB(
        User(username : this.username,password : this.password, loggedIn : false, directMessages : directMessages),
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
    for(DirectMessage dm in dms) {
      print("${dm.sender.username} : ${dm.content}");
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
