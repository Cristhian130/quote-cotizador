import 'package:dio/dio.dart';
import '../../models/vehicle_info.dart';
import '../../../../core/config/app_config.dart';

class VehicleService {
  final Dio _dio;

  VehicleService([Dio? dio])
      : _dio = dio ??
            Dio(
              BaseOptions(
                connectTimeout: const Duration(seconds: 15),
                receiveTimeout: const Duration(seconds: 15),
              ),
            );

  Future<VehicleInfo?> getVehicleInfo(String placa) async {
    final cleanPlaca = placa.trim().toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');
    if (cleanPlaca.isEmpty) {
      throw Exception('La placa no puede estar vacía');
    }

    final url = 'https://tiempos-qa.macrollantas.com/api/control-apis/vin-importdora?api_key=sk_1e929ac467fad4ae3cd389a9fb106334212a5383e102f938&placa=$cleanPlaca';

    try {
      final response = await _dio.get(
        url,
        options: Options(
          headers: {
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
          },
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          return VehicleInfo.fromJson(data);
        } else {
          throw Exception('Respuesta inesperada del servidor');
        }
      }
      return null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return null;
      }
      final errorMsg = e.response?.data?['error'] ?? e.message ?? 'Error de conexión';
      throw Exception(errorMsg);
    } catch (e) {
      throw Exception('Error de conexión o timeout');
    }
  }

  Future<void> trackVinQuery(String placa, String usuario, VehicleInfo info) async {
    final url = '${AppConfig.baseUrl}/api/cotizacion/vin-queried';
    
    try {
      await _dio.post(
        url,
        data: {
          'placa': placa,
          'usuario': usuario,
          'vin de este vehiculo': {
            'marca': info.marca,
            'linea': info.linea,
            'version': info.version,
            'modelo': info.modelo,
            'vin': info.vin,
          }
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );
    } catch (e) {
      // Ignorar de forma silenciosa ya que es solo para analíticas
      print('Error en trackVinQuery: $e');
    }
  }
}
