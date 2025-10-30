import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:anxeb_flutter/anxeb.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

enum ApiMethods { put, get, post, delete }

class Api {
  final String _uri;
  final Dio _dio;
  final String? token;

  Api(
    this._uri, {
    this.token,
    Duration connectTimeout = const Duration(seconds: 7),
    Duration receiveTimeout = const Duration(seconds: 7),
  }) : _dio = Dio(
          BaseOptions(
            baseUrl: _uri,
            connectTimeout: connectTimeout,
            receiveTimeout: receiveTimeout,
          ),
        ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (token != null && token!.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          options.headers['Content-Type'] ??= 'application/json';
          options.headers['source'] = 'Anxeb';
          handler.next(options);
        },
        onResponse: (response, handler) => handler.next(response),
        onError: (DioException e, handler) => handler.next(e),
      ),
    );

    if (!kIsWeb) {
      (_dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
        return HttpClient()
          ..badCertificateCallback =
              (X509Certificate cert, String host, int port) => true;
      };
    }
  }

  Interceptors get interceptors => _dio.interceptors;

  // ----------------------------
  // Internal unified request handler
  // ----------------------------
  Future<Data> _process(
    ApiMethods method,
    String route, {
    dynamic data,
    Map<String, dynamic>? query,
    ProgressCallback? progress,
    CancelToken? cancelToken,
    Options? options,
  }) async {
    final res = await request(
      method,
      route,
      data: data,
      query: query,
      progress: progress,
      cancelToken: cancelToken,
      options: options,
    );
    return Data(res.data);
  }

  Future<Response> request(
    ApiMethods method,
    String route, {
    dynamic data,
    Map<String, dynamic>? query,
    ProgressCallback? progress,
    CancelToken? cancelToken,
    Options? options,
  }) async {
    dynamic body;
    if (data != null) {
      if (data is Data) {
        body = data.toObjects();
      } else if (data is Model) {
        body = data.toObjects();
      } else {
        body = data;
      }
    }

    try {
      switch (method) {
        case ApiMethods.get:
          return await _dio.get(
            route,
            queryParameters: query,
            cancelToken: cancelToken,
            options: options,
          );
        case ApiMethods.delete:
          return await _dio.delete(
            route,
            queryParameters: query,
            cancelToken: cancelToken,
            data: body,
            options: options,
          );
        case ApiMethods.post:
          return await _dio.post(
            route,
            queryParameters: query,
            cancelToken: cancelToken,
            onSendProgress: progress,
            data: body,
            options: options,
          );
        case ApiMethods.put:
          return await _dio.put(
            route,
            queryParameters: query,
            cancelToken: cancelToken,
            onSendProgress: progress,
            data: body,
            options: options,
          );
      }
    } catch (err) {
      throw ApiException.fromErr(err);
    }
  }

  String getUri(String path) => '$_uri$path';

  // ----------------------------
  // HTTP helpers
  // ----------------------------
  Future<Data> delete(String route, [dynamic data]) =>
      _process(ApiMethods.delete, route, data: data);

  Future<Data> post(
    String route,
    dynamic data, {
    ProgressCallback? progress,
    CancelToken? cancelToken,
    Options? options,
  }) =>
      _process(
        ApiMethods.post,
        route,
        data: data,
        progress: progress,
        cancelToken: cancelToken,
        options: options,
      );

  Future<Data> put(
    String route,
    dynamic data, {
    ProgressCallback? progress,
    CancelToken? cancelToken,
  }) =>
      _process(
        ApiMethods.put,
        route,
        data: data,
        progress: progress,
        cancelToken: cancelToken,
      );

  Future<Data> get(String route, [Map<String, dynamic>? query]) =>
      _process(ApiMethods.get, route, query: query);

  // ----------------------------
  // File download
  // ----------------------------
  Future<Uint8List> download(
    String route, {
    ProgressCallback? progress,
    CancelToken? cancelToken,
    Map<String, dynamic>? query,
  }) async {
    try {
      final response = await _dio.get<Uint8List>(
        route,
        onReceiveProgress: (count, total) =>
            progress?.call(count, count > total ? count : total),
        cancelToken: cancelToken,
        queryParameters: query,
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: false,
          validateStatus: (status) => status != null && status < 500,
        ),
      );
      return response.data!;
    } catch (err) {
      throw ApiException.fromErr(err);
    }
  }

  // ----------------------------
  // File upload
  // ----------------------------
  Future<Data> upload(
    String route, {
    required Map<String, dynamic> form,
    required Map<String, PlatformFile> files,
    ProgressCallback? progress,
    CancelToken? cancelToken,
    Map<String, dynamic>? query,
  }) async {
    try {
      for (final entry in files.entries) {
        final key = entry.key;
        final file = entry.value;
        final contentType = lookupMimeType(file.name) ?? 'application/octet-stream';
        form[key] = MultipartFile.fromBytes(
          file.bytes!,
          filename: file.name,
          contentType: MediaType.parse(contentType),
        );
      }

      final res = await _dio.put(
        route,
        data: FormData.fromMap(form),
        onSendProgress: progress,
        cancelToken: cancelToken,
        queryParameters: query,
      );
      return Data(res.data);
    } catch (err) {
      throw ApiException.fromErr(err);
    }
  }

  String get uri => _uri;
}

// ==========================================================
// EXCEPTION HANDLER
// ==========================================================
class ApiException implements Exception {
  final String message;
  final dynamic code;
  final dynamic raw;
  final ApiException? inner;

  ApiException(this.message, this.code, this.raw, [this.inner]);

  factory ApiException.fromData(Map<String, dynamic> data) {
    return ApiException(
      data['message'] ?? translate('anxeb.middleware.api.exception.internal_error'),
      data['code'] ?? 0,
      data,
    );
  }

  factory ApiException.fromErr(dynamic err) {
    if (err is DioException) {
      switch (err.type) {
        case DioExceptionType.connectionTimeout:
          return ApiException(
            translate('anxeb.middleware.api.exception.connect_timeout'),
            0,
            err,
          );
        case DioExceptionType.receiveTimeout:
          return ApiException(
            translate('anxeb.middleware.api.exception.receive_timeout'),
            408,
            err,
          );
        case DioExceptionType.sendTimeout:
          return ApiException(
            translate('anxeb.middleware.api.exception.send_timeout'),
            408,
            err,
          );
        case DioExceptionType.cancel:
          return ApiException(
            translate('anxeb.middleware.api.exception.user_cancelled'),
            408,
            err,
          );
        default:
          if (err.error is SocketException) {
            return ApiException(
              translate('anxeb.middleware.api.exception.socket_exception'),
              0,
              err,
            );
          }

          try {
            final data = err.response?.data;
            final status = data?['status'] ?? err.response?.statusCode;
            if (data != null && data is Map<String, dynamic>) {
              final inner = data['inner'] != null
                  ? ApiException.fromData(data['inner'])
                  : null;
              return _getStatusException(err, status: status, inner: inner) ??
                  ApiException(
                    data['message'] ??
                        translate('anxeb.middleware.api.exception.internal_error'),
                    status,
                    err,
                    inner,
                  );
            }
          } catch (_) {
            return _getStatusException(err) ??
                ApiException(
                  err.message ??
                      translate('anxeb.middleware.api.exception.internal_error'),
                  0,
                  err,
                );
          }
      }
    }

    return ApiException(
      translate('anxeb.middleware.api.exception.internal_error'),
      0,
      err,
    );
  }

  static ApiException? _getStatusException(
    DioException err, {
    dynamic status,
    ApiException? inner,
  }) {
    final statusCode = status?.toString();
    switch (statusCode) {
      case '400':
        return ApiException(
            translate('anxeb.middleware.api.exception.status_400'), 400, err, inner);
      case '401':
        return ApiException(
            translate('anxeb.middleware.api.exception.status_401'), 401, err, inner);
      case '402':
        return ApiException(
            translate('anxeb.middleware.api.exception.status_402'), 402, err, inner);
      case '403':
        return ApiException(
            translate('anxeb.middleware.api.exception.status_403'), 403, err, inner);
      case '404':
        return ApiException(
            translate('anxeb.middleware.api.exception.status_404'), 404, err, inner);
      case '405':
        return ApiException(
            translate('anxeb.middleware.api.exception.status_405'), 405, err, inner);
      case '408':
        return ApiException(
            translate('anxeb.middleware.api.exception.status_408'), 408, err, inner);
      case '500':
        return ApiException(
            translate('anxeb.middleware.api.exception.status_500'), 500, err, inner);
    }
    return null;
  }

  dynamic get meta {
    if (raw is DioException) {
      try {
        return (raw as DioException).response?.data?['meta'];
      } catch (_) {
        return null;
      }
    }
    if (raw is Map<String, dynamic>) {
      return raw['meta'];
    }
    return null;
  }

  @override
  String toString() => message;
}
