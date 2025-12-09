class Sender {
  final String id;
  final String name;
  final String role;
  final String image; // Optional

  Sender({
    required this.id,
    required this.name,
    required this.role,
    required this.image,
  });

  factory Sender.fromJson(Map<String, dynamic> json) {
    return Sender(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      role: json['role'] ?? '',
      image: json['image'] ?? "", // may be null
    );
  }
}

class MessageModel {
  final String id;
  final String chat;
  final String text;
  final String image;
  final String type;
  final Sender sender;
  final List<String> seenBy;
  final bool isSeen;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int version;

  MessageModel({
    required this.id,
    required this.chat,
    required this.text,
    required this.type,
    required this.sender,
    required this.seenBy,
    required this.isSeen,
    required this.createdAt,
    required this.updatedAt,
    required this.version,
    required this.image,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['_id'] ?? '',
      chat: json['chat'] ?? '',
      text: json['text'] ?? '',
      image: json['image'] ?? '',
      type: json['type'] ?? 'general',
      sender: Sender.fromJson(json['sender'] ?? {}),
      seenBy: List<String>.from(json['seenBy'] ?? []),
      isSeen: json['isSeen'] ?? false,
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updatedAt'] ?? DateTime.now().toIso8601String(),
      ),
      version: json['__v'] ?? 0,
    );
  }
}
