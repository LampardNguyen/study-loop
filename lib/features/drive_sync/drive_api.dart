import 'dart:io';

import 'package:dio/dio.dart';

import 'google_drive_auth.dart';

/// Drive appDataFolder 中的一个文件。
class DriveFile {
  const DriveFile({
    required this.id,
    required this.name,
    required this.size,
    this.modifiedTime,
  });

  final String id;
  final String name;
  final int size;
  final DateTime? modifiedTime;
}

/// 同步只用到的 Drive v3 操作；测试中替换为内存实现。
abstract class DriveApi {
  Future<List<DriveFile>> listFiles({CancelToken? cancelToken});

  /// 上传 [file]；[existingId] 不为空时覆盖该文件内容。
  Future<void> upload(
    String name,
    File file, {
    String? existingId,
    CancelToken? cancelToken,
    void Function(int sent, int total)? onProgress,
  });

  Future<void> download(
    String id,
    String targetPath, {
    CancelToken? cancelToken,
    void Function(int received, int total)? onProgress,
  });

  Future<void> delete(String id);
}

/// 基于 Dio 的 Drive REST v3 实现（不引入 googleapis 依赖）。
class DioDriveApi implements DriveApi {
  DioDriveApi(Future<String> Function() accessToken, {Dio? dio})
    : _dio = dio ?? Dio() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          try {
            options.headers['Authorization'] = 'Bearer ${await accessToken()}';
            handler.next(options);
          } catch (error) {
            handler.reject(DioException(requestOptions: options, error: error));
          }
        },
      ),
    );
  }

  static const _api = 'https://www.googleapis.com/drive/v3/files';
  static const _upload = 'https://www.googleapis.com/upload/drive/v3/files';

  final Dio _dio;

  @override
  Future<List<DriveFile>> listFiles({CancelToken? cancelToken}) async {
    final files = <DriveFile>[];
    String? pageToken;
    do {
      final response = await _dio.get<Map<String, dynamic>>(
        _api,
        queryParameters: {
          'spaces': 'appDataFolder',
          'pageSize': 1000,
          'fields': 'nextPageToken,files(id,name,size,modifiedTime)',
          if (pageToken != null) 'pageToken': pageToken,
        },
        cancelToken: cancelToken,
      );
      final data = response.data ?? const {};
      for (final raw in (data['files'] as List? ?? const [])) {
        final item = raw as Map<String, dynamic>;
        files.add(
          DriveFile(
            id: item['id'] as String,
            name: item['name'] as String,
            size: int.tryParse('${item['size'] ?? 0}') ?? 0,
            modifiedTime: DateTime.tryParse('${item['modifiedTime'] ?? ''}'),
          ),
        );
      }
      pageToken = data['nextPageToken'] as String?;
    } while (pageToken != null);
    return files;
  }

  @override
  Future<void> upload(
    String name,
    File file, {
    String? existingId,
    CancelToken? cancelToken,
    void Function(int sent, int total)? onProgress,
  }) async {
    final length = await file.length();
    // 断点续传协议：先建会话拿到上传地址，再流式发送文件内容，避免整文件进内存。
    final session = existingId == null
        ? await _dio.post<void>(
            _upload,
            queryParameters: {'uploadType': 'resumable'},
            data: {
              'name': name,
              'parents': ['appDataFolder'],
            },
            cancelToken: cancelToken,
          )
        : await _dio.patch<void>(
            '$_upload/$existingId',
            queryParameters: {'uploadType': 'resumable'},
            data: <String, dynamic>{},
            cancelToken: cancelToken,
          );
    final location = session.headers.value('location');
    if (location == null) {
      throw DioException(
        requestOptions: session.requestOptions,
        message: 'Missing resumable upload location',
      );
    }
    await _dio.put<void>(
      location,
      data: file.openRead(),
      options: Options(
        headers: {
          Headers.contentLengthHeader: length,
          Headers.contentTypeHeader: 'application/octet-stream',
        },
      ),
      cancelToken: cancelToken,
      onSendProgress: onProgress,
    );
  }

  @override
  Future<void> download(
    String id,
    String targetPath, {
    CancelToken? cancelToken,
    void Function(int received, int total)? onProgress,
  }) async {
    await _dio.download(
      '$_api/$id',
      targetPath,
      queryParameters: {'alt': 'media'},
      cancelToken: cancelToken,
      onReceiveProgress: onProgress,
    );
  }

  @override
  Future<void> delete(String id) => _dio.delete<void>('$_api/$id');
}

/// 将 Drive 请求错误归类，供界面显示对应提示。
enum DriveSyncFailure { authExpired, network, quotaExceeded, other }

DriveSyncFailure classifyDriveError(Object error) {
  if (error is DriveAuthExpiredException) return DriveSyncFailure.authExpired;
  if (error is DioException) {
    if (error.error is DriveAuthExpiredException) {
      return DriveSyncFailure.authExpired;
    }
    final status = error.response?.statusCode;
    if (status == 401) return DriveSyncFailure.authExpired;
    if (status == 403 && '${error.response?.data}'.contains('storageQuota')) {
      return DriveSyncFailure.quotaExceeded;
    }
    if (error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout ||
        error.error is SocketException) {
      return DriveSyncFailure.network;
    }
  }
  return DriveSyncFailure.other;
}
