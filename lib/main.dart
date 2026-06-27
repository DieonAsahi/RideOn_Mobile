import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/routes/app_pages.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:timeago/src/messages/id_messages.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await GetStorage.init();

  await Supabase.initialize(
    url: 'https://ttgqzqulswmponstjspb.supabase.co',
    publishableKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InR0Z3F6cXVsc3dtcG9uc3Rqc3BiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzc2MTk3MTksImV4cCI6MjA5MzE5NTcxOX0.dN8m6YJbZOrxgnQXzB3Xjux8rzDiH69JNYbeJh9Orn0',
  );

  timeago.setLocaleMessages('id', IdMessages());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: Routes.WELCOME,
      getPages: AppPages.routes,
    );
  }
}
