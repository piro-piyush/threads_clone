import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:thread_clone/controllers/home_controller.dart';
import 'package:thread_clone/routes/route_names.dart';
import 'package:thread_clone/services/navigation_service.dart';
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
        return RefreshIndicator(
          onRefresh: () async => await controller.initialize(),
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
              if (controller.threads.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.feed_outlined,
                            size: 80,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 20),
                          Text(
                            "No Threads Yet",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[200],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "There are no threads to show at the moment.\nStart sharing your thoughts now!",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[400],
                            ),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            onPressed: () =>
                                Get.find<NavigationService>().updateIndex(2),
                            icon: Icon(Icons.add),
                            label: Text("Create Thread"),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final thread = controller.threads[index];
                    return ThreadCardWidget(
                      onTap: () {
                        Get.toNamed(RouteNames.thread, arguments: thread.id);
                      },
                      thread: thread,
                      uid: controller.uid,
                      onLikeTapped: controller.onLikeTapped,
                      onCommentTapped: (thread) {
                        Get.toNamed(
                          RouteNames.addComment,
                          arguments: thread.id,
                        );
                      },
                      onShareTapped: controller.onShareTapped,
                      canEditThread: controller.canEditThread,
                      canDeleteThread: controller.canDeleteThread,
                      editThread: controller.editThread,
                      deleteThread: (thread) =>
                          controller.deleteThread(context, thread),
                      isLiked: controller.isThreadLiked,
                      likesMap: controller.likesMap,
                    );
                  }, childCount: controller.threads.length),
                ),
            ],
          ),
        );
      }),
    );
  }
}
