import 'package:flutter/material.dart';

class PageContent extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onBackToDashboard;

  const PageContent({
    super.key,
    required this.title,
    required this.icon,
    required this.onBackToDashboard,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFFEBF8FF),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 80,
                color: const Color(0xFF4299E1),
              ),
            ),
            const SizedBox(height: 30),
            Text(
              title,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3748),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Esta sección está en desarrollo',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF718096),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: onBackToDashboard,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4299E1),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Volver al Dashboard',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}