import 'package:flutter/material.dart';
import '../../../../core/theme/ia_colors.dart';
import '../../../../core/config/app_config.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';

class InvoiceHeader extends StatefulWidget {
  const InvoiceHeader({super.key});

  @override
  State<InvoiceHeader> createState() => _InvoiceHeaderState();
}

class _InvoiceHeaderState extends State<InvoiceHeader> {
  String _activeUrl = AppConfig.baseUrl;

  void _showServerPicker() {
    final customCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A2535),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(
          children: const [
            Icon(LucideIcons.server, color: Color(0xFF458AC9), size: 18),
            SizedBox(width: 10),
            Text(
              'Servidor backend',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: 480,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Selecciona un preset o ingresa una URL:',
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),
              const SizedBox(height: 12),
              // Presets
              ...AppConfig.presets.map((url) {
                final isActive = _activeUrl == url;
                return _ServerTile(
                  url: url,
                  label: url == AppConfig.localUrl
                      ? '🖥  Local     (localhost:3001)'
                      : '🌐 Ngrok    (ngrok-free.app)',
                  isActive: isActive,
                  onTap: () async {
                    await AppConfig.setBaseUrl(url);
                    if (mounted) {
                      setState(() => _activeUrl = url);
                      Navigator.of(ctx).pop();
                      _showSnack(url);
                    }
                  },
                );
              }),
              const SizedBox(height: 12),
              const Divider(color: Colors.white12),
              const SizedBox(height: 8),
              const Text(
                'URL personalizada:',
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: customCtrl,
                style: const TextStyle(color: Colors.white, fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'https://tu-backend.ngrok.io',
                  hintStyle: const TextStyle(
                    color: Colors.white30,
                    fontSize: 12,
                  ),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.06),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(7),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(7),
                    borderSide: const BorderSide(color: Color(0xFF458AC9)),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Colors.white38),
            ),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.check, size: 15),
            label: const Text('Aplicar URL'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF458AC9),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(7),
              ),
            ),
            onPressed: () async {
              final url = customCtrl.text.trim();
              if (url.isNotEmpty) {
                await AppConfig.setBaseUrl(url);
                if (mounted) {
                  setState(() => _activeUrl = url);
                  Navigator.of(ctx).pop();
                  _showSnack(url);
                }
              }
            },
          ),
        ],
      ),
    );
  }

  void _showSnack(String url) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✅ Backend → $url'),
        backgroundColor: const Color(0xFF192D4D),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final formattedDate = DateFormat('dd/MM/yyyy').format(now);
    final formattedTime = DateFormat('hh:mm a').format(now).toLowerCase();

    final isLocal = _activeUrl == AppConfig.localUrl;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: const BoxDecoration(
        color: IaColors.card,
        border: Border(bottom: BorderSide(color: IaColors.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // ── Logo ─────────────────────────────────────
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: IaColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: const Text(
                  'IA',
                  style: TextStyle(
                    color: IaColors.primaryForeground,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Importadoras Asociadas',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: IaColors.foreground,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Text(
                    'Sistema de Facturacion',
                    style: TextStyle(
                      fontSize: 12,
                      color: IaColors.mutedForeground,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // ── Right controls ────────────────────────────
          Row(
            children: [
              // Server indicator + picker
              Tooltip(
                message: 'Cambiar servidor backend',
                child: InkWell(
                  onTap: _showServerPicker,
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: (isLocal ? Colors.green : const Color(0xFF458AC9))
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color:
                            (isLocal ? Colors.green : const Color(0xFF458AC9))
                                .withOpacity(0.4),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isLocal ? LucideIcons.hardDrive : LucideIcons.globe,
                          size: 12,
                          color: isLocal
                              ? Colors.green
                              : const Color(0xFF458AC9),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isLocal ? 'Local' : 'Ngrok',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isLocal
                                ? Colors.green
                                : const Color(0xFF458AC9),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          LucideIcons.chevronsUpDown,
                          size: 11,
                          color: IaColors.mutedForeground,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // Factura label
              const Row(
                children: [
                  Icon(
                    LucideIcons.fileText,
                    size: 14,
                    color: IaColors.mutedForeground,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Factura de Contingencia',
                    style: TextStyle(
                      fontSize: 12,
                      color: IaColors.mutedForeground,
                    ),
                  ),
                ],
              ),

              const SizedBox(width: 16),

              // Clock
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: IaColors.accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    const Icon(
                      LucideIcons.clock,
                      size: 14,
                      color: IaColors.accent,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$formattedDate $formattedTime',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'monospace',
                        color: IaColors.foreground,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Helper tile inside the dialog ──────────────────────────
class _ServerTile extends StatelessWidget {
  final String url;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _ServerTile({
    required this.url,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFF458AC9).withOpacity(0.12)
              : Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive
                ? const Color(0xFF458AC9).withOpacity(0.5)
                : Colors.white12,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: isActive
                          ? const Color(0xFF458AC9)
                          : Colors.white70,
                      fontSize: 13,
                      fontWeight: isActive
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                  Text(
                    url,
                    style: const TextStyle(
                      color: Colors.white38,
                      fontSize: 11,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
            if (isActive)
              const Icon(
                Icons.check_circle_rounded,
                color: Color(0xFF458AC9),
                size: 18,
              ),
          ],
        ),
      ),
    );
  }
}
