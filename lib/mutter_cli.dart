import 'dart:async';
import 'dart:core';

import 'package:mutter_cli/cli/category.dart';
import 'package:mutter_cli/cli/channel.dart';
import 'package:mutter_cli/cli/message.dart';
import 'package:mutter_cli/cli/user.dart';
import 'package:mutter_cli/cli/server.dart';
import 'package:mutter_cli/cli/role.dart';
import 'package:mutter_cli/cli/exceptions/invalid_creds.dart';
import 'package:mutter_cli/db/database_crud.dart';
import 'package:mutter_cli/enum/channel_type.dart';
import 'package:mutter_cli/enum/permissions.dart';

class MutterAPI {
  List<User> users = [];
  List<Server> servers = [];
  bool someoneLoggedIn = false;
  Future<void> populateArrays() async {
    // users.forEach((element) {print(element.username);});
    users = await UserIO.getAllUsers();
    servers = await ServerIO.getAllServers();
  }

  //Users
  Future<void> registerUser(String? username, String? password) async {
    if (username == null || password == null) {
      throw InvalidCredentialsException();
    }
    List<DirectMessage> emptyDms = [];
    var usernames = users.map((e) => e.username).toList();
    if (usernames.contains(username)) {
      throw Exception("User already exists");
    }
    var newUser = User(username, password, false, emptyDms);

    users.add(newUser);
    await newUser.register();
  }

  Future<void> loginUser(String? username, String? password) async {
    if (password == null || username == null) {
      throw InvalidCredentialsException();
    }
    if (someoneLoggedIn) {
      throw Exception("Please logout of the current session to login again");
    }
    var reqUser = getUser(username);
    someoneLoggedIn = true;
    await reqUser.login(password);
  }

  Future<void> logoutUser(String? username) async {
    if (username == null) {
      throw InvalidCredentialsException();
    }
    var reqUser = getUser(username);
    reqUser.loggedIn = false;
    someoneLoggedIn = false;
    await reqUser.logout();
  }

  User getUser(String name) {
    return users.firstWhere((user) => user.username == name,
        orElse: () => throw Exception("User does not exist"));
  }

  String? getCurrentLoggedIn() {
    for (User user in users) {
      if (user.loggedIn) {
        return user.username;
      }
    }
    return null;
  }

  void displayUsers() {
    for (User user in users) {
      print("${user.username}");
    }
  }

  //Servers
  Future<void> createServer(String? serverName, String? userName) async {
    if (serverName == null || userName == null) {
      throw Exception(
          "Please enter the required credentials, or login to continue.");
    }
    var creator = getUser(userName);
    var newServer = Server(
        serverName: serverName,
        members: [],
        roles: [],
        categories: [Category(categoryName: "none", channels: [])],
        channels: []);
    servers.add(newServer);
    await newServer.instantiateServer(creator);
  }

  Server getServer(String name) {
    return servers.firstWhere((server) => server.serverName == name,
        orElse: () => throw Exception("Server does not exist"));
  }

  Future<void> addMemberToServer(
      String? serverName, String? userName, String? ownerName) async {
    if (serverName == null || userName == null || ownerName == null) {
      throw Exception(
          "Please enter the correct command, or login to continue.");
    }
    var reqUser = getUser(userName);
    var reqServer = getServer(serverName);
    reqServer.checkAccessLevel(ownerName, 2);
    await reqServer.addMember(reqUser);
  }

  Future<void> addCategoryToServer(
      String? serverName, String? categoryName, String? userName) async {
    if (serverName == null || categoryName == null || userName == null) {
      throw Exception(
          "Please enter the valid credentials, or login to continue.");
    }
    var reqServer = getServer(serverName);
    reqServer.checkAccessLevel(userName, 2);
    await reqServer
        .addCategory(Category(categoryName: categoryName, channels: []));
  }

  Future<void> addChannelToServer(
      String? serverName,
      String? channelName,
      String? channelPerm,
      String? channelType,
      String? parentCategoryName,
      String? userName) async {
    if (serverName == null ||
        channelName == null ||
        channelPerm == null ||
        channelType == null ||
        userName == null) {
      throw Exception(
          "Please enter the valid credentials, or login to continue.");
    }
    parentCategoryName ??= "none";
    late ChannelType chanType;
    late Permission perm;
    //bad pattern
    if (channelType == "video") {
      chanType = ChannelType.video;
    } else if (channelType == "voice") {
      chanType = ChannelType.voice;
    } else {
      chanType = ChannelType.text;
    }
    if (channelPerm == "owner") {
      perm = Permission.owner;
    } else if (channelPerm == "moderator") {
      perm = Permission.moderator;
    } else {
      perm = Permission.member;
    }

    var reqServer = getServer(serverName);
    reqServer.checkAccessLevel(userName, 2);
    await reqServer.addChannel(
        Channel(
            channelName: channelName,
            messages: [],
            type: chanType,
            permission: perm),
        parentCategoryName);
  }

  Future<void> sendMessageInServer(String? serverName, String? userName,
      String? channelName, String? messageContent) async {
    if (serverName == null ||
        userName == null ||
        channelName == null ||
        messageContent == null) {
      throw Exception("Please enter a valid command, or login to continue.");
    }
    var reqServer = getServer(serverName);
    var reqUser = getUser(userName);
    var reqChannel = reqServer.getChannel(channelName);
    if (reqChannel.type != ChannelType.text) {
      throw Exception("You can only send a message in a text channel");
    }
    if (!(reqUser.loggedIn)) {
      throw Exception("Not logged in");
    }
    await reqServer.addMessageToChannel(
        reqChannel, reqUser, Message(messageContent, reqUser));
  }

  Future<void> sendDirectMessage(
      String? senderName, String? receiverName, String? content) async {
    if (senderName == null || receiverName == null || content == null) {
      throw Exception("Please enter a valid command, or login to continue");
    }
    var sender = getUser(senderName);
    var receiver = getUser(receiverName);
    await sender.DM(receiver, content);
  }

  Future<void> createRole(String? serverName, String? roleName,
      String? permLevel, String? callerName) async {
    late Permission newPerm;
    if (serverName == null ||
        roleName == null ||
        permLevel == null ||
        callerName == null) {
      throw Exception("Invalid command");
    }
    if (permLevel == "owner") {
      throw Exception("Owner privileges cannot be shared to other roles.");
    } else if (permLevel == "moderator") {
      newPerm = Permission.moderator;
    } else {
      newPerm = Permission.member;
    }
    var reqServer = getServer(serverName);
    reqServer.checkAccessLevel(callerName, 2);
    await reqServer
        .addRole(Role(roleName: roleName, accessLevel: newPerm, holders: []));
  }

  Future<void> addRoleToUser(String? serverName, String? roleName,
      String? memberName, String? callerName) async {
    if (serverName == null ||
        roleName == null ||
        memberName == null ||
        callerName == null) {
      throw Exception("Enter a valid command");
    }
    var reqServer = getServer(serverName);
    reqServer.checkAccessLevel(callerName, 2);
    if (!(reqServer.isMember(memberName))) {
      throw Exception("User is not a member of the server");
    }
    if (roleName == "owner") {
      throw Exception("There can only be one owner");
    }
    var reqRole = reqServer.getRole(roleName);
    var reqMember = reqServer.getMember(memberName);
    await reqServer.assignRole(reqRole, reqMember);
  }

  Future<void> addChannelToCategory(String? serverName, String? channelName,
      String? categoryName, String? callerName) async {
    if (serverName == null ||
        channelName == null ||
        categoryName == null ||
        callerName == null) {
      throw Exception("Please enter a valid command, or login to continue");
    }
    var reqServer = getServer(serverName);
    reqServer.checkAccessLevel(callerName, 2);
    await reqServer.assignChannel(channelName, categoryName);
  }

  Future<void> changePermission(String? serverName, String? channelName,
      String? newPerm, String? callerName) async {
    if (serverName == null ||
        channelName == null ||
        newPerm == null ||
        callerName == null) {
      throw Exception("Please enter a valid command, or login to continue");
    }
    late Permission perm;
    var reqServer = getServer(serverName);
    reqServer.checkAccessLevel(callerName, 2);
    if (newPerm == "owner") {
      perm = Permission.owner;
    } else if (newPerm == "moderator") {
      perm = Permission.moderator;
    } else if (newPerm == "member") {
      perm = Permission.member;
    } else {
      throw Exception("Please enter a valid permission");
    }
    await reqServer.changePerm(channelName, perm);
  }

  Future<void> deleteServer(String? serverName, String? callerName) async {
    if (serverName == null || callerName == null) {
      throw Exception("Please enter a valid command, or login to continue");
    }
    var reqServer = getServer(serverName);
    getUser(callerName);
    reqServer.checkAccessLevel(callerName, 2);
    servers.remove(reqServer);
    await ServerIO.deleteFromDB(reqServer);
  }

  Future<void> deleteChannel(
      String? serverName, String? channelName, String? callerName) async {
    if (serverName == null || channelName == null || callerName == null) {
      throw Exception("Please enter a valid command, or login to continue");
    }
    var reqServer = getServer(serverName);
    getUser(callerName);
    reqServer.checkAccessLevel(callerName, 2);
    await reqServer.removeChannel(channelName);
  }

  Future<void> deleteCategory(
      String? serverName, String? categoryName, String? callerName) async {
    if (serverName == null || categoryName == null || callerName == null) {
      throw Exception("Please enter a valid command, or login to continue");
    }
    var reqServer = getServer(serverName);
    getUser(callerName);
    reqServer.checkAccessLevel(callerName, 2);
    await reqServer.removeCategory(categoryName);
  }

  Future<void> deleteRole(
      String? serverName, String? roleName, String? callerName) async {
    if (serverName == null || roleName == null || callerName == null) {
      throw Exception("Please enter a valid command, or login to continue");
    }
    var reqServer = getServer(serverName);
    getUser(callerName);
    reqServer.checkAccessLevel(callerName, 2);
    await reqServer.removeRole(roleName);
  }

  Future<void> deleteMember(
      String? serverName, String? userName, String? callerName) async {
    if (serverName == null || userName == null || callerName == null) {
      throw Exception("Please enter a valid command, or login to continue");
    }
    var reqServer = getServer(serverName);
    getUser(callerName);
    getUser(userName);
    reqServer.checkAccessLevel(callerName, 2);
    //established that caller is owner
    if (callerName == userName) {
      throw Exception("You cannot remove yourself. Try leaving instead!");
    }
    await reqServer.removeMember(userName);
  }

  Future<void> changeOwnership(
      String? serverName, String? currentOwner, String? newOwner) async {
    if (currentOwner == null || newOwner == null || serverName == null) {
      throw Exception("Please enter a valid command, or login to continue");
    }
    var reqServer = getServer(serverName);
    getUser(currentOwner);
    getUser(newOwner);
    reqServer.checkAccessLevel(currentOwner, 2);
    if (!(reqServer.isMember(newOwner))) {
      throw Exception("The specified user is not a member of the server");
    }
    await reqServer.swapOwner(currentOwner, newOwner);
  }

  Future<void> leaveServer(String? serverName, String? callerName) async {
    if (serverName == null || callerName == null) {
      throw Exception("Please enter a valid command, or login to continue");
    }
    var reqServer = getServer(serverName);
    getUser(callerName);
    if (!(reqServer.isMember(callerName))) {
      throw Exception("The user is not a member of the server");
    }
    //if user leaving is owner
    if (reqServer.getRole("owner").holders[0].username == callerName) {
      throw Exception(
          "Please change ownership before leaving your server, as you are the owner");
    }
    await reqServer.removeMember(callerName);
  }

  void displayDms(String? receiverName, String? incomingName) {
    if (incomingName == null || receiverName == null) {
      throw Exception("Please enter a valid command, or login to continue.");
    }
    var receiver = getUser(receiverName);
    var incoming = getUser(incomingName);
    if (!(receiver.loggedIn)) {
      throw Exception("Please log in.");
    }
    receiver.showDMs(incoming);
  }

  void displayServers() {
    for (Server server in servers) {
      print("${server.serverName} ");
    }
  }

  void displayChannels() {
    for (Server server in servers) {
      for (Category category in server.categories) {
        print(category.categoryName);
        for (Channel channel in category.channels) {
          print(channel.channelName);
        }
      }
    }
  }

  void displayMembers(String? serverName) {
    if (serverName == null) {
      throw Exception("Please enter a valid command");
    }
    var reqServer = getServer(serverName);
    for (User member in reqServer.members) {
      print(member.username);
    }
  }

  void displayMessages(String? serverName) {
    if (serverName == null) {
      throw Exception("Please enter a valid command");
    }
    var reqServer = getServer(serverName);
    for (Channel channel in reqServer.channels) {
      print("${channel.channelName} : ");
      for (Message message in channel.messages) {
        print("${message.sender.username} : ${message.content}");
      }
    }
  }

  void displayRoles(String serverName) {
    var reqServer = getServer(serverName);
    for (Role role in reqServer.roles) {
      print("\n${role.roleName} (${role.accessLevel}) : \n Holders ");
      for (User holder in role.holders) {
        print("\t${holder.username}");
      }
    }
  }
}
