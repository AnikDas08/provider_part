class ProviderModel {
  final String id;
  final String primaryLocation;
  final LocationData location;
  final int serviceDistance;
  final double pricePerHour;
  final bool isActive;
  final bool isOnline;
  final String name;
  final String? image;
  final String category;
  final String subCategory;
  final double price;

  ProviderModel({
    required this.id,
    required this.primaryLocation,
    required this.location,
    required this.serviceDistance,
    required this.pricePerHour,
    required this.isActive,
    required this.isOnline,
    required this.name,
    this.image,
    required this.category,
    required this.subCategory,
    required this.price,
  });

  factory ProviderModel.fromJson(Map<String, dynamic> json) {
    return ProviderModel(
      id: json['_id'] ?? '',
      primaryLocation: json['primaryLocation'] ?? '',
      location: LocationData.fromJson(json['location'] ?? {}),
      serviceDistance: json['serviceDistance'] ?? 0,
      pricePerHour: (json['pricePerHour'] ?? 0).toDouble(),
      isActive: json['isActive'] ?? false,
      isOnline: json['isOnline'] ?? false,
      name: json['name'] ?? '',
      image: json['image'],
      category: json['category'] ?? '',
      subCategory: json['subCategory'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'primaryLocation': primaryLocation,
      'location': location.toJson(),
      'serviceDistance': serviceDistance,
      'pricePerHour': pricePerHour,
      'isActive': isActive,
      'isOnline': isOnline,
      'name': name,
      'image': image,
      'category': category,
      'subCategory': subCategory,
      'price': price,
    };
  }
}

class LocationData {
  final String type;
  final List<double> coordinates;

  LocationData({
    required this.type,
    required this.coordinates,
  });

  factory LocationData.fromJson(Map<String, dynamic> json) {
    return LocationData(
      type: json['type'] ?? 'Point',
      coordinates: json['coordinates'] != null
          ? List<double>.from(json['coordinates'].map((x) => x.toDouble()))
          : [0.0, 0.0],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'coordinates': coordinates,
    };
  }

  // Helper getters
  double get longitude => coordinates.isNotEmpty ? coordinates[0] : 0.0;
  double get latitude => coordinates.length > 1 ? coordinates[1] : 0.0;
}

class ProvidersResponse {
  final bool success;
  final String message;
  final List<ProviderModel> data;

  ProvidersResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory ProvidersResponse.fromJson(Map<String, dynamic> json) {
    return ProvidersResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? List<ProviderModel>.from(
          json['data'].map((x) => ProviderModel.fromJson(x)))
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data.map((x) => x.toJson()).toList(),
    };
  }
}