// API_BASE_URL 配置全球 API 候选地址；实际区域由 RuntimeEndpointRouter 在运行时选择。

import 'package:flutter/foundation.dart' show kReleaseMode;

/// 全球生产 API 地址，可通过 `API_BASE_URL` 编译期变量覆盖。
///
/// 自托管版：默认**留空**（未配置）。原作者后端的所有功能（远程配置、精选播客、
/// 社区合集、版本检查、云端转录……）因此一律走「未配置」降级分支，不会向
/// echo-loop.top / echo-loop.cn 发出任何请求。AI 功能改为直连用户自己的 OpenAI Key。
const globalApiBaseUrl = String.fromEnvironment('API_BASE_URL');

/// 发布使用全球 API 候选地址；开发和测试默认使用本地地址，也允许覆盖。
const apiBaseUrl = kReleaseMode
    ? globalApiBaseUrl
    : String.fromEnvironment(
        'API_BASE_URL',
        defaultValue: 'http://localhost:3000',
      );

/// 是否配置了原作者后端 API（自托管版默认未配置）。
const isBackendApiConfigured = globalApiBaseUrl != '';

/// 自托管版（Study Loop）源码仓库。
const _selfHostRepoUrl = 'https://github.com/LampardNguyen/study-loop';

/// 自托管版的「社区 / 联系我们」入口：原作者后端未配置时改为打开本 fork 的主页。
///
/// 只在用户主动点击时由系统浏览器打开，App 自身不发请求。
Uri communityPageUri() => Uri.parse(_selfHostRepoUrl);

/// 设置页「查看源码」：指向本 fork（AGPL 要求可获取所分发版本的源码）。
Uri selfHostSourceUri() => Uri.parse(_selfHostRepoUrl);

/// 设置页「反馈」：改为本 fork 的 GitHub Issues，不再发邮件给原作者。
Uri selfHostFeedbackUri() => Uri.parse('$_selfHostRepoUrl/issues');
