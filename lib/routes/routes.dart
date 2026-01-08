import 'package:get/get.dart';
import 'package:thread_clone/routes/route_names.dart';
import 'package:thread_clone/views/auth/login_view.dart';
import 'package:thread_clone/views/auth/register_view.dart';
import 'package:thread_clone/views/profile/edit_profile_view.dart';
import 'package:thread_clone/views/settings/settings_view.dart';
import 'package:thread_clone/widgets/bottom_nav_bar_widget.dart';

class Routes {
  static final List<GetPage> pages = [
    GetPage(
      name: RouteNames.login,
      page: () => LoginView(),
    ),

    GetPage(
      name: RouteNames.register,
      page: () => RegisterView(),
    ),

    GetPage(
      name: RouteNames.home,
      page: () => BottomNavBarWidget(),
    ),

    GetPage(
      name: RouteNames.editProfile,
      page: () => EditProfileView(),
    ),
    GetPage(
      name: RouteNames.settings,
      page: () => SettingsView(),
    ),
  ];
}
