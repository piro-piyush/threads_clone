import 'package:flutter/material.dart';

class CreateThreadView extends StatelessWidget {
  const CreateThreadView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Create Thread")),
      body: Center(
        child: Text("Create Thread"),
      ),
    );
  }
}
