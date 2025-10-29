import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'config/app_initializer.dart';
import 'controllers/theme_controller.dart';
import 'utils/app_routes.dart';
import 'utils/app_theme.dart';
import 'controllers/usuario_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await AppInitializer.initialize();
  Get.put(UsuarioController());
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find<ThemeController>();
    
    return Obx(() => GetMaterialApp(
      title: 'GestAsocia',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeController.themeMode,
      initialRoute: AppRoutes.login, 
      getPages: AppRoutes.routes,
    ));
  }
}