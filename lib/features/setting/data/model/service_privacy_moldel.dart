class ServicePrivacyModel {
  final String id;
  final String content;

  ServicePrivacyModel({
    required this.id,
    required this.content,
  });

  factory ServicePrivacyModel.fromJson(Map<String, dynamic> json) {
    return ServicePrivacyModel(
      id: json['_id'] ?? '',
      content: json['providerUsagePolicy'] ?? 'No Data Found',
    );
  }
}
