import 'api_config.dart';

/// 全球模型与离线资源 CDN 地址。
///
/// 自托管版：可通过 `MODEL_CDN_BASE_URL` 编译期变量改为自己的存储（R2 / GitHub
/// Releases 等，目录结构需与原 CDN 一致，见 `docs/selfhost/README.md`）。
/// 默认仍用原作者 CDN：只下载公开的模型 / 词典静态文件，不携带任何用户数据。
const globalModelCdnBaseUrl = String.fromEnvironment(
  'MODEL_CDN_BASE_URL',
  defaultValue: 'https://cdn.echo-loop.top',
);

/// 中国 API 与模型 CDN 地址；与全球地址一起编入同一个发布包。
/// 中国 API 可通过 `API_CHINA_BASE_URL` 编译期变量覆盖；自托管版默认留空（未配置）。
const chinaApiBaseUrl = String.fromEnvironment('API_CHINA_BASE_URL');
const chinaModelCdnBaseUrl = 'https://cdn.echo-loop.cn/';

class RegionalServiceEndpoints {
  const RegionalServiceEndpoints({
    required this.globalApiBaseUrl,
    required this.chinaApiBaseUrl,
    required this.globalModelCdnBaseUrl,
    required this.chinaModelCdnBaseUrl,
  });

  final String globalApiBaseUrl;
  final String chinaApiBaseUrl;
  final String globalModelCdnBaseUrl;
  final String chinaModelCdnBaseUrl;

  String? apiBaseUrlFor(ServiceEndpointRegion region) =>
      _configuredUrl(switch (region) {
        ServiceEndpointRegion.global => globalApiBaseUrl,
        ServiceEndpointRegion.china => chinaApiBaseUrl,
      });

  String? modelCdnBaseUrlFor(ServiceEndpointRegion region) =>
      _configuredUrl(switch (region) {
        ServiceEndpointRegion.global => globalModelCdnBaseUrl,
        ServiceEndpointRegion.china => chinaModelCdnBaseUrl,
      });

  static String? _configuredUrl(String value) {
    final normalized = value.trim();
    if (normalized.isEmpty) return null;
    final uri = Uri.tryParse(normalized);
    if (uri == null || !uri.hasAuthority || uri.host.isEmpty) return null;
    if (uri.scheme != 'http' && uri.scheme != 'https') return null;
    return normalized.endsWith('/')
        ? normalized.substring(0, normalized.length - 1)
        : normalized;
  }
}

enum ServiceEndpointRegion { global, china }

const regionalServiceEndpoints = RegionalServiceEndpoints(
  globalApiBaseUrl: apiBaseUrl,
  chinaApiBaseUrl: chinaApiBaseUrl,
  globalModelCdnBaseUrl: globalModelCdnBaseUrl,
  chinaModelCdnBaseUrl: chinaModelCdnBaseUrl,
);
