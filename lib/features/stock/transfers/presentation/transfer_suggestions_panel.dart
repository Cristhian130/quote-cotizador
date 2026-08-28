import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/theme/ia_colors.dart';
import '../../shared/presentation/erp_stock_widgets.dart';
import '../domain/transfer_suggestion.dart';

class TransferSuggestionsPanel extends StatefulWidget {
  final TransferSuggestionsResult? result;
  final TransferPreview? preview;
  final bool loading;
  final bool previewing;
  final Object? error;
  final VoidCallback onPreview;

  const TransferSuggestionsPanel({
    super.key,
    required this.result,
    required this.preview,
    required this.loading,
    required this.previewing,
    required this.error,
    required this.onPreview,
  });

  @override
  State<TransferSuggestionsPanel> createState() =>
      _TransferSuggestionsPanelState();
}

class _TransferSuggestionsPanelState extends State<TransferSuggestionsPanel>
    with SingleTickerProviderStateMixin {
  late final AnimationController _routeAnimation;

  @override
  void initState() {
    super.initState();
    _routeAnimation = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();
  }

  @override
  void dispose() {
    _routeAnimation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.loading && widget.result == null) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }
    if (widget.error != null && widget.result == null) {
      return ErpEmptyState(
        title: 'No fue posible consultar traslados',
        message: _transferError(widget.error!),
        isError: true,
      );
    }
    if (widget.result == null) {
      return const ErpEmptyState(
        title: 'Consulta de traslados pendiente',
        message: 'Selecciona la ciudad y consulta los repuestos que requieren abastecimiento.',
      );
    }

    final result = widget.result!;
    final candidates = result.candidates;
    final best = result.bestCandidate;

    return ColoredBox(
      color: Colors.white,
      child: ListView(
        children: [
          _ProductHeading(result: result),
          _SummaryBand(result: result),
          if (result.needsTransfer && best != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: _TransferRoute(
                result: result,
                candidate: best,
                animation: _routeAnimation,
              ),
            )
          else
            _NoTransferNeeded(stock: result.quoteCityStock),
          if (result.quoteCityInventory.isNotEmpty)
            _OriginWarehouses(inventory: result.quoteCityInventory),
          const Divider(height: 1, color: IaColors.border),
          _AlternativesHeading(count: candidates.length),
          if (candidates.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 42),
              child: ErpEmptyState(
                title: 'No hay bodegas candidatas con disponibilidad',
                message: 'No se encontró una ruta de abastecimiento para este repuesto.',
              ),
            )
          else
            ...candidates.map(
              (candidate) => _AlternativeRow(
                candidate: candidate,
                isBest: best?.warehouse == candidate.warehouse &&
                    best?.city == candidate.city,
              ),
            ),
          if (widget.preview != null) _PreviewStatus(preview: widget.preview!),
          const Divider(height: 1, color: IaColors.border),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Preview operativo',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: stockText,
                    ),
                  ),
                ),
                ErpActionButton(
                  label: widget.previewing ? 'Preparando...' : 'Generar preview',
                  icon: LucideIcons.eye,
                  onPressed: widget.previewing ? null : widget.onPreview,
                  primary: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductHeading extends StatelessWidget {
  final TransferSuggestionsResult result;

  const _ProductHeading({required this.result});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(16, 15, 16, 13),
    decoration: const BoxDecoration(
      border: Border(bottom: BorderSide(color: IaColors.border)),
    ),
    child: Row(
      children: [
        Container(
          width: 30,
          height: 30,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: result.needsTransfer
                ? const Color(0xFFFFF3E6)
                : const Color(0xFFF0F9F4),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Icon(
            result.needsTransfer ? LucideIcons.arrowRightLeft : LucideIcons.check,
            size: 16,
            color: result.needsTransfer ? stockWarning : stockSuccess,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                result.reference.isEmpty ? 'Sugerencias de traslado' : result.reference,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: stockText,
                ),
              ),
              if (result.description.isNotEmpty)
                Text(
                  result.description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 10.5, color: stockMuted),
                ),
            ],
          ),
        ),
        ErpStatusPill(
          label: result.needsTransfer ? 'Traslado requerido' : 'Disponible',
          color: result.needsTransfer ? stockWarning : stockSuccess,
        ),
      ],
    ),
  );
}

class _SummaryBand extends StatelessWidget {
  final TransferSuggestionsResult result;

  const _SummaryBand({required this.result});

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    color: result.needsTransfer
        ? const Color(0xFFFFF9ED)
        : const Color(0xFFF2FBF6),
    child: Text(
      result.summary.isEmpty
          ? 'Disponibilidad en ${result.quoteCity}: ${_number(result.quoteCityStock)} unidades.'
          : result.summary,
      style: TextStyle(
        fontSize: 11,
        height: 1.35,
        color: result.needsTransfer ? const Color(0xFF9A5B06) : stockSuccess,
      ),
    ),
  );
}

class _TransferRoute extends StatelessWidget {
  final TransferSuggestionsResult result;
  final TransferCandidate candidate;
  final Animation<double> animation;

  const _TransferRoute({
    required this.result,
    required this.candidate,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: const Color(0xFFFBFCFD),
      border: Border.all(color: IaColors.border),
      borderRadius: BorderRadius.circular(6),
    ),
    child: LayoutBuilder(
      builder: (context, constraints) {
        final vertical = constraints.maxWidth < 620;
        if (vertical) {
          return Column(
            children: [
              _RouteStop(
                label: 'NECESITA STOCK',
                city: result.quoteCity,
                warehouse: '${_number(result.quoteCityStock)} uds disponibles',
                color: stockDanger,
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Icon(LucideIcons.arrowDown, size: 18, color: stockWarning),
              ),
              _RouteStop(
                label: 'MEJOR ORIGEN',
                city: candidate.city,
                warehouse: '${candidate.warehouse} · ${_number(candidate.available)} uds',
                color: stockSuccess,
              ),
            ],
          );
        }
        return Row(
          children: [
            Expanded(
              child: _RouteStop(
                label: 'NECESITA STOCK',
                city: result.quoteCity,
                warehouse: '${_number(result.quoteCityStock)} uds disponibles',
                color: stockDanger,
              ),
            ),
            Expanded(
              flex: 2,
              child: SizedBox(
                height: 44,
                child: AnimatedBuilder(
                  animation: animation,
                  builder: (context, child) => Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(height: 2, color: const Color(0xFFF5C27A)),
                      Align(
                        alignment: Alignment(-1 + (animation.value * 2), 0),
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: stockWarning,
                            boxShadow: [
                              BoxShadow(
                                color: Color(0x449A5B06),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Align(
                        alignment: Alignment(0, -0.82),
                        child: Text(
                          'RUTA SUGERIDA',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: stockMuted,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: _RouteStop(
                label: 'MEJOR ORIGEN',
                city: candidate.city,
                warehouse: '${candidate.warehouse} · ${_number(candidate.available)} uds',
                color: stockSuccess,
              ),
            ),
          ],
        );
      },
    ),
  );
}

class _RouteStop extends StatelessWidget {
  final String label;
  final String city;
  final String warehouse;
  final Color color;

  const _RouteStop({
    required this.label,
    required this.city,
    required this.warehouse,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: stockMuted,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        city,
        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: color),
      ),
      const SizedBox(height: 2),
      Text(warehouse, style: const TextStyle(fontSize: 10, color: stockText)),
    ],
  );
}

class _NoTransferNeeded extends StatelessWidget {
  final double stock;

  const _NoTransferNeeded({required this.stock});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(16),
    child: Text(
      'La ciudad cotizada cuenta con ${_number(stock)} unidades disponibles.',
      style: const TextStyle(fontSize: 11.5, color: stockSuccess),
    ),
  );
}

class _OriginWarehouses extends StatelessWidget {
  final List<TransferCityInventory> inventory;

  const _OriginWarehouses({required this.inventory});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 15, 16, 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'INVENTARIO EN CIUDAD COTIZADA',
          style: TextStyle(
            fontSize: 9.5,
            fontWeight: FontWeight.w700,
            color: stockMuted,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 7,
          runSpacing: 7,
          children: inventory
              .map(
                (item) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF4F3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${item.warehouse} · ${_number(item.available)} uds',
                    style: const TextStyle(fontSize: 10.5, color: stockDanger),
                  ),
                ),
              )
              .toList(growable: false),
        ),
      ],
    ),
  );
}

class _AlternativesHeading extends StatelessWidget {
  final int count;

  const _AlternativesHeading({required this.count});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 15, 16, 9),
    child: Row(
      children: [
        const Expanded(
          child: Text(
            'ALTERNATIVAS DE ABASTECIMIENTO',
            style: TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
              color: stockMuted,
            ),
          ),
        ),
        Text('$count candidatas', style: const TextStyle(fontSize: 10.5, color: stockMuted)),
      ],
    ),
  );
}

class _AlternativeRow extends StatelessWidget {
  final TransferCandidate candidate;
  final bool isBest;

  const _AlternativeRow({required this.candidate, required this.isBest});

  @override
  Widget build(BuildContext context) {
    final color = candidate.coversQuantity ? stockSuccess : stockWarning;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
      decoration: BoxDecoration(
        color: isBest ? const Color(0xFFF0F9F4) : Colors.white,
        border: Border.all(color: isBest ? const Color(0xFFCBE9D6) : IaColors.border),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        children: [
          Icon(
            isBest ? LucideIcons.badgeCheck : LucideIcons.building2,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${candidate.warehouse} · ${candidate.city}',
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: stockText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${candidate.transferOrder > 0 ? '#${candidate.transferOrder} · ' : ''}Prioridad ciudad ${candidate.cityPriority} · ${_number(candidate.available)} uds disponibles',
                  style: const TextStyle(fontSize: 10.5, color: stockMuted),
                ),
              ],
            ),
          ),
          ErpStatusPill(
            label: candidate.coversQuantity ? 'Cubre' : 'Parcial',
            color: color,
          ),
        ],
      ),
    );
  }
}

class _PreviewStatus extends StatelessWidget {
  final TransferPreview preview;

  const _PreviewStatus({required this.preview});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.fromLTRB(16, 13, 16, 10),
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    color: const Color(0xFFF0F9F4),
    child: Text(
      'Preview ${preview.status.isEmpty ? 'listo' : preview.status}: ${preview.quantity} unidades · ${preview.candidatesCount} candidatas.',
      style: const TextStyle(fontSize: 10.5, color: stockSuccess),
    ),
  );
}

String _number(num value) => value == value.roundToDouble()
    ? value.toInt().toString()
    : value.toStringAsFixed(2);

String _transferError(Object error) {
  if (error is DioException) {
    final data = error.response?.data;
    if (data is Map) {
      final message = data['message'] ?? data['error'] ?? data['details'];
      if (message != null && '$message'.trim().isNotEmpty) return '$message';
    }
  }
  return 'Revisa la ciudad y los refinamientos de la consulta.';
}
