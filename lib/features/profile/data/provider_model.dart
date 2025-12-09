
class ProviderData {
  String? id;
  User? user;  // Changed from String? to User?
  String? aboutMe;
  List<Service>? services;
  List<String>? serviceLanguage;
  String? primaryLocation;
  Location? location;
  num? serviceDistance;
  double? pricePerHour;
  List<String>? serviceImages;
  bool? isRead;
  bool? isActive;
  bool? isOnline;
  DateTime? createdAt;
  DateTime? updatedAt;
  List<Schedule>? schedules;

  ProviderData({
    this.id,
    this.user,
    this.aboutMe,
    this.services,
    this.serviceLanguage,
    this.primaryLocation,
    this.location,
    this.serviceDistance,
    this.pricePerHour,
    this.serviceImages,
    this.isRead,
    this.isActive,
    this.isOnline,
    this.createdAt,
    this.updatedAt,
    this.schedules,
  });

  factory ProviderData.fromJson(Map<dynamic, dynamic> json) => ProviderData(
    id: json["_id"],
    user: json["user"] != null ? User.fromJson(json["user"]) : null,  // Parse as User object
    aboutMe: json["aboutMe"],
    services: json["services"] != null
        ? List<Service>.from(json["services"].map((x) => Service.fromJson(x)))
        : null,
    serviceLanguage: json["serviceLanguage"] != null
        ? List<String>.from(json["serviceLanguage"].map((x) => x))
        : null,
    primaryLocation: json["primaryLocation"],
    location: json["location"] != null ? Location.fromJson(json["location"]) : null,
    serviceDistance: json["serviceDistance"],
    pricePerHour: json["pricePerHour"]?.toDouble(),
    serviceImages: json["serviceImages"] != null
        ? List<String>.from(json["serviceImages"].map((x) => x))
        : null,
    isRead: json["isRead"],
    isActive: json["isActive"],
    isOnline: json["isOnline"],
    createdAt: json["createdAt"] != null ? DateTime.parse(json["createdAt"]) : null,
    updatedAt: json["updatedAt"] != null ? DateTime.parse(json["updatedAt"]) : null,
    schedules: json["schedules"] != null
        ? List<Schedule>.from(json["schedules"].map((x) => Schedule.fromJson(x)))
        : null,
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "user": user?.toJson(),  // Changed to toJson()
    "aboutMe": aboutMe,
    "services": services != null ? List<dynamic>.from(services!.map((x) => x.toJson())) : null,
    "serviceLanguage": serviceLanguage,
    "primaryLocation": primaryLocation,
    "location": location?.toJson(),
    "serviceDistance": serviceDistance,
    "pricePerHour": pricePerHour,
    "serviceImages": serviceImages,
    "isRead": isRead,
    "isActive": isActive,
    "isOnline": isOnline,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "schedules": schedules != null ? List<dynamic>.from(schedules!.map((x) => x.toJson())) : null,
  };

  ProviderData copyWith({
    String? id,
    User? user,  // Changed from String? to User?
    String? aboutMe,
    List<Service>? services,
    List<String>? serviceLanguage,
    String? primaryLocation,
    Location? location,
    num? serviceDistance,
    double? pricePerHour,
    List<String>? serviceImages,
    bool? isRead,
    bool? isActive,
    bool? isOnline,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<Schedule>? schedules,
  }) =>
      ProviderData(
        id: id ?? this.id,
        user: user ?? this.user,
        aboutMe: aboutMe ?? this.aboutMe,
        services: services ?? this.services,
        serviceLanguage: serviceLanguage ?? this.serviceLanguage,
        primaryLocation: primaryLocation ?? this.primaryLocation,
        location: location ?? this.location,
        serviceDistance: serviceDistance ?? this.serviceDistance,
        pricePerHour: pricePerHour ?? this.pricePerHour,
        serviceImages: serviceImages ?? this.serviceImages,
        isRead: isRead ?? this.isRead,
        isActive: isActive ?? this.isActive,
        isOnline: isOnline ?? this.isOnline,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        schedules: schedules ?? this.schedules,
      );
}

// User class to handle user object from API
class User {
  String? id;
  String? role;
  String? name;
  String? image;
  String? email;
  String? contact;
  String? location;
  num? credits;
  bool? isActive;
  bool? verified;
  bool? verifiedService;
  bool? isModified;
  bool? isDeleted;
  DateTime? createdAt;
  DateTime? updatedAt;
  User({
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
    this.verifiedService,
    this.isModified,
    this.isDeleted,
    this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<dynamic, dynamic> json) => User(
    id: json["_id"],
    role: json["role"],
    name: json["name"],
    image: json["image"],
    email: json["email"],
    contact: json["contact"],
    location: json["location"],
    credits: json["credits"],
    isActive: json["isActive"],
    verified: json["verified"],
    verifiedService: json["verifiedService"],
    isModified: json["isModified"],
    isDeleted: json["isDeleted"],
    createdAt: json["createdAt"] != null ? DateTime.parse(json["createdAt"]) : null,
    updatedAt: json["updatedAt"] != null ? DateTime.parse(json["updatedAt"]) : null,
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "role": role,
    "name": name,
    "image": image,
    "email": email,
    "contact": contact,
    "location": location,
    "credits": credits,
    "isActive": isActive,
    "verified": verified,
    "verifiedService": verifiedService,
    "isModified": isModified,
    "isDeleted": isDeleted,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
  };
}

class Service {
  String? id;
  Category? category;
  SubCategory? subCategory;
  int? price;
  String? status;
  DateTime? createdAt;
  DateTime? updatedAt;

  Service({
    this.id,
    this.category,
    this.subCategory,
    this.price,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory Service.fromJson(Map<String, dynamic> json) => Service(
    id: json["_id"],
    category: json["category"] != null ? Category.fromJson(json["category"]) : null,
    subCategory: json["subCategory"] != null ? SubCategory.fromJson(json["subCategory"]) : null,
    price: json["price"],
    status: json["status"],
    createdAt: json["createdAt"] != null ? DateTime.parse(json["createdAt"]) : null,
    updatedAt: json["updatedAt"] != null ? DateTime.parse(json["updatedAt"]) : null,
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "category": category?.toJson(),
    "subCategory": subCategory?.toJson(),
    "price": price,
    "status": status,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
  };
}

class Category {
  String? id;
  String? name;
  String? icon;

  Category({this.id, this.name, this.icon});

  factory Category.fromJson(Map<String, dynamic> json) => Category(
    id: json["_id"],
    name: json["name"],
    icon: json["icon"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "name": name,
    "icon": icon,
  };
}

class SubCategory {
  String? id;
  String? category;
  String? name;

  SubCategory({this.id, this.category, this.name});

  factory SubCategory.fromJson(Map<String, dynamic> json) => SubCategory(
    id: json["_id"],
    category: json["category"],
    name: json["name"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "category": category,
    "name": name,
  };
}

class Location {
  String? type;
  List<double>? coordinates;

  Location({this.type, this.coordinates});

  factory Location.fromJson(Map<String, dynamic> json) => Location(
    type: json["type"],
    coordinates: json["coordinates"] != null
        ? List<double>.from(json["coordinates"].map((x) => x.toDouble()))
        : null,
  );

  Map<String, dynamic> toJson() => {
    "type": type,
    "coordinates": coordinates,
  };
}

class Schedule {
  String? id;
  String? provider;
  DateTime? date;
  DateTime? startTime;
  DateTime? endTime;
  int? duration;
  int? count;
  List<AvailableSlot>? availableSlots;
  bool? isActive;

  Schedule({
    this.id,
    this.provider,
    this.date,
    this.startTime,
    this.endTime,
    this.duration,
    this.count,
    this.availableSlots,
    this.isActive,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) => Schedule(
    id: json["_id"],
    provider: json["provider"],
    date: json["date"] != null ? DateTime.parse(json["date"]) : null,
    startTime: json["startTime"] != null ? DateTime.parse(json["startTime"]) : null,
    endTime: json["endTime"] != null ? DateTime.parse(json["endTime"]) : null,
    duration: json["duration"],
    count: json["count"],
    availableSlots: json["available_slots"] != null
        ? List<AvailableSlot>.from(json["available_slots"].map((x) => AvailableSlot.fromJson(x)))
        : null,
    isActive: json["isActive"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "provider": provider,
    "date": date?.toIso8601String(),
    "startTime": startTime?.toIso8601String(),
    "endTime": endTime?.toIso8601String(),
    "duration": duration,
    "count": count,
    "available_slots": availableSlots != null ? List<dynamic>.from(availableSlots!.map((x) => x.toJson())) : null,
    "isActive": isActive,
  };
}

class AvailableSlot {
  String? id;
  DateTime? start;
  DateTime? end;

  AvailableSlot({this.id, this.start, this.end});

  factory AvailableSlot.fromJson(Map<String, dynamic> json) => AvailableSlot(
    id: json["_id"],
    start: json["start"] != null ? DateTime.parse(json["start"]) : null,
    end: json["end"] != null ? DateTime.parse(json["end"]) : null,
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "start": start?.toIso8601String(),
    "end": end?.toIso8601String(),
  };
}