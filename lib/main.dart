import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:haircutmen_user_app/utils/extensions/extension.dart';

import 'app.dart';
import 'config/dependency/dependency_injection.dart';
import 'main.dart' as GetStorage;
import 'services/notification/notification_service.dart';
import 'services/socket/socket_service.dart';
import 'services/storage/storage_services.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  await init.tryCatch();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // Transparent বা app primary color
      statusBarIconBrightness: Brightness.dark, // Android এর জন্য
      statusBarBrightness: Brightness.light,    // iOS এর জন্য
    ),
  );

  runApp(const MyApp());
}

init() async {
  DependencyInjection dI = DependencyInjection();
  dI.dependencies();
  SocketServices.connectToSocket();

  await Future.wait([
    LocalStorage.getAllPrefData(),
    NotificationService.initLocalNotification(),
  ]);
}
