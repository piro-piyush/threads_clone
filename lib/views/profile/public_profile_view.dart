import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:thread_clone/controllers/public_profile_controller.dart';
import 'package:thread_clone/routes/route_names.dart';
import 'package:thread_clone/views/profile/widgets/silver_app_bar_delegate.dart';
import 'package:thread_clone/widgets/circular_image_widget.dart';
import 'package:thread_clone/widgets/status_loader_widget.dart';
import 'package:thread_clone/widgets/thread_card_widget.dart';
import 'package:thread_clone/widgets/thread_reply_widget.dart';


class PublicProfileView extends StatelessWidget {
  const PublicProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PublicProfileController());

    return Scaffold(
      appBar: AppBar(
        // actions: [
        //   IconButton(
        //     onPressed: () => Get.toNamed(RouteNames.settings),
        //     icon: const Icon(Icons.sort),
        //   )
        // ],
      ),
      body: DefaultTabController(
        length: 2,
        child: NestedScrollView(
          headerSliverBuilder: (_, bool innerBoxIsScrolled) {
            return [
              SliverAppBar(
                expandedHeight: 140,
                collapsedHeight: 140,
                automaticallyImplyLeading: false,
                flexibleSpace: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                  child: Obx(
                        () => controller.isUserLoading.value
                        ? const StatusLoaderWidget(
                      icon: Icons.person_outline,
                      title: "Loading profile",
                      subtitle: "Getting things ready for you",
                    )
                        : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                controller.user.value?.metadata.name ?? '',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 25,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                controller.user.value?.metadata.description ?? '',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        CircularProfileImageWidget(
                          url: controller.user.value?.metadata.imageUrl,
                          radius: 40,
                          uid:controller.user.value?.id,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SliverPersistentHeader(
                floating: true,
                pinned: true,
                delegate: SliverAppBarDelegate(
                  const TabBar(
                    indicatorSize: TabBarIndicatorSize.tab,
                    tabs: [
                      Tab(text: 'Threads'),
                      Tab(text: 'Replies'),
                    ],
                  ),
                ),
              )
            ];
          },
          body: TabBarView(
            children: [
              // ---------------- Threads Tab ----------------
              Obx(
                    () => controller.isThreadsLoading.value
                    ? const Center(child: CircularProgressIndicator())
                    : controller.threads.isNotEmpty
                    ? ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  itemCount: controller.threads.length,
                  itemBuilder: (_, index) {
                    final thread = controller.threads[index];
                    return ThreadCardWidget(
                      thread: thread,
                      onLikeTapped: controller.onLikeTapped,
                      onCommentTapped: (thread) {
                        Get.toNamed(RouteNames.addComment, arguments: thread.id);
                      },
                      onTap: () {
                        Get.toNamed(RouteNames.thread, arguments: thread.id);
                      },
                      onShareTapped: controller.onShareTapped,
                      uid: controller.uid,

                      canEditThread: controller.canEditThread,
                      canDeleteThread: controller.canDeleteThread,
                      editThread: controller.editThread,
                      deleteThread: (thread) =>
                          controller.deleteThread(context, thread),
                      isLiked: controller.threadLikeService.isThreadLiked,

                      likesMap: controller.likesMap,

                    );
                  }
                )
                    : const Center(child: Text("No threads found")),
              ),

              // ---------------- Replies Tab ----------------
              Obx(
                    () => controller.isRepliesLoading.value
                    ? const Center(child: CircularProgressIndicator())
                    : controller.repliedThreads.isNotEmpty
                    ? ListView.builder(
                  padding: const EdgeInsets.all(8),
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  itemCount: controller.repliedThreads.length,
                  itemBuilder: (_, index) => ThreadReplyWidget(
                    reply: controller.repliedThreads[index],
                  ),
                )
                    : const Center(child: Text("No replies found")),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
