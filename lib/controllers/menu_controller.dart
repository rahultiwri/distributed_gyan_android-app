import '../services/menu_service.dart';

class MenuController {
  MenuController._();

  static Future<void> getUserApps() async {
    await MenuService.getUserApps();
  }
}