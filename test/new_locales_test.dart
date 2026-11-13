import 'package:cloudflare_dns/core/app_language.dart';
import 'package:cloudflare_dns/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  for (final code in ['de', 'ar', 'hi', 'ko']) {
    test('supports $code in system detection and saved selection', () {
      expect(
        AppLocalizations.supportedLocales.any(
          (locale) => locale.languageCode == code,
        ),
        isTrue,
      );
      expect(AppLanguageController.fromStorageValue(code), Locale(code));
      expect(
        AppLocalizations.textForLocale('settings', Locale(code)),
        isNot('Settings'),
      );
      expect(
        AppLocalizations.textForLocale(
          'updateAvailableMessage',
          Locale(code),
          values: {'version': '2.2.0'},
        ),
        contains('2.2.0'),
      );
    });

    test('bundles the $code version history', () async {
      final history =
          await rootBundle.loadString('assets/changelog/CHANGELOG_$code.md');
      expect(history, contains('## [2.1.0]'));
      expect(history, contains('## [1.0.0]'));
    });
  }

  testWidgets('Arabic uses right-to-left layout', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ar'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: Builder(
          builder: (context) => Scaffold(
            body: Text(context.l10n.text('settings')),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      Directionality.of(tester.element(find.byType(Scaffold))),
      TextDirection.rtl,
    );
  });
}
