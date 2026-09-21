import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/theme/ia_colors.dart';
import '../../domain/entities/product_autocomplete.dart';
import '../atoms/ia_button.dart';
import '../molecules/labeled_input.dart';

class SearchPanel extends StatefulWidget {
  final String referencia;
  final ValueChanged<String> setReferencia;
  final String descripcion;
  final ValueChanged<String> setDescripcion;
  final String bodega;
  final ValueChanged<String> setBodega;
  final VoidCallback onBuscar;
  final Future<ProductAutocompleteResult> Function(String, CancelToken)
      onAutocomplete;
  final ValueChanged<ProductAutocompleteSuggestion> onSuggestionSelected;

  const SearchPanel({
    super.key,
    required this.referencia,
    required this.setReferencia,
    required this.descripcion,
    required this.setDescripcion,
    required this.bodega,
    required this.setBodega,
    required this.onBuscar,
    required this.onAutocomplete,
    required this.onSuggestionSelected,
  });

  @override
  State<SearchPanel> createState() => _SearchPanelState();
}

class _SearchPanelState extends State<SearchPanel> {
  Timer? _debounce;
  CancelToken? _cancelToken;
  int _requestId = 0;
  bool _loading = false;
  bool _isLocal = false;
  List<ProductAutocompleteSuggestion> _suggestions = const [];

  @override
  void dispose() {
    _debounce?.cancel();
    _cancelToken?.cancel();
    super.dispose();
  }

  void _onQueryChanged(String value, ValueChanged<String> onChanged) {
    onChanged(value);
    _debounce?.cancel();
    _cancelToken?.cancel();
    _requestId++;
    final query = value.trim();
    if (query.length < 2) {
      setState(() {
        _loading = false;
        _suggestions = const [];
        _isLocal = false;
      });
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 350), () {
      _loadSuggestions(query);
    });
  }

  Future<void> _loadSuggestions(String query) async {
    final requestId = ++_requestId;
    final token = CancelToken();
    _cancelToken = token;
    setState(() => _loading = true);
    try {
      final result = await widget.onAutocomplete(query, token);
      if (!mounted || requestId != _requestId) return;
      setState(() {
        _suggestions = result.suggestions;
        _isLocal = result.isLocal;
      });
    } on DioException catch (error) {
      if (CancelToken.isCancel(error)) return;
      if (mounted && requestId == _requestId) {
        setState(() => _suggestions = const []);
      }
    } finally {
      if (mounted && requestId == _requestId) {
        setState(() => _loading = false);
      }
    }
  }

  void _select(ProductAutocompleteSuggestion suggestion) {
    _debounce?.cancel();
    _cancelToken?.cancel();
    _requestId++;
    setState(() => _suggestions = const []);
    widget.onSuggestionSelected(suggestion);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: const BoxDecoration(
        color: IaColors.card,
        border: Border(bottom: BorderSide(color: IaColors.border)),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: LabeledInput(
                  label: 'Referencia',
                  placeholder: 'Buscar por referencia...',
                  value: widget.referencia,
                  onChanged: (value) => _onQueryChanged(
                    value,
                    widget.setReferencia,
                  ),
                  onSubmitted: (_) => widget.onBuscar(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: LabeledInput(
                  label: 'Descripcion',
                  placeholder: 'Buscar por descripcion...',
                  value: widget.descripcion,
                  onChanged: (value) => _onQueryChanged(
                    value,
                    widget.setDescripcion,
                  ),
                  onSubmitted: (_) => widget.onBuscar(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: LabeledInput(
                  label: 'Bodega',
                  placeholder: 'Bodega...',
                  value: widget.bodega,
                  onChanged: widget.setBodega,
                  onSubmitted: (_) => widget.onBuscar(),
                ),
              ),
              const SizedBox(width: 12),
              IAButton(
                onPressed: widget.onBuscar,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9.5),
                child: const Row(
                  children: [
                    Icon(LucideIcons.search),
                    SizedBox(width: 8),
                    Text('Buscar'),
                  ],
                ),
              ),
            ],
          ),
          if (_loading || _suggestions.isNotEmpty) ...[
            const SizedBox(height: 8),
            _AutocompleteList(
              suggestions: _suggestions,
              loading: _loading,
              isLocal: _isLocal,
              onSelected: _select,
            ),
          ],
        ],
      ),
    );
  }
}

class _AutocompleteList extends StatelessWidget {
  final List<ProductAutocompleteSuggestion> suggestions;
  final bool loading;
  final bool isLocal;
  final ValueChanged<ProductAutocompleteSuggestion> onSelected;

  const _AutocompleteList({
    required this.suggestions,
    required this.loading,
    required this.isLocal,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(maxHeight: 274),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: IaColors.border),
      borderRadius: BorderRadius.circular(5),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (loading)
          const LinearProgressIndicator(
            minHeight: 2,
            color: IaColors.primaryLight,
          ),
        if (isLocal)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            color: const Color(0xFFFFF9ED),
            child: const Text(
              'Coincidencias locales',
              style: TextStyle(fontSize: 10.5, color: Color(0xFF9A5B06)),
            ),
          ),
        Flexible(
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: suggestions.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final suggestion = suggestions[index];
              return InkWell(
                onTap: () => onSelected(suggestion),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                  child: Row(
                    children: [
                      const Icon(
                        LucideIcons.search,
                        size: 16,
                        color: IaColors.primaryLight,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              suggestion.reference,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: IaColors.foreground,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              suggestion.description,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 11,
                                color: IaColors.mutedForeground,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${_number(suggestion.nationalAvailableStock)} disp.',
                        style: const TextStyle(
                          fontSize: 10.5,
                          color: IaColors.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    ),
  );
}

String _number(num value) => value == value.roundToDouble()
    ? value.toInt().toString()
    : value.toStringAsFixed(2);
