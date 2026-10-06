import 'package:core/core.dart';
import 'package:dio/dio.dart';

/// Translation of a [DioException] into core's [ApiError]: the only error
/// type that leaves this package.
class DioApiError implements ApiError {
  const DioApiError({required this.statusCode, required this.body, required this.message});

  factory DioApiError.from(DioException exception) => DioApiError(
        statusCode: exception.response?.statusCode,
        body: exception.response?.data,
        message: exception.message ?? exception.type.name,
      );

  @override
  final int? statusCode;

  @override
  final Object? body;

  final String message;

  @override
  String toString() => 'DioApiError(statusCode: $statusCode, message: $message)';
}
