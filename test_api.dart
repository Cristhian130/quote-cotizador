import 'package:dio/dio.dart';

void main() async {
  print("=== INICIANDO PRUEBA DE CONEXION A API LOCAL ===");
  print("Endpoint: http://localhost:3001/api/cotizacion/delivery-rules");

  final dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );

  try {
    print("Enviando petición GET...");
    final stopwatch = Stopwatch()..start();
    final response = await dio.get(
      'http://localhost:3001/api/cotizacion/delivery-rules',
    );
    stopwatch.stop();

    print("--- RESULTADO EXITOSO ---");
    print("Tiempo: ${stopwatch.elapsedMilliseconds} ms");
    print("Status Code: ${response.statusCode}");

    final payload = response.data;
    if (payload is Map) {
      print("Status Body: ${payload['status']}");
      print("Count Body: ${payload['count']}");
    } else {
      print("No es un JSON Map");
    }
  } on DioException catch (e) {
    print("--- ERROR DE DIO (RED) ---");
    print("Type: ${e.type}");
    print("Message: ${e.message}");
    if (e.response != null) {
      print("Status Code del Error: ${e.response?.statusCode}");
      print("Data del Error: ${e.response?.data}");
    } else {
      print(
        "No se recibió respuesta del servidor (Posible timeout o caida de Node)",
      );
    }
  } catch (e) {
    print("--- ERROR DESCONOCIDO ---");
    print(e.toString());
  }
}
