import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:thread_clone/services/navigation_service.dart';

class HomeView extends StatelessWidget {
   HomeView({super.key});
  final NavigationService navigationService = Get.put(NavigationService());
  @override
  Widget build(BuildContext context) {

    return Obx(() {
      return Scaffold(
        bottomNavigationBar: NavigationBar(
          selectedIndex: navigationService.currentIndex.value,
          onDestinationSelected: navigationService.updateIndex,

          height: 60,
          destinations: [
            NavigationDestination(icon: Icon(Icons.home_outlined), label: "Home", selectedIcon: Icon(Icons.home)),
            NavigationDestination(icon: Icon(Icons.search_outlined), label: "Search", selectedIcon: Icon(Icons.search)),

            NavigationDestination(icon: Icon(Icons.add_outlined), label: "Create", selectedIcon: Icon(Icons.add)),

            NavigationDestination(icon: Icon(Icons.favorite_border_outlined), label: "Notification", selectedIcon: Icon(Icons.favorite)),

            NavigationDestination(icon: Icon(Icons.person_outlined), label: "Profile", selectedIcon: Icon(Icons.person)),
          ],
        ),
        body: AnimatedSwitcher(duration: Duration(microseconds: 50), switchInCurve: Curves.ease, switchOutCurve: Curves.easeInOut, child: navigationService.pages()[navigationService.currentIndex.value]),
      );
    });
  }
}
