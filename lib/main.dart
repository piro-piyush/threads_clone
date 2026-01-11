import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_storage/get_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:thread_clone/routes/route_names.dart';
import 'package:thread_clone/routes/routes.dart';
import 'package:thread_clone/services/storage_service.dart';
import 'package:thread_clone/utils/env.dart';
import 'package:thread_clone/utils/theme/theme.dart';
import 'package:get/get.dart';

import 'bindings/general_bindings.dart';

/// Entry point of the application
void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    // Load environment variables from .env
    await dotenv.load(fileName: '.env');

    // Initialize Supabase with the URL and anon key
    await Supabase.initialize(url: Env.supabaseUrl, anonKey: Env.supabaseKey);

    // Initialize local storage
    await GetStorage.init();

    runApp(const MyApp());
  } catch (e, stackTrace) {
    // Log full error
    print('Error during app initialization: $e');
    print('Stack trace: $stackTrace');
    runApp(const MyApp());
  }
}

/// Root widget of the application
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Thread Clone',
      debugShowCheckedModeBanner: false,

      /// App theme
      theme: theme,

      /// Named routes
      getPages: Routes.pages,

      /// Global dependency injections
      initialBinding: GeneralBindings(),

      /// Decide initial route based on user login state
      initialRoute: StorageService.isLoggedIn
          ? RouteNames.home
          : RouteNames.login,
    );
  }
}
