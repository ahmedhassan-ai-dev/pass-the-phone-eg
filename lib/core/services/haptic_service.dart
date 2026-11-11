import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Optional, action-only feedback. Reads the current setting on every request.
class HapticService {
  static const channel = MethodChannel('com.ahmedhassan.passthephone/haptics');
  static const cooldown = Duration(milliseconds: 120);
  final bool Function() _isEnabled;
  final Duration Function()? _elapsed;
  final Stopwatch _clock = Stopwatch()..start();
  Duration? _lastPulse;

  HapticService({
    required bool Function() isEnabled,
    Duration Function()? elapsed,
  }) : _isEnabled = isEnabled,
       _elapsed = elapsed;

  Future<void> selection() => _emit(20, HapticFeedback.lightImpact);
  Future<void> gameStart() => _emit(30, HapticFeedback.lightImpact);
  Future<void> passPhone() => _emit(50, HapticFeedback.mediumImpact);
  Future<void> revealQuestion() => _emit(30, HapticFeedback.lightImpact);

  Future<void> _emit(int durationMs, Future<void> Function() fallback) async {
    if (!_isEnabled()) return;
    final now = _elapsed?.call() ?? _clock.elapsed;
    if (_lastPulse != null && now - _lastPulse! < cooldown) return;
    // Drop bursts, never queue or retry pulses after the setting changes.
    _lastPulse = now;
    try {
      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
        await channel.invokeMethod<bool>('pulse', {
          'enabled': true,
          'durationMs': durationMs,
        });
      } else {
        await fallback();
      }
    } on PlatformException {
      // Optional feedback must not interrupt play on an unsupported platform.
    } on MissingPluginException {
      // Some platforms have no haptic implementation.
    }
  }
}
