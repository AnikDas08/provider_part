class ProfileModel {
  final bool? success;
  final String? message;
  final ProfileData? data;

  ProfileModel({
    this.success,
    this.message,
    this.data,
  });

  factory ProfileModel.fromJson(Map<dynamic, dynamic> json) {
    return ProfileModel(
      success: json['success'],
      message: json['message'],
      data: json['data'] != null ? ProfileData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data?.toJson(),
    };
  }

  /// 🔁 copyWith method (ProfileModel)
  ProfileModel copyWith({
    bool? success,
    String? message,
    ProfileData? data,
  }) {
    return ProfileModel(
      success: success ?? this.success,
      message: message ?? this.message,
      data: data ?? this.data,
    );
  }
}

class ProfileData {
  final String? id;
  final String? role;
  final String? name;
  final String? image;
  final String? email;
  final String? contact;
  final String? location;
  final num? credits;
  final bool? isActive;
  final bool? verified;
  final bool? isDeleted;
  final String? createdAt;
  final String? updatedAt;
  final int? v;

  ProfileData({
    this.id,
    this.role,
    this.name,
    this.image,
    this.email,
    this.contact,
    this.location,
    this.credits,
    this.isActive,
    this.verified,
    this.isDeleted,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory ProfileData.fromJson(Map<dynamic, dynamic> json) {
    return ProfileData(
      id: json['_id'],
      role: json['role'],
      name: json['name'],
      image: json['image'],
      email: json['email'],
      contact: json['contact'],
      location: json['location'],
      credits: json['credits'],
      isActive: json['isActive'],
      verified: json['verified'],
      isDeleted: json['isDeleted'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      v: json['__v'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'role': role,
      'name': name,
      'image': image,
      'email': email,
      'contact': contact,
      'location': location,
      'credits': credits,
      'isActive': isActive,
      'verified': verified,
      'isDeleted': isDeleted,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      '__v': v,
    };
  }

  /// 🔁 copyWith method (ProfileData)
  ProfileData copyWith({
    String? id,
    String? role,
    String? name,
    String? image,
    String? email,
    String? contact,
    String? location,
    num? credits,
    bool? isActive,
    bool? verified,
    bool? isDeleted,
    String? createdAt,
    String? updatedAt,
    int? v,
  }) {
    return ProfileData(
      id: id ?? this.id,
      role: role ?? this.role,
      name: name ?? this.name,
      image: image ?? this.image,
      email: email ?? this.email,
      contact: contact ?? this.contact,
      location: location ?? this.location,
      credits: credits ?? this.credits,
      isActive: isActive ?? this.isActive,
      verified: verified ?? this.verified,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      v: v ?? this.v,
    );
  }
}
