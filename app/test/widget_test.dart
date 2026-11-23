import 'dart:convert';
import 'dart:io';

import 'package:app_citas/almacen/almacen_citas.dart';
import 'package:app_citas/main.dart';
import 'package:app_citas/widgets/calendario.dart';
import 'package:app_citas/widgets/selector_hora.dart';
import 'package:boton_grupal/boton_grupal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory carpeta;
  late String ruta;

  setUp(() {
    carpeta = Directory.systemTemp.createTempSync('citas_test');
    ruta = '${carpeta.path}/citas.json';
    File(ruta).writeAsStringSync('[]');
  });

  tearDown(() {
    if (carpeta.existsSync()) {
      carpeta.deleteSync(recursive: true);
    }
  });

  Future<void> montar(WidgetTester tester, {AlmacenCitas? almacen}) async {
    tester.view.physicalSize = const Size(1200, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MiApp(almacen: almacen ?? AlmacenCitas(ruta: ruta)),
    );
    await tester.pumpAndSettle();
  }

  Finder botonConTexto(String texto) {
    return find.descendant(
      of: find.widgetWithText(BotonGrupal, texto),
      matching: find.byType(ElevatedButton),
    );
  }

  testWidgets('muestra el calendario, la hora y guarda en el archivo',
      (tester) async {
    await montar(tester);

    expect(find.byType(Calendario), findsOneWidget);
    expect(find.byType(SelectorHora), findsOneWidget);
    expect(find.widgetWithText(BotonGrupal, 'Guardar cita'), findsOneWidget);

    final boton = botonConTexto('Guardar cita');
    await tester.ensureVisible(boton);
    await tester.pumpAndSettle();
    await tester.tap(boton);
    await tester.pumpAndSettle();

    final citas = jsonDecode(File(ruta).readAsStringSync()) as List;
    expect(citas, hasLength(1));

    final cita = citas.single as Map;
    expect(cita['dia'], isA<int>());
    expect(cita['mes'], isA<int>());
    expect(cita['anio'], isA<int>());
    expect(cita['hora'], isA<int>());
    expect(cita['minutos'], isA<int>());
    expect(find.text('Citas guardadas: 1'), findsOneWidget);
  });

  testWidgets('el botón Info ocupa un cuarto y muestra el párrafo encima',
      (tester) async {
    await montar(tester);

    expect(find.byKey(const Key('texto_info')), findsNothing);

    final posicionInicial = tester.getTopLeft(
      find.text('Tu próxima visita'),
    );
    final tamanoBoton = tester.getSize(
      find.widgetWithText(BotonGrupal, 'Info'),
    );
    expect(tamanoBoton.width, closeTo(1200 / 4, 0.1));

    await tester.tap(botonConTexto('Info'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('texto_info')), findsOneWidget);
    expect(find.textContaining('desde hoy hasta'), findsOneWidget);

    // El párrafo está superpuesto: no desplaza el contenido de la página.
    expect(
      tester.getTopLeft(find.text('Tu próxima visita')),
      posicionInicial,
    );

    await tester.tap(botonConTexto('Info'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('texto_info')), findsNothing);
  });

  testWidgets('usa siempre la ruta fija y no permite cambiarla',
      (tester) async {
    tester.view.physicalSize = const Size(1200, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MiApp());
    await tester.pumpAndSettle();

    expect(find.text('Archivo: $rutaArchivoCitas'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Archivo JSON'), findsNothing);
  });

  testWidgets('se adapta a una pantalla estrecha', (tester) async {
    tester.view.physicalSize = const Size(390, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MiApp(almacen: AlmacenCitas(ruta: ruta)),
    );
    await tester.pumpAndSettle();

    expect(find.byType(Calendario), findsOneWidget);
    expect(find.byType(SelectorHora), findsOneWidget);

    await tester.tap(botonConTexto('Info'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('texto_info')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
