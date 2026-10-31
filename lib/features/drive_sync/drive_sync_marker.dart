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
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/app_logger.dart';
import '../../utils/app_data_dir.dart';

const _deviceIdKey = 'drive_sync_device_id';
const _lastSyncedAtKey = 'drive_sync_last_synced_at';
const _lastSyncedDbShaKey = 'drive_sync_last_synced_db_sha';
const _dismissedBackupAtKey = 'drive_sync_dismissed_backup_at';

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
