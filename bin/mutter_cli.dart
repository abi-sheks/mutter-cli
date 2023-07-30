import 'package:mutter_cli/mutter_cli.dart';
import 'dart:io';

void main(List<String> arguments) {
  MutterAPI api = MutterAPI();
  Future.wait([api.populateArrays()]).then((value) => {runApp(api)});
  //rest of the application cannot start until above function completes.
}

void runApp(MutterAPI api) async {
  String? currUsername;
  String? currentCommand;
  currUsername = api.getCurrentLoggedIn();
  print(
      "Welcome to Mutter! Read the documentation to get started on using the interface. Type \"exit\" to close the application.");
  print(currUsername);
  while (true) {
    try {
      currentCommand = stdin.readLineSync();
      if (currentCommand == null) {
        throw Exception("Please enter a command");
      }
      var ccs = currentCommand.split(" ");
      if (ccs[0] == "register") {
        print(currentCommand);
        await api.registerUser(ccs[1], ccs[2]);
        print("Registration successful!");
      } else if (ccs[0] == "login") {
        await api.loginUser(ccs[1], ccs[2]);
        currUsername = ccs[1];
        print("Login successful!");
      } else if (ccs[0] == "logout") {
        await api.logoutUser(currUsername);
        currUsername = null;
        print("Successfully logged out, see you again!");
      } else if (ccs[0] == "create-server") {
        await api.createServer(ccs[1], currUsername);
        print("Created server succesfully");
      } else if (ccs[0] == "add-member") {
        await api.addMemberToServer(ccs[1], ccs[2], currUsername);
        print("Added member successfully");
      } else if (ccs[0] == "add-category") {
        await api.addCategoryToServer(ccs[1], ccs[2], currUsername);
        print("Added category successfully");
      } else if (ccs[0] == "add-channel") {
        await api.addChannelToServer(
            ccs[1], ccs[2], ccs[3], ccs[4], ccs[5], currUsername);
        print("Added channel successfully");
      } else if (ccs[0] == "send-msg") {
        print("Enter the text message to be sent");
        var message = stdin.readLineSync();
        await api.sendMessageInServer(ccs[1], currUsername, ccs[2], message);
        print('Message sent succesfully');
      } else if (ccs[0] == "display-users") {
        api.displayUsers();
      } else if (ccs[0] == "display-servers") {
        api.displayServers();
      } else if (ccs[0] == "display-channels") {
        api.displayChannels();
      } else if (ccs[0] == "display-messages") {
        api.displayMessages(ccs[1]);
      } else if (ccs[0] == "dm") {
        print("Enter the dm");
        var content = stdin.readLineSync();
        await api.sendDirectMessage(currUsername, ccs[1], content);
        print("DM sent successfully");
      } else if (ccs[0] == "show-dms") {
        api.displayDms(currUsername, ccs[1]);
      } else if(ccs[0] == "create-role") {
        await api.createRole(ccs[1], ccs[2], ccs[3], currUsername);
        print("Role created successfully");
      } else if(ccs[0] == "assign-role") {
        await api.addRoleToUser(ccs[1], ccs[2], ccs[3], currUsername);
        print("Role assigned successfully");
      } else if(ccs[0] == "display-roles") {
        api.displayRoles(ccs[1]);
      } else if(ccs[0] == "exit") {
        print("See you soon!");
        break;
      }
    } on Exception catch (e) {
      print("$e");
    }
  }
}
