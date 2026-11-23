// Importamos material_ui (la versión actual de Material en Flutter).
// De aquí salen TimeOfDay, showTimePicker, Card, Text, Color, etc.
import 'package:material_ui/material_ui.dart';

/// Tarjeta "Selecciona la hora": muestra la hora y los minutos en dos cajas
/// grandes. Al pulsar cualquiera de ellas se abre el [showTimePicker] oficial.
/// Un chip permite alternar entre formato de 24 h y 12 h.
///
/// Todas las propiedades tienen valor por defecto, por lo que `SelectorHora()`
/// funciona sin configuración (09:30 en formato 24 h).
///
/// Ejemplo:
///
/// ```dart
/// SelectorHora(
///   horaInicial: const TimeOfDay(hour: 18, minute: 0),
///   onChanged: (hora) => debugPrint('Nueva hora: $hora'),
///   onFormatoChanged: (es24h) => debugPrint('24 h: $es24h'),
/// )
/// ```
// Es StatefulWidget porque la hora y el formato cambian mientras se usa.
class SelectorHora extends StatefulWidget {
  const SelectorHora({
    super.key,
    // Propiedades configurables. Todas tienen valor por defecto,
    // salvo los callbacks, que son opcionales (pueden ser null).
    this.horaInicial = const TimeOfDay(hour: 9, minute: 30),
    this.titulo = 'Selecciona la hora',
    this.etiquetaHora = 'Hora',
    this.etiquetaMinutos = 'Minutos',
    this.formato24h = true,
    this.colorPrincipal = const Color(0xFF4062C8),
    this.habilitado = true,
    this.onChanged,
    this.onFormatoChanged,
  });

  /// Hora mostrada al principio. Por defecto 09:30.
  final TimeOfDay horaInicial;

  /// Título de la tarjeta.
  final String titulo;

  /// Texto bajo la caja de la hora.
  final String etiquetaHora;

  /// Texto bajo la caja de los minutos.
  final String etiquetaMinutos;

  /// Si es `true` se muestra en formato 24 h; si no, en 12 h con AM/PM.
  final bool formato24h;

  /// Color de la caja de la hora y del chip de formato.
  final Color colorPrincipal;

  /// Si es `false` no se puede cambiar la hora ni el formato.
  final bool habilitado;

  /// Evento: se llama cada vez que el usuario confirma una nueva hora.
  final ValueChanged<TimeOfDay>? onChanged;

  /// Evento: se llama cuando el usuario alterna el formato (`true` = 24 h).
  final ValueChanged<bool>? onFormatoChanged;

  @override
  State<SelectorHora> createState() => _SelectorHoraState();
}

/// Estado interno del componente (privado: no se exporta fuera del paquete).
class _SelectorHoraState extends State<SelectorHora> {
  // Hora y formato actuales. Se inicializan con lo que pasa la app, pero
  // después los cambia el propio componente al interactuar el usuario.
  late TimeOfDay _hora = widget.horaInicial;
  late bool _formato24h = widget.formato24h;

  /// Si la app reconstruye el widget con otros valores iniciales, el estado
  /// interno se actualiza para reflejarlos.
  @override
  void didUpdateWidget(covariant SelectorHora oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.formato24h != widget.formato24h) {
      _formato24h = widget.formato24h;
    }
    if (oldWidget.horaInicial != widget.horaInicial) {
      _hora = widget.horaInicial;
    }
  }

  /// Abre el selector de hora oficial y, si el usuario acepta,
  /// guarda la nueva hora y avisa a la app con [SelectorHora.onChanged].
  Future<void> _elegirHora() async {
    final elegida = await showTimePicker(
      context: context,
      initialTime: _hora,
      // Con el builder forzamos que el diálogo use el mismo formato (24 h o
      // 12 h) que el chip de la tarjeta.
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(alwaysUse24HourFormat: _formato24h),
        child: child!,
      ),
    );
    // showTimePicker devuelve null si el usuario cancela -> no hacemos nada.
    // `mounted` evita usar el estado si el widget ya no está en pantalla.
    if (elegida == null || !mounted) return;
    setState(() => _hora = elegida); // redibuja con la nueva hora
    widget.onChanged?.call(elegida); // avisa a la app (si hay callback)
  }

  /// Cambia entre 24 h y 12 h y avisa con [SelectorHora.onFormatoChanged].
  void _alternarFormato() {
    setState(() => _formato24h = !_formato24h);
    widget.onFormatoChanged?.call(_formato24h);
  }

  /// Hora como texto de dos dígitos.
  /// En 12 h se usa hourOfPeriod (0-11) y el 0 se muestra como 12.
  String get _textoHora {
    final h = _formato24h
        ? _hora.hour
        : (_hora.hourOfPeriod == 0 ? 12 : _hora.hourOfPeriod);
    return h.toString().padLeft(2, '0'); // 9 -> "09"
  }

  /// Minutos como texto de dos dígitos.
  String get _textoMinutos => _hora.minute.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    const texto = Color(0xFF1F2A44); // color de texto oscuro del diseño
    // Tarjeta blanca con bordes redondeados y borde fino (según Figma).
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: Color(0xFFE3E8F2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min, // la tarjeta mide lo justo
          children: [
            // Título de la tarjeta.
            Text(
              widget.titulo,
              style: const TextStyle(fontSize: 14, color: Color(0xFF5B6784)),
            ),
            const SizedBox(height: 14),
            // Fila: [hora] : [minutos] [chip formato]
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Caja de la hora (color principal, texto blanco).
                Expanded(
                  child: _Caja(
                    key: const Key('caja_hora'), // clave para los tests
                    valor: _textoHora,
                    etiqueta: widget.etiquetaHora,
                    fondo: widget.colorPrincipal,
                    colorTexto: Colors.white,
                    // Si está deshabilitado, onTap es null y no responde.
                    onTap: widget.habilitado ? _elegirHora : null,
                  ),
                ),
                // Separador ":" entre hora y minutos.
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 20),
                  child: Text(':',
                      style: TextStyle(fontSize: 36, color: texto)),
                ),
                // Caja de los minutos (fondo claro, texto oscuro).
                Expanded(
                  child: _Caja(
                    key: const Key('caja_minutos'),
                    valor: _textoMinutos,
                    etiqueta: widget.etiquetaMinutos,
                    fondo: const Color(0xFFEAEFFA),
                    colorTexto: texto,
                    onTap: widget.habilitado ? _elegirHora : null,
                  ),
                ),
                const SizedBox(width: 12),
                // Chip "24 h" / "12 h" para alternar el formato.
                Padding(
                  padding: const EdgeInsets.only(top: 24),
                  child: GestureDetector(
                    key: const Key('chip_formato'),
                    onTap: widget.habilitado ? _alternarFormato : null,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAEFFA),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        _formato24h ? '24 h' : '12 h',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: widget.colorPrincipal,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // El indicador AM/PM solo aparece en formato de 12 h.
            if (!_formato24h)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  _hora.period == DayPeriod.am ? 'AM' : 'PM',
                  key: const Key('periodo'),
                  style: const TextStyle(color: Color(0xFF5B6784)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Caja reutilizable: valor grande (hora o minutos) con su etiqueta debajo.
/// Se usa dos veces (hora y minutos) para no duplicar código.
class _Caja extends StatelessWidget {
  const _Caja({
    super.key,
    required this.valor,
    required this.etiqueta,
    required this.fondo,
    required this.colorTexto,
    required this.onTap,
  });

  final String valor; // número a mostrar, p. ej. "09"
  final String etiqueta; // texto bajo la caja, p. ej. "Hora"
  final Color fondo; // color de fondo de la caja
  final Color colorTexto; // color del número
  final VoidCallback? onTap; // acción al pulsar (null = no responde)

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 80,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: fondo,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              valor,
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.w300,
                color: colorTexto,
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(etiqueta,
            style: const TextStyle(fontSize: 12, color: Color(0xFF5B6784))),
      ],
    );
  }
}
