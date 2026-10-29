import 'package:echo_loop/features/drive_sync/google_drive_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  Future<String?> read() async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    return container.read(driveSyncSignedInEmailProvider.future);
  }

  test('未登录返回 null', () async {
    SharedPreferences.setMockInitialValues({});
    expect(await read(), isNull);
  });

  test('已登录返回缓存邮箱', () async {
    SharedPreferences.setMockInitialValues({
      'drive_sync_signed_in': true,
      'drive_sync_signed_in_email': 'a@gmail.com',
    });
    expect(await read(), 'a@gmail.com');
  });

  test('旧版本已登录但无缓存邮箱返回空串', () async {
    SharedPreferences.setMockInitialValues({'drive_sync_signed_in': true});
    expect(await read(), '');
  });
}
