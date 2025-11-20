import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/theme_controller.dart';
import '../controllers/asociados_controller.dart';
import '../controllers/cargas_familiares_controller.dart';
import '../controllers/historial_clinico_controller.dart';
import '../controllers/configuracion_controller.dart';
import '../controllers/dashboard_page_controller.dart';
import '../controllers/historial_controller.dart'; 
import '../controllers/historial_cargas_controller.dart';
import '../controllers/usuario_controller.dart'; 
import '../controllers/reserva_horas_controller.dart'; 


class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    // Controladores principales (permanentes)
    Get.put<AuthController>(AuthController(), permanent: true);
    Get.put<ThemeController>(ThemeController(), permanent: true);
    Get.put<DashboardPageController>(DashboardPageController(), permanent: true);
    Get.put<ConfiguracionController>(ConfiguracionController(), permanent: true);

    // Controladores de Módulos (permanentes)
    Get.put<AsociadosController>(AsociadosController(), permanent: true);
    Get.put<CargasFamiliaresController>(CargasFamiliaresController(), permanent: true);
    Get.put<HistorialClinicoController>(HistorialClinicoController(), permanent: true);
    Get.put<ReservaHorasController>(ReservaHorasController(), permanent: true);

    // Controladores de Utilidad y Datos (permanentes)
    Get.put<HistorialController>(HistorialController(), permanent: true);
    Get.put<HistorialCargasController>(HistorialCargasController(), permanent: true);
    Get.put<UsuarioController>(UsuarioController(), permanent: true);
    
    // NOTA: El MockDataController fue eliminado de aquí.
  }
}