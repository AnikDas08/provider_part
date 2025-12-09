class PrivacyPolicyModel {
  final String id;
  final String content;

  PrivacyPolicyModel({
    required this.id,
    required this.content,
  });

  factory PrivacyPolicyModel.fromJson(Map<String, dynamic> json) {
    return PrivacyPolicyModel(
      id: json['_id'] ?? '',
      content: json['privacyPolicy'] ?? 'No Data Found',
    );
  }
}
