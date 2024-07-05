/// @see: https://docs.flutter.dev/data-and-backend/serialization/json
///
/// dart run build_runner watch --delete-conflicting-outputs
///
/// $ dart run build_runner build --delete-conflicting-outputs
///
library;

// from: https://github.com/ZachHandley/elevenlabs_flutter/blob/main/lib/elevenlabs_flutter.dart
// library elevenlabs_flutter;

import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:lola_ai_app/features/core/elevenlabs/types.dart';
import 'package:lola_ai_app/features/core/time.dart';
import 'package:path_provider/path_provider.dart';

import './generated/types.dart' as T;

@immutable
class ElevenLabsConfig {
  final String apiKey;
  final String baseUrl;

  const ElevenLabsConfig({
    required this.apiKey,
    this.baseUrl = 'https://api.elevenlabs.io',
  });
}

class ElevenLabsAPI {
  // Singleton instance
  static final ElevenLabsAPI _instance = ElevenLabsAPI._privateConstructor();
  factory ElevenLabsAPI() => _instance;
  ElevenLabsAPI._privateConstructor();

  // Dio client
  final Dio _dio = Dio();

  /// Initialize API
  /// Takes [baseUrl] and [apiKey] as arguments
  Future<void> init({
    required ElevenLabsConfig config,
  }) async {
    _dio
      ..options.baseUrl = config.baseUrl
      ..options.connectTimeout = const Duration(seconds: 10)
      ..options.receiveTimeout = const Duration(seconds: 20)
      ..options.headers = {
        'Content-Type': 'application/json',
        'xi-api-key': config.apiKey,
      };

    if (Platform.isIOS || Platform.isAndroid) {
      _dio.httpClientAdapter = HttpClientAdapter();
    }
  }

  // Voices

  /// List available voices
  /// Returns a list of [Voice] objects
  Future<T.Voices> listVoices() async {
    try {
      final response = await _dio.get('/v1/voices');
      return T.Voices.fromJson(response.data);
    } catch (error) {
      throw _handleError(error);
    }
  }

  // Synthesis

  /// Synthesize text to speech
  /// Takes a [TextToSpeechRequest] object and a value from 0 to 1 on how much to optimize for streaming latency
  /// Returns a [HistoryItem] object
  Future<File> synthesize(TextToSpeechRequest request,
      {int optimizeStreamingLatency = 0}) async {
    try {
      Response<dynamic> response;
      if (optimizeStreamingLatency != 0) {
        response = await _dio.post(
          '/v1/text-to-speech/${request.voiceId}',
          data: request,
          queryParameters: {
            'optimize_streaming_latency': optimizeStreamingLatency
          },
          options: Options(
            responseType: ResponseType.bytes,
          ),
        );
      } else {
        response = await _dio.post(
          '/v1/text-to-speech/${request.voiceId}',
          data: request,
          options: Options(
            responseType: ResponseType.bytes,
          ),
        );
      }

      // final localStorage = await Directory.systemTemp.createTemp();
      final localStorage = await getTemporaryDirectory();
      final String fileName =
          "${localStorage.path}/lola_11labs_tmp_${request.voiceId}_${formatTimestamp(DateTime.now())}.wav";
      debugPrint('>> $fileName');
      final responseFile = await File(fileName).writeAsBytes(response.data);
      return responseFile;
    } catch (error) {
      throw _handleError(error);
    }
  }

  // Helper methods

  dynamic _handleError(error) {
    // Handle DioExceptions
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          debugPrint(error.message);
          throw TimeoutException(error.message);
        case DioExceptionType.badResponse:
          switch (error.response?.statusCode) {
            case 400:
              throw BadRequestException(error.response?.data['error']);
            case 401:
              throw UnauthorizedException(error.response?.data['error']);
            case 403:
              throw ForbiddenException(error.response?.data['error']);
            case 404:
              throw NotFoundException(error.response?.data['error']);
            case 409:
              throw ConflictException(error.response?.data['error']);
            case 429:
              throw TooManyRequestsException(error.response?.data['error']);
            case 500:
              throw InternalServerErrorException(error.response?.data['error']);
          }
        case DioExceptionType.cancel:
          throw RequestCanceledException(error.message);
        case DioExceptionType.unknown:
          throw NoInternetConnectionException(error.message);
        default:
          throw UnknownApiException(error);
      }
    }

    // Handle general errors
    throw UnknownApiException(error);
  }
}

// Custom exceptions
class UnknownApiException implements Exception {
  final dynamic error;

  UnknownApiException(this.error);
}

class TimeoutException implements Exception {
  final String? message;

  TimeoutException(this.message);
}

class BadRequestException implements Exception {
  final String? message;

  BadRequestException(this.message);
}

class UnauthorizedException implements Exception {
  final String? message;

  UnauthorizedException(this.message);
}

class ForbiddenException implements Exception {
  final String? message;

  ForbiddenException(this.message);
}

class NotFoundException implements Exception {
  final String? message;

  NotFoundException(this.message);
}

class ConflictException implements Exception {
  final String? message;

  ConflictException(this.message);
}

class TooManyRequestsException implements Exception {
  final String? message;

  TooManyRequestsException(this.message);
}

class InternalServerErrorException implements Exception {
  final String? message;

  InternalServerErrorException(this.message);
}

class RequestCanceledException implements Exception {
  final String? message;

  RequestCanceledException(this.message);
}

class NoInternetConnectionException implements Exception {
  final String? message;

  NoInternetConnectionException(this.message);
}
