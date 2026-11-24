import 'package:boton_grupal/boton_grupal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('normaliza el nombre del archivo', () {
    expect(JsonStore(fileName: ' citas ').fileName, 'citas.json');
    expect(JsonStore(fileName: 'reservas.JSON').fileName, 'reservas.JSON');
    expect(
      () => JsonStore(fileName: '   '),
      throwsA(isA<ArgumentError>()),
    );
  });

  test('guarda y lee datos arbitrarios', () async {
    final store = JsonStore(fileName: 'lo_que_sea.json');
    final payload = {
      'dia': 23,
      'mes': 11,
      'hora': 14,
      'minutos': 30,
      'etiquetas': ['cita', 'importante'],
      'meta': {'ok': true},
    };

    await store.write(payload);

    expect(await store.read(), payload);
    expect(await store.exists(), isTrue);
    expect(await JsonStore.listFiles(), ['lo_que_sea.json']);
  });

  test('append acumula elementos en una lista', () async {
    final store = JsonStore(fileName: 'citas');
    await store.save({'hora': 9, 'minutos': 0});
    await store.save({'hora': 10, 'minutos': 15});

    expect(await store.readList(), [
      {'hora': 9, 'minutos': 0},
      {'hora': 10, 'minutos': 15},
    ]);
  });

  test('sin append reemplaza el contenido', () async {
    final store = JsonStore(fileName: 'citas.json');
    await store.save({'valor': 1});
    await store.save({'valor': 2}, append: false);

    expect(await store.read(), {'valor': 2});
  });

  test('append falla si el archivo no contiene una lista', () async {
    final store = JsonStore(fileName: 'citas.json');
    await store.write({'valor': 1});

    expect(
      () => store.save({'valor': 2}),
      throwsA(isA<StateError>()),
    );
  });

  test('guarda bajo una clave dentro de un objeto', () async {
    final store = JsonStore(fileName: 'agenda.json');
    await store.save('primera', key: 'citas');
    await store.save('segunda', key: 'citas');

    expect(await store.readMap(), {
      'citas': ['primera', 'segunda'],
    });
  });

  test('clear y deleteFile eliminan el contenido', () async {
    final store = JsonStore(fileName: 'temporal.json');
    await store.write([1, 2, 3]);
    await store.clear();
    expect(await store.read(), isNull);

    await store.write([1]);
    await JsonStore.deleteFile('temporal');
    expect(await store.read(), isNull);
    expect(await JsonStore.listFiles(), isEmpty);
  });

  testWidgets('guarda el payload dinámico al pulsar', (tester) async {
    final payload = {
      'titulo': 'Cita con Ana',
      'fecha': {'dia': 3, 'mes': 12, 'anio': 2026},
      'hora': {'hora': 10, 'minutos': 45},
      'notas': 'Llevar documentos',
    };

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: BotonGrupal(
              label: 'Guardar cita',
              payload: payload,
              jsonFileName: 'citas.json',
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Guardar cita'));
    await tester.pumpAndSettle();

    final store = JsonStore(fileName: 'citas.json');
    expect(await store.readList(), [payload]);
  });

  testWidgets('entrega el payload al callback externo', (tester) async {
    dynamic recibido;
    var pulsado = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: BotonGrupal(
              label: 'Acción externa',
              payload: 'cualquier cosa',
              showSnackBar: false,
              onPressed: (payload) async {
                pulsado = true;
                recibido = payload;
              },
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Acción externa'));
    await tester.pumpAndSettle();

    expect(pulsado, isTrue);
    expect(recibido, 'cualquier cosa');
  });

  testWidgets('funciona dentro de un Row sin ancho acotado', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              BotonGrupal(
                label: 'Botón en fila',
                payload: {'ok': true},
                showSnackBar: false,
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Botón en fila'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('se puede deshabilitar desde fuera', (tester) async {
    var pulsado = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: BotonGrupal(
              label: 'Deshabilitado',
              enabled: false,
              showSnackBar: false,
              onPressed: (_) => pulsado = true,
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Deshabilitado'));
    await tester.pumpAndSettle();

    expect(pulsado, isFalse);
    final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
    expect(button.onPressed, isNull);
  });
}
