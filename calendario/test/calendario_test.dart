import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../lib/calendario.dart';

Widget _envolverEnApp(Widget child) {
  return MaterialApp(home: Scaffold(body: child));
}

void main() {
  testWidgets('selecciona un dia habilitado y dispara onFechaSeleccionada', (
    WidgetTester tester,
  ) async {
    DateTime? fechaRecibida;

    await tester.pumpWidget(
      _envolverEnApp(
        Calendario(
          fechaInicial: DateTime(2026, 11, 17),
          onFechaSeleccionada: (fecha) {
            fechaRecibida = fecha;
          },
        ),
      ),
    );

    expect(find.text('Noviembre de 2026'), findsOneWidget);
    expect(find.text('Mar, 17 de noviembre'), findsOneWidget);

    await tester.tap(find.text('20'));
    await tester.pump();

    expect(find.text('Vie, 20 de noviembre'), findsOneWidget);
    expect(fechaRecibida, DateTime(2026, 11, 20));
  });

  testWidgets('cambia de mes con las flechas y dispara onMesCambiado', (
    WidgetTester tester,
  ) async {
    DateTime? mesRecibido;

    await tester.pumpWidget(
      _envolverEnApp(
        Calendario(
          fechaInicial: DateTime(2026, 11, 17),
          onFechaSeleccionada: (_) {},
          onMesCambiado: (nuevoMes) {
            mesRecibido = nuevoMes;
          },
        ),
      ),
    );

    await tester.tap(find.byTooltip('Mes siguiente'));
    await tester.pump();

    expect(find.text('Diciembre de 2026'), findsOneWidget);
    expect(mesRecibido, DateTime(2026, 12, 1));
  });

  testWidgets('no permite seleccionar dias anteriores a fechaMinima', (
    WidgetTester tester,
  ) async {
    DateTime? fechaRecibida;

    await tester.pumpWidget(
      _envolverEnApp(
        Calendario(
          fechaInicial: DateTime(2026, 11, 17),
          fechaMinima: DateTime(2026, 11, 15),
          onFechaSeleccionada: (fecha) {
            fechaRecibida = fecha;
          },
        ),
      ),
    );

    await tester.tap(find.text('10'));
    await tester.pump();

    expect(find.text('Mar, 17 de noviembre'), findsOneWidget);
    expect(fechaRecibida, isNull);
  });
}
