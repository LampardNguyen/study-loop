import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../config/auth_config.dart' as auth_config;
import '../../services/app_logger.dart';

/// 仅访问应用在 Drive 中的隐藏数据目录（appDataFolder）。
const driveAppDataScope = 'https://www.googleapis.com/auth/drive.appdata';

/// Google 授权失效或未授予 Drive 权限，需要用户重新登录。
class DriveAuthExpiredException implements Exception {
  const DriveAuthExpiredException();

  @override
  String toString() => 'DriveAuthExpiredException';
}

/// 构建期未注入 `GOOGLE_WEB_CLIENT_ID`。
class DriveAuthNotConfiguredException implements Exception {
  const DriveAuthNotConfiguredException();

  @override
  String toString() => 'DriveAuthNotConfiguredException';
}

/// Google 登录（仅用于 Drive 同步）。
///
/// OAuth 客户端 ID 只在构建时通过 `--dart-define-from-file` 注入，代码中不保存。
class GoogleDriveAuth {
  GoogleDriveAuth({GoogleSignIn? googleSignIn})
    : _googleSignIn = googleSignIn ?? GoogleSignIn.instance;

  final GoogleSignIn _googleSignIn;
  Future<void>? _initializeFuture;

  Future<void> _initialize() {
    final clientId = auth_config.googleWebClientId;
    if (clientId.isEmpty) throw const DriveAuthNotConfiguredException();
    return _initializeFuture ??= _googleSignIn.initialize(
      serverClientId: clientId,
    );
  }

  /// 静默恢复上次登录的账号，没有则返回 null。
  Future<GoogleSignInAccount?> restore() async {
    if (auth_config.googleWebClientId.isEmpty) return null;
    await _initialize();
    return await _googleSignIn.attemptLightweightAuthentication();
  }

  /// 交互式登录并申请 Drive appDataFolder 权限。
  Future<GoogleSignInAccount> signIn() async {
    await _initialize();
    try {
      final account = await _googleSignIn.authenticate(
        scopeHint: const [driveAppDataScope],
      );
      AppLogger.log('DriveSync', 'authenticate_success');
      await account.authorizationClient.authorizeScopes(const [
        driveAppDataScope,
      ]);
      AppLogger.log('DriveSync', 'sign_in_success');
      return account;
    } on GoogleSignInException catch (error) {
      AppLogger.log(
        'DriveSync',
        'sign_in_failed code=${error.code} '
            'description=${error.description} details=${error.details}',
      );
      rethrow;
    }
  }

  /// 退出并撤销 Drive 授权（Google API 用户数据政策要求可撤销访问）。
  Future<void> signOut() async {
    await _initialize();
    try {
      await _googleSignIn.disconnect();
    } catch (error) {
      // Play services 偶发 revokeAccess 失败（如 [28404]），仍需本地退出；
      // 用户可在 Google 账号权限页手动撤销。
      AppLogger.log('DriveSync', 'disconnect_failed error=$error');
      await _googleSignIn.signOut();
    }
  }

  /// 获取访问 Drive 的 access token（SDK 自行缓存与刷新）。
  Future<String> accessToken(GoogleSignInAccount account) async {
    final authorization = await account.authorizationClient
        .authorizationForScopes(const [driveAppDataScope]);
    final token = authorization?.accessToken;
    if (token == null || token.isEmpty) {
      throw const DriveAuthExpiredException();
    }
    return token;
  }
}

final googleDriveAuthProvider = Provider<GoogleDriveAuth>(
  (ref) => GoogleDriveAuth(),
);

/// 是否曾登录：未登录时不尝试静默恢复，避免打开设置页就弹出账号选择界面。
const _signedInKey = 'drive_sync_signed_in';

/// 上次登录账号的邮箱，供设置页展示，避免为显示邮箱而触发 Google 静默登录界面。
const _signedInEmailKey = 'drive_sync_signed_in_email';

/// 设置页展示用的登录状态：未登录为 null；已登录但未缓存邮箱（旧版本登录）为空串。
final driveSyncSignedInEmailProvider = FutureProvider<String?>((ref) async {
  final preferences = await SharedPreferences.getInstance();
  if (preferences.getBool(_signedInKey) != true) return null;
  return preferences.getString(_signedInEmailKey) ?? '';
});

Future<void> _cacheEmail(Ref ref, String email) async {
  await (await SharedPreferences.getInstance()).setString(
    _signedInEmailKey,
    email,
  );
  ref.invalidate(driveSyncSignedInEmailProvider);
}

/// 当前登录的 Google 账号（null 表示未登录）。
class GoogleDriveAccountNotifier extends AsyncNotifier<GoogleSignInAccount?> {
  @override
  Future<GoogleSignInAccount?> build() async {
    final preferences = await SharedPreferences.getInstance();
    if (preferences.getBool(_signedInKey) != true) return null;
    try {
      final account = await ref.read(googleDriveAuthProvider).restore();
      if (account != null) await _cacheEmail(ref, account.email);
      return account;
    } catch (error) {
      AppLogger.log('DriveSync', 'restore_failed error=$error');
      return null;
    }
  }

  Future<void> signIn() async {
    final account = await ref.read(googleDriveAuthProvider).signIn();
    await (await SharedPreferences.getInstance()).setBool(_signedInKey, true);
    await _cacheEmail(ref, account.email);
    state = AsyncData(account);
  }

  Future<void> signOut() async {
    await ref.read(googleDriveAuthProvider).signOut();
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_signedInKey);
    await preferences.remove(_signedInEmailKey);
    ref.invalidate(driveSyncSignedInEmailProvider);
    state = const AsyncData(null);
  }
}

final googleDriveAccountProvider =
    AsyncNotifierProvider<GoogleDriveAccountNotifier, GoogleSignInAccount?>(
      GoogleDriveAccountNotifier.new,
    );
