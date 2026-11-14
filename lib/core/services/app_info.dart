import 'package:flutter/services.dart';

/// The two Android-only Settings actions; no networking or WebView in the app.
class AppInfo {
  static const privacyUrl =
      'https://ahmedhassan-ai-dev.github.io/pass-the-phone-eg/privacy/';
  static const channel = MethodChannel('com.ahmedhassan.passthephone/app_info');

  static Future<String?> versionLabel() async {
    try {
      final info = await channel.invokeMapMethod<String, dynamic>('version');
      final version = info?['version'];
      final build = info?['build'];
      if (version is String && version.isNotEmpty && build is int) {
        return '$version ($build)';
      }
    } on PlatformException {
      // Keep Settings usable if package information is unavailable.
    } on MissingPluginException {
      // Non-Android previews have no package bridge.
    }
    return null;
  }

  static Future<bool> openPrivacyPolicy() async {
    try {
      return await channel.invokeMethod<bool>('privacy') ?? false;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }
}
