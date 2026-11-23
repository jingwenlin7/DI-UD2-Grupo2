import 'package:boton_grupal/boton_grupal.dart';
import 'package:flutter/material.dart';

import 'almacen/almacen_citas.dart';
import 'widgets/calendario.dart';
import 'widgets/selector_hora.dart';

void main() {
  runApp(const MiApp());
}

class MiApp extends StatelessWidget {
  const MiApp({super.key, this.almacen});

  /// Permite usar otro almacén en las pruebas.
  final AlmacenCitas? almacen;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Citas',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF4F6F9),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3B59B6)),
      ),
      home: PaginaCitas(almacen: almacen),
    );
  }
}

class PaginaCitas extends StatefulWidget {
  const PaginaCitas({super.key, this.almacen});

  final AlmacenCitas? almacen;

  @override
  State<PaginaCitas> createState() => _PaginaCitasState();
}

class _PaginaCitasState extends State<PaginaCitas> {
  final TextEditingController tituloCtrl = TextEditingController(text: 'Cita');

  // Almacén del JSON fijo: assets/data/citas.json.
  late final AlmacenCitas almacen = widget.almacen ?? AlmacenCitas();

  late final DateTime _hoy = DateTime.now();
  late final DateTime _fechaMinima = DateTime(_hoy.year, _hoy.month, _hoy.day);
  late final DateTime _fechaMaxima =
      DateTime(_hoy.year + 1, _hoy.month, _hoy.day);

  DateTime fecha = DateTime.now();
  int hora = 9;
  int minutos = 30;
  List<dynamic> citas = [];
  bool mostrarInfo = false;

  @override
  void initState() {
    super.initState();
    leerCitas();
  }

  @override
  void dispose() {
    tituloCtrl.dispose();
    super.dispose();
  }

  // Payload que recibe el botón al pulsarlo.
  Map<String, dynamic> get datosCita {
    final titulo = tituloCtrl.text.trim();

    return {
      'titulo': titulo.isEmpty ? 'Cita' : titulo,
      'dia': fecha.day,
      'mes': fecha.month,
      'anio': fecha.year,
      'hora': hora,
      'minutos': minutos,
    };
  }

  // Lee el JSON y actualiza la lista de la página.
  Future<void> leerCitas() async {
    try {
      final lista = await almacen.leer();
      if (!mounted) return;
      setState(() {
        citas = lista;
      });
    } catch (error) {
      if (!mounted) return;
      mostrarAviso('No se pudo leer ${almacen.ruta}: $error', esError: true);
    }
  }

  // El botón llama aquí: añade la cita al JSON y recarga la lista.
  Future<void> guardarCita(dynamic payload) async {
    try {
      await almacen.guardar(Map<String, dynamic>.from(payload as Map));
      await leerCitas();
      if (!mounted) return;
      mostrarAviso('Cita guardada en ${almacen.ruta}');
    } catch (error) {
      if (!mounted) return;
      mostrarAviso('No se pudo guardar: $error', esError: true);
    }
  }

  // Aviso flotante con el resultado del guardado.
  void mostrarAviso(String mensaje, {bool esError = false}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(mensaje),
          backgroundColor: esError ? Colors.red.shade700 : null,
        ),
      );
  }

  // Muestra u oculta el párrafo del botón Info.
  void alternarInfo() {
    setState(() {
      mostrarInfo = !mostrarInfo;
    });
  }

  @override
  Widget build(BuildContext context) {
    final anchoPantalla = MediaQuery.sizeOf(context).width;
    final anchoPanel = (anchoPantalla * 0.8).clamp(240.0, 420.0).toDouble();

    return Scaffold(
      body: SafeArea(
        // Stack para que el botón y el párrafo queden por encima del contenido
        // sin reservar espacio en el scroll.
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 32, 20, 20),
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
                    style: TextStyle(
                      color: Color(0xFF6B7385),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SelectorHora(
                    horaInicial: TimeOfDay(hour: hora, minute: minutos),
                    onChanged: (valor) {
                      setState(() {
                        hora = valor.hour;
                        minutos = valor.minute;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  Calendario(
                    fechaInicial: fecha,
                    fechaMinima: _fechaMinima,
                    fechaMaxima: _fechaMaxima,
                    onFechaSeleccionada: (nuevaFecha) {
                      setState(() {
                        fecha = nuevaFecha;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: tituloCtrl,
                    decoration: InputDecoration(
                      labelText: 'Título de la cita',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Ruta fija del JSON, no editable.
                  Text(
                    'Archivo: ${almacen.ruta}',
                    style: const TextStyle(
                      color: Color(0xFF6B7385),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Botón del paquete: entrega el payload a guardarCita.
                  BotonGrupal(
                    label: 'Guardar cita',
                    icon: Icons.event_available_rounded,
                    payload: datosCita,
                    autoSave: false,
                    showSnackBar: false,
                    onPressed: guardarCita,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Citas guardadas: ${citas.length}',
                    style: const TextStyle(
                      color: Color(0xFF2B3347),
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  for (final cita in citas)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(
                        Icons.event,
                        color: Color(0xFF3B59B6),
                      ),
                      title: Text(
                        cita is Map ? '${cita['titulo'] ?? 'Cita'}' : 'Cita',
                      ),
                      subtitle: Text(
                        cita is Map
                            ? 'Día ${cita['dia']} · Mes ${cita['mes']} · '
                                'Año ${cita['anio']} · '
                                'Hora ${cita['hora']} · '
                                'Minutos ${cita['minutos']}'
                            : '$cita',
                      ),
                    ),
                ],
              ),
            ),
            // El párrafo solo existe cuando está visible: no ocupa espacio.
            if (mostrarInfo)
              Positioned(
                top: 64,
                right: 8,
                width: anchoPanel,
                child: _PanelInfo(alCerrar: alternarInfo),
              ),
            // Último hijo del Stack: el botón Info queda por encima de todo.
            Positioned(
              top: 8,
              right: 8,
              width: anchoPantalla / 4,
              child: BotonGrupal(
                label: 'Info',
                tooltip: 'Mostrar u ocultar la explicación',
                autoSave: false,
                showSnackBar: false,
                elevation: 2,
                textStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 4,
                  vertical: 12,
                ),
                onPressed: (_) => alternarInfo(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Párrafo explicativo que aparece superpuesto bajo el botón «Info».
class _PanelInfo extends StatelessWidget {
  const _PanelInfo({required this.alCerrar});

  final VoidCallback alCerrar;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 8,
      shadowColor: const Color(0x33111827),
      borderRadius: BorderRadius.circular(16),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.6,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Cómo funciona',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2B3347),
                      ),
                    ),
                  ),
                  IconButton(
                    key: const Key('cerrar_info'),
                    icon: const Icon(Icons.close, size: 18),
                    tooltip: 'Cerrar',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: alCerrar,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'Esta página sirve para reservar una cita. En el calendario '
                'solo se pueden elegir fechas desde hoy hasta el mismo día '
                'del próximo año: los días fuera de ese rango aparecen en '
                'gris y las flechas se desactivan al llegar a los límites. '
                'La hora se cambia pulsando las cajas, que abren el selector '
                'de Flutter, y el chip alterna entre formato de 12 h y 24 h. '
                'Escribe un título y pulsa «Guardar cita» para añadir día, '
                'mes, año, hora y minutos a assets/data/citas.json. En web '
                'el archivo es de solo lectura; para guardar de verdad hay '
                'que ejecutar la app de escritorio.',
                key: Key('texto_info'),
                style: TextStyle(
                  fontSize: 13,
                  height: 1.45,
                  color: Color(0xFF5B6784),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
