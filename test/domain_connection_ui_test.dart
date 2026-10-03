import 'package:cloudflare_dns/data/api.dart';
import 'package:cloudflare_dns/l10n/app_localizations.dart';
import 'package:cloudflare_dns/screens/add_domain_screen.dart';
import 'package:cloudflare_dns/screens/pending_domain_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget localized(Widget child) => MaterialApp(
        locale: const Locale('pt'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: child,
      );

  testWidgets('validates the domain before trying to connect it',
      (tester) async {
    await tester.pumpWidget(
      localized(
        const ConnectDomainScreen(
          account: {'id': 'account-id', 'name': 'Conta principal'},
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('connectDomainContinue')));
    await tester.pump();

    expect(find.text('Informe um domínio.'), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('connectDomainField')),
      'domínio inválido',
    );
    await tester.tap(find.byKey(const ValueKey('connectDomainContinue')));
    await tester.pump();

    expect(
      find.text('Informe um domínio raiz válido, como exemplo.com.br.'),
      findsOneWidget,
    );
  });

  testWidgets('shows fallback notice and searches accounts with Ctrl+F',
      (tester) async {
    await tester.pumpWidget(
      localized(
        AccountSelectionScreen(
          accountsLoader: () async => const AccountListResult(
            accounts: [
              {'id': 'account-1', 'name': 'Conta principal'},
              {'id': 'account-2', 'name': 'Conta secundária'},
            ],
            usedZoneFallback: true,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('limitedAccountsNotice')), findsOneWidget);
    expect(find.text('Conta principal'), findsOneWidget);
    expect(find.text('Conta secundária'), findsOneWidget);

    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyF);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('accountSearchField')), findsOneWidget);
    await tester.enterText(
      find.byKey(const ValueKey('accountSearchField')),
      'secundária',
    );
    await tester.pump();

    expect(find.text('Conta principal'), findsNothing);
    expect(find.text('Conta secundária'), findsOneWidget);

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pump();

    expect(find.byKey(const ValueKey('accountSearchField')), findsNothing);
    expect(find.text('Conta principal'), findsOneWidget);
    expect(find.text('Conta secundária'), findsOneWidget);
  });

  testWidgets('pending domain shows both name servers and check action',
      (tester) async {
    await tester.pumpWidget(
      localized(
        const PendingDomainScreen(
          zone: {
            'id': 'zone-id',
            'name': 'example.com',
            'status': 'pending',
            'name_servers': ['amy.ns.cloudflare.com', 'bob.ns.cloudflare.com'],
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('amy.ns.cloudflare.com'), findsOneWidget);
    expect(find.text('bob.ns.cloudflare.com'), findsOneWidget);
    expect(find.byKey(const ValueKey('checkDomainActivation')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('copyNameServer-amy.ns.cloudflare.com')),
      findsOneWidget,
    );
  });
}
