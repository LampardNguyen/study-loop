import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';

import '../../l10n/app_localizations.dart';
import '../../services/app_logger.dart';
import '../../services/backup/backup_progress.dart';
import '../../services/backup/backup_service.dart';
import '../../utils/file_size.dart';
import 'drive_api.dart';
import 'drive_sync_actions.dart';
import 'drive_sync_service.dart';
import 'google_drive_auth.dart';
import 'google_sign_in_button.dart';

/// Google Drive 同步页：登录、手动备份与恢复。
class DriveSyncScreen extends ConsumerStatefulWidget {
  const DriveSyncScreen({super.key});

  @override
  ConsumerState<DriveSyncScreen> createState() => _DriveSyncScreenState();
}

class _DriveSyncScreenState extends ConsumerState<DriveSyncScreen> {
  bool _restoring = false;
  bool _signingIn = false;
  BackupProgress? _progress;
  CancelToken? _cancelToken;
  Object? _error;

  bool get _busy => _cancelToken != null;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final account = ref.watch(googleDriveAccountProvider);
    return PopScope(
      canPop: !_busy,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmCancel(l10n);
      },
      child: Scaffold(
        appBar: AppBar(title: Text(l10n.driveSync)),
        body: account.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => _buildSignedOut(l10n),
          data: (value) => value == null
              ? _buildSignedOut(l10n)
              : _buildSignedIn(l10n, value),
        ),
      ),
    );
  }

  Widget _buildSignedOut(AppLocalizations l10n) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Icon(Icons.cloud_outlined, size: 64),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.driveSyncIntro),
                const SizedBox(height: 8),
                _keyNotice(l10n),
              ],
            ),
          ),
        ),
        if (_error != null) _buildError(l10n),
        const SizedBox(height: 16),
        GoogleSignInButton(
          label: l10n.driveSyncSignIn,
          loading: _signingIn,
          onPressed: () => _signIn(l10n),
        ),
      ],
    );
  }

  Widget _buildSignedIn(AppLocalizations l10n, GoogleSignInAccount account) {
    final index = ref.watch(driveBackupIndexProvider(account));
    final hasBackup = index.valueOrNull != null;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage: account.photoUrl == null
                  ? null
                  : NetworkImage(account.photoUrl!),
              child: account.photoUrl == null ? const Icon(Icons.person) : null,
            ),
            title: Text(account.displayName ?? account.email),
            subtitle: Text(account.email),
            trailing: TextButton(
              onPressed: _busy ? null : _signOut,
              child: Text(l10n.driveSyncSignOut),
            ),
          ),
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: _busy ? _buildProgress(l10n) : _buildBackupInfo(l10n, index),
          ),
        ),
        if (_error != null) _buildError(l10n),
        const SizedBox(height: 16),
        if (_busy)
          OutlinedButton(
            onPressed: () => _cancelToken?.cancel(),
            child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
          )
        else ...[
          FilledButton(
            onPressed: () => _backup(l10n, account),
            child: Text(l10n.driveSyncBackupNow),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: hasBackup
                ? () => _restore(l10n, account, index.value!)
                : null,
            child: Text(l10n.driveSyncRestore),
          ),
        ],
        const SizedBox(height: 12),
        _keyNotice(l10n),
      ],
    );
  }

  Widget _buildBackupInfo(
    AppLocalizations l10n,
    AsyncValue<DriveMediaIndex?> index,
  ) {
    return index.when(
      loading: () => const LinearProgressIndicator(),
      error: (error, _) => Text(_errorText(l10n, error)),
      data: (value) {
        if (value == null) return Text(l10n.driveSyncNoBackup);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.driveSyncLastBackup,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 4),
            Text(_formatDate(value.createdAt)),
            Text(
              l10n.driveSyncBackupSummary(
                value.files.length,
                formatBytes(value.totalBytes),
              ),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        );
      },
    );
  }

  Widget _buildProgress(AppLocalizations l10n) {
    final progress = _progress;
    final value = progress?.progress ?? -1;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _restoring ? l10n.driveSyncRestoring : l10n.driveSyncBackingUp,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(value: value >= 0 && value <= 1 ? value : null),
        const SizedBox(height: 8),
        Text(
          _stageText(l10n, progress?.stage),
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildError(AppLocalizations l10n) {
    final colors = Theme.of(context).colorScheme;
    final authExpired =
        classifyDriveError(_error!) == DriveSyncFailure.authExpired;
    return Card(
      color: colors.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _errorText(l10n, _error!),
              style: TextStyle(color: colors.onErrorContainer),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.driveSyncDataUnchanged,
              style: TextStyle(color: colors.onErrorContainer),
            ),
            if (authExpired) ...[
              const SizedBox(height: 8),
              GoogleSignInButton(
                label: l10n.driveSyncSignInAgain,
                loading: _signingIn,
                onPressed: () => _signIn(l10n),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _keyNotice(AppLocalizations l10n) => Text(
    l10n.driveSyncKeyNotice,
    style: Theme.of(context).textTheme.bodySmall,
  );

  String _formatDate(DateTime value) =>
      DateFormat.yMd().add_Hm().format(value.toLocal());

  String _stageText(AppLocalizations l10n, String? stage) {
    if (stage == null) return l10n.driveSyncStepPreparing;
    final parts = stage.split(':');
    return switch (parts.first) {
      'driveHashing' => l10n.driveSyncStepHashing,
      'driveUploadingMedia' => l10n.driveSyncStepUploadingMedia(parts.last),
      'driveDownloadingMedia' => l10n.driveSyncStepDownloadingMedia(parts.last),
      'driveUploadingBackup' => l10n.driveSyncStepUploadingBackup,
      'driveDownloadingBackup' => l10n.driveSyncStepDownloadingBackup,
      final value when value.startsWith('importing') =>
        l10n.driveSyncStepApplying,
      _ => l10n.driveSyncStepPreparing,
    };
  }

  String _errorText(AppLocalizations l10n, Object error) {
    if (error is DriveAuthNotConfiguredException) {
      return l10n.driveSyncErrorNotConfigured;
    }
    if (error is DriveBackupMismatchException) {
      return l10n.driveSyncErrorMismatch;
    }
    if (error is BackupException &&
        (error.code == BackupFailureCode.incompatibleVersion ||
            error.code == BackupFailureCode.unsupportedVersion)) {
      return l10n.driveSyncErrorVersion;
    }
    return switch (classifyDriveError(error)) {
      DriveSyncFailure.authExpired => l10n.driveSyncErrorAuth,
      DriveSyncFailure.network => l10n.driveSyncErrorNetwork,
      DriveSyncFailure.quotaExceeded => l10n.driveSyncErrorQuota,
      DriveSyncFailure.other => l10n.driveSyncErrorGeneric('$error'),
    };
  }

  Future<void> _signIn(AppLocalizations l10n) async {
    setState(() {
      _error = null;
      _signingIn = true;
    });
    try {
      await ref.read(googleDriveAccountProvider.notifier).signIn();
    } on GoogleSignInException catch (error) {
      if (error.code == GoogleSignInExceptionCode.canceled) return;
      if (mounted) setState(() => _error = error);
    } catch (error) {
      if (mounted) setState(() => _error = error);
    } finally {
      if (mounted) setState(() => _signingIn = false);
    }
  }

  Future<void> _signOut() async {
    setState(() => _error = null);
    await ref.read(googleDriveAccountProvider.notifier).signOut();
  }

  Future<void> _backup(
    AppLocalizations l10n,
    GoogleSignInAccount account,
  ) async {
    await _run(
      restoring: false,
      action: (onProgress, token) => performDriveBackup(
        ref,
        account,
        onProgress: onProgress,
        cancelToken: token,
      ),
      successMessage: l10n.driveSyncBackupDone,
      account: account,
    );
  }

  Future<void> _restore(
    AppLocalizations l10n,
    GoogleSignInAccount account,
    DriveMediaIndex index,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.driveSyncRestoreTitle),
        content: Text(
          l10n.driveSyncRestoreConfirm(
            _formatDate(index.createdAt),
            index.files.length,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.driveSyncRestoreAction),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await _run(
      restoring: true,
      action: (onProgress, token) => performDriveRestore(
        ref,
        account,
        onProgress: onProgress,
        cancelToken: token,
      ),
      successMessage: l10n.driveSyncRestoreDone,
      account: account,
    );
  }

  Future<void> _run({
    required bool restoring,
    required Future<Object?> Function(
      void Function(BackupProgress) onProgress,
      CancelToken token,
    )
    action,
    required String successMessage,
    required GoogleSignInAccount account,
  }) async {
    final token = CancelToken();
    setState(() {
      _restoring = restoring;
      _progress = null;
      _error = null;
      _cancelToken = token;
    });
    try {
      await action((value) {
        if (mounted) setState(() => _progress = value);
      }, token);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(successMessage)));
    } catch (error) {
      AppLogger.log('DriveSync', 'operation_failed error=$error');
      final cancelled = error is DioException && CancelToken.isCancel(error);
      if (mounted && !cancelled) setState(() => _error = error);
    } finally {
      if (mounted) {
        setState(() => _cancelToken = null);
        ref.invalidate(driveBackupIndexProvider(account));
      }
    }
  }

  Future<void> _confirmCancel(AppLocalizations l10n) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(l10n.driveSyncCancelConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(MaterialLocalizations.of(context).closeButtonLabel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(MaterialLocalizations.of(context).okButtonLabel),
          ),
        ],
      ),
    );
    if (confirmed == true) _cancelToken?.cancel();
  }
}
