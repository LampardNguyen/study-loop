/// 本机 Drive 同步标记（self-host 新增）。
///
/// - 设备 ID / 设备名：写入 Drive 索引，用于区分「本机」与「其它设备」的备份。
/// - 同步标记：最近一次备份/恢复的时间 + 当时本地数据库 sha256，
///   用于判断 Drive 上的备份是否更新、本机是否有未备份的改动。
///
/// key 均以 `drive_sync_` 开头，被备份黑名单排除，不会跨设备恢复。
library;

import 'dart:io';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/app_logger.dart';
import '../../utils/app_data_dir.dart';
import 'drive_sync_service.dart';

const _deviceIdKey = 'drive_sync_device_id';
const _lastSyncedAtKey = 'drive_sync_last_synced_at';
const _lastSyncedDbShaKey = 'drive_sync_last_synced_db_sha';
const _dismissedBackupAtKey = 'drive_sync_dismissed_backup_at';
const _lastBackupAtKey = 'drive_sync_last_backup_at';
const _lastBackupDeviceIdKey = 'drive_sync_last_backup_device_id';
const _lastBackupDeviceNameKey = 'drive_sync_last_backup_device_name';

const _deviceInfoChannel = MethodChannel('top.echo-loop/device_info');

/// 本机最近一次 Drive 同步（备份或恢复）的标记。
class DriveSyncMarker {
  const DriveSyncMarker({this.lastSyncedAt, this.dbSha256, this.dismissedAt});

  /// 最近一次同步对应的备份时间；null 表示本机从未同步过。
  final DateTime? lastSyncedAt;

  /// 同步当时的本地数据库 sha256。
  final String? dbSha256;

  /// 用户对哪一份备份（按创建时间）点过「以后再说」。
  final DateTime? dismissedAt;
}

/// 本机设备 ID（首次调用时随机生成并保存）。
Future<String> driveDeviceId() async {
  final prefs = await SharedPreferences.getInstance();
  final existing = prefs.getString(_deviceIdKey);
  if (existing != null && existing.isNotEmpty) return existing;
  final random = Random.secure();
  final id = List.generate(
    16,
    (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0'),
  ).join();
  await prefs.setString(_deviceIdKey, id);
  return id;
}

/// 设备名：厂商 + 型号（如「Samsung SM-N970F」），读取失败返回空串。
Future<String> driveDeviceName() async {
  try {
    final info = await _deviceInfoChannel.invokeMapMethod<String, Object?>(
      'getDeviceInfo',
    );
    final maker = (info?['manufacturer'] as String? ?? '').trim();
    final model = (info?['model'] as String? ?? '').trim();
    final brand = maker.isEmpty
        ? ''
        : '${maker[0].toUpperCase()}${maker.substring(1)}';
    if (model.toLowerCase().startsWith(maker.toLowerCase())) return model;
    return [brand, model].where((s) => s.isNotEmpty).join(' ');
  } catch (e) {
    AppLogger.log('DriveSync', 'device_name_failed error=$e');
    return '';
  }
}

/// 当前本地数据库文件的 sha256；文件不存在返回空串。
Future<String> localDatabaseSha256() async {
  final dir = await getAppDataDirectory();
  final file = File(p.join(dir.path, 'echo_loop.db'));
  if (!await file.exists()) return '';
  return (await sha256.bind(file.openRead()).first).toString();
}

/// 读取本机同步标记。
Future<DriveSyncMarker> readDriveSyncMarker() async {
  final prefs = await SharedPreferences.getInstance();
  return DriveSyncMarker(
    lastSyncedAt: DateTime.tryParse(prefs.getString(_lastSyncedAtKey) ?? ''),
    dbSha256: prefs.getString(_lastSyncedDbShaKey),
    dismissedAt: DateTime.tryParse(
      prefs.getString(_dismissedBackupAtKey) ?? '',
    ),
  );
}

/// 备份/恢复成功后记录同步标记（[backupCreatedAt] 为该备份的创建时间）。
Future<void> recordDriveSync(DateTime backupCreatedAt) async {
  final prefs = await SharedPreferences.getInstance();
  final dbSha = await localDatabaseSha256();
  await prefs.setString(
    _lastSyncedAtKey,
    backupCreatedAt.toUtc().toIso8601String(),
  );
  await prefs.setString(_lastSyncedDbShaKey, dbSha);
  AppLogger.log('DriveSync', 'marker_recorded at=$backupCreatedAt');
}

/// 记录用户对某份备份点了「以后再说」。
Future<void> dismissDriveBackup(DateTime backupCreatedAt) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(
    _dismissedBackupAtKey,
    backupCreatedAt.toUtc().toIso8601String(),
  );
}

/// Thông tin bản sao lưu gần nhất trên Drive đã biết (cache cục bộ, T15.10).
class LastDriveBackupInfo {
  const LastDriveBackupInfo({
    required this.createdAt,
    this.deviceName,
    this.isThisDevice = false,
  });

  final DateTime createdAt;

  /// Tên thiết bị tạo bản sao lưu; null với bản sao lưu cũ không ghi tên.
  final String? deviceName;

  /// Bản sao lưu được tạo từ chính máy này.
  final bool isThisDevice;
}

/// Lưu thông tin bản sao lưu gần nhất vào cache; [index] null (Drive trống) → xoá cache.
/// Không gọi mạng; người gọi tự `invalidate(lastDriveBackupProvider)`.
Future<void> cacheLastDriveBackup(DriveMediaIndex? index) async {
  final prefs = await SharedPreferences.getInstance();
  if (index == null) return clearLastDriveBackup();
  await prefs.setString(
    _lastBackupAtKey,
    index.createdAt.toUtc().toIso8601String(),
  );
  for (final (key, value) in [
    (_lastBackupDeviceIdKey, index.deviceId),
    (_lastBackupDeviceNameKey, index.deviceName),
  ]) {
    if (value == null || value.isEmpty) {
      await prefs.remove(key);
    } else {
      await prefs.setString(key, value);
    }
  }
}

/// Xoá cache bản sao lưu gần nhất (vd khi đăng xuất).
Future<void> clearLastDriveBackup() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove(_lastBackupAtKey);
  await prefs.remove(_lastBackupDeviceIdKey);
  await prefs.remove(_lastBackupDeviceNameKey);
}

/// Đọc cache bản sao lưu gần nhất cho tab Cá nhân (null = chưa biết).
final lastDriveBackupProvider = FutureProvider<LastDriveBackupInfo?>((
  ref,
) async {
  final prefs = await SharedPreferences.getInstance();
  final at = DateTime.tryParse(prefs.getString(_lastBackupAtKey) ?? '');
  if (at == null) return null;
  final id = prefs.getString(_lastBackupDeviceIdKey);
  return LastDriveBackupInfo(
    createdAt: at,
    deviceName: prefs.getString(_lastBackupDeviceNameKey),
    isThisDevice: id != null && id == prefs.getString(_deviceIdKey),
  );
});

/// Định dạng thời gian sao lưu: hôm nay → "[today] HH:mm", cùng năm → "dd/MM HH:mm",
/// khác năm → "dd/MM/yyyy".
String formatLastDriveBackupAt(DateTime at, DateTime now, String today) {
  final local = at.toLocal();
  String two(int v) => v.toString().padLeft(2, '0');
  final time = '${two(local.hour)}:${two(local.minute)}';
  if (local.year == now.year &&
      local.month == now.month &&
      local.day == now.day) {
    return '$today $time';
  }
  final date = '${two(local.day)}/${two(local.month)}';
  if (local.year == now.year) return '$date $time';
  return '$date/${local.year}';
}
