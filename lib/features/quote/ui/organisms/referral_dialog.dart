import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/ia_colors.dart';
import '../atoms/ia_button.dart';
import '../atoms/ia_input.dart';
import '../../models/referral.dart';
import '../../presentation/services/referral_service.dart';

class ReferralDialog extends StatefulWidget {
  const ReferralDialog({super.key});

  static void show(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => const ReferralDialog(),
    );
  }

  @override
  State<ReferralDialog> createState() => _ReferralDialogState();
}

class _ReferralDialogState extends State<ReferralDialog> {
  final _controller = TextEditingController();
  final _service = ReferralService();
  bool _isLoading = false;
  Referral? _referral;
  String? _errorMessage;
  bool _searched = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _validate() async {
    final code = _controller.text.trim();
    if (code.isEmpty) {
      setState(() {
        _errorMessage = 'Por favor ingresa un código de referido';
        _searched = true;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _referral = null;
      _searched = true;
    });

    try {
      final res = await _service.validateReferral(code);
      if (res != null) {
        setState(() {
          _referral = res;
        });
      } else {
        setState(() {
          _errorMessage = 'No se encontró ningún referido con el código "$code"';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: IaColors.primaryLight),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: IaColors.mutedForeground,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: IaColors.foreground,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 8,
      backgroundColor: Colors.white,
      child: Container(
        width: 480,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(LucideIcons.gift, color: IaColors.primaryLight, size: 24),
                    SizedBox(width: 10),
                    Text(
                      'Validación de Referido',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: IaColors.primary,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(LucideIcons.x, size: 20),
                  color: IaColors.mutedForeground,
                  splashRadius: 20,
                ),
              ],
            ),
            const Divider(height: 24, color: IaColors.border),

            // Search input section
            if (!_searched || _errorMessage != null) ...[
              const Text(
                'Ingresa el código de referido para consultar su estado y datos asociados.',
                style: TextStyle(fontSize: 13, color: IaColors.mutedForeground),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: IAInput(
                      controller: _controller,
                      placeholder: 'Ej. REF-0002',
                      onSubmitted: (_) => _isLoading ? null : _validate(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  IAButton(
                    onPressed: _isLoading ? null : _validate,
                    child: _isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text('Validar'),
                  ),
                ],
              ),
            ],

            // Loader when searching
            if (_isLoading) ...[
              const SizedBox(height: 40),
              const Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(IaColors.primaryLight),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Consultando con el servidor...',
                      style: TextStyle(
                        fontSize: 13,
                        color: IaColors.mutedForeground,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Error display
            if (_errorMessage != null && !_isLoading) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFFCA5A5)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(LucideIcons.alertCircle, color: IaColors.destructive, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Error de Validación',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF991B1B),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _errorMessage!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFFB91C1C),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IAButton(
                    variant: IAButtonVariant.ghost,
                    onPressed: () {
                      setState(() {
                        _searched = false;
                        _errorMessage = null;
                      });
                    },
                    child: const Text('Intentar de nuevo'),
                  ),
                ],
              ),
            ],

            // Succeeded display (Beautiful Card!)
            if (_referral != null && !_isLoading) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF86EFAC)),
                ),
                child: Row(
                  children: [
                    const Icon(LucideIcons.checkCircle, color: Color(0xFF15803D), size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'El usuario ${_referral!.nombre} está ${_referral!.estado}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF15803D),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.white, Color(0xFFF8FAFC)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: IaColors.border, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        border: Border(bottom: BorderSide(color: IaColors.border)),
                        color: Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(11),
                          topRight: Radius.circular(11),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: IaColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(LucideIcons.userCheck, color: Colors.white, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _referral!.nombre,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: IaColors.primary,
                                  ),
                                ),
                                Text(
                                  'Código: ${_controller.text.trim().toUpperCase()}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: IaColors.mutedForeground,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: _referral!.estado.toLowerCase() == 'activo'
                                  ? const Color(0xFFDCFCE7)
                                  : const Color(0xFFFEE2E2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: _referral!.estado.toLowerCase() == 'activo'
                                    ? const Color(0xFF86EFAC)
                                    : const Color(0xFFFCA5A5),
                              ),
                            ),
                            child: Text(
                              _referral!.estado,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: _referral!.estado.toLowerCase() == 'activo'
                                    ? const Color(0xFF166534)
                                    : const Color(0xFF991B1B),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                     Padding(
                       padding: const EdgeInsets.all(16),
                       child: Column(
                         children: [
                           _buildDetailRow(
                             LucideIcons.users,
                             'Socio Actual',
                             _referral!.socioActual.isEmpty ? 'Ninguno' : _referral!.socioActual,
                           ),
                         ],
                       ),
                     ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IAButton(
                    variant: IAButtonVariant.ghost,
                    onPressed: () {
                      setState(() {
                        _searched = false;
                        _referral = null;
                        _controller.clear();
                      });
                    },
                    child: const Row(
                      children: [
                        Icon(LucideIcons.search, size: 14),
                        SizedBox(width: 6),
                        Text('Validar otro'),
                      ],
                    ),
                  ),
                  IAButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cerrar'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
