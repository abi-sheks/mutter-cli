import 'package:mutter_cli/cli/channel.dart';

class Category {
  List<Channel> channels = [];
  late String categoryName;
  Category({required this.categoryName, required this.channels});
  Map<String, dynamic> toMap() {
    var mappedChannels = channels.map((e) => e.toMap()).toList();
    return {
      'categoryName': categoryName,
      'channels': mappedChannels,
    };
  }

  static Category fromMap(Map<String, dynamic> map) {
    late List<Channel> unmappedChannels;
    if(map['channels'] == null) {
      unmappedChannels = [];
    }
    unmappedChannels = (map['channels'] as List)
        .map((channel) => Channel.fromMap(channel))
        .toList();
    return Category(
        categoryName: map['categoryName'], channels: unmappedChannels);
  }
}
