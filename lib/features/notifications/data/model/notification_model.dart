class NotificationModel {
  final String? id;
  final String? type;
  final String? message;
  final String? title;
  final String? createdAt;
  final String? updatedAt;
  final Map<String, dynamic>? referenceId;
  final bool? isRead;
  final Map<String, dynamic>? data;

  NotificationModel({
    this.id,
    this.type,
    this.message,
    this.title,
    this.createdAt,
    this.updatedAt,
    this.isRead,
    this.data,
    this.referenceId
  });

  /// Factory constructor to create NotificationModel from JSON
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id']?.toString(),
      type: json['type']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? json['createdAt']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? json['updatedAt']?.toString() ?? '',
      isRead: json['is_read'] ?? json['isRead'] ?? false,
      data: json['data'] is Map ? Map<String, dynamic>.from(json['data']) : null,
      referenceId: json['referenceId'] is Map ? Map<String, dynamic>.from(json['referenceId']) : null,
    );
  }

  /// Convert NotificationModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'message': message,
      'title': title,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'is_read': isRead,
      'data': data,
      'referenceId': referenceId,
    };
  }

  /// Copy with method for updating specific fields
  NotificationModel copyWith({
    String? id,
    String? type,
    String? message,
    String? title,
    String? createdAt,
    String? updatedAt,
    bool? isRead,
    Map<String, dynamic>? data,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      type: type ?? this.type,
      message: message ?? this.message,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isRead: isRead ?? this.isRead,
      data: data ?? this.data,
    );
  }
}