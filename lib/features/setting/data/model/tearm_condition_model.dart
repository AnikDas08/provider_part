class TearmConditionModel {
  final String id;
  final String content;

  TearmConditionModel({
    required this.id,
    required this.content,
  });

  factory TearmConditionModel.fromJson(Map<String, dynamic> json) {
    return TearmConditionModel(
      id: json['_id'] ?? '',
      content: json['termsAndConditions'] ?? 'No Data Found',
    );
  }
}
