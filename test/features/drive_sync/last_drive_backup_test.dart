import 'package:echo_loop/features/drive_sync/drive_sync_marker.dart';
import 'package:echo_loop/features/drive_sync/drive_sync_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

DriveMediaIndex _index({String? id, String? name}) => DriveMediaIndex(
  dbSha256: 'x',
  createdAt: DateTime.utc(2026, 11, 5, 7, 32),
  appVersion: '1',
  files: const {},
  deviceId: id,
  deviceName: name,
);

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<LastDriveBackupInfo?> read() async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    return c.read(lastDriveBackupProvider.future);
  }

  test('chưa có cache → null', () async {
    expect(await read(), isNull);
  });

  test('lưu tên máy, nhận ra máy này', () async {
    final myId = await driveDeviceId();
    await cacheLastDriveBackup(_index(id: myId, name: 'Pixel 9 Pro'));
    final info = await read();
    expect(info!.deviceName, 'Pixel 9 Pro');
    expect(info.isThisDevice, isTrue);
    expect(info.createdAt, DateTime.utc(2026, 11, 5, 7, 32));
  });

  test('máy khác / bản cũ không tên / xoá cache', () async {
    await driveDeviceId();
    await cacheLastDriveBackup(_index(id: 'other', name: 'Samsung A'));
    expect((await read())!.isThisDevice, isFalse);
    await cacheLastDriveBackup(_index());
    expect((await read())!.deviceName, isNull);
    await cacheLastDriveBackup(null);
    expect(await read(), isNull);
  });

  test('định dạng thời gian', () {
    final now = DateTime(2026, 11, 5, 20);
    expect(
      formatLastDriveBackupAt(DateTime(2026, 11, 5, 14, 32), now, 'hôm nay'),
      'hôm nay 14:32',
    );
    expect(
      formatLastDriveBackupAt(DateTime(2026, 11, 4, 9, 5), now, 'hôm nay'),
      '04/11 09:05',
    );
    expect(
      formatLastDriveBackupAt(DateTime(2025, 1, 2, 9, 5), now, 'hôm nay'),
      '02/01/2025',
    );
  });
}
