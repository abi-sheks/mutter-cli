import 'package:mutter_cli/cli/user.dart';
import 'package:mutter_cli/enum/permissions.dart';

class Role {
  List<User> holders = [];
  final String roleName;
  final Permission accessLevel;
  Role({required this.roleName, required this.accessLevel, required this.holders});

  Map<String, dynamic> toMap() {
    var mappedHolders = holders.map((holder) => holder.toMap()).toList();
    return {
      'roleName' : roleName,
      'holders' : mappedHolders,
      'accessLevel' : accessLevel.toString(),
      "finder" : "finder",
    };
  }
  static Role fromMap(Map<String, dynamic> map) {
    late Permission perm;
    late List<User> unmappedHolders;
    if(map['accessLevel'] == "Permission.owner") {
      perm = Permission.owner;
    }
    else if(map['accessLevel'] == "Permission.moderator") {
      perm = Permission.moderator;
    }
    else perm = Permission.member;
    if(map['holders'] == null) {
      unmappedHolders = [];
    }
    unmappedHolders = (map['holders'] as List).map((holder) => User.fromMap(holder)).toList();
    return Role(roleName: map['roleName'], accessLevel: perm, holders: unmappedHolders);
  }
}