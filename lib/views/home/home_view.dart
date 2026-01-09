import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:thread_clone/controllers/home_controller.dart';
import 'package:thread_clone/widgets/status_loader_widget.dart';
import 'package:thread_clone/widgets/thread_card_widget.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: StatusLoaderWidget(
              title: "Loading Threads...",
              subtitle: "Please wait while we fetch your threads.",
              icon: Icons.refresh,
            ),
          );
        }
        return CustomMaterialIndicator(
          onRefresh: () async => await controller.init(),

          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                title: Padding(
                  padding: EdgeInsetsGeometry.only(top: 10),
                  child: Image.asset(
                    'assets/images/logo.png',
                    height: 40,
                    width: 40,
                  ),
                ),
                centerTitle: true,
              ),
              SliverToBoxAdapter(
                child: ListView.builder(
                  itemCount: controller.threads.length,
                  shrinkWrap: true,
                  physics: BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    final thread = controller.threads[index];
                    return ThreadCardWidget(
                      thread: thread,
                      uid: controller.uid,
                      onLikeTapped: controller.onLikeTapped,
                      onCommentTapped: controller.onCommentTapped,
                      onShareTapped: controller.onShareTapped,
                    );
                  },
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
