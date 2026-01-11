import 'package:get/get.dart';
import 'package:thread_clone/controllers/auth_controller.dart';
import 'package:thread_clone/controllers/comment_controller.dart';
import 'package:thread_clone/controllers/home_controller.dart';
import 'package:thread_clone/controllers/public_profile_controller.dart';
import 'package:thread_clone/controllers/thread_controller.dart';
import 'package:thread_clone/routes/route_names.dart';
import 'package:thread_clone/views/auth/change_password_view.dart';
import 'package:thread_clone/views/auth/login_view.dart';
import 'package:thread_clone/views/auth/register_view.dart';
import 'package:thread_clone/views/home/add_comment_view.dart';
import 'package:thread_clone/views/profile/edit_profile_view.dart';
import 'package:thread_clone/views/profile/public_profile_view.dart';
import 'package:thread_clone/views/settings/settings_view.dart';
import 'package:thread_clone/views/thread/full_screen_image_view.dart';
import 'package:thread_clone/views/thread/thread_view.dart';
import 'package:thread_clone/widgets/bottom_nav_bar_widget.dart';

/// Centralized route configuration for the app.
///
/// Each route is linked with its view and, where necessary, its GetX binding.
/// Lazy loading is used for controllers to optimize memory usage.
/// Auth-guard can be added later if needed for protected routes.
class Routes {
  static final List<GetPage> pages = [
    /// -------------------------------- AUTH ROUTES --------------------------------
    GetPage(
      name: RouteNames.login,
      page: () => LoginView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<AuthController>(() => AuthController());
      }),
    ),
    GetPage(
      name: RouteNames.register,
      page: () => RegisterView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<AuthController>(() => AuthController());
      }),
    ),
    GetPage(
      name: RouteNames.changePassword,
      page: () => ChangePasswordView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<AuthController>(() => AuthController());
      }),
    ),

    /// -------------------------------- HOME / FEED --------------------------------
    GetPage(
      name: RouteNames.home,
      page: () => BottomNavBarWidget(),
      binding: BindingsBuilder(() {
        Get.lazyPut<HomeController>(() => HomeController());
      }),
    ),

    /// -------------------------------- THREAD ROUTES --------------------------------
    GetPage(
      name: RouteNames.thread,
      page: () => ThreadView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<ThreadController>(() => ThreadController());
      }),
    ),
    GetPage(
      name: RouteNames.addComment,
      page: () => AddCommentView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<CommentController>(() => CommentController());
      }),
    ),
    GetPage(
      name: RouteNames.fullScreenImage,
      page: () => FullScreenImageView(),
    ),

    /// -------------------------------- PROFILE ROUTES --------------------------------
    GetPage(
      name: RouteNames.showProfile,
      page: () => PublicProfileView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<PublicProfileController>(() => PublicProfileController());
      }),
    ),
    GetPage(
      name: RouteNames.editProfile,
      page: () => EditProfileView(),
      binding: BindingsBuilder(() {
        // If you have an EditProfileController, add it here
        // Get.lazyPut<EditProfileController>(() => EditProfileController());
      }),
    ),

    /// -------------------------------- SETTINGS --------------------------------
    GetPage(name: RouteNames.settings, page: () => SettingsView()),
  ];
}
