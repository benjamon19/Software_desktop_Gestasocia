import 'package:get/get.dart';
import '../bindings/auth_binding.dart';
import '../bindings/dashboard_binding.dart';
import '../pages/login_page.dart';
import '../pages/register_page.dart';
import '../pages/dashboard.dart';

class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String dashboard = '/dashboard';
  
  static List<GetPage> routes = [
    GetPage(
      name: login,
      page: () => const LoginPage(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: register,
      page: () => const RegisterPage(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: dashboard,
      page: () => const DashboardPage(),
      binding: DashboardBinding(), 
    ),
  ];
}