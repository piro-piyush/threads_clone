import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:thread_clone/models/user_model.dart';
import 'package:thread_clone/services/user_service.dart';

/// SearchingController handles user search functionality.
///
/// Responsibilities:
/// - Managing search input
/// - Debouncing search requests
/// - Fetching users from backend
/// - Handling loading & empty states
///
/// Uses:
/// - GetX for state management
/// - Timer for debounce optimization
class SearchingController extends GetxController {
  // ---------------- UI ----------------

  /// Search text controller
  late final TextEditingController searchController;

  // ---------------- SERVICES ----------------

  /// User-related API operations
  final UserService _userService = Get.find<UserService>();

  // ---------------- STATE ----------------

  /// Indicates API call in progress
  final RxBool isLoading = false.obs;

  /// Search result users
  final RxList<UserModel> users = <UserModel>[].obs;

  /// Indicates no user found
  final RxBool notFound = false.obs;

  // ---------------- DEBOUNCE ----------------

  Timer? _debounce;

  // ---------------- LIFECYCLE ----------------

  @override
  void onInit() {
    super.onInit();
    searchController = TextEditingController();
  }

  @override
  void onClose() {
    _debounce?.cancel();
    searchController.dispose();
    super.onClose();
  }

  // ---------------- SEARCH ----------------

  /// Searches users by name with debounce
  Future<void> searchUser(String query) async {
    // Cancel previous debounce if active
    if (_debounce?.isActive ?? false) _debounce?.cancel();

    if (query.trim().isEmpty) {
      users.clear();
      notFound.value = false;
      isLoading.value = false;
      return;
    }

    isLoading.value = true;
    notFound.value = false;

    _debounce = Timer(
      const Duration(milliseconds: 500),
          () async {
        try {
          final result = await _userService.searchUser(query.trim());

          users.value = result;
          notFound.value = result.isEmpty;
        } catch (_) {
          users.clear();
          notFound.value = true;
        } finally {
          isLoading.value = false;
        }
      },
    );
  }
}
