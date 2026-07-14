import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class AppLifecycle extends WidgetsBindingObserver {
  final box = GetStorage();

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.paused) {
      box.write("last_closed", DateTime.now().toIso8601String());
    }

    if (state == AppLifecycleState.resumed) {
      final last = box.read("last_closed");

      if (last != null) {
        final diff = DateTime.now().difference(DateTime.parse(last));

        if (diff.inMinutes >= 1) {
          await box.erase();
          Get.offAllNamed('/login');
        }
      }
    }
  }
}