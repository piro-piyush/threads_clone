import 'package:flutter/material.dart';
import 'package:get/state_manager.dart';
import 'package:thread_clone/views/create_thread/create_thread_view.dart';
import 'package:thread_clone/views/home/home_view.dart';
import 'package:thread_clone/views/notification/notification_view.dart';
import 'package:thread_clone/views/profile/profile_view.dart';
import 'package:thread_clone/views/search/search_view.dart';

class NavigationService extends GetxService {
  RxInt currentIndex = 0.obs;
  RxInt previousIndex = 0.obs;

  void updateIndex(int index) {
    previousIndex.value = currentIndex.value;
    currentIndex.value = index;
  }

  void backToPrevIndex() {
    currentIndex.value = previousIndex.value;
  }

  // Lazy-loaded pages to avoid self-reference
  List<Widget> pages() {
    return [
       HomeView(),          // HomeView should NOT call Get.put(NavigationService())!
      const SearchView(),
      const CreateThreadView(),
      const NotificationView(),
       ProfileView(),
    ];
  }

  Widget get currentPage {
    switch (currentIndex.value) {
      case 0:
        return  HomeView();
      case 1:
        return const SearchView();
      case 2:
        return const CreateThreadView();
      case 3:
        return const NotificationView();
      case 4:
        return  ProfileView();
      default:
        return  HomeView();
    }
  }
}
