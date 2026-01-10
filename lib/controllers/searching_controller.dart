import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:thread_clone/models/searched_user_model.dart';
import 'package:thread_clone/services/user_service.dart';

class SearchingController extends GetxController {
  late TextEditingController searchController;
  final UserService _userService = Get.find<UserService>();
  RxBool isLoading = false.obs;
  RxList<SearchedUserModel> users = <SearchedUserModel>[].obs;
  RxBool notFound = false.obs;
  Timer? _debounce;

  @override
  void onInit() {
    super.onInit();
    searchController = TextEditingController();
  }

  Future<void> searchUser(String name) async {
    isLoading.value = true;
    notFound.value = false;
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (name.isNotEmpty) {
        final data = await _userService.searchUser(name);
        isLoading.value = false;
        if (data.isNotEmpty) {
          users.value = data;
          notFound.value = false;
        } else {
          notFound.value = true;
        }
      }
      isLoading.value = false;
    });
  }
}
