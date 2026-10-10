import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'package:capbatu/app/modules/rwttambah/controllers/rwttambah_controller.dart';
import 'package:capbatu/app/modules/Feature/home/controllers/home_controller.dart';
import 'package:capbatu/app/modules/Feature/kendaraan/controllers/kendaraan_controller.dart';
import 'package:capbatu/app/modules/Feature/service/controllers/service_controller.dart';
import 'package:capbatu/app/modules/Feature/profil/controllers/profil_controller.dart';
import 'package:capbatu/app/modules/bengkel/controllers/bengkel_controller.dart';
import 'package:capbatu/app/modules/petabengkel/controllers/petabengkel_controller.dart';
import 'package:capbatu/app/modules/notif/controllers/notif_controller.dart';

class ConnectivityService extends GetxService {
  static ConnectivityService get to => Get.find<ConnectivityService>();

  final isOffline = false.obs;
  final isChecking = false.obs;
  DateTime? disconnectStartTime;

  Timer? _recoveryTimer;
  int _consecutiveRecoveryCount = 0;
  StreamSubscription<List<ConnectivityResult>>? _recoverySubscription;
  final Connectivity _connectivity = Connectivity();

  // Konsep baru: saat user diam / idle, TIDAK ADA background check berkala
  // yang memaksa layar menjadi offline agar tidak kelap-kelip.
  // Tampilan tidak ada koneksi HANYA muncul saat ada aktivitas (CRUD/loading/request)
  // yang gagal karena masalah jaringan via handleNetworkError().

  /// Aktifkan monitoring pemulihan HANYA saat kondisi offline sedang aktif
  void _startRecoveryMonitoring() {
    _stopRecoveryMonitoring();

    // 1. Cek berkala hanya saat offline untuk mendeteksi kapan jaringan pulih stabil
    _consecutiveRecoveryCount = 0;
    _recoveryTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
      if (!isOffline.value) {
        _stopRecoveryMonitoring();
        return;
      }

      final hasInternet = await _pingSocket();
      if (hasInternet) {
        _consecutiveRecoveryCount++;
        // Butuh 2 kali sukses berturut-turut untuk memastikan benar-benar stabil
        if (_consecutiveRecoveryCount >= 2) {
          setOffline(false);
          reloadActiveControllers();
        }
      } else {
        _consecutiveRecoveryCount = 0;
      }
    });

    // 2. Dengarkan broadcast perubahan koneksi OS saat offline
    _recoverySubscription = _connectivity.onConnectivityChanged.listen((results) async {
      if (!isOffline.value) return;
      final isConnected = results.isNotEmpty &&
          results.any((r) => r != ConnectivityResult.none);
      if (isConnected) {
        final hasInternet = await _pingSocket();
        if (hasInternet && isOffline.value) {
          _consecutiveRecoveryCount++;
          if (_consecutiveRecoveryCount >= 2) {
            setOffline(false);
            reloadActiveControllers();
          }
        }
      }
    });
  }

  /// Hentikan seluruh monitoring saat aplikasi sudah online / normal
  void _stopRecoveryMonitoring() {
    _recoveryTimer?.cancel();
    _recoveryTimer = null;
    _recoverySubscription?.cancel();
    _recoverySubscription = null;
    _consecutiveRecoveryCount = 0;
  }

  /// Ping langsung via socket TCP ke DNS publik
  Future<bool> _pingSocket() async {
    try {
      final socket = await Socket.connect('8.8.8.8', 53,
              timeout: const Duration(milliseconds: 1200))
          .catchError((e) => throw e);
      socket.destroy();
      return true;
    } catch (_) {
      try {
        final socket = await Socket.connect('1.1.1.1', 53,
                timeout: const Duration(milliseconds: 1200))
            .catchError((e) => throw e);
        socket.destroy();
        return true;
      } catch (_) {
        return false;
      }
    }
  }

  /// Set status offline dan tutup semua snackbar agar error backend tidak bocor ke user
  void setOffline(bool offline) {
    if (offline) {
      // Tutup semua snackbar agar pesan error raw/backend tidak bocor
      if (Get.isSnackbarOpen) {
        Get.closeAllSnackbars();
      }
      if (!isOffline.value) {
        disconnectStartTime = DateTime.now();
        isOffline.value = true;
        _startRecoveryMonitoring();
      }
    } else {
      if (isOffline.value) {
        _stopRecoveryMonitoring();
        // Cek durasi offline: jika lebih dari 10 menit, reset data form input
        if (disconnectStartTime != null) {
          final elapsed = DateTime.now().difference(disconnectStartTime!);
          if (elapsed > const Duration(minutes: 10)) {
            _resetActiveForms();
          }
        }
        disconnectStartTime = null;
        isOffline.value = false;
      }
    }
  }

  /// Cek koneksi internet manual (dipanggil oleh tombol 'Muat ulang')
  Future<bool> checkConnection({bool silent = false}) async {
    if (!silent) isChecking.value = true;

    final hasConnection = await _pingSocket();

    if (hasConnection) {
      setOffline(false);
    } else {
      setOffline(true);
    }

    if (!silent) isChecking.value = false;
    return hasConnection;
  }

  /// Muat ulang data pada controller aktif setelah koneksi tersambung kembali
  void reloadActiveControllers() {
    try {
      if (Get.isRegistered<HomeController>()) {
        Get.find<HomeController>().fetchHome(force: true);
      }
    } catch (_) {}

    try {
      if (Get.isRegistered<KendaraanController>()) {
        Get.find<KendaraanController>().getVehicles(force: true);
      }
    } catch (_) {}

    try {
      if (Get.isRegistered<ServiceController>()) {
        Get.find<ServiceController>().getServices(force: true);
      }
    } catch (_) {}

    try {
      if (Get.isRegistered<ProfilController>()) {
        Get.find<ProfilController>().getProfile(force: true);
      }
    } catch (_) {}

    try {
      if (Get.isRegistered<BengkelController>()) {
        Get.find<BengkelController>().loadNearestWorkshop();
      }
    } catch (_) {}

    try {
      if (Get.isRegistered<PetabengkelController>()) {
        Get.find<PetabengkelController>().loadMapData();
      }
    } catch (_) {}

    try {
      if (Get.isRegistered<NotifController>()) {
        Get.find<NotifController>().getNotifications(silent: true);
      }
    } catch (_) {}
  }

  /// Cek apakah error merupakan kendala jaringan (koneksi terputus/timeout)
  static bool isNetworkError(dynamic error) {
    if (error == null) return false;
    if (error is SocketException ||
        error is TimeoutException ||
        error is HttpException) {
      return true;
    }
    final str = error.toString().toLowerCase();
    return str.contains('socketexception') ||
        str.contains('failed host lookup') ||
        str.contains('network is unreachable') ||
        str.contains('network unreachable') ||
        str.contains('connection refused') ||
        str.contains('connection timed out') ||
        str.contains('connection closed') ||
        str.contains('connection reset') ||
        str.contains('clientexception') ||
        str.contains('timeoutexception') ||
        str.contains('no address associated with hostname') ||
        str.contains('handshakeexception') ||
        str.contains('os error: no address associated') ||
        str.contains('software caused connection abort') ||
        str.contains('network error') ||
        str.contains('dioexception') ||
        str.contains('connectionerror') ||
        str.contains('errno = 7') ||
        str.contains('errno = 101') ||
        str.contains('errno = 110') ||
        str.contains('errno = 111') ||
        str.contains('tidak bisa konek ke server') ||
        str.contains('tidak bisa terhubung') ||
        str.contains('failed to connect');
  }

  /// Tangani error jaringan secara global: tutup snackbar dan tampilkan widget offline
  static bool handleNetworkError(dynamic error) {
    if (isNetworkError(error)) {
      if (Get.isSnackbarOpen) {
        Get.closeAllSnackbars();
      }
      if (Get.isRegistered<ConnectivityService>()) {
        ConnectivityService.to.setOffline(true);
      }
      return true;
    }
    return false;
  }

  void _resetActiveForms() {
    try {
      if (Get.isRegistered<RwttambahController>()) {
        Get.find<RwttambahController>().resetForm();
      }
    } catch (_) {}
  }

  @override
  void onClose() {
    _stopRecoveryMonitoring();
    super.onClose();
  }
}
