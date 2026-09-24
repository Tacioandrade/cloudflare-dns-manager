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
      'dns_types': ['A', 'CNAME'],
    });
  });

  testWidgets('long press selects a record and No leaves bulk mode',
      (tester) async {
    await _pumpScreen(tester);

    await tester.longPress(find.text('A • one.example.com'));
    await tester.pumpAndSettle();

    expect(find.byType(Checkbox), findsNWidgets(2));
    expect(
      tester
          .widget<Checkbox>(find.byKey(const ValueKey('bulk-select-1')))
          .value,
      isTrue,
    );
    expect(find.byKey(const ValueKey('bulk-delete-fab')), findsOneWidget);
    expect(find.byKey(const ValueKey('add-record-fab')), findsNothing);

    await tester.tap(find.byKey(const ValueKey('bulk-delete-fab')));
    await tester.pumpAndSettle();

    expect(
      find.text('Deseja deletar todos os registros abaixo?'),
      findsOneWidget,
    );
    await tester.tap(find.text('Não'));
    await tester.pumpAndSettle();

    expect(find.byType(Checkbox), findsNothing);
    expect(find.byKey(const ValueKey('add-record-fab')), findsOneWidget);
  });

  testWidgets('toolbar selection deletes all checked records', (tester) async {
    final records = _records();
    final deletedIds = <String>[];
    var loadCount = 0;

    await _pumpScreen(
      tester,
      recordsLoader: (_) async {
        loadCount++;
        return List<dynamic>.from(records);
      },
      recordDeleter: (_, recordId) async {
        deletedIds.add(recordId);
        records.removeWhere((record) => record['id'] == recordId);
      },
    );

    await tester.tap(find.byKey(const ValueKey('bulk-delete-mode-button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('bulk-select-1')));
    await tester.tap(find.byKey(const ValueKey('bulk-select-2')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('bulk-delete-fab')));
    await tester.pumpAndSettle();

    expect(find.text('A • one.example.com'), findsNWidgets(2));
    expect(find.text('CNAME • two.example.com'), findsNWidgets(2));

    await tester.tap(find.text('Sim'));
    await tester.pumpAndSettle();

    expect(deletedIds, ['1', '2']);
    expect(loadCount, 2);
    expect(find.byType(Checkbox), findsNothing);
    expect(find.byKey(const ValueKey('add-record-fab')), findsOneWidget);
    expect(find.text('Nenhum registro encontrado.'), findsOneWidget);
  });
}

Future<void> _pumpScreen(
  WidgetTester tester, {
  DnsRecordsLoader? recordsLoader,
  DnsRecordDeleter? recordDeleter,
}) async {
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
        recordsLoader: recordsLoader ?? (_) async => _records(),
        recordDeleter: recordDeleter ?? (_, __) async {},
      ),
    ),
  );
  await tester.pumpAndSettle();
}

List<dynamic> _records() => [
      {
        'id': '1',
        'type': 'A',
        'name': 'one.example.com',
        'content': '192.0.2.1',
        'proxied': true,
        'proxiable': true,
      },
      {
        'id': '2',
        'type': 'CNAME',
        'name': 'two.example.com',
        'content': 'one.example.com',
        'proxied': false,
        'proxiable': true,
      },
    ];
