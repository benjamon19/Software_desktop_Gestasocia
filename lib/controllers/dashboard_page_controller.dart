import 'package:get/get.dart';

class DashboardPageController extends GetxController {
  final RxInt selectedIndex = 0.obs;

  void changeModule(int index) {
    selectedIndex.value = index;
  }

  void goToHome() => changeModule(0);
  void goToAsociados() => changeModule(1);
  void goToCargas() => changeModule(2);
  void goToHistorialClinico() => changeModule(3);
  void goToReservaHoras() => changeModule(4);
  void goToConfiguracion() => changeModule(5);
  void goToPerfil() => changeModule(6);
}