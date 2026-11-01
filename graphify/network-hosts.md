# Host mạng của bản self-host

**Mục đích:** biết app gọi ra ngoài tới đâu (CLAUDE.local.md §4).

| Chức năng | Host | Ghi chú |
|---|---|---|
| API gốc (remote config, podcast nổi bật, cộng đồng…) | `API_BASE_URL` — rỗng ở release | `lib/config/api_config.dart`; debug mặc định `http://localhost:3000`. Remote config chỉ chạy khi `backendApiConfiguredProvider` = true (`lib/router/main_shell.dart`). |
| CDN model / từ điển offline | `MODEL_CDN_BASE_URL`, mặc định `https://cdn.echo-loop.top` | `lib/config/regional_service_endpoints.dart`; chỉ tải file công khai. |
| AI (chat, TTS, chép lời) | OpenAI, key người dùng | |
| Cập nhật app | GitHub Releases | `lib/services/app_update_checker.dart` |
| Đồng bộ | Google Drive appDataFolder | [[drive-sync]] |
| Link điều khoản / đăng nhập | `www.echo-loop.top` | Chỉ mở trình duyệt khi người dùng bấm. |

## Liên quan
- [[drive-sync]]
