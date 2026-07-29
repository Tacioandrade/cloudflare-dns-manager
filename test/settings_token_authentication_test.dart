import 'package:cloudflare_dns/l10n/app_localizations.dart';
import 'package:cloudflare_dns/screens/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget appWithSettings(SettingsScreen settings) {
    return MaterialApp(
      locale: const Locale('pt'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: settings,
    );
  }

  Finder tokenFieldFinder() => find.byWidgetPredicate(
        (widget) =>
            widget is TextField && widget.controller?.text == 'token-secreto',
      );

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues(
        {'cf_api_token': 'token-secreto'});
  });

  testWidgets('requires the app password before revealing the API token',
      (tester) async {
    var acceptedPassword = false;

    await tester.pumpWidget(
      appWithSettings(
        SettingsScreen(
          systemAuthenticator: (_) async => false,
          passwordVerifier: (password) async {
            acceptedPassword = password == 'senha-correta';
            return acceptedPassword;
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    TextField tokenField() => tester.widget<TextField>(tokenFieldFinder());

    expect(tokenField().obscureText, isTrue);

    await tester.tap(find.byKey(const ValueKey('tokenVisibilityButton')));
    await tester.pumpAndSettle();

    expect(find.text('Confirme sua identidade'), findsOneWidget);
    expect(tokenField().obscureText, isTrue);

    await tester.enterText(
      find.byKey(const ValueKey('tokenReauthenticationPassword')),
      'senha-errada',
    );
    await tester.tap(find.text('AUTENTICAR'));
    await tester.pumpAndSettle();

    expect(find.text('Credenciais inválidas!'), findsOneWidget);
    expect(tokenField().obscureText, isTrue);
    expect(acceptedPassword, isFalse);

    await tester.enterText(
      find.byKey(const ValueKey('tokenReauthenticationPassword')),
      'senha-correta',
    );
    await tester.tap(find.text('AUTENTICAR'));
    await tester.pumpAndSettle();

    expect(find.text('Confirme sua identidade'), findsNothing);
    expect(tokenField().obscureText, isFalse);
    expect(acceptedPassword, isTrue);

    await tester.tap(find.byKey(const ValueKey('tokenVisibilityButton')));
    await tester.pump();

    expect(tokenField().obscureText, isTrue);
  });

  testWidgets('reveals the API token after successful system authentication',
      (tester) async {
    var passwordVerifierCalled = false;

    await tester.pumpWidget(
      appWithSettings(
        SettingsScreen(
          systemAuthenticator: (_) async => true,
          passwordVerifier: (_) async {
            passwordVerifierCalled = true;
            return false;
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('tokenVisibilityButton')));
    await tester.pumpAndSettle();

    final tokenField = tester.widget<TextField>(tokenFieldFinder());
    expect(tokenField.obscureText, isFalse);
    expect(find.byKey(const ValueKey('tokenReauthenticationPassword')),
        findsNothing);
    expect(passwordVerifierCalled, isFalse);
  });
}
