import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app/core/app_lifecycle.dart';
import 'app/routes/app_pages.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'app/services/local_notification_service.dart';
import 'app/services/firebase_messaging_service.dart';
import 'app/services/location_service.dart';
import 'app/services/connectivity_service.dart';
import 'app/widgets/no_internet_widget.dart';
import 'app/core/theme/app_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  WidgetsBinding.instance.addObserver(AppLifecycle());

  await dotenv.load(fileName: ".env");

  await GetStorage.init();

  // Inisialisasi ConnectivityService secara global
  Get.put(ConnectivityService(), permanent: true);

  await initializeDateFormatting('id_ID', null);

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    publishableKey: dotenv.env['SUPABASE_PUBLISHABLE_KEY']!,
  );

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // Local notification
  await LocalNotificationService.init();

  // FCM
  await FirebaseMessagingService.init();

  // Request location permission at app startup
  await LocationService.requestLocationPermission();

  timeago.setLocaleMessages('id', timeago.IdMessages());

  runApp(const MyApp());

  await FirebaseMessagingService.handleInitialMessage();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: Routes.WELCOME,
      getPages: AppPages.routes,
      builder: (context, child) {
        return Stack(
          children: [
            child ?? const SizedBox.shrink(),
            const GlobalNoInternetOverlay(),
          ],
        );
      },
    );
  }
}
