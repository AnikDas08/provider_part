class ChatModel {
  final String id;
  final Participant participant;   // Assuming first participant
  final LatestMessage latestMessage;
  final int unreadCount;
  final DateTime updatedAt;

  ChatModel({
    required this.id,
    required this.participant,
    required this.latestMessage,
    required this.unreadCount,
    required this.updatedAt,
  });

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      id: json['_id'] ?? '',
      participant: Participant.fromJson(
        (json['participants'] != null && json['participants'].isNotEmpty)
            ? json['participants'][0]
            : {},
      ),
      latestMessage: LatestMessage.fromJson(json['lastMessage'] ?? {}),
      unreadCount: json['unreadCount'] ?? 0,
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }
}

class Participant {
  final String id;
  final String name;
  final String role;
  final String image;
  final String email;

  Participant({
    required this.id,
    required this.name,
    required this.role,
    required this.image,
    required this.email,
  });

  factory Participant.fromJson(Map<String, dynamic> json) {
    return Participant(
      id: json['_id'] ?? '',
      role: json['role'] ?? '',
      name: json['name'] ?? '',
      image: json['image'] ?? '',
      email: json['email'] ?? '',
    );
  }
}

class LatestMessage {
  final String id;
  final Sender sender;
  final String type;
  final String text;

  LatestMessage({
    required this.id,
    required this.sender,
    required this.type,
    required this.text,
  });

  factory LatestMessage.fromJson(Map<String, dynamic> json) {
    return LatestMessage(
      id: json['_id'] ?? '',
      sender: Sender.fromJson(json['sender'] ?? {}),
      type: json['type'] ?? '',
      text: json['text'] ?? '',
    );
  }
}

class Sender {
  final String id;
  final String role;
  final String name;
  final String image;

  Sender({
    required this.id,
    required this.role,
    required this.name,
    required this.image,
  });

  factory Sender.fromJson(Map<String, dynamic> json) {
    return Sender(
      id: json['_id'] ?? '',
      role: json['role'] ?? '',
      name: json['name'] ?? '',
      image: json['image'] ?? '',
    );
  }
}
