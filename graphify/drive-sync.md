# Sao lưu / Khôi phục Google Drive (drive-sync)

## File chính
- `lib/features/drive_sync/drive_sync_screen.dart` — màn Đồng bộ (nút Sao lưu / Khôi phục).
- `lib/features/drive_sync/drive_sync_actions.dart` — `performDriveRestore` tải bản sao lưu về rồi gọi `performImport`.
- `lib/features/drive_sync/drive_sync_service.dart` — upload/download trên Drive appDataFolder: `backup.zip` + từng file audio/phụ đề `media-<sha256>` (bỏ qua file đã có) + `backup-index.json`.
- `lib/services/backup/backup_service.dart` — đóng gói zip: DB `echo_loop.db` + `settings.json` (đổ **toàn bộ SharedPreferences**, trừ `_spBlacklist` / `_spPrefixBlacklist`).
- `lib/providers/backup_provider.dart` — `performImport`: áp dụng bản sao lưu, đổi DB, nạp lại provider.

## Những gì được sao lưu
- Mọi cài đặt lưu trong SharedPreferences: cài đặt học tập, ghi âm ([[recording]]), TTS, nghe chép, nhắc nhở, từ điển, ngôn ngữ/giao diện…
- Không sao lưu (cố ý): `demo_mode`, `anonymous_id`, `app_update_*`, phiên Supabase, `drive_sync_*`, `selfhost.ai_*`.
- Không sao lưu: cấu hình AI (`AiProviderConfig`: apiKey + baseUrl + model) vì nằm trong `flutter_secure_storage` (`ai_settings_repository.dart`). Key không sync là cố ý; baseUrl/model mất theo.
- Không sao lưu: model tải về (từ điển, ASR, Piper/Kokoro) — tải lại được.

## Bẫy: nạp lại sau khi khôi phục (phát hiện 2026-10-31)
`performImport` chỉ `invalidate` các provider DB + `appSettingsProvider` + `dictionaryProvider`.
Các Notifier đọc SharedPreferences một lần lúc khởi động (vd `learningSettingsProvider` dùng snapshot `initialLearningSettingsProvider` được override cố định trong `main.dart`, `recordingSettingsNotifierProvider`, `ttsSettings`, `reminderSettings`, `*_prefs_provider`…) giữ giá trị cũ trong bộ nhớ. Chỉ `invalidate` thì không đủ, vì app sẽ đọc lại đúng snapshot cũ.
**Cách xử lý (T14.13):** khôi phục Drive thành công → `showRestoreDoneDialog` → `appRestarterProvider` → native `restartApp` (kênh `top.echo-loop/app_update`, `MainActivity.restartApp`) khởi động lại tiến trình. Khôi phục từ file cục bộ (`backup_restore_screen.dart`) chưa làm như vậy.

## Báo bản sao lưu mới hơn từ máy khác (T14.14)
- `drive_sync_marker.dart`: `driveDeviceId()` (ngẫu nhiên, prefs `drive_sync_device_id`), `driveDeviceName()` (kênh `top.echo-loop/device_info`), mốc `drive_sync_last_synced_at` + `drive_sync_last_synced_db_sha` (ghi trong `performDriveBackup` / `performDriveRestore`), `drive_sync_dismissed_backup_at` (nút "Để sau"). Tất cả có tiền tố `drive_sync_` nên không bị sao lưu.
- `backup-index.json` có thêm `deviceId`/`deviceName`. Bản sao lưu cũ không có hai trường này → bỏ qua.
- `newer_backup_check.dart`: `checkNewerDriveBackup(ref)` chạy từ `main.dart` (mở app sau 5s, khi resumed; giới hạn 15 phút; không chạy khi `driveSyncScreenOpen`). Điều kiện hiện: `shouldOfferNewerBackup`. "Có thay đổi" = `hasLocalChanges` (chưa từng đồng bộ hoặc sha DB khác) → có thể báo thừa.
- Bấm Khôi phục → `context.push(AppRoutes.driveSync, extra: driveSyncAutoRestore)` → `DriveSyncScreen(autoRestore: true)` tự chạy khôi phục.

## Liên quan
- [[index]] · [[settings-screen]] · [[recording]]
