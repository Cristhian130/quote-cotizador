import 'package:dio/dio.dart';
import '../../models/referral.dart';

class ReferralService {
  final Dio _dio;

  ReferralService([Dio? dio])
      : _dio = dio ??
            Dio(
              BaseOptions(
                connectTimeout: const Duration(seconds: 15),
                receiveTimeout: const Duration(seconds: 15),
              ),
            );

  Future<Referral?> validateReferral(String codigo) async {
    final cleanCodigo = codigo.trim();
    if (cleanCodigo.isEmpty) {
      throw Exception('El código de referido no puede estar vacío');
    }

    final url = 'https://server.elsocio.importadorasasociadas.com/api/v1/referidos/by-codigo/$cleanCodigo';

    try {
      final response = await _dio.get(
        url,
        options: Options(
          headers: {
            'Authorization': 'Bearer f82675704f5254c5f890eb9a3af4f5e16fea69c868fa44de19c4e96842ffa243a2a6642cbc1098b4541f5c328c2cf3b6',
          },
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        // If data is a String or Map, handle accordingly
        if (data is Map<String, dynamic>) {
          return Referral.fromJson(data);
        } else {
          throw Exception('Respuesta inesperada del servidor');
        }
      }
      return null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        // Referral not found is a expected result, so we return null
        return null;
      }
      // Other network/server error
      final errorMsg = e.response?.data?['message'] ?? e.message ?? 'Error de conexión';
      throw Exception(errorMsg);
    } catch (e) {
      throw Exception('Ocurrió un error inesperado: $e');
    }
  }
}
