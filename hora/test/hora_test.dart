// Pruebas de widget del componente SelectorHora.
// Se ejecutan con: flutter test
import 'package:flutter_test/flutter_test.dart';
import 'package:hora/hora.dart';
import 'package:material_ui/material_ui.dart';

/// Envuelve el componente en una MaterialApp + Scaffold, que necesita para
/// poder dibujarse y para poder abrir el selector de hora (showTimePicker).
Widget _app(Widget child) =>
    MaterialApp(home: Scaffold(body: Center(child: child)));

void main() {
  // ---------------------------------------------------------------------------
  // VALORES POR DEFECTO Y PROPIEDADES
  // ---------------------------------------------------------------------------

  testWidgets('muestra la hora por defecto 09:30', (tester) async {
    // Sin pasar ninguna propiedad: debe usar los valores por defecto.
    await tester.pumpWidget(_app(const SelectorHora()));
    expect(find.text('09'), findsOneWidget);
    expect(find.text('30'), findsOneWidget);
    expect(find.text('24 h'), findsOneWidget);
  });

  testWidgets('textos personalizados: titulo y etiquetas', (tester) async {
    await tester.pumpWidget(_app(const SelectorHora(
      titulo: 'Elige la hora',
      etiquetaHora: 'H',
      etiquetaMinutos: 'M',
    )));
    // Aparecen los textos nuevos y desaparece el título por defecto.
    expect(find.text('Elige la hora'), findsOneWidget);
    expect(find.text('H'), findsOneWidget);
    expect(find.text('M'), findsOneWidget);
    expect(find.text('Selecciona la hora'), findsNothing);
  });

  testWidgets('formato24h false arranca en 12 h con AM/PM', (tester) async {
    await tester.pumpWidget(_app(const SelectorHora(
      horaInicial: TimeOfDay(hour: 21, minute: 45),
      formato24h: false,
    )));
    // 21:45 en formato 12 h es 09:45 PM.
    expect(find.text('12 h'), findsOneWidget);
    expect(find.text('09'), findsOneWidget);
    expect(find.text('45'), findsOneWidget);
    expect(find.text('PM'), findsOneWidget);
  });

  testWidgets('medianoche en 12 h se muestra como 12 AM', (tester) async {
    // Caso límite: la hora 0 debe mostrarse como 12, no como 00.
    await tester.pumpWidget(_app(const SelectorHora(
      horaInicial: TimeOfDay(hour: 0, minute: 0),
      formato24h: false,
    )));
    expect(find.text('12'), findsOneWidget);
    expect(find.text('00'), findsOneWidget);
    expect(find.text('AM'), findsOneWidget);
  });

  testWidgets('si la app cambia horaInicial, el componente se actualiza',
      (tester) async {
    await tester.pumpWidget(_app(const SelectorHora()));
    expect(find.text('09'), findsOneWidget);

    // Reconstruimos el widget con otra hora inicial (didUpdateWidget).
    await tester.pumpWidget(_app(const SelectorHora(
      horaInicial: TimeOfDay(hour: 7, minute: 15),
    )));
    expect(find.text('07'), findsOneWidget);
    expect(find.text('15'), findsOneWidget);
  });

  // ---------------------------------------------------------------------------
  // CHIP DE FORMATO (evento onFormatoChanged)
  // ---------------------------------------------------------------------------

  testWidgets('el chip alterna 24h/12h y avisa con onFormatoChanged',
      (tester) async {
    bool? formato; // aquí guardamos lo que recibe el callback
    await tester.pumpWidget(_app(SelectorHora(
      horaInicial: const TimeOfDay(hour: 15, minute: 5),
      onFormatoChanged: (v) => formato = v,
    )));
    expect(find.text('15'), findsOneWidget); // empieza en 24 h

    // Pulsamos el chip.
    await tester.tap(find.byKey(const Key('chip_formato')));
    await tester.pump();

    // Ahora está en 12 h: 15:05 -> 03:05 PM, y el callback recibió false.
    expect(formato, isFalse);
    expect(find.text('12 h'), findsOneWidget);
    expect(find.text('03'), findsOneWidget);
    expect(find.text('PM'), findsOneWidget);
  });

  testWidgets('pulsar el chip dos veces vuelve a 24 h', (tester) async {
    final eventos = <bool>[]; // lista con todos los valores recibidos
    await tester.pumpWidget(_app(SelectorHora(
      horaInicial: const TimeOfDay(hour: 15, minute: 5),
      onFormatoChanged: eventos.add,
    )));

    await tester.tap(find.byKey(const Key('chip_formato')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('chip_formato')));
    await tester.pump();

    // Primero false (12 h) y luego true (24 h); el AM/PM desaparece.
    expect(eventos, [false, true]);
    expect(find.text('24 h'), findsOneWidget);
    expect(find.text('15'), findsOneWidget);
    expect(find.byKey(const Key('periodo')), findsNothing);
  });

  // ---------------------------------------------------------------------------
  // SELECTOR DE HORA (evento onChanged)
  // ---------------------------------------------------------------------------

  testWidgets('al pulsar la hora abre el selector y onChanged recibe la hora',
      (tester) async {
    TimeOfDay? resultado;
    await tester
        .pumpWidget(_app(SelectorHora(onChanged: (t) => resultado = t)));

    // Pulsar la caja de la hora abre el diálogo de showTimePicker.
    await tester.tap(find.byKey(const Key('caja_hora')));
    await tester.pumpAndSettle(); // espera a que termine la animación
    expect(find.byType(Dialog), findsOneWidget);

    // Aceptamos sin cambiar nada: onChanged recibe la hora inicial.
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    expect(resultado, const TimeOfDay(hour: 9, minute: 30));
  });

  testWidgets('la caja de minutos tambien abre el selector', (tester) async {
    await tester.pumpWidget(_app(const SelectorHora()));
    await tester.tap(find.byKey(const Key('caja_minutos')));
    await tester.pumpAndSettle();
    expect(find.byType(Dialog), findsOneWidget);
  });

  testWidgets('cancelar el selector no llama a onChanged ni cambia la hora',
      (tester) async {
    var llamadas = 0;
    await tester.pumpWidget(_app(SelectorHora(onChanged: (_) => llamadas++)));

    await tester.tap(find.byKey(const Key('caja_hora')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    // Nada ha cambiado: ni evento ni hora mostrada.
    expect(llamadas, 0);
    expect(find.text('09'), findsOneWidget);
    expect(find.text('30'), findsOneWidget);
  });

  testWidgets('escribir una hora nueva en el selector actualiza la tarjeta',
      (tester) async {
    TimeOfDay? resultado;
    await tester
        .pumpWidget(_app(SelectorHora(onChanged: (t) => resultado = t)));

    await tester.tap(find.byKey(const Key('caja_hora')));
    await tester.pumpAndSettle();
    // Cambiamos el diálogo al modo teclado para poder escribir la hora.
    await tester.tap(find.byIcon(Icons.keyboard_outlined));
    await tester.pumpAndSettle();

    final campos = find.byType(TextField);
    await tester.enterText(campos.at(0), '18'); // hora
    await tester.enterText(campos.at(1), '45'); // minutos
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    // El evento recibe la hora nueva y la tarjeta la muestra.
    expect(resultado, const TimeOfDay(hour: 18, minute: 45));
    expect(find.text('18'), findsOneWidget);
    expect(find.text('45'), findsOneWidget);
  });

  // ---------------------------------------------------------------------------
  // ESTADO DESHABILITADO
  // ---------------------------------------------------------------------------

  testWidgets('deshabilitado no abre el selector', (tester) async {
    await tester.pumpWidget(_app(const SelectorHora(habilitado: false)));
    await tester.tap(find.byKey(const Key('caja_hora')));
    await tester.pumpAndSettle();
    // No debe aparecer ningún diálogo.
    expect(find.byType(Dialog), findsNothing);
  });

  testWidgets('deshabilitado tampoco permite cambiar el formato',
      (tester) async {
    var llamadas = 0;
    await tester.pumpWidget(_app(SelectorHora(
      habilitado: false,
      onFormatoChanged: (_) => llamadas++,
    )));
    await tester.tap(find.byKey(const Key('chip_formato')));
    await tester.pump();
    // El callback no se llama y el formato sigue en 24 h.
    expect(llamadas, 0);
    expect(find.text('24 h'), findsOneWidget);
  });
}
