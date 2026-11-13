import 'package:dio/dio.dart';

class NetworkFailure implements Exception {
  final int code;
  final String message;

  const NetworkFailure({required this.code, required this.message});

  @override
  String toString() => 'NetworkFailure($code): $message';
}

/// Menerjemahkan error teknis Dio menjadi pesan berbahasa Indonesia.
class ErrorHandler implements Exception {
  late final NetworkFailure failure;

  ErrorHandler.handle(dynamic error) {
    if (error is NetworkFailure) {
      failure = error;
    } else if (error is DioException) {
      failure = _handleDioError(error);
    } else {
      failure = NetworkFailure(code: -7, message: 'Terjadi kesalahan tidak diketahui: $error');
    }
  }

  NetworkFailure _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkFailure(
          code: -1,
          message: 'Waktu koneksi habis (Timeout). Periksa koneksi internet Anda.',
        );
      case DioExceptionType.cancel:
        return const NetworkFailure(code: -2, message: 'Permintaan ke server dibatalkan.');
      case DioExceptionType.connectionError:
        return const NetworkFailure(
          code: -6,
          message: 'Gagal terhubung ke server. Pastikan perangkat terhubung ke internet.',
        );
      case DioExceptionType.badResponse:
        return _handleBadResponse(error);
      default:
        return NetworkFailure(
          code: -8,
          message: 'Gangguan koneksi: ${error.message ?? 'Terjadi kesalahan tidak diketahui'}',
        );
    }
  }

  NetworkFailure _handleBadResponse(DioException error) {
    final statusCode = error.response?.statusCode ?? -4;
    final data = error.response?.data;
    final serverMessage = data is Map && data['message'] is String
        ? data['message'] as String
        : null;
    return NetworkFailure(
      code: statusCode,
      message: serverMessage ?? _getFallbackMessage(statusCode),
    );
  }

  String _getFallbackMessage(int statusCode) {
    switch (statusCode) {
      case 400:
        return 'Permintaan tidak valid (400 Bad Request).';
      case 401:
        return 'Sesi tidak sah, silakan masuk kembali (401 Unauthorized).';
      case 403:
        return 'Akses ditolak oleh server (403 Forbidden).';
      case 404:
        return 'Data tidak ditemukan di server (404 Not Found).';
      case 500:
        return 'Server sedang bermasalah, coba lagi nanti (500 Server Error).';
      default:
        return 'Server merespons dengan kode $statusCode.';
    }
  }
}
