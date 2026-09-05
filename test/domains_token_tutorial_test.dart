import 'package:cloudflare_dns/l10n/app_localizations.dart';
import 'package:cloudflare_dns/screens/domains_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
  });

  Widget appWithLocale(Locale locale) => MaterialApp(
        locale: locale,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: const DomainsScreen(),
      );

  testWidgets('shows the localized setup tutorial when the token is missing',
      (tester) async {
    await tester.pumpWidget(appWithLocale(const Locale('pt')));
    await tester.pumpAndSettle();

    expect(find.text('Configuração da Cloudflare API Token'), findsOneWidget);
    expect(find.text('Cloudflare API Token'), findsOneWidget);
    expect(find.textContaining('Zona / Zone'), findsNWidgets(2));
    expect(
        find.textContaining('Limpeza do cache / Cache Purge'), findsOneWidget);
    expect(
        find.byKey(const ValueKey('cloudflareApiTokenLink')), findsOneWidget);
    expect(find.byKey(const ValueKey('tokenTutorialSettingsButton')),
        findsOneWidget);
  });

  testWidgets('does not duplicate permission labels in English',
      (tester) async {
    await tester.pumpWidget(appWithLocale(const Locale('en')));
    await tester.pumpAndSettle();

    expect(find.textContaining('Zone / Zone'), findsNothing);
    expect(find.textContaining('Cache Purge / Cache Purge'), findsNothing);
    expect(find.textContaining('Zone => Cache Purge => Clear'), findsOneWidget);
    expect(find.textContaining('Zone => DNS => Edit'), findsOneWidget);
  });
}
