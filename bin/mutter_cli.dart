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
  loop:
  while (true) {
    try {
      currentCommand = stdin.readLineSync();
      if (currentCommand == null) {
        throw Exception("Please enter a command");
      }
      var ccs = currentCommand.split(" ");
      switch (ccs[0]) {
        case "register":
          {
            await api.registerUser(ccs[1], ccs[2]);
            print("Registration successful!");
            break;
          }
        case "login":
          {
            await api.loginUser(ccs[1], ccs[2]);
            currUsername = ccs[1];
            print("Login successful!");
            break;
          }
        case "logout":
          {
            await api.logoutUser(currUsername);
            currUsername = null;
            print("Successfully logged out, see you again!");
            break;
          }
        case 'current-session' :
        {
          print("$currUsername is logged in");
        }  
        case "create-server":
          {
            await api.createServer(ccs[1], currUsername, ccs[2]);
            print("Created server succesfully");
            break;
          }
        case "add-member":
          {
            await api.addMemberToServer(ccs[1], ccs[2], currUsername);
            print("Added member successfully");
            break;
          }
        case "add-category":
          {
            await api.addCategoryToServer(ccs[1], ccs[2], currUsername);
            print("Added category successfully");
            break;
          }
        case "add-channel":
          {
            await api.addChannelToServer(
                ccs[1], ccs[2], ccs[3], ccs[4], ccs[5], currUsername);
            print("Added channel successfully");
            break;
          }
        case "send-msg":
          {
            print("Enter the text message to be sent");
            var message = stdin.readLineSync();
            await api.sendMessageInServer(
                ccs[1], currUsername, ccs[2], message);
            print('Message sent succesfully');
            break;
          }
        case "display-users":
          {
            api.displayUsers();
            break;
          }
        case "display-servers":
          {
            api.displayServers();
            break;
          }
        case "display-channels":
          {
            api.displayChannels();
            break;
          }
        case "display-messages":
          {
            api.displayMessages(ccs[1]);
            break;
          }
        case "dm":
          {
            print("Enter the dm");
            var content = stdin.readLineSync();
            await api.sendDirectMessage(currUsername, ccs[1], content);
            print("DM sent successfully");
            break;
          }
        case "show-dms":
          {
            api.displayDms(currUsername, ccs[1]);
            break;
          }
        case "create-role":
          {
            await api.createRole(ccs[1], ccs[2], ccs[3], currUsername);
            print("Role created successfully");
            break;
          }
        case "assign-role":
          {
            await api.addRoleToUser(ccs[1], ccs[2], ccs[3], currUsername);
            print("Role assigned successfully");
            break;
          }
        case "display-roles":
          {
            api.displayRoles(ccs[1]);
            break;
          }
        case "display-members":
          {
            api.displayMembers(ccs[1]);
            break;
          }
        case "channel-to-cat":
          {
            await api.addChannelToCategory(
                ccs[1], ccs[2], ccs[3], currUsername);
            print("Channel added to category");
            break;
          }
        case "change-perm":
          {
            await api.changePermission(ccs[1], ccs[2], ccs[3], currUsername);
            print("Permission changed successfully.");
            break;
          }
        case "delete-server":
          {
            print("Are you sure you want to proceed? (y/n)");
            var confirm = stdin.readLineSync();
            if (confirm == null) {
              break;
            }
            confirm = confirm.toLowerCase();
            if (confirm == "y" || confirm == "yes") {
              await api.deleteServer(ccs[1], currUsername);
              print("Server deleted.");
            }
            break;
          }
        case "delete-channel":
          {
            print("Are you sure you want to proceed? (y/n)");
            var confirm = stdin.readLineSync();
            if (confirm == null) {
              break;
            }
            confirm = confirm.toLowerCase();
            if (confirm == "y" || confirm == "yes") {
              await api.deleteChannel(ccs[1], ccs[2], currUsername);
              print("Channel deleted");
            }
            break;
          }
        case "delete-category":
          {
            print("Are you sure you want to proceed? (y/n)");
            var confirm = stdin.readLineSync();
            if (confirm == null) {
              break;
            }
            confirm = confirm.toLowerCase();
            if (confirm == "y" || confirm == "yes") {
              await api.deleteCategory(ccs[1], ccs[2], currUsername);
              print("Category deleted");
            }
            break;
          }
        case "delete-role":
          {
            print("Are you sure you want to proceed? (y/n)");
            var confirm = stdin.readLineSync();
            if (confirm == null) {
              break;
            }
            confirm = confirm.toLowerCase();
            if (confirm == "y" || confirm == "yes") {
              await api.deleteRole(ccs[1], ccs[2], currUsername);
              print("Role deleted");
            }
            break;
          }
        case "delete-member":
          {
            print("Are you sure you want to proceed? (y/n)");
            var confirm = stdin.readLineSync();
            if (confirm == null) {
              break;
            }
            confirm = confirm.toLowerCase();
            if (confirm == "y" || confirm == "yes") {
              await api.deleteMember(ccs[1], ccs[2], currUsername);
              print("Member deleted");
            }
            break;
          }
        case "change-ownership":
          {
            await api.changeOwnership(ccs[1], currUsername, ccs[2]);
            break;
          }
        case "leave-server":
          {
            print("Are you sure you want to proceed? (y/n)");
            var confirm = stdin.readLineSync();
            if (confirm == null) {
              break;
            }
            confirm = confirm.toLowerCase();
            if (confirm == "y" || confirm == "yes") {
              await api.leaveServer(ccs[1], currUsername);
              print("Member deleted");
            }
            break;
          }
        case 'join-server':
          {
            await api.joinServer(ccs[1], currUsername);
            print("Server joined successfully.");
          }
        case "exit":
          {
            print("See you soon!");
            break loop;
          }
        default:
          {
            print("Please enter a valid command.");
          }
      }
    } on Exception catch (e) {
      print("$e");
    }
  }
}
