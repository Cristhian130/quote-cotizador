import 'package:dio/dio.dart';

import '../../../../core/config/app_config.dart';
import '../domain/transfer_suggestion.dart';

class TransfersRemoteDataSource {
  final Dio _dio;

  TransfersRemoteDataSource(this._dio);

  String get _baseUrl => '${AppConfig.baseUrl}/api/cotizacion/traslados';

  Future<TransferSuggestionsResult> findSuggestionsByCity(
    CityTransferRequest request,
  ) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '$_baseUrl/sugerencias-ciudad',
      queryParameters: request.toQueryParameters(),
    );
    return _suggestionsFromPayload(
      response.data ?? const <String, dynamic>{},
      fallbackOrigin: {
        'bodega': request.originWarehouse,
        'centroOperacion': request.originOperationCenter,
        'ciudadNormalizada': request.city,
        'idEmpresa': request.companyId,
      },
    );
  }

  Future<TransferSuggestionsResult> findSuggestions(
    TransferRequest request,
  ) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '$_baseUrl/sugerencias',
      queryParameters: request.toQueryParameters(),
    );
    return _suggestionsFromPayload(
      response.data ?? const <String, dynamic>{},
    );
  }

  TransferSuggestionsResult _suggestionsFromPayload(
    Map<String, dynamic> payload, {
    Map<String, dynamic>? fallbackOrigin,
  }) => TransferSuggestionsResult.fromJson(
    payload,
    fallbackOrigin: fallbackOrigin,
  );

  Future<TransferPreview> preview(TransferRequest request) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '$_baseUrl/preview',
      data: request.toPreviewJson(),
    );
    return TransferPreview.fromJson(
      response.data ?? const <String, dynamic>{},
    );
  }
}
