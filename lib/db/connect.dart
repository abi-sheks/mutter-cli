import 'package:mongo_dart/mongo_dart.dart';

Future<Db> connectDB(String connectionString) async {
  var database = await Db.create(connectionString);
  await database.open();
  return database;
}