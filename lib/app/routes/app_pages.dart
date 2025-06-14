import 'package:get/get.dart';

import '../modules/DaftarMatkul/bindings/daftar_matkul_binding.dart';
import '../modules/DaftarMatkul/views/daftar_matkul_view.dart';
import '../modules/camera/bindings/camera_binding.dart';
import '../modules/camera/views/camera_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/tools/bindings/tools_binding.dart';
import '../modules/tools/views/tools_view.dart';
import '../modules/introduction/bindings/introduction_binding.dart';
import '../modules/introduction/views/introduction_view.dart';
import '../modules/journal/bindings/journal_binding.dart';
import '../modules/journal/views/journal_view.dart';
import '../modules/permission_template/bindings/permission_template_binding.dart';
import '../modules/permission_template/views/permission_template_view.dart';
import '../modules/permission_template/bindings/permission_editor_binding.dart';
import '../modules/permission_template/views/permission_editor_view.dart';
import '../modules/jadwal/bindings/jadwal_binding.dart';
import '../modules/jadwal/views/jadwal_view.dart';
import '../modules/login/bindings/login_binding.dart';
import '../modules/login/views/login_view.dart';
import '../modules/profile/bindings/profile_binding.dart';
import '../modules/profile/views/profile_view.dart';
import '../modules/settings/bindings/settings_binding.dart';
import '../modules/settings/views/settings_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.INTRODUCTION;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.LOGIN,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: _Paths.PROFILE,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: _Paths.CAMERA,
      page: () => const CameraView(),
      binding: CameraBinding(),
    ),
    GetPage(
      name: _Paths.INTRODUCTION,
      page: () => const IntroductionView(),
      binding: IntroductionBinding(),
    ),
    GetPage(
      name: _Paths.SETTINGS,
      page: () => const SettingsView(),
      binding: SettingsBinding(),
    ),
    GetPage(
      name: _Paths.JADWAL,
      page: () => const JadwalView(),
      binding: JadwalBinding(),
    ),
    GetPage(
      name: _Paths.DAFTAR_MATKUL,
      page: () => const DaftarMatkulView(),
      binding: DaftarMatkulBinding(),
    ),
    GetPage(
      name: _Paths.TOOLS,
      page: () => const ToolsView(),
      binding: ToolsBinding(),
    ),
    GetPage(
      name: _Paths.JOURNAL,
      page: () => const JournalView(),
      binding: JournalBinding(),
    ),
    GetPage(
      name: _Paths.PERMISSION_TEMPLATE,
      page: () => const PermissionTemplateView(),
      binding: PermissionTemplateBinding(),
    ),
    GetPage(
      name: _Paths.PERMISSION_EDITOR,
      page: () => const PermissionEditorView(),
      binding: PermissionEditorBinding(),
    ),
  ];
}
