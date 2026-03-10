import 'package:dio/dio.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/delivery_rule.dart';
import '../../../../core/config/app_config.dart';

class RemoteDataSource {
  final Dio _dio;

  RemoteDataSource(this._dio);

  Future<List<Product>> fetchAllProducts() async {
    final url = '${AppConfig.baseUrl}/api/cotizacion/inventario';
    print('======================================================');
    print('🔄 [SYNC] Haciendo petición GET a: $url');
    print('======================================================');

    final response = await _dio.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> payload = response.data;
      final List<dynamic> data = payload['data'] ?? [];
      return data.map((json) => Product.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load products from API');
    }
  }

  Future<List<DeliveryRule>> fetchDeliveryRules() async {
    try {
      // Small delay so that the massive product sync doesn't crash the Node.js connection pool
      await Future.delayed(const Duration(seconds: 2));

      final url = '${AppConfig.baseUrl}/api/cotizacion/delivery-rules';
      print('======================================================');
      print('📦 [SYNC] Haciendo petición GET a: $url');
      print('======================================================');

      final response = await _dio.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> payload = response.data;
        final List<dynamic> data = payload['data'] ?? [];
        return data.map((json) => DeliveryRule.fromJson(json)).toList();
      } else {
        print(
          '⚠️ [SYNC] delivery-rules respondió ${response.statusCode}, ignorando.',
        );
        return [];
      }
    } on DioException catch (e) {
      print("=== DIO ERROR EN FETCH DELIVERY RULES ===");
      print(e.message);
      if (e.response != null) {
        print("NestJS Error Data: ${e.response?.data}");
      }
      print(
        '⚠️ [SYNC] delivery-rules no disponible, continuando sin reglas de entrega.',
      );
      // No-bloqueante: devolvemos lista vacía para que el sync de inventario no falle
      return [];
    } catch (e) {
      print('⚠️ [SYNC] Error inesperado en delivery-rules: $e');
      return [];
    }
  }
}
