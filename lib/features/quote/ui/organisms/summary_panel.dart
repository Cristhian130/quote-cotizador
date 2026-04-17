import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/ia_colors.dart';
import '../molecules/checkbox_with_label.dart';
import '../molecules/ia_select.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../presentation/providers/delivery_provider.dart';
import '../../presentation/providers/quote_provider.dart';

class SummaryPanel extends ConsumerWidget {
  final double valMercancia;
  final double descuentos;
  final double subtotal;
  final double iva;
  final bool cobraDomicilio;
  final ValueChanged<bool> setCobraDomicilio;
  final String vehiculo;
  final ValueChanged<String?> setVehiculo;
  final String ciudad;
  final ValueChanged<String?> setCiudad;
  final String barrio;
  final ValueChanged<String?> setBarrio;
  final String bodega;
  final double valorNeto;

  const SummaryPanel({
    super.key,
    required this.valMercancia,
    required this.descuentos,
    required this.subtotal,
    required this.iva,
    required this.cobraDomicilio,
    required this.setCobraDomicilio,
    required this.vehiculo,
    required this.setVehiculo,
    required this.ciudad,
    required this.setCiudad,
    required this.barrio,
    required this.setBarrio,
    required this.bodega,
    required this.valorNeto,
  });

  String _formatCurrency(double value) {
    return '\$ ${NumberFormat.simpleCurrency(locale: 'es_CO', name: '', decimalDigits: 0).format(value)}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Autodisparar la sincronización de las reglas de negocio en 2do plano
    ref.watch(syncDeliveryRulesProvider);

    // Escuchar las ciudades disponibles según la bodega seleccionada
    final ciudadesAsync = ref.watch(deliveryCitiesProvider(bodega));
    final List<String> opcionesCiudad = ciudadesAsync.value ?? [];

    if (ciudadesAsync.hasError) {
      print('=== DELIVERY CITIES PROVIDER ERROR ===');
      print(ciudadesAsync.error);
      print(ciudadesAsync.stackTrace);
    }
    print("UI Rendered Cities: ${opcionesCiudad.length}");

    final safeCiudad = opcionesCiudad.contains(ciudad)
        ? ciudad
        : (opcionesCiudad.isNotEmpty ? opcionesCiudad.first : ciudad);

    // Escuchar los barrios disponibles según la bodega y ciudad seleccionada
    final barriosAsync = ref.watch(
      deliveryBarriosProvider((bodegaId: bodega, ciudad: safeCiudad)),
    );
    final List<String> opcionesBarrio = barriosAsync.value ?? [];

    final safeBarrio = opcionesBarrio.contains(barrio)
        ? barrio
        : (opcionesBarrio.isNotEmpty ? opcionesBarrio.first : barrio);

    // Escuchar los vehiculos disponibles según la bodega, ciudad y barrio seleccionados
    final vehiculosAsync = ref.watch(
      deliveryVehiculosProvider((
        bodegaId: bodega,
        ciudad: safeCiudad,
        barrio: safeBarrio,
      )),
    );
    final List<String> opcionesVehiculo = vehiculosAsync.value ?? [];

    final safeVehiculo = opcionesVehiculo.contains(vehiculo)
        ? vehiculo
        : (opcionesVehiculo.isNotEmpty ? opcionesVehiculo.first : vehiculo);

    // Traer la regla de tarifa completa para el calculo en backend/frontend (opcional para ui)
    final tarifaAsync = ref.watch(
      deliveryTarifaProvider((
        bodegaId: bodega,
        ciudad: safeCiudad,
        barrio: safeBarrio,
        tipoVehiculo: safeVehiculo,
      )),
    );
    final tarifaAplicada = cobraDomicilio
        ? (tarifaAsync.value?.tarifa ?? 0.0)
        : 0.0;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (safeCiudad != ciudad && safeCiudad.isNotEmpty) {
        setCiudad(safeCiudad);
      }
      if (safeBarrio != barrio && safeBarrio.isNotEmpty) {
        setBarrio(safeBarrio);
      }
      if (safeVehiculo != vehiculo && safeVehiculo.isNotEmpty) {
        setVehiculo(safeVehiculo);
      }
      // Sincronizar tarifa con el proveedor global para que el PDF lo vea
      if (tarifaAplicada != ref.read(quoteProvider).tarifaDomicilio) {
        ref.read(quoteProvider.notifier).updateConfig(tarifaDomicilio: tarifaAplicada);
      }
    });
    return Container(
      width: 320,
      decoration: const BoxDecoration(
        color: IaColors.card,
        border: Border(left: BorderSide(color: IaColors.border)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'RESUMEN',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: IaColors.mutedForeground,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 16),
                _summaryRow('Val. Mercancia', valMercancia),
                const SizedBox(height: 8),
                _summaryRow('Descuentos', descuentos, isNegative: true),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1, color: IaColors.border),
                ),
                _summaryRow('Subtotal', subtotal),
                const SizedBox(height: 8),
                _summaryRow('IVA', iva),
              ],
            ),
          ),
          const Divider(height: 1, color: IaColors.border),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CheckboxWithLabel(
                    value: cobraDomicilio,
                    onChanged: (v) => setCobraDomicilio(v ?? false),
                    label: 'Cobra domicilio',
                    icon: LucideIcons.truck,
                  ),
                  if (cobraDomicilio) ...[
                    const SizedBox(height: 16),
                    IaSelect(
                      label: 'Vehiculo',
                      icon: LucideIcons.truck,
                      value: safeVehiculo.isEmpty ? null : safeVehiculo,
                      options: opcionesVehiculo.isEmpty
                          ? (safeVehiculo.isEmpty ? [] : [safeVehiculo])
                          : opcionesVehiculo,
                      onChanged: (val) => setVehiculo(val ?? ''),
                    ),
                    const SizedBox(height: 12),
                    IaSelect(
                      label: 'Ciudad',
                      icon: LucideIcons.mapPin,
                      placeholder: 'Buscar ciudad...',
                      value: safeCiudad.isEmpty ? null : safeCiudad,
                      options: opcionesCiudad.isEmpty
                          ? (safeCiudad.isEmpty ? [] : [safeCiudad])
                          : opcionesCiudad,
                      onChanged: (val) {
                        setCiudad(val ?? '');
                        setBarrio(''); // Resetear barrio al cambiar ciudad
                      },
                    ),
                    const SizedBox(height: 12),
                    IaSelect(
                      label: 'Barrio',
                      icon: LucideIcons.navigation,
                      placeholder: 'Buscar barrio...',
                      value: safeBarrio.isEmpty ? null : safeBarrio,
                      options: opcionesBarrio.isEmpty
                          ? (safeBarrio.isEmpty ? [] : [safeBarrio])
                          : opcionesBarrio,
                      onChanged: (val) => setBarrio(val ?? ''),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Tarifa domicilio',
                          style: TextStyle(
                            fontSize: 14,
                            color: IaColors.mutedForeground,
                          ),
                        ),
                        Text(
                          tarifaAsync.isLoading
                              ? 'Calculando...'
                              : _formatCurrency(tarifaAplicada),
                          style: const TextStyle(
                            fontSize: 14,
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: IaColors.accent.withOpacity(0.1),
              border: const Border(top: BorderSide(color: IaColors.border)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Valor Neto',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                Text(
                  _formatCurrency(valorNeto),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                    color: IaColors.accent,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, double value, {bool isNegative = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: IaColors.mutedForeground),
        ),
        Text(
          '${isNegative ? '-' : ''}${_formatCurrency(value)}',
          style: TextStyle(
            fontSize: 14,
            fontFamily: 'monospace',
            fontWeight: FontWeight.w500,
            color: isNegative ? IaColors.destructive : IaColors.foreground,
          ),
        ),
      ],
    );
  }
}
