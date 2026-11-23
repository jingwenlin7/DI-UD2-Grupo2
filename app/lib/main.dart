import 'package:material_ui/material_ui.dart';
import 'package:calendario/calendario.dart';
import 'package:hora/hora.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Componentes',
      theme: ThemeData(
        scaffoldBackgroundColor: Color(0xFFF4F6F9),
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF3B59B6)),
      ),
      home: Scaffold(
        body: SafeArea(
          // Scroll para que la pantalla no se desborde en móviles pequeños.
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(20, 32, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tu próxima visita',
                  style: TextStyle(
                    color: Color(0xFF2B3347),
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Elige cuándo renovar tu estilo.',
                  style: TextStyle(
                    color: Color(0xFF6B7385),
                    fontSize: 12,
                  ),
                ),
                SizedBox(height: 20),
                SelectorHora(),
                SizedBox(height: 16),
                Calendario(
                  onFechaSeleccionada: _ignorarFechaSeleccionada,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void _ignorarFechaSeleccionada(DateTime fecha) {}
