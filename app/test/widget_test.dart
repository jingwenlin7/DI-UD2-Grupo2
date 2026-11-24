import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:componentes/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Muestra componentes y botones flotantes de Informacion y Reservar cita', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('Tu próxima visita'), findsOneWidget);
    // Componente hora.
    expect(find.text('Selecciona la hora'), findsOneWidget);
    // Componente calendario.
    expect(find.text('Selecciona la fecha'), findsOneWidget);

    // Botones flotantes con BotonGrupal
    expect(find.text('Información'), findsOneWidget);
    expect(find.text('Reservar cita'), findsOneWidget);

    // Pulsar Información abre el diálogo de explicación
    await tester.tap(find.text('Información'));
    await tester.pumpAndSettle();

    expect(find.text('Cómo usar la app'), findsOneWidget);
    expect(find.text('Entendido'), findsOneWidget);

    await tester.tap(find.text('Entendido'));
    await tester.pumpAndSettle();

    expect(find.text('Cómo usar la app'), findsNothing);
  });
}
