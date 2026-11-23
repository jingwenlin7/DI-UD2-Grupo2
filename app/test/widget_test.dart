// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:componentes/main.dart';

void main() {
  testWidgets('Muestra la hora y el calendario de la cita', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text('Tu próxima visita'), findsOneWidget);
    // Componente hora.
    expect(find.text('Selecciona la hora'), findsOneWidget);
    // Componente calendario. No se comprueba la fecha concreta porque el
    // calendario arranca en el día de hoy y el test dependería del día.
    expect(find.text('Selecciona la fecha'), findsOneWidget);
  });
}
