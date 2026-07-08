import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/config/app_config.dart';

part 'bonus_service.g.dart';

@riverpod
BonusService bonusService(Ref ref) {
  final dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(minutes: 15),
      receiveTimeout: const Duration(minutes: 15),
      headers: {
        'ngrok-skip-browser-warning': 'true',
      },
    ),
  );
  return BonusService(dio);
}

class BonusService {
  final Dio _dio;

  BonusService(this._dio);

  Future<Map<String, dynamic>> previewBonus({
    required String companyId,
    required String operationCenter,
    required String customerId,
    required String sellerId,
    required String promoCode,
    required List<Map<String, dynamic>> items,
  }) async {
    final url = '${AppConfig.baseUrl}/api/cotizacion/bonus-discount/preview';
    final payload = {
      "companyId": companyId,
      "operationCenter": operationCenter,
      "customerId": customerId,
      "sellerId": sellerId,
      "promoCode": promoCode,
      "items": items,
    };

    try {
      final response = await _dio.post(url, data: payload);
      return response.data;
    } catch (e) {
      throw Exception('Error previewing bonus: $e');
    }
  }

  Future<Map<String, dynamic>> applyBonusOrders({
    required String companyId,
    required String operationCenter,
    required String customerId,
    required String sellerId,
    required String promoCode,
    required List<Map<String, dynamic>> items,
  }) async {
    final url = '${AppConfig.baseUrl}/api/cotizacion/bonus-discount/orders';
    final payload = {
      "companyId": companyId,
      "operationCenter": operationCenter,
      "customerId": customerId,
      "sellerId": sellerId,
      "promoCode": promoCode,
      "items": items,
    };

    try {
      final response = await _dio.post(url, data: payload);
      return response.data;
    } catch (e) {
      throw Exception('Error applying bonus orders: $e');
    }
  }
}
