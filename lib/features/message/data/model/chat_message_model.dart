// models/message_model.dart

enum MessageType { text, image, multiImage }

class ChatMessage {
  final String id;
  final String message;
  final DateTime timestamp;
  final bool isMe;
  final MessageType type;
  final List<String>? imagePaths; // For local images
  final List<String>? imageUrls;  // For network images

  ChatMessage({
    required this.id,
    required this.message,
    required this.timestamp,
    required this.isMe,
    this.type = MessageType.text,
    this.imagePaths,
    this.imageUrls,
  });

  factory ChatMessage.text({
    required String id,
    required String message,
    required bool isMe,
  }) {
    return ChatMessage(
      id: id,
      message: message,
      timestamp: DateTime.now(),
      isMe: isMe,
      type: MessageType.text,
    );
  }

  factory ChatMessage.image({
    required String id,
    required String imagePath,
    required bool isMe,
    String message = "",
  }) {
    return ChatMessage(
      id: id,
      message: message,
      timestamp: DateTime.now(),
      isMe: isMe,
      type: MessageType.image,
      imagePaths: [imagePath],
    );
  }

  factory ChatMessage.multiImage({
    required String id,
    required List<String> imagePaths,
    required bool isMe,
    String message = "",
  }) {
    return ChatMessage(
      id: id,
      message: message,
      timestamp: DateTime.now(),
      isMe: isMe,
      type: MessageType.multiImage,
      imagePaths: imagePaths,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'isMe': isMe,
      'type': type.toString(),
      'imagePaths': imagePaths,
      'imageUrls': imageUrls,
    };
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      message: json['message'],
      timestamp: DateTime.parse(json['timestamp']),
      isMe: json['isMe'],
      type: MessageType.values.firstWhere(
            (e) => e.toString() == json['type'],
        orElse: () => MessageType.text,
      ),
      imagePaths: json['imagePaths']?.cast<String>(),
      imageUrls: json['imageUrls']?.cast<String>(),
    );
  }
}