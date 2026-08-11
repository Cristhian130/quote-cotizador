import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../models/vehicle_info.dart';
import '../../presentation/services/vehicle_service.dart';
import '../../../../core/config/app_config.dart';

class VehicleDialog extends StatefulWidget {
  const VehicleDialog({super.key});

  static void show(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => const VehicleDialog(),
    );
  }

  @override
  State<VehicleDialog> createState() => _VehicleDialogState();
}

class _VehicleDialogState extends State<VehicleDialog> {
  final _controller = TextEditingController();
  final _service = VehicleService();
  bool _isLoading = false;
  VehicleInfo? _vehicleInfo;
  String? _errorMessage;
  bool _searched = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _consultar() async {
    final placa = _controller.text.trim();
    if (placa.isEmpty) {
      setState(() {
        _errorMessage = 'Por favor ingresa una placa';
        _searched = true;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _vehicleInfo = null;
      _searched = true;
    });

    try {
      final res = await _service.getVehicleInfo(placa);
      if (res != null) {
        setState(() {
          _vehicleInfo = res;
        });
        // Registrar en backend en background
        _service.trackVinQuery(placa, AppConfig.sellerName, res);
      } else {
        setState(() {
          _errorMessage = 'No se encontró información para la placa "$placa"';
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

  Widget _buildResultCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E22),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF2D2D32)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Color(0xFF9E9E9E),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          SelectableText(
            value.isEmpty ? '-' : value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: label.toLowerCase() == 'vin' ? 'monospace' : null,
              letterSpacing: label.toLowerCase() == 'vin' ? 1.0 : null,
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
      backgroundColor: const Color(0xFF121214), // Premium Dark Background
      child: Container(
        width: 520,
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header: Logo & Close Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const _IALogo(height: 32),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(LucideIcons.x, size: 20),
                  color: const Color(0xFF9E9E9E),
                  hoverColor: Colors.white24,
                  splashRadius: 20,
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Sub-header Text
            const Text(
              'CONSULTA DE VIN',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Color(0xFFE11D48), // Pink/Red kicker
                letterSpacing: 1.0,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            // Tab bar visual
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'CONSULTA',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      height: 2,
                      width: 68,
                      color: const Color(0xFFC0152F),
                    ),
                  ],
                ),
              ],
            ),
            const Divider(height: 20, color: Color(0xFF2D2D32)),

            // Search input section (only show if not searched OR if we got an error)
            if (!_searched || _errorMessage != null) ...[
              const Text(
                'Consulta rápida por placa',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Ingresa la placa y consulta la información del vehículo en segundos.',
                style: TextStyle(fontSize: 13, color: Color(0xFF9E9E9E)),
              ),
              const SizedBox(height: 20),
              
              const Text(
                'Placa:',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E22),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF2D2D32)),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      child: TextField(
                        controller: _controller,
                        textCapitalization: TextCapitalization.characters,
                        onSubmitted: (_) => _isLoading ? null : _consultar(),
                        style: const TextStyle(fontSize: 15, color: Colors.white, fontWeight: FontWeight.w500),
                        decoration: const InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                          border: InputBorder.none,
                          hintText: 'EJ: ABC123',
                          hintStyle: TextStyle(
                            color: Colors.white24,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Material(
                    color: const Color(0xFFC0152F),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: InkWell(
                      onTap: _isLoading ? null : _consultar,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        child: _isLoading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text(
                                'Consultar',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ],

            // Loading status (when searching and results not yet displayed)
            if (_isLoading) ...[
              const SizedBox(height: 30),
              Center(
                child: Column(
                  children: const [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFC0152F)),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Consultando vehículo...',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF9E9E9E),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Error display
            if (_errorMessage != null && !_isLoading) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF451A1A),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF7F1D1D)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(LucideIcons.alertTriangle, color: Color(0xFFF87171), size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Error en la Consulta',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFFCA5A5),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _errorMessage!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFFF87171),
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
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _searched = false;
                        _errorMessage = null;
                      });
                    },
                    child: const Text(
                      'Intentar de nuevo',
                      style: TextStyle(color: Color(0xFFC0152F), fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],

            // Succeeded Display (Matches screenshots)
            if (_vehicleInfo != null && !_isLoading) ...[
              const SizedBox(height: 4),
              // Success banner
              const Row(
                children: [
                  Icon(LucideIcons.checkCircle2, color: Color(0xFF10B981), size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Consulta completada.',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF10B981),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              const Text(
                'RESULTADO',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 12),

              // Responsive grid / column layout
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // VIN (Full width card)
                  _buildResultCard('VIN', _vehicleInfo!.vin),
                  const SizedBox(height: 10),
                  // Row for Marca & Línea
                  Row(
                    children: [
                      Expanded(child: _buildResultCard('Marca', _vehicleInfo!.marca)),
                      const SizedBox(width: 10),
                      Expanded(child: _buildResultCard('Linea', _vehicleInfo!.linea)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Row for Versión & Modelo
                  Row(
                    children: [
                      Expanded(child: _buildResultCard('Version', _vehicleInfo!.version)),
                      const SizedBox(width: 10),
                      Expanded(child: _buildResultCard('Modelo', _vehicleInfo!.modelo)),
                    ],
                  ),
                ],
              ),
              
              // Warning banner if placeholder VIN
              if (_vehicleInfo!.vinEsReferenciaNoReal) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF452D1A),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF854D0E)),
                  ),
                  child: const Row(
                    children: [
                      Icon(LucideIcons.alertCircle, color: Color(0xFFFBBF24), size: 18),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'El VIN no está disponible en el sistema nacional, se muestra código de referencia.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFFFBBF24),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _searched = false;
                        _vehicleInfo = null;
                        _controller.clear();
                      });
                    },
                    icon: const Icon(LucideIcons.search, size: 14, color: Color(0xFFC0152F)),
                    label: const Text(
                      'Consultar otra',
                      style: TextStyle(color: Color(0xFFC0152F), fontWeight: FontWeight.bold),
                    ),
                  ),
                  Material(
                    color: const Color(0xFF1E1E22),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                      side: const BorderSide(color: Color(0xFF2D2D32)),
                    ),
                    child: InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      borderRadius: BorderRadius.circular(6),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: const Text(
                          'Cerrar',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
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

// Vector-based IA Logo matching branding
class _IALogo extends StatelessWidget {
  final double height;

  const _IALogo({required this.height});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          height: height,
          width: height * 1.2,
          child: CustomPaint(
            painter: _IALogoPainter(color: const Color(0xFF458AC9)),
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Importadoras',
              style: TextStyle(
                fontSize: height * 0.42,
                fontWeight: FontWeight.bold,
                height: 1.0,
                color: Colors.white,
              ),
            ),
            Text(
              'Asociadas',
              style: TextStyle(
                fontSize: height * 0.42,
                fontWeight: FontWeight.w400,
                height: 1.0,
                color: const Color(0xFF458AC9),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _IALogoPainter extends CustomPainter {
  final Color color;

  _IALogoPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Draw left diagonal bar
    final path1 = Path();
    path1.moveTo(size.width * 0.1, size.height * 0.9);
    path1.lineTo(size.width * 0.4, size.height * 0.1);
    path1.lineTo(size.width * 0.6, size.height * 0.1);
    path1.lineTo(size.width * 0.3, size.height * 0.9);
    path1.close();
    canvas.drawPath(path1, paint);

    // Draw right diagonal bar
    final path2 = Path();
    path2.moveTo(size.width * 0.4, size.height * 0.9);
    path2.lineTo(size.width * 0.7, size.height * 0.1);
    path2.lineTo(size.width * 0.9, size.height * 0.1);
    path2.lineTo(size.width * 0.6, size.height * 0.9);
    path2.close();
    canvas.drawPath(path2, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
