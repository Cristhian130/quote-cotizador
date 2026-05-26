import 'package:dio/dio.dart';
import '../../models/vehicle_info.dart';

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

    final url = 'http://190.248.128.190:5051/api/vin?placa=$cleanPlaca';

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
      throw Exception('Ocurrió un error inesperado: $e');
    }
  }
}
