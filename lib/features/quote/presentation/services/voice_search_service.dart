import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

class VoiceSearchException implements Exception {
  final String message;

  const VoiceSearchException(this.message);

  @override
  String toString() => message;
}

class VoiceSearchService {
  static const _transcriptionUrl =
      'https://router.huggingface.co/hf-inference/models/'
      'openai/whisper-large-v3-turbo';
  String _token = const String.fromEnvironment('HF_TOKEN');
  bool _disposed = false;

  Stream<double> get levels => _recorder
      .onAmplitudeChanged(const Duration(milliseconds: 100))
      .map((amplitude) => amplitude.current.isFinite
          ? ((amplitude.current + 60) / 60).clamp(0.0, 1.0).toDouble()
          : 0.0);

  Future<void> _loadToken() async {
    if (_token.trim().isNotEmpty) return;
    _token = Platform.environment['HF_TOKEN']?.trim() ?? '';
    if (_token.isNotEmpty || !kDebugMode) return;
    final config = File('config/secrets.json');
    if (await config.exists()) {
      final data = jsonDecode(await config.readAsString());
      if (data is Map && data['HF_TOKEN'] is String) {
        _token = (data['HF_TOKEN'] as String).trim();
      }
    }
  }

  final AudioRecorder _recorder;
  final Dio _dio;
  String? _recordingPath;

  VoiceSearchService({AudioRecorder? recorder, Dio? dio})
    : _recorder = recorder ?? AudioRecorder(),
      _dio =
          dio ??
          Dio(
            BaseOptions(
              connectTimeout: const Duration(seconds: 15),
              receiveTimeout: const Duration(seconds: 45),
            ),
          );

  Future<void> startRecording() async {
    await _loadToken();
    if (_token.isEmpty) {
      throw const VoiceSearchException(
        'Falta configurar el acceso de transcripcion.',
      );
    }
    if (!await _recorder.hasPermission()) {
      throw const VoiceSearchException(
        'No se autorizo el uso del microfono.',
      );
    }

    final directory = await getTemporaryDirectory();
    if (_disposed) return;
    _recordingPath =
        '${directory.path}${Platform.pathSeparator}'
        'quote_voice_${DateTime.now().microsecondsSinceEpoch}.wav';
    await _recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.wav,
        numChannels: 1,
        sampleRate: 16000,
      ),
      path: _recordingPath!,
    );
  }

  Future<String> stopAndTranscribe() async {
    final path = await _recorder.stop() ?? _recordingPath;
    _recordingPath = null;
    if (path == null) {
      throw const VoiceSearchException(
        'No se encontro una grabacion para transcribir.',
      );
    }

    try {
      final audio = Uint8List.fromList(await File(path).readAsBytes());
      final response = await _dio.post<Map<String, dynamic>>(
        _transcriptionUrl,
        data: Stream.value(audio),
        options: Options(
          headers: {
            'Authorization': 'Bearer $_token',
            'Content-Type': 'audio/wav',
            'Accept': 'application/json',
            'Content-Length': audio.length.toString(),
          },
        ),
      );
      final text = response.data?['text'];
      if (text is! String || text.trim().isEmpty) {
        throw const VoiceSearchException('No se detecto una busqueda en el audio.');
      }
      return text.trim();
    } on VoiceSearchException {
      rethrow;
    } on DioException catch (error) {
      final status = error.response?.statusCode;
      if (status == 401 || status == 403) {
        throw const VoiceSearchException('El acceso de transcripcion no es valido.');
      }
      if (status == 402) {
        throw const VoiceSearchException('No hay credito disponible para transcribir.');
      }
      if (status == 429) {
        throw const VoiceSearchException('La transcripcion esta temporalmente ocupada.');
      }
      throw const VoiceSearchException('No fue posible transcribir el audio.');
    } catch (_) {
      throw const VoiceSearchException('No fue posible procesar el audio.');
    } finally {
      await _deleteFile(path);
    }
  }

  Future<void> cancelRecording() async {
    final path = _recordingPath;
    _recordingPath = null;
    await _recorder.cancel();
    if (path != null) await _deleteFile(path);
  }

  Future<void> dispose() async {
    _disposed = true;
    _dio.close(force: true);
    try {
      await cancelRecording();
    } catch (_) {
      // The platform may already have released the microphone.
    } finally {
      await _recorder.dispose();
    }
  }

  Future<void> _deleteFile(String path) async {
    final file = File(path);
    try {
      if (await file.exists()) await file.delete();
    } on FileSystemException {
      // Temporary-file cleanup must not discard a successful transcription.
    }
  }
}
