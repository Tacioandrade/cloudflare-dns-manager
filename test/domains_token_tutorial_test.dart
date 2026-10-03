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

  Widget appWithLocale(Locale locale, {Widget? home}) => MaterialApp(
        locale: locale,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: home ?? const DomainsScreen(),
      );

  Stream<dynamic> oneZone() async* {
    yield {
      'id': 'zone-id',
      'name': 'example.com',
      'status': 'active',
      'account': {'id': 'account-id', 'name': 'Main account'},
    };
  }

  testWidgets('shows the localized setup tutorial when the token is missing',
      (tester) async {
    await tester.pumpWidget(appWithLocale(const Locale('pt')));
    await tester.pumpAndSettle();

    expect(find.text('Configuração da Cloudflare API Token'), findsOneWidget);
    expect(find.text('Cloudflare API Token'), findsOneWidget);
    expect(find.textContaining('Zona / Zone'), findsNWidgets(3));
    expect(
        find.textContaining('Limpeza do cache / Cache Purge'), findsOneWidget);
    expect(
        find.byKey(const ValueKey('cloudflareApiTokenLink')), findsOneWidget);
    expect(find.byKey(const ValueKey('tokenTutorialSettingsButton')),
        findsOneWidget);
    expect(
      find.text('Token de API apenas para administrar domínios cadastrados'),
      findsOneWidget,
    );
    expect(
      find.text(
        'Token de API para adicionar novos domínios e administrar existentes',
      ),
      findsOneWidget,
    );
  });

  testWidgets('does not duplicate permission labels in English',
      (tester) async {
    await tester.pumpWidget(appWithLocale(const Locale('en')));
    await tester.pumpAndSettle();

    expect(find.textContaining('Zone / Zone'), findsNothing);
    expect(find.textContaining('Cache Purge / Cache Purge'), findsNothing);
    expect(find.textContaining('Zone => Cache Purge => Purge'), findsOneWidget);
    expect(find.textContaining('Zone => DNS => Edit'), findsOneWidget);
    expect(find.textContaining('Zone => Zone => Edit'), findsOneWidget);
    expect(
      find.textContaining('User => Memberships => Read'),
      findsOneWidget,
    );
    expect(
      find.textContaining('Zone resources => Include => All zones'),
      findsOneWidget,
    );
    expect(find.textContaining('com.cloudflare.api.account.zone.create'),
        findsNothing);
  });

  testWidgets('places add left of refresh when zone creation is allowed',
      (tester) async {
    FlutterSecureStorage.setMockInitialValues({'cf_api_token': 'token'});
    await tester.pumpWidget(
      appWithLocale(
        const Locale('pt'),
        home: DomainsScreen(
          zonesStream: oneZone,
          zoneCreationChecker: (_) async => true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    final add = find.byKey(const ValueKey('addDomainButton'));
    final refresh = find.byKey(const ValueKey('refreshDomainsButton'));
    expect(add, findsOneWidget);
    expect(refresh, findsOneWidget);
    expect(tester.getCenter(add).dx, lessThan(tester.getCenter(refresh).dx));
    expect(tester.getCenter(add).dy, tester.getCenter(refresh).dy);
  });

  testWidgets('hides add when zone creation permission is unavailable',
      (tester) async {
    FlutterSecureStorage.setMockInitialValues({'cf_api_token': 'token'});
    await tester.pumpWidget(
      appWithLocale(
        const Locale('pt'),
        home: DomainsScreen(
          zonesStream: oneZone,
          zoneCreationChecker: (_) async => false,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('addDomainButton')), findsNothing);
    expect(
      find.byKey(const ValueKey('refreshDomainsButton')),
      findsOneWidget,
    );
  });
}
