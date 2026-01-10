import 'package:get/get.dart';
import 'package:thread_clone/services/auth_service.dart';
import 'package:thread_clone/services/comments_service.dart';
import 'package:thread_clone/services/notifications_service.dart';
import 'package:thread_clone/services/thread_like_service.dart';
import 'package:thread_clone/services/threads_service.dart';
import 'package:thread_clone/services/user_service.dart';

class GeneralBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(AuthService(), permanent: true);
    Get.put(UserService(), permanent: true);
    Get.put(ThreadsService(), permanent: true);
    Get.put(ThreadLikeService(), permanent: true);
    Get.put(CommentsService(), permanent: true);
    Get.put(NotificationsService(), permanent: true);
  }
}
