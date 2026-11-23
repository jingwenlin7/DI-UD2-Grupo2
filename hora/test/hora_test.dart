// Pruebas de widget del componente SelectorHora.
// Se ejecutan con: flutter test
import 'package:flutter_test/flutter_test.dart';
import 'package:hora/hora.dart';
import 'package:material_ui/material_ui.dart';

/// Envuelve el componente en una MaterialApp + Scaffold, que necesita para
/// poder dibujarse y para poder abrir el selector de hora (showTimePicker).
Widget _app(Widget child) => MaterialApp(
  home: Scaffold(body: Center(child: child)),
);

void main() {
  testWidgets('muestra la hora por defecto 09:30 en formato 24 h', (
    tester,
  ) async {
    // Sin pasar ninguna propiedad: debe usar los valores por defecto.
    await tester.pumpWidget(_app(const SelectorHora()));

    expect(find.text('09'), findsOneWidget);
    expect(find.text('30'), findsOneWidget);
    expect(find.text('24 h'), findsOneWidget);
  });

  testWidgets('el chip alterna 24 h/12 h y avisa con onFormatoChanged', (
    tester,
  ) async {
    bool? formato; // aquí guardamos lo que recibe el evento
    await tester.pumpWidget(
      _app(
        SelectorHora(
          horaInicial: const TimeOfDay(hour: 15, minute: 5),
          onFormatoChanged: (v) => formato = v,
        ),
      ),
    );
    expect(find.text('15'), findsOneWidget); // empieza en 24 h

    // Pulsamos el chip.
    await tester.tap(find.byKey(const Key('chip_formato')));
    await tester.pump();

    // Ahora está en 12 h: 15:05 -> 03:05 PM, y el evento recibió false.
    expect(formato, isFalse);
    expect(find.text('12 h'), findsOneWidget);
    expect(find.text('03'), findsOneWidget);
    expect(find.text('PM'), findsOneWidget);
  });

  testWidgets('al pulsar la hora abre el selector y onChanged recibe la hora', (
    tester,
  ) async {
    TimeOfDay? resultado;
    await tester.pumpWidget(
      _app(SelectorHora(onChanged: (t) => resultado = t)),
    );

    // Pulsar la caja de la hora abre el diálogo de showTimePicker.
    await tester.tap(find.byKey(const Key('caja_hora')));
    await tester.pumpAndSettle(); // espera a que termine la animación
    expect(find.byType(Dialog), findsOneWidget);

    // Aceptamos sin cambiar nada: onChanged recibe la hora inicial.
    await tester.tap(find.text('Aceptar'));
    await tester.pumpAndSettle();

    expect(resultado, const TimeOfDay(hour: 9, minute: 30));
  });

  testWidgets('cancelar el selector no llama a onChanged ni cambia la hora', (
    tester,
  ) async {
    var llamadas = 0;
    await tester.pumpWidget(_app(SelectorHora(onChanged: (_) => llamadas++)));

    await tester.tap(find.byKey(const Key('caja_hora')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();

    // Nada ha cambiado: ni evento ni hora mostrada.
    expect(llamadas, 0);
    expect(find.text('09'), findsOneWidget);
    expect(find.text('30'), findsOneWidget);
  });

  testWidgets('deshabilitado no abre el selector', (tester) async {
    await tester.pumpWidget(_app(const SelectorHora(habilitado: false)));

    await tester.tap(find.byKey(const Key('caja_hora')));
    await tester.pumpAndSettle();

    // No debe aparecer ningún diálogo.
    expect(find.byType(Dialog), findsNothing);
  });
}
