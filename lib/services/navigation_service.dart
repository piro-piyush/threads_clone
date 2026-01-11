import 'package:flutter/material.dart';
import 'package:get/state_manager.dart';
import 'package:thread_clone/views/home/home_view.dart';
import 'package:thread_clone/views/notification/notification_view.dart';
import 'package:thread_clone/views/profile/profile_view.dart';
import 'package:thread_clone/views/search/search_view.dart';
import 'package:thread_clone/views/thread/create_thread_view.dart';

/// Service to manage bottom navigation and active page state.
class NavigationService extends GetxService {
  /// Current selected index in bottom navigation
  final RxInt currentIndex = 0.obs;

  /// Previous index to support "back" navigation
  final RxInt previousIndex = 0.obs;

  /// Updates the current index and saves previous index
  void updateIndex(int index) {
    previousIndex.value = currentIndex.value;
    currentIndex.value = index;
  }

  /// Navigates back to the previous index
  void backToPrevIndex() {
    currentIndex.value = previousIndex.value;
  }

  /// Lazily loaded list of pages for bottom navigation
  List<Widget> pages() => [
    HomeView(),
    const SearchView(),
    const CreateThreadView(),
    const NotificationView(),
    ProfileView(),
  ];

  /// Returns the current page based on `currentIndex`
  Widget get currentPage {
    switch (currentIndex.value) {
      case 0:
        return HomeView();
      case 1:
        return const SearchView();
      case 2:
        return const CreateThreadView();
      case 3:
        return const NotificationView();
      case 4:
        return ProfileView();
      default:
        return HomeView();
    }
  }
}
