import 'package:get/get.dart';
import 'package:thread_clone/routes/route_names.dart';
import 'package:thread_clone/views/auth/login_view.dart';
import 'package:thread_clone/views/auth/register_view.dart';
import 'package:thread_clone/views/home_view.dart';

class Routes {
  static final List<GetPage> pages = [GetPage(name: RouteNames.home, page: () => HomeView()), GetPage(name: RouteNames.login, page: () => LoginView()), GetPage(name: RouteNames.register, page: () => RegisterView())];
}
