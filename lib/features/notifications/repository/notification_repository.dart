import '../../../config/api/api_end_point.dart';
import '../../../services/api/api_service.dart';
import '../data/model/notification_model.dart';

/// Notification Repository - Fetches notifications from API
Future<List<NotificationModel>> notificationRepository(int page) async {
  try {
    final response = await ApiService.get(
      "${ApiEndPoint.notifications}?page=$page",
      header: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      // Try to extract the list from different possible keys
      dynamic rawData = response.data;
      List dataList = [];

      if (rawData is List) {
        dataList = rawData;
      } else if (rawData is Map) {
        // ✅ Adjust these keys according to your backend
        dataList = rawData['data'] ??
            rawData['notifications'] ??
            rawData['items'] ??
            [];
      }

      // ✅ Convert to NotificationModel
      return dataList
          .whereType<Map>() // ensure it's a list of Map
          .map((json) => NotificationModel.fromJson(Map<String, dynamic>.from(json)))
          .toList();
    } else {
      print('Error fetching notifications: ${response.message}');
      return [];
    }
  } catch (e) {
    print('Exception in notificationRepository: $e');
    return [];
  }
}
