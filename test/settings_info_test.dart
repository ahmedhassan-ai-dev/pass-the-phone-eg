import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pass_the_phone/app/app.dart';
import 'package:pass_the_phone/core/services/app_info.dart';
import 'package:pass_the_phone/core/services/app_store.dart';
import 'package:pass_the_phone/features/settings/settings_screen.dart';
import 'app_store_upgrade_test.dart' show MemoryPreferences;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  tearDown(
    () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(AppInfo.channel, null),
  );

  test(
    'version is installed metadata and privacy requests only the fixed native action',
    () async {
      final calls = <MethodCall>[];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(AppInfo.channel, (call) async {
            calls.add(call);
            return call.method == 'version'
                ? {'version': '0.8.0', 'build': 8}
                : true;
          });
      expect(await AppInfo.versionLabel(), '0.8.0 (8)');
      expect(await AppInfo.openPrivacyPolicy(), isTrue);
      expect(calls.map((c) => c.method), ['version', 'privacy']);
      expect(calls.last.arguments, isNull);
    },
  );

  test('platform errors and absent bridge are safe', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          AppInfo.channel,
          (_) async => throw PlatformException(code: 'unavailable'),
        );
    expect(await AppInfo.versionLabel(), isNull);
    expect(await AppInfo.openPrivacyPolicy(), isFalse);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(AppInfo.channel, null);
    expect(await AppInfo.versionLabel(), isNull);
    expect(await AppInfo.openPrivacyPolicy(), isFalse);
  });

  for (final available in [true, false]) {
    testWidgets(
      'Settings displays actual version; browser available=$available',
      (tester) async {
        final methods = <String>[];
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(AppInfo.channel, (call) async {
              methods.add(call.method);
              return call.method == 'version'
                  ? {'version': '0.8.0', 'build': 8}
                  : available;
            });
        final store = AppStore(preferences: MemoryPreferences({}));
        await tester.runAsync(store.load);
        await tester.pumpWidget(PassThePhoneApp(store: store));
        await tester.tap(find.byTooltip('الإعدادات'));
        await tester.pumpAndSettle();
        expect(find.byType(SettingsScreen), findsOneWidget);
        await tester.scrollUntilVisible(find.text('سياسة الخصوصية'), 300);
        await tester.tap(find.text('سياسة الخصوصية'));
        await tester.pumpAndSettle();
        expect(methods, contains('privacy'));
        if (!available) expect(find.text('نسخ الرابط'), findsOneWidget);
        await tester.ensureVisible(find.text('Pass The Phone · 0.8.0 (8)'));
        expect(find.text('Pass The Phone · 0.8.0 (8)'), findsOneWidget);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
        store.dispose();
      },
    );
  }

  testWidgets(
    'privacy copy fallback writes the exact policy URL to clipboard',
    (tester) async {
      const policyUrl =
          'https://ahmedhassan-ai-dev.github.io/pass-the-phone-eg/privacy/';
      final messenger =
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
      final clipboardWrites = <Object?>[];
      messenger.setMockMethodCallHandler(AppInfo.channel, (call) async {
        return call.method == 'version'
            ? {'version': '0.8.0', 'build': 8}
            : false;
      });
      messenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
        if (call.method == 'Clipboard.setData') {
          clipboardWrites.add(call.arguments);
        }
        return null;
      });
      addTearDown(
        () => messenger.setMockMethodCallHandler(SystemChannels.platform, null),
      );
      final store = AppStore(preferences: MemoryPreferences({}));
      await tester.runAsync(store.load);
      await tester.pumpWidget(PassThePhoneApp(store: store));
      await tester.tap(find.byTooltip('الإعدادات'));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('سياسة الخصوصية'), 300);
      await tester.tap(find.text('سياسة الخصوصية'));
      await tester.pumpAndSettle();
      expect(clipboardWrites, isEmpty);
      await tester.tap(find.text('نسخ الرابط'));
      await tester.pumpAndSettle();
      expect(clipboardWrites, [
        <String, dynamic>{'text': policyUrl},
      ]);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      store.dispose();
    },
  );
}
