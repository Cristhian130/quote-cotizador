import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/theme/ia_colors.dart';
import '../../domain/entities/product_autocomplete.dart';
import '../../presentation/services/voice_search_service.dart';
import '../atoms/ia_button.dart';
import '../molecules/labeled_input.dart';
import '../molecules/voice_recording_bar.dart';

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
  bool _voiceRecording = false;
  bool _voiceProcessing = false;
  bool _voiceStarting = false;
  Timer? _voiceLimit;
  Stream<double>? _voiceLevels;
  String? _voiceMessage;
  List<ProductAutocompleteSuggestion> _suggestions = const [];
  late final VoiceSearchService _voiceSearch;
  final _suggestionsOverlay = OverlayPortalController();
  final _searchAnchor = GlobalKey();
  final _searchLink = LayerLink();

  void _dismissSuggestions() {
    _debounce?.cancel();
    _cancelToken?.cancel();
    _requestId++;
    _suggestionsOverlay.hide();
    setState(() {
      _loading = false;
      _suggestions = const [];
    });
  }

  void _submitSearch() {
    _dismissSuggestions();
    widget.onBuscar();
  }

  @override
  void initState() {
    super.initState();
    _voiceSearch = VoiceSearchService();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _cancelToken?.cancel();
    _voiceLimit?.cancel();
    unawaited(_voiceSearch.dispose());
    super.dispose();
  }

  Future<void> _toggleVoiceSearch() async {
    if (_voiceProcessing || _voiceStarting) return;

    if (_voiceRecording) {
      _voiceLimit?.cancel();
      setState(() {
        _voiceRecording = false;
        _voiceProcessing = true;
        _voiceMessage = 'Transcribiendo...';
      });
      try {
        final transcription = await _voiceSearch.stopAndTranscribe();
        if (!mounted) return;
        widget.setReferencia('');
        _onQueryChanged(transcription, widget.setDescripcion);
        setState(() => _voiceMessage = 'Busqueda por voz lista.');
      } on VoiceSearchException catch (error) {
        if (mounted) setState(() => _voiceMessage = error.message);
      } catch (_) {
        if (mounted) setState(() => _voiceMessage = 'No fue posible procesar el audio.');
      } finally {
        if (mounted) setState(() => _voiceProcessing = false);
      }
      return;
    }

    setState(() {
      _voiceStarting = true;
      _voiceMessage = 'Activando microfono...';
    });
    try {
      await _voiceSearch.startRecording();
      if (mounted) {
        setState(() {
          _voiceRecording = true;
          _voiceLevels = _voiceSearch.levels;
          _voiceMessage = 'Escuchando...';
        });
        _voiceLimit = Timer(const Duration(seconds: 30), () {
          if (mounted && _voiceRecording) unawaited(_toggleVoiceSearch());
        });
      }
    } on VoiceSearchException catch (error) {
      if (mounted) setState(() => _voiceMessage = error.message);
    } catch (_) {
      if (mounted) setState(() => _voiceMessage = 'No se pudo activar el microfono. Revisa el dispositivo y sus permisos.');
    } finally {
      if (mounted) setState(() => _voiceStarting = false);
    }
  }

  Future<void> _cancelVoice() async {
    _voiceLimit?.cancel();
    setState(() {
      _voiceRecording = false;
      _voiceProcessing = true;
      _voiceMessage = null;
    });
    try {
      await _voiceSearch.cancelRecording();
    } catch (_) {
      if (mounted) setState(() => _voiceMessage = 'No se pudo cerrar el microfono.');
    } finally {
      if (mounted) setState(() => _voiceProcessing = false);
    }
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
    _dismissSuggestions();
    widget.onSuggestionSelected(suggestion);
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_loading || _suggestions.isNotEmpty) {
        if (!_suggestionsOverlay.isShowing) _suggestionsOverlay.show();
      } else if (_suggestionsOverlay.isShowing) {
        _suggestionsOverlay.hide();
      }
    });
    return OverlayPortal(
      controller: _suggestionsOverlay,
      overlayChildBuilder: (context) {
        final box = _searchAnchor.currentContext?.findRenderObject();
        if ((!_loading && _suggestions.isEmpty) || box is! RenderBox || !box.hasSize) {
          return const SizedBox.shrink();
        }
        final media = MediaQuery.of(context);
        final bottom = box.localToGlobal(Offset(0, box.size.height)).dy;
        final available = (media.size.height - media.viewInsets.bottom - bottom - 12)
            .clamp(0.0, 274.0).toDouble();
        if (available < 48) return const SizedBox.shrink();
        return Positioned(
          top: 0,
          left: 0,
          width: box.size.width,
          child: CompositedTransformFollower(
            link: _searchLink,
            showWhenUnlinked: false,
            targetAnchor: Alignment.bottomLeft,
            followerAnchor: Alignment.topLeft,
            offset: const Offset(0, 4),
            child: TapRegion(
              groupId: _searchLink,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Material(
                  elevation: 6,
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5),
                  clipBehavior: Clip.antiAlias,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: available),
                    child: _AutocompleteList(
                      suggestions: _suggestions,
                      loading: _loading,
                      isLocal: _isLocal,
                      onSelected: _select,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
      child: TapRegion(
        groupId: _searchLink,
        onTapOutside: (_) => _dismissSuggestions(),
        child: CompositedTransformTarget(
          key: _searchAnchor,
          link: _searchLink,
          child: _buildSearchContent(),
        ),
      ),
    );
  }

  Widget _buildSearchContent() {
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
                  onSubmitted: (_) => _submitSearch(),
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
                  onSubmitted: (_) => _submitSearch(),
                  suffixIcon: IconButton(
                    onPressed: _voiceProcessing || _voiceStarting ? null : _toggleVoiceSearch,
                    constraints: const BoxConstraints.tightFor(width: 32, height: 32),
                    padding: EdgeInsets.zero,
                    tooltip: _voiceRecording
                        ? 'Detener grabacion'
                        : 'Buscar por voz',
                    icon: _voiceProcessing || _voiceStarting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Icon(
                            _voiceRecording
                                ? LucideIcons.square
                                : LucideIcons.mic,
                            size: 18,
                            color: _voiceRecording
                                ? IaColors.destructive
                                : IaColors.primaryLight,
                          ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: LabeledInput(
                  label: 'Bodega',
                  placeholder: 'Bodega...',
                  value: widget.bodega,
                  onChanged: widget.setBodega,
                  onSubmitted: (_) => _submitSearch(),
                ),
              ),
              const SizedBox(width: 12),
              IAButton(
                onPressed: _submitSearch,
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
          if (_voiceRecording && _voiceLevels != null) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: VoiceRecordingBar(
                  levels: _voiceLevels!,
                  onCancel: _cancelVoice,
                  onStop: _toggleVoiceSearch,
                ),
              ),
            ),
          ],
          if (_voiceMessage != null && !_voiceRecording) ...[
            const SizedBox(height: 7),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                _voiceMessage!,
                style: TextStyle(
                  fontSize: 11,
                  color: _voiceRecording || _voiceProcessing
                      ? IaColors.mutedForeground
                      : IaColors.primary,
                ),
              ),
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
            primary: false,
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
