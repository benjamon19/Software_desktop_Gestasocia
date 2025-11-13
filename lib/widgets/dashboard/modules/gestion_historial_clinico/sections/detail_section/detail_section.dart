import 'package:flutter/material.dart';
import '../../../../../../utils/app_theme.dart';
import 'components/historial_header.dart';
import 'components/clinical_data_card.dart';
import 'components/image_upload_card.dart';

class DetailSection extends StatefulWidget {
  final Map<String, dynamic> historial;
  final VoidCallback? onBack;

  const DetailSection({
    super.key,
    required this.historial,
    this.onBack,
  });

  @override
  State<DetailSection> createState() => _DetailSectionState();
}

class _DetailSectionState extends State<DetailSection> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String historialId = widget.historial['id'] as String;

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.getSurfaceColor(context),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).brightness == Brightness.dark 
                ? Colors.black.withValues(alpha: 0.3)
                : Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HistorialHeader(
            historial: widget.historial,
            onBack: widget.onBack,
          ),
          Expanded(
            child: Scrollbar(
              controller: _scrollController,
              thumbVisibility: true,
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClinicalDataCard(historial: widget.historial),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                      child: ImageUploadCard(historialId: historialId),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}