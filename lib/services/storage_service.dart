import 'package:get_storage/get_storage.dart';
import 'package:thread_clone/utils/storage_keys.dart';

class StorageService  {
  static final GetStorage storage = GetStorage();

  static dynamic userSession = storage.read(StorageKeys.userSession);
}
