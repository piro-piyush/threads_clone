import 'package:flutter/material.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Icon(Icons.language),
        centerTitle: false,
        actions: [IconButton(onPressed: () {}, icon: Icon(Icons.sort))],
      ),
      body: Center(child: Text("Profile")),
    );
  }
}
