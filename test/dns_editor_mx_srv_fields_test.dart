import 'package:cloudflare_dns/l10n/app_localizations.dart';
import 'package:cloudflare_dns/screens/dns_editor_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({
      'dns_types': ['A', 'MX', 'SRV'],
    });
  });

  testWidgets('new record dialog shows priority field for MX',
      (tester) async {
    await _pumpScreen(tester);

    await tester.tap(find.byKey(const ValueKey('add-record-fab')));
    await tester.pumpAndSettle();

    expect(find.text('Prioridade'), findsNothing);

    await tester.tap(find.text('Tipo'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('MX').last);
    await tester.pumpAndSettle();

    expect(find.text('Prioridade'), findsOneWidget);
    expect(find.text('Conteúdo (IP ou destino)'), findsOneWidget);
    expect(find.text('Proxied'), findsNothing);
  });

  testWidgets('new record dialog shows service/weight/port/target for SRV',
      (tester) async {
    await _pumpScreen(tester);

    await tester.tap(find.byKey(const ValueKey('add-record-fab')));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Tipo'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('SRV').last);
    await tester.pumpAndSettle();

    expect(find.text('Serviço (ex.: _sip)'), findsOneWidget);
    expect(find.text('Protocolo'), findsOneWidget);
    expect(find.text('Prioridade'), findsOneWidget);
    expect(find.text('Peso'), findsOneWidget);
    expect(find.text('Porta'), findsOneWidget);
    expect(find.text('Destino (hostname)'), findsOneWidget);
    expect(find.text('Conteúdo (IP ou destino)'), findsNothing);
    expect(find.text('Proxied'), findsNothing);
  });

  testWidgets('editing an existing SRV record pre-fills service/proto/data',
      (tester) async {
    await _pumpScreen(tester);

    await tester.tap(find.byKey(const ValueKey('record-actions-4')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Editar registro'));
    await tester.pumpAndSettle();

    TextField fieldWithLabel(String label) => tester.widget<TextField>(
          find.ancestor(
            of: find.text(label),
            matching: find.byType(TextField),
          ),
        );

    expect(fieldWithLabel('Serviço (ex.: _sip)').controller?.text, '_sip');
    expect(fieldWithLabel('Prioridade').controller?.text, '10');
    expect(fieldWithLabel('Peso').controller?.text, '5');
    expect(fieldWithLabel('Porta').controller?.text, '5223');
    expect(
      fieldWithLabel('Destino (hostname)').controller?.text,
      'server.example.com',
    );
    expect(find.text('_tcp'), findsOneWidget);
  });
}

Future<void> _pumpScreen(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(1100, 700));
  addTearDown(() => tester.binding.setSurfaceSize(null));

  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('pt'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: DnsEditorScreen(
        zoneId: 'zone-1',
        zoneName: 'example.com',
        recordsLoader: (_) async => _records(),
        recordDeleter: (_, __) async {},
      ),
    ),
  );
  await tester.pumpAndSettle();
}

List<dynamic> _records() => [
      {
        'id': '3',
        'type': 'MX',
        'name': 'example.com',
        'content': 'mail.example.com',
        'priority': 20,
        'proxied': false,
        'proxiable': false,
      },
      {
        'id': '4',
        'type': 'SRV',
        'name': '_sip._tcp.example.com',
        'content': '5 5223 server.example.com',
        'priority': 10,
        'data': {
          'priority': 10,
          'weight': 5,
          'port': 5223,
          'target': 'server.example.com',
        },
        'proxied': false,
        'proxiable': false,
      },
    ];
