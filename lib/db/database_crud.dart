import "package:mutter_cli/cli/server.dart";
import 'package:mutter_cli/db/connect.dart';
import 'package:mutter_cli/cli/user.dart';

class DatabaseIO {
  DatabaseIO();
  static Future<void> addToDB(dynamic document, String collectionName) async {
    var db = await connectDB(
        "mongodb+srv://abishekarun2017:aklkzDXKb8QaFtdy@cluster0.1sqgttx.mongodb.net/?retryWrites=true&w=majority");
    //db logic
    print("db connected");
    var reqCollection = db.collection(collectionName);
    await reqCollection.insertOne(document.toMap());
    print("inserted");
    db.close();
  }

  // static Future<dynamic> getFromDB(String collectionName) async {
  //   var db = await connectDB("mongodb+srv://abishekarun2017:aklkzDXKb8QaFtdy@cluster0.1sqgttx.mongodb.net/?retryWrites=true&w=majority");
  //   var reqCollection = db.collection(collectionName);
  //   return await reqCollection.find({'username' : 'abishek'}).toList();
  // }
  // static Future<void> updateDB(dynamic document, String collectionName) async {
  //   var db = await connectDB(
  //       "mongodb+srv://abishekarun2017:aklkzDXKb8QaFtdy@cluster0.1sqgttx.mongodb.net/?retryWrites=true&w=majority");
  //   var reqCollection = db.collection(collectionName);
  //   reqCollection.replaceOne({'username': document.username}, document.toMap());
  //   db.close();
  // }
}

class UserIO extends DatabaseIO {
  UserIO._();
  static Future<List<User>> getAllUsers() async {
    var db = await connectDB(
        "mongodb+srv://abishekarun2017:aklkzDXKb8QaFtdy@cluster0.1sqgttx.mongodb.net/?retryWrites=true&w=majority");
    var reqUsers =
        await db.collection("users").find({"finder": "finder"}).toList();
    db.close();
    return reqUsers.map((e) => User.fromMap(e)).toList();
  }
  static Future<void> updateDB(dynamic document, String collectionName) async {
    var db = await connectDB(
        "mongodb+srv://abishekarun2017:aklkzDXKb8QaFtdy@cluster0.1sqgttx.mongodb.net/?retryWrites=true&w=majority");
    var reqCollection = db.collection(collectionName);
    await reqCollection.replaceOne({'username': document.username}, document.toMap());
    db.close();
  }
}

class ServerIO extends DatabaseIO {
  ServerIO._();
  static Future<List<Server>> getAllServers() async {
    var db = await connectDB(
        "mongodb+srv://abishekarun2017:aklkzDXKb8QaFtdy@cluster0.1sqgttx.mongodb.net/?retryWrites=true&w=majority");
    var reqServers =
        await db.collection("servers").find({"finder": "finder"}).toList();
    db.close();
    if(reqServers == [null]) {
    }
    return reqServers.map((e) => Server.fromMap(e)).toList();
  }
  static Future<void> updateDB(dynamic document, String collectionName) async {
    var db = await connectDB(
        "mongodb+srv://abishekarun2017:aklkzDXKb8QaFtdy@cluster0.1sqgttx.mongodb.net/?retryWrites=true&w=majority");
    var reqCollection = db.collection(collectionName);
    await reqCollection.replaceOne({'serverName': document.serverName}, document.toMap());
    db.close();
  }
}
