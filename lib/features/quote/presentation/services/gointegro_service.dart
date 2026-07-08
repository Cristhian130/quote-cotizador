import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:intl/intl.dart';

part 'gointegro_service.g.dart';

@riverpod
GointegroService gointegroService(Ref ref) {
  final dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );
  return GointegroService(dio);
}

class BonusValidationResult {
  final bool isValid;
  final String title;
  final String description;
  final String amount;
  final String balance;
  final String date;
  final String errorMsg;

  BonusValidationResult({
    required this.isValid,
    this.title = '',
    this.description = '',
    this.amount = '',
    this.balance = '',
    this.date = '',
    this.errorMsg = '',
  });
}

class GointegroService {
  final Dio _dio;
  String? _accessToken;
  DateTime? _tokenExpiry;

  // Credenciales El Socio 2
  static const _clientId = '4uujg27mf72880ck44w8sgcwk0wskw40000k4w484ss48ogww4';
  static const _clientSecret = '3dsw9z2790u88sgosgcw0k4cwoo0cg4wk04ocgk8sswgso8ock';
  static const _username = 'api.user+elsocio2@gointegro.com';
  static const _password = 'QtH8y-qKQpN85-eJtjE2KD';
  static const _hostname = 'elsocio.gointegro.com';
  static const _ecosystemId = '582';

  GointegroService(this._dio);

  Future<void> _authenticate() async {
    if (_accessToken != null && _tokenExpiry != null && DateTime.now().isBefore(_tokenExpiry!)) {
      return; // Token is still valid
    }

    try {
      final response = await _dio.post(
        'https://api.gointegro.com/oauth/token',
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          headers: {'Accept': 'application/json'},
        ),
        data: {
          'grant_type': 'password',
          'username': _username,
          'password': _password,
          'client_id': _clientId,
          'client_secret': _clientSecret,
          'hostname': _hostname,
        },
      );

      final data = response.data;
      _accessToken = data['access_token'];
      final expiresIn = data['expires_in'] as int;
      // Restamos un poco de tiempo por seguridad
      _tokenExpiry = DateTime.now().add(Duration(seconds: expiresIn - 300));
    } catch (e) {
      throw Exception('Error autenticando en GOintegro: $e');
    }
  }

  Future<BonusValidationResult> validateBonusCode(String code) async {
    // Modo de prueba sin API (Offline mock)
    if (code.toUpperCase().startsWith('TEST') || code.toUpperCase() == 'LAPROMO') {
      await Future.delayed(const Duration(milliseconds: 1200));
      return BonusValidationResult(
        isValid: true,
        title: 'MOCK eGift Card',
        description: 'Bono de prueba offline',
        amount: '-500',
        balance: '1500',
        date: DateTime.now().toIso8601String(),
      );
    }

    try {
      await _authenticate();

      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      // Buscamos desde inicio de año
      final fromDate = '${DateTime.now().year}-01-01';

      final response = await _dio.get(
        'https://api.gointegro.com/bank/transactions',
        options: Options(
          headers: {
            'Accept': 'application/vnd.api+json',
            'Authorization': 'Bearer $_accessToken',
          },
        ),
        queryParameters: {
          'filter[ecosystem-id]': _ecosystemId,
          'filter[account-type]': 'user_wallet_account',
          'filter[type]': 'redemption',
          'filter[date-from]': fromDate,
          'filter[date-to]': today,
          'page[limit]': 50,
          'page[offset]': 0,
          'sort': '-date',
        },
      );

      final List data = response.data['data'] ?? [];

      for (var tx in data) {
        final attributes = tx['attributes'];
        final txCode = attributes['code']?.toString() ?? '';
        final description = attributes['description']?.toString() ?? '';

        // Buscamos coincidencia exacta en code o description por si acaso
        if (txCode.toUpperCase() == code.toUpperCase() || description.toUpperCase() == code.toUpperCase()) {
          return BonusValidationResult(
            isValid: true,
            title: attributes['title']?.toString() ?? '',
            description: description,
            amount: attributes['amount']?.toString() ?? '',
            balance: attributes['balance']?.toString() ?? '',
            date: attributes['date']?.toString() ?? '',
          );
        }
      }

      return BonusValidationResult(
        isValid: false,
        errorMsg: 'Código no encontrado en las transacciones de GOintegro.',
      );
    } catch (e) {
      return BonusValidationResult(
        isValid: false,
        errorMsg: 'Error de conexión con GOintegro: ${e.toString()}',
      );
    }
  }
}
