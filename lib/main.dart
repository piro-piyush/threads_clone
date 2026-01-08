import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_storage/get_storage.dart';
import 'package:thread_clone/routes/route_names.dart';
import 'package:thread_clone/routes/routes.dart';
import 'package:thread_clone/services/storage_service.dart';
import 'package:thread_clone/utils/theme/theme.dart';
import 'package:get/get.dart';

import 'bindings/general_bindings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');
  await GetStorage.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Thread Clone',
      getPages: Routes.pages,
      debugShowCheckedModeBanner: false,
      theme: theme,
      initialBinding: GeneralBindings(),
      initialRoute: StorageService.userSession != null ? RouteNames.home : RouteNames.login,
    );
  }
}
