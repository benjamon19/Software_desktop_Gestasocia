// lib/widgets/dashboard/perfil/perfil_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/auth_controller.dart';
import '../../../utils/app_theme.dart';
import 'sections/perfil_info_section.dart';
import 'sections/perfil_edit_section.dart';

class PerfilView extends StatefulWidget {
  const PerfilView({super.key});

  @override
  State<PerfilView> createState() => _PerfilViewState();
}

class _PerfilViewState extends State<PerfilView> {
  final AuthController authController = Get.find<AuthController>();
  int selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final bool isSmallScreen = screenWidth < 600;
    final bool isMediumScreen = screenWidth >= 600 && screenWidth < 1000;
    final bool isShortScreen = screenHeight < 700;
    final bool isVeryShortScreen = screenHeight < 600;
    
    // Padding adaptativo
    double containerPadding = isVeryShortScreen ? 16 : (isShortScreen ? 20 : (isSmallScreen ? 24 : 30));
    double sectionSpacing = isVeryShortScreen ? 16 : (isShortScreen ? 20 : 30);
    double tabSpacing = isVeryShortScreen ? 12 : (isShortScreen ? 16 : 20);
    
    return Container(
      padding: EdgeInsets.all(containerPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAdaptiveHeader(context, isSmallScreen, isMediumScreen, isVeryShortScreen),
          SizedBox(height: sectionSpacing),
          _buildAdaptiveTabBar(context, isSmallScreen, isVeryShortScreen),
          SizedBox(height: tabSpacing),
          Expanded(
            child: _buildTabContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildAdaptiveHeader(BuildContext context, bool isSmallScreen, bool isMediumScreen, bool isVeryShortScreen) {
    if (isVeryShortScreen) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Obx(() {
                final photoUrl = authController.userPhotoUrl;
                final displayName = authController.userDisplayName;

                return Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.primaryColor, // fallback de fondo
                    image: photoUrl != null && photoUrl.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(photoUrl),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: photoUrl == null || photoUrl.isEmpty
                      ? Center(
                          child: Text(
                            displayName.isNotEmpty
                                ? displayName[0].toUpperCase()
                                : 'U',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 32,
                            ),
                          ),
                        )
                      : null,
                );
              }),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mi Perfil',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.getTextPrimary(context),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Obx(() => Text(
                      authController.userDisplayName,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )),
                  ],
                ),
              ),
            ],
          ),
        ],
      );
    }

    if (isSmallScreen) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Obx(() {
            final photoUrl = authController.userPhotoUrl;
            return Container(
              width: isMediumScreen ? 70 : 60,
              height: isMediumScreen ? 70 : 60,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                shape: BoxShape.circle,
                image: photoUrl != null
                    ? DecorationImage(image: NetworkImage(photoUrl), fit: BoxFit.cover)
                    : null,
              ),
              child: photoUrl == null
                  ? Center(
                      child: Text(
                        authController.userDisplayName.isNotEmpty
                            ? authController.userDisplayName[0].toUpperCase()
                            : 'A',
                        style: TextStyle(
                          fontSize: isMediumScreen ? 28 : 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    )
                  : null,
            );
          }),
          const SizedBox(height: 16),
          Column(
            children: [
              Text(
                'Mi Perfil',
                style: TextStyle(
                  fontSize: isMediumScreen ? 24 : 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.getTextPrimary(context),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Obx(() => Text(
                authController.userDisplayName,
                style: TextStyle(
                  fontSize: isMediumScreen ? 18 : 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryColor,
                ),
                textAlign: TextAlign.center,
              )),
              const SizedBox(height: 4),
              Obx(() => Text(
                authController.userEmail,
                style: TextStyle(
                  fontSize: isMediumScreen ? 14 : 13,
                  color: AppTheme.getTextSecondary(context),
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )),
            ],
          ),
        ],
      );
    }

    // Layout grande
    return Row(
      children: [
        Obx(() {
          final photoUrl = authController.userPhotoUrl;
          return Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              shape: BoxShape.circle,
              image: photoUrl != null
                  ? DecorationImage(image: NetworkImage(photoUrl), fit: BoxFit.cover)
                  : null,
            ),
            child: photoUrl == null
                ? Center(
                    child: Text(
                      authController.userDisplayName.isNotEmpty
                          ? authController.userDisplayName[0].toUpperCase()
                          : 'A',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  )
                : null,
          );
        }),
        const SizedBox(width: 24),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Mi Perfil',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.getTextPrimary(context),
                ),
              ),
              const SizedBox(height: 8),
              Obx(() => Text(
                authController.userDisplayName,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryColor,
                ),
              )),
              const SizedBox(height: 4),
              Obx(() => Text(
                authController.userEmail,
                style: TextStyle(
                  fontSize: 16,
                  color: AppTheme.getTextSecondary(context),
                ),
              )),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAdaptiveTabBar(BuildContext context, bool isSmallScreen, bool isVeryShortScreen) {
    final tabs = [
      {'icon': Icons.person_outline, 'title': 'Información'},
      {'icon': Icons.edit_outlined, 'title': 'Editar Perfil'},
    ];

    return Container(
      padding: EdgeInsets.all(isVeryShortScreen ? 4 : 6),
      decoration: BoxDecoration(
        color: AppTheme.getInputBackground(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.getBorderLight(context),
        ),
      ),
      child: isVeryShortScreen 
          ? _buildCompactTabBar(context, tabs)
          : _buildNormalTabBar(context, tabs, isSmallScreen),
    );
  }

  Widget _buildCompactTabBar(BuildContext context, List<Map<String, dynamic>> tabs) {
    return Row(
      children: List.generate(tabs.length, (index) {
        final tab = tabs[index];
        final isSelected = selectedTabIndex == index;
        
        return Expanded(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => setState(() => selectedTabIndex = index),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? AppTheme.primaryColor 
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  tab['icon'] as IconData,
                  size: 18,
                  color: isSelected 
                      ? Colors.white 
                      : AppTheme.getTextSecondary(context),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildNormalTabBar(BuildContext context, List<Map<String, dynamic>> tabs, bool isSmallScreen) {
    return Row(
      children: List.generate(tabs.length, (index) {
        final tab = tabs[index];
        final isSelected = selectedTabIndex == index;
        
        return Expanded(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => setState(() => selectedTabIndex = index),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: EdgeInsets.symmetric(
                  vertical: isSmallScreen ? 10 : 12, 
                  horizontal: isSmallScreen ? 12 : 16,
                ),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? AppTheme.primaryColor 
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      tab['icon'] as IconData,
                      size: isSmallScreen ? 18 : 20,
                      color: isSelected 
                          ? Colors.white 
                          : AppTheme.getTextSecondary(context),
                    ),
                    SizedBox(width: isSmallScreen ? 6 : 8),
                    Flexible(
                      child: Text(
                        tab['title'] as String,
                        style: TextStyle(
                          fontSize: isSmallScreen ? 12 : 14,
                          fontWeight: FontWeight.w600,
                          color: isSelected 
                              ? Colors.white 
                              : AppTheme.getTextPrimary(context),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildTabContent() {
    switch (selectedTabIndex) {
      case 0:
        return const PerfilInfoSection();
      case 1:
        return const PerfilEditSection();
      default:
        return const PerfilInfoSection();
    }
  }
}