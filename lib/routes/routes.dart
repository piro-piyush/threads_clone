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

class Routes {
  static final List<GetPage> pages = [
    GetPage(
      name: RouteNames.login,
      page: () => LoginView(),
      binding: BindingsBuilder(() {
        Get.put(AuthController());
      }),
    ),

    GetPage(
      name: RouteNames.register,
      page: () => RegisterView(),
      binding: BindingsBuilder(() {
        Get.put(AuthController());
      }),
    ),
    GetPage(
      name: RouteNames.changePassword,
      page: () => ChangePasswordView(),
      binding: BindingsBuilder(() {
        Get.put(AuthController());
      }),
    ),

    GetPage(
      name: RouteNames.home,
      page: () => BottomNavBarWidget(),
      binding: BindingsBuilder(() {
        Get.put(HomeController());
      }),
    ),
    GetPage(
      name: RouteNames.thread,
      page: () => ThreadView(),
      binding: BindingsBuilder(() {
        Get.put(ThreadController());
      }),
    ),
    GetPage(
      name: RouteNames.showProfile,
      page: () => PublicProfileView(),
      binding: BindingsBuilder(() {
        Get.put(PublicProfileController());
      }),
    ),

    GetPage(name: RouteNames.editProfile, page: () => EditProfileView()),
    GetPage(name: RouteNames.settings, page: () => SettingsView()),
    GetPage(
      name: RouteNames.fullScreenImage,
      page: () => FullScreenImageView(),
    ),
    GetPage(
      name: RouteNames.addComment,
      page: () => AddCommentView(),
      binding: BindingsBuilder(() {
        Get.put(CommentController());
      }),
    ),
  ];
}
