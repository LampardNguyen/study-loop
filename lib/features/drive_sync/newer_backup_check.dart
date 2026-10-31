/// 启动 / 回前台时检查 Drive 上是否有来自其它设备的更新备份（self-host 新增）。
///
/// 只提示，不自动恢复：恢复是整体替换，会覆盖本机未备份的改动。
library;

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../l10n/app_localizations.dart';
import '../../router/app_router.dart';
import '../../services/app_logger.dart';
import 'drive_api.dart';
import 'drive_sync_marker.dart';
import 'drive_sync_service.dart';
import 'google_drive_auth.dart';

/// 两次检查的最短间隔
const _checkInterval = Duration(minutes: 15);

DateTime? _lastCheckAt;
bool _checking = false;

/// Drive 同步页是否打开（打开时不弹提示）。由 DriveSyncScreen 维护。
bool driveSyncScreenOpen = false;

/// 是否应提示 [remote] 这份备份。
@visibleForTesting
bool shouldOfferNewerBackup({
  required DriveMediaIndex? remote,
  required String myDeviceId,
  required DriveSyncMarker marker,
}) {
  if (remote == null) return false;
  // 旧版本备份没有设备 ID，无法区分是否本机，跳过。
  final from = remote.deviceId;
  if (from == null || from == myDeviceId) return false;
  final last = marker.lastSyncedAt;
  if (last != null && !remote.createdAt.isAfter(last)) return false;
  final dismissed = marker.dismissedAt;
  if (dismissed != null && !remote.createdAt.isAfter(dismissed)) return false;
  return true;
}

/// 本机是否有未备份的改动：从未同步过，或数据库与同步时不同。
@visibleForTesting
bool hasLocalChanges(DriveSyncMarker marker, String currentDbSha) =>
    marker.lastSyncedAt == null || marker.dbSha256 != currentDbSha;

/// 检查并按需弹出提示（Android、已登录 Drive 时）。失败静默。
Future<void> checkNewerDriveBackup(WidgetRef ref) async {
  if (kIsWeb || !Platform.isAndroid || _checking || driveSyncScreenOpen) {
    return;
  }
  final now = DateTime.now();
  final last = _lastCheckAt;
  if (last != null && now.difference(last) < _checkInterval) return;
  _checking = true;
  _lastCheckAt = now;
  try {
    final account = await ref.read(googleDriveAccountProvider.future);
    if (account == null) return;
    final auth = ref.read(googleDriveAuthProvider);
    final remote = await DriveSyncService(
      DioDriveApi(() => auth.accessToken(account)),
    ).fetchIndex();
    final marker = await readDriveSyncMarker();
    final myId = await driveDeviceId();
    final offer = shouldOfferNewerBackup(
      remote: remote,
      myDeviceId: myId,
      marker: marker,
    );
    AppLogger.log(
      'DriveSync',
      'newer_check remote=${remote?.createdAt} from=${remote?.deviceName} '
          'last=${marker.lastSyncedAt} offer=$offer',
    );
    if (!offer || driveSyncScreenOpen) return;
    final changed = hasLocalChanges(marker, await localDatabaseSha256());
    final context = rootNavigatorKey.currentContext;
    if (context == null || !context.mounted) return;
    final restore = await showNewerBackupDialog(
      context,
      deviceName: remote!.deviceName ?? '',
      createdAt: remote.createdAt,
      localChanges: changed,
      lastSyncedAt: marker.lastSyncedAt,
    );
    if (restore == true) {
      if (context.mounted) {
        context.push(AppRoutes.driveSync, extra: driveSyncAutoRestore);
      }
    } else {
      await dismissDriveBackup(remote.createdAt);
    }
  } catch (e) {
    AppLogger.log('DriveSync', 'newer_check_failed error=$e');
  } finally {
    _checking = false;
  }
}

/// 传给 DriveSyncScreen 路由的 extra：进入后自动开始恢复。
const driveSyncAutoRestore = 'autoRestore';

/// 提示对话框；返回 true 表示用户选择恢复。
@visibleForTesting
Future<bool?> showNewerBackupDialog(
  BuildContext context, {
  required String deviceName,
  required DateTime createdAt,
  required bool localChanges,
  DateTime? lastSyncedAt,
}) {
  final l10n = AppLocalizations.of(context)!;
  final format = DateFormat('HH:mm, dd/MM');
  final device = deviceName.isEmpty
      ? l10n.driveNewerBackupOtherDevice
      : deviceName;
  return showDialog<bool>(
    context: context,
    builder: (context) {
      final theme = Theme.of(context);
      final danger = theme.colorScheme.error;
      return AlertDialog(
        title: Text(l10n.driveNewerBackupTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.driveNewerBackupMessage(
                device,
                format.format(createdAt.toLocal()),
              ),
            ),
            const SizedBox(height: 12),
            if (localChanges)
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  lastSyncedAt == null
                      ? l10n.driveNewerBackupLocalNeverSynced
                      : l10n.driveNewerBackupLocalChanges(
                          format.format(lastSyncedAt.toLocal()),
                        ),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onErrorContainer,
                  ),
                ),
              )
            else
              Text(
                l10n.driveNewerBackupNote,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.driveNewerBackupLater),
          ),
          FilledButton(
            style: localChanges
                ? FilledButton.styleFrom(
                    backgroundColor: danger,
                    foregroundColor: theme.colorScheme.onError,
                  )
                : null,
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              localChanges
                  ? l10n.driveNewerBackupRestoreAnyway
                  : l10n.driveNewerBackupRestore,
            ),
          ),
        ],
      );
    },
  );
}
