import 'package:get/get.dart';
import 'package:thread_clone/services/auth_service.dart';
import 'package:thread_clone/services/comments_service.dart';
import 'package:thread_clone/services/notifications_service.dart';
import 'package:thread_clone/services/thread_like_service.dart';
import 'package:thread_clone/services/threads_service.dart';
import 'package:thread_clone/services/user_service.dart';

/// GeneralBindings is responsible for registering all
/// app-level services using GetX Dependency Injection.
///
/// These services are marked as `permanent: true`,
/// which means they are created once and live
/// throughout the entire lifecycle of the application.
///
/// This binding is usually initialized at app start
/// (e.g., in `initialBinding` of GetMaterialApp).
class GeneralBindings extends Bindings {
  @override
  void dependencies() {
    /// Handles authentication logic
    /// - Login / Signup
    /// - Logout
    /// - Session management
    Get.put(AuthService(), permanent: true);

    /// Manages user-related operations
    /// - Fetch user profile
    /// - Update user data
    /// - Current user state
    Get.put(UserService(), permanent: true);

    /// Handles thread CRUD operations
    /// - Create thread
    /// - Fetch threads
    /// - Delete / update threads
    Get.put(ThreadsService(), permanent: true);

    /// Manages like/unlike functionality for threads
    /// - Toggle likes
    /// - Fetch like state
    Get.put(ThreadLikeService(), permanent: true);

    /// Handles comments feature
    /// - Add comment
    /// - Fetch comments
    /// - Delete comments
    Get.put(CommentsService(), permanent: true);

    /// Manages notifications
    /// - Push notifications
    /// - In-app notifications
    /// - Notification read/unread state
    Get.put(NotificationsService(), permanent: true);
  }
}

