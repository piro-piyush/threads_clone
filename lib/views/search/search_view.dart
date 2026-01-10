import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:thread_clone/controllers/searching_controller.dart';
import 'package:thread_clone/views/search/widgets/search_field_widget.dart';
import 'package:thread_clone/views/search/widgets/user_tile_widget.dart';

import 'widgets/search_loading_widget.dart';

class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final TextEditingController textEditingController = TextEditingController(
    text: "",
  );
  final SearchingController controller = Get.put(SearchingController());

  void searchUser(String? name) async {
    if (name != null) {
      await controller.searchUser(name);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            centerTitle: false,
            title: const Text(
              "Search",
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
            expandedHeight: GetPlatform.isIOS ? 110 : 105,
            collapsedHeight: GetPlatform.isIOS ? 90 : 91,
            flexibleSpace: Padding(
              padding: EdgeInsets.only(
                top: GetPlatform.isIOS ? 110.0 : 105,
                // left: 0,
                // right: 0,
              ),
              child: SearchFieldWidget(
                textController: textEditingController,
                hintText: "Search",
                callback: searchUser,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Obx(
              () => controller.isLoading.value
                  ? const SearchLoadingWidget()
                  : Column(
                      children: [
                        if (controller.users.isNotEmpty)
                          ListView.builder(
                            shrinkWrap: true,
                            padding: EdgeInsets.zero,
                            itemCount: controller.users.length,
                            physics: const BouncingScrollPhysics(),
                            itemBuilder: (context, index) =>
                                UserTileWidget(user: controller.users[index]),
                          )
                        else if (controller.users.isEmpty &&
                            controller.notFound.value == true)
                          const Text("No user found")
                        else
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.only(top: 20),
                              child: Text("Search users with their names"),
                            ),
                          ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
