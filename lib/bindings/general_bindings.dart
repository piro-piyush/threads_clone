import 'package:get/get.dart';
import 'package:thread_clone/services/auth_service.dart';
import 'package:thread_clone/services/threads_service.dart';
import 'package:thread_clone/services/user_service.dart';

class GeneralBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(AuthService(), permanent: true);
    Get.put(UserService(), permanent: true);
    Get.put(ThreadsService(), permanent: true);
  }
}
