import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:thread_clone/controllers/notifications_controller.dart';
import 'package:thread_clone/routes/route_names.dart';
import 'package:thread_clone/services/navigation_service.dart';
import 'package:thread_clone/utils/enums.dart';
import 'package:thread_clone/widgets/status_loader_widget.dart';

class NotificationView extends StatelessWidget {
  const NotificationView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NotificationsController());

    return Scaffold(
      appBar: AppBar(
        leading: CloseButton(
          onPressed: Get.find<NavigationService>().backToPrevIndex,
        ),
        title: Text("Notifications"),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: StatusLoaderWidget(
              title: "Loading Notifications...",
              subtitle: "Please wait while we fetch your notifications.",
              icon: Icons.refresh,
            ),
          );
        }

        final notifications = controller.notifications;

        if (notifications.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.notifications_none,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "No Notifications",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[200],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "You have no notifications at the moment.\nCheck back later!",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey[400]),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: controller.initialize,
                    icon: Icon(Icons.refresh),
                    label: Text("Refresh"),
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
          );
        }

        return RefreshIndicator(
          onRefresh: () async => controller.initialize(),
          displacement: 40,
          edgeOffset: 20,
          child: ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: notifications.length,
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final notification = notifications[index];
              final type = NotificationTypeExtension.fromString(
                notification.type,
              );

              return InkWell(
                onTap: () {
                  if (notification.threadId != null) {
                    Get.toNamed(
                      RouteNames.thread,
                      arguments: notification.threadId,
                    );
                  }
                },
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // avatar
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundImage:
                          notification.fromUser?.metadata.imageUrl != null
                              ? NetworkImage(
                            notification.fromUser!.metadata.imageUrl,
                          )
                              : null,
                          backgroundColor:
                          notification.fromUser?.metadata.imageUrl == null
                              ? Colors.grey[300]
                              : null,
                          child:
                          notification.fromUser?.metadata.imageUrl == null
                              ? Icon(type.icon, color: Colors.white, size: 20)
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: CircleAvatar(
                            radius: 10,
                            backgroundColor: Colors.white,
                            child: Icon(
                              type.icon,
                              size: 14,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 12),

                    // text
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            notification.fromUser?.metadata.name ?? "",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: notification.hasRead
                                  ? FontWeight.normal
                                  : FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            notification.headlineText,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[400],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // time + unread dot
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          notification.formattedCreatedAt,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                        const SizedBox(height: 6),
                        if (!notification.hasRead)
                          Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        );

      }),
    );
  }
}
