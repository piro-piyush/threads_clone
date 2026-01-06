import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:thread_clone/routes/route_names.dart';
import 'package:thread_clone/routes/routes.dart';
import 'package:thread_clone/utils/theme/theme.dart';
import 'package:thread_clone/views/home_view.dart';
import 'package:get/get.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(title: 'Thread Clone', getPages: Routes.pages, debugShowCheckedModeBanner: false, theme: theme, home: const HomeView(), initialRoute: RouteNames.login);
  }
}
