import 'package:get/get.dart';

import '../modules/Feature/edukasi/bindings/edukasi_binding.dart';
import '../modules/Feature/edukasi/views/edukasi_view.dart';
import '../modules/Feature/home/bindings/home_binding.dart';
import '../modules/Feature/home/views/home_view.dart';
import '../modules/Feature/kendaraan/bindings/kendaraan_binding.dart';
import '../modules/Feature/kendaraan/views/kendaraan_view.dart';
import '../modules/Feature/profil/bindings/profil_binding.dart';
import '../modules/Feature/profil/views/profil_view.dart';
import '../modules/Feature/service/bindings/service_binding.dart';
import '../modules/Feature/service/views/service_view.dart';
import '../modules/bengkel/bindings/bengkel_binding.dart';
import '../modules/bengkel/views/bengkel_view.dart';
import '../modules/changepass/bindings/changepass_binding.dart';
import '../modules/changepass/views/changepass_view.dart';
import '../modules/dtlperforma/bindings/dtlperforma_binding.dart';
import '../modules/dtlperforma/views/dtlperforma_view.dart';
import '../modules/editprofil/bindings/editprofil_binding.dart';
import '../modules/editprofil/views/editprofil_view.dart';
import '../modules/emailver/bindings/emailver_binding.dart';
import '../modules/emailver/views/emailver_view.dart';
import '../modules/estimasi/bindings/estimasi_binding.dart';
import '../modules/estimasi/views/estimasi_view.dart';
import '../modules/kerusakan/bindings/kerusakan_binding.dart';
import '../modules/kerusakan/views/kerusakan_view.dart';
import '../modules/kerusakanhasil/bindings/kerusakanhasil_binding.dart';
import '../modules/kerusakanhasil/views/kerusakanhasil_view.dart';
import '../modules/login/bindings/login_binding.dart';
import '../modules/login/views/login_view.dart';
import '../modules/mainscreen/bindings/mainscreen_binding.dart';
import '../modules/mainscreen/views/mainscreen_view.dart';
import '../modules/notif/bindings/notif_binding.dart';
import '../modules/notif/views/notif_view.dart';
import '../modules/otpemail/bindings/otpemail_binding.dart';
import '../modules/otpemail/views/otpemail_view.dart';
import '../modules/petabengkel/bindings/petabengkel_binding.dart';
import '../modules/petabengkel/views/petabengkel_view.dart';
import '../modules/pluskendaraan/bindings/pluskendaraan_binding.dart';
import '../modules/pluskendaraan/views/pluskendaraan_view.dart';
import '../modules/register/bindings/register_binding.dart';
import '../modules/register/views/register_view.dart';
import '../modules/rwtservis/bindings/rwtservis_binding.dart';
import '../modules/rwtservis/views/rwtservis_view.dart';
import '../modules/rwttambah/bindings/rwttambah_binding.dart';
import '../modules/rwttambah/views/rwttambah_view.dart';
import '../modules/updtodometer/bindings/updtodometer_binding.dart';
import '../modules/updtodometer/views/updtodometer_view.dart';
import '../modules/welcome/bindings/welcome_binding.dart';
import '../modules/welcome/views/welcome_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.MAINSCREEN;

  static final routes = [
    GetPage(
      name: _Paths.REGISTER,
      page: () => const RegisterView(),
      binding: RegisterBinding(),
    ),
    GetPage(
      name: _Paths.LOGIN,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.WELCOME,
      page: () => const WelcomeView(),
      binding: WelcomeBinding(),
    ),
    GetPage(
      name: _Paths.OTPEMAIL,
      page: () => const OtpemailView(),
      binding: OtpemailBinding(),
    ),
    GetPage(
      name: _Paths.PROFILE,
      page: () => const ProfilView(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: _Paths.MAINSCREEN,
      page: () => const MainscreenView(),
      binding: MainscreenBinding(),
    ),
    GetPage(
      name: _Paths.EDUKASI,
      page: () => const EdukasiView(),
      binding: EdukasiBinding(),
    ),
    GetPage(
      name: _Paths.NOTIF,
      page: () => const NotifView(),
      binding: NotifBinding(),
    ),
    GetPage(
      name: _Paths.CHANGEPASS,
      page: () => const ChangepassView(),
      binding: ChangepassBinding(),
    ),
    GetPage(
      name: _Paths.EMAILVER,
      page: () => const EmailverView(),
      binding: EmailverBinding(),
    ),
    GetPage(
      name: _Paths.KENDARAAN,
      page: () => const KendaraanView(),
      binding: KendaraanBinding(),
    ),
    GetPage(
      name: _Paths.SERVICE,
      page: () => const ServiceView(),
      binding: ServiceBinding(),
    ),
    GetPage(
      name: _Paths.PLUSKENDARAAN,
      page: () => const PluskendaraanView(),
      binding: PluskendaraanBinding(),
    ),
    GetPage(
      name: _Paths.RWTSERVIS,
      page: () => const RwtservisView(),
      binding: RwtservisBinding(),
    ),
    GetPage(
      name: _Paths.ESTIMASI,
      page: () => const EstimasiView(),
      binding: EstimasiBinding(),
    ),
    GetPage(
      name: _Paths.BENGKEL,
      page: () => const BengkelView(),
      binding: BengkelBinding(),
    ),
    GetPage(
      name: _Paths.RWTTAMBAH,
      page: () => const RwttambahView(),
      binding: RwttambahBinding(),
    ),
    GetPage(
      name: _Paths.PETABENGKEL,
      page: () => const PetabengkelView(),
      binding: PetabengkelBinding(),
    ),
    GetPage(
      name: _Paths.KERUSAKAN,
      page: () => const KerusakanView(),
      binding: KerusakanBinding(),
    ),
    GetPage(
      name: _Paths.KERUSAKANHASIL,
      page: () => const KerusakanhasilView(),
      binding: KerusakanhasilBinding(),
    ),
    GetPage(
      name: _Paths.EDITPROFIL,
      page: () => const EditprofilView(),
      binding: EditprofilBinding(),
    ),
    GetPage(
      name: _Paths.DTLPERFORMA,
      page: () => const DtlperformaView(),
      binding: DtlperformaBinding(),
    ),
    GetPage(
      name: _Paths.UPDTODOMETER,
      page: () => const UpdtodometerView(),
      binding: UpdtodometerBinding(),
    ),
  ];
}
