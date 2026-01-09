import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:thread_clone/controllers/profile_controller.dart';
import 'package:thread_clone/routes/route_names.dart';
import 'package:thread_clone/services/auth_service.dart';
import 'package:thread_clone/utils/helper.dart';
import 'package:thread_clone/views/profile/widgets/profile_header_widget.dart';
import 'package:thread_clone/views/profile/widgets/silver_app_bar_delegate.dart';
import 'package:thread_clone/widgets/replies_widget.dart';
import 'package:thread_clone/widgets/threads_widget.dart';

class ProfileView extends StatelessWidget {
  ProfileView({super.key});

  final AuthService authService = Get.find<AuthService>();

  void shareProfile({required String? uid, required String? name}) {
    if (uid == null || uid.isEmpty || name == null || name.isEmpty) {
      showSnackBar("Error", "Failed to share profile");
      return;
    }

    // Construct your profile URL
    final profileUrl = "https://threads_clone.com/user/$uid";

    // Text to share
    final shareText = "Check out $name's profile:\n$profileUrl";

    // Trigger system share sheet with proper null safety
    SharePlus.instance.share(
      ShareParams(
        text: shareText,
        title: "Share Profile",
        subject: "Profile of $name",
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ProfileController controller = Get.put(ProfileController());
    return Scaffold(
      appBar: AppBar(
        title: Icon(Icons.language),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: () => Get.toNamed(RouteNames.settings),
            icon: Icon(Icons.settings),
          ),
        ],
      ),
      body: DefaultTabController(
        length: 2,
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return <Widget>[
              SliverAppBar(
                expandedHeight: 160,
                collapsedHeight: 160,
                automaticallyImplyLeading: false,
                flexibleSpace: Padding(
                  padding: EdgeInsetsGeometry.symmetric(horizontal: 16),
                  child: Obx(() {
                    return ProfileHeaderWidget(
                      name:
                          authService.user?.userMetadata?['name'] ?? "Loading",
                      description:
                          authService.user?.userMetadata?['description'] ??
                          "No Description",
                      imageUrl: authService.user?.userMetadata?['image_url'],
                      onEditTapped: () => Get.toNamed(RouteNames.editProfile),
                      onShareTapped: () => shareProfile(
                        uid: authService.user?.id,
                        name: authService.user?.userMetadata?['name'],
                      ),
                    );
                  }),
                ),
              ),
              SliverPersistentHeader(
                delegate: SliverAppBarDelegate(
                  TabBar(
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerHeight: 0,
                    tabs: [
                      Tab(text: "Threads"),
                      Tab(text: "Replies"),
                    ],
                  ),
                ),
                pinned: true,
                floating: true,
              ),
            ];
          },
          body: TabBarView(children: [ThreadsWidget(), RepliesWidget()]),
        ),
      ),
    );
  }
}
