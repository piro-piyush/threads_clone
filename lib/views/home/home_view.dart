import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:thread_clone/services/navigation_service.dart';

class HomeView extends StatelessWidget {
  HomeView({super.key});

  final NavigationService navigationService = Get.put(NavigationService());

  @override
  Widget build(BuildContext context) {
    return Text("Hey i am home");
  }
}
