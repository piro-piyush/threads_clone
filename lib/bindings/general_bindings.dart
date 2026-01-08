import 'package:get/get.dart';
import 'package:thread_clone/services/supabase_service.dart';

class GeneralBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(SupabaseService(), permanent: true);
  }
}
