import 'package:boton_grupal/boton_grupal.dart';
import 'package:calendario/calendario.dart';
import 'package:hora/hora.dart';
import 'package:material_ui/material_ui.dart';

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
        scaffoldBackgroundColor: const Color(0xFFF4F6F9),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3B59B6)),
      ),
      home: const PaginaPrincipal(),
    );
  }
}

class PaginaPrincipal extends StatefulWidget {
  const PaginaPrincipal({super.key});

  @override
  State<PaginaPrincipal> createState() => _PaginaPrincipalState();
}

class _PaginaPrincipalState extends State<PaginaPrincipal> {
  final JsonStore _store = JsonStore(fileName: 'citas.json');

  DateTime _fecha = DateTime.now();
  TimeOfDay _hora = const TimeOfDay(hour: 9, minute: 30);
  List<dynamic> _citas = [];

  @override
  void initState() {
    super.initState();
    _cargarCitas();
  }

  Future<void> _cargarCitas() async {
    try {
      final lista = await _store.readList();
      if (!mounted) return;
      setState(() => _citas = lista);
    } catch (_) {
      // Si el archivo no existe aún o hay un error de lectura
    }
  }

  Map<String, dynamic> get _datosCita {
    return {
      'titulo': 'Cita',
      'dia': _fecha.day,
      'mes': _fecha.month,
      'anio': _fecha.year,
      'hora': _hora.hour,
      'minutos': _hora.minute,
    };
  }

  void _mostrarExplicacion() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Row(
          children: [
            Icon(Icons.info_outline, color: Color(0xFF3B59B6)),
            SizedBox(width: 8),
            Text(
              'Cómo usar la app',
              style: TextStyle(
                color: Color(0xFF2B3347),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: const Text(
          '1. Selecciona la hora deseada pulsando sobre las cajas de hora y minutos.\n\n'
          '2. Elige el día de tu cita navegando por el calendario.\n\n'
          '3. Pulsa el botón flotante "Reservar cita" para guardar tu reserva con la fecha y hora seleccionadas.',
          style: TextStyle(
            color: Color(0xFF5B6784),
            fontSize: 14,
            height: 1.45,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          BotonGrupal(
            label: 'Información',
            icon: Icons.info,
            width: 170,
            autoSave: false,
            showSnackBar: false,
            backgroundColor: const Color(0xFF3B59B6),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            borderRadius: 16,
            onPressed: (_) => _mostrarExplicacion(),
          ),
          const SizedBox(height: 12),
          BotonGrupal(
            label: 'Reservar cita',
            icon: Icons.add,
            width: 170,
            jsonFileName: 'citas.json',
            payload: _datosCita,
            appendToList: true,
            backgroundColor: const Color(0xFF3B59B6),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            borderRadius: 16,
            successMessage: 'Cita reservada correctamente',
            onPressed: (_) async {
              await _cargarCitas();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 32, 20, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tu próxima visita',
                style: TextStyle(
                  color: Color(0xFF2B3347),
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Elige cuándo renovar tu estilo.',
                style: TextStyle(color: Color(0xFF6B7385), fontSize: 12),
              ),
              const SizedBox(height: 20),
              SelectorHora(
                horaInicial: _hora,
                onChanged: (nuevaHora) {
                  setState(() => _hora = nuevaHora);
                },
              ),
              const SizedBox(height: 16),
              Calendario(
                fechaInicial: _fecha,
                onFechaSeleccionada: (nuevaFecha) {
                  setState(() => _fecha = nuevaFecha);
                },
              ),
              if (_citas.isNotEmpty) ...[
                const SizedBox(height: 28),
                Text(
                  'Citas guardadas (${_citas.length}):',
                  style: const TextStyle(
                    color: Color(0xFF2B3347),
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                for (final cita in _citas.reversed)
                  Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    color: Colors.white,
                    elevation: 0.5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: const Icon(
                        Icons.event,
                        color: Color(0xFF3B59B6),
                      ),
                      title: Text(
                        cita is Map ? '${cita['titulo'] ?? 'Cita'}' : 'Cita',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        cita is Map
                            ? '${cita['dia'].toString().padLeft(2, '0')}/${cita['mes'].toString().padLeft(2, '0')}/${cita['anio']} a las ${cita['hora'].toString().padLeft(2, '0')}:${cita['minutos'].toString().padLeft(2, '0')}'
                            : '$cita',
                      ),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
