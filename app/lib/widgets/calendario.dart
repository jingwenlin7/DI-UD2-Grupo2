import 'package:flutter/material.dart';

/// Calendario mensual reutilizable para elegir una fecha.
///
/// Muestra una tarjeta con la fecha elegida en grande, el mes visible con
/// flechas para cambiar de mes y la cuadrícula de días (semana de lunes a
/// domingo). Se puede limitar el rango de fechas seleccionables.
class Calendario extends StatefulWidget {
  const Calendario({
    super.key,
    required this.onFechaSeleccionada,
    this.onMesCambiado,
    this.fechaInicial,
    this.fechaMinima,
    this.fechaMaxima,
    this.titulo = 'Selecciona la fecha',
    this.colorAcento = const Color(0xFF3B59B6),
  });

  /// EVENTO principal: se ejecuta cada vez que el usuario pulsa un día
  /// habilitado. Recibe la fecha elegida (sin hora).
  final ValueChanged<DateTime> onFechaSeleccionada;

  /// EVENTO opcional: se ejecuta al cambiar de mes con las flechas.
  /// Recibe el día 1 del nuevo mes.
  final ValueChanged<DateTime>? onMesCambiado;

  /// Fecha seleccionada al empezar. Si es null, se usa el día de hoy.
  final DateTime? fechaInicial;

  /// Primer día que se puede elegir. Los anteriores aparecen deshabilitados.
  final DateTime? fechaMinima;

  /// Último día que se puede elegir. Los posteriores aparecen deshabilitados.
  final DateTime? fechaMaxima;

  /// Texto pequeño que aparece encima de la fecha elegida.
  final String titulo;

  /// Color del día seleccionado.
  final Color colorAcento;

  @override
  State<Calendario> createState() => _CalendarioState();
}

class _CalendarioState extends State<Calendario> {
  static const List<String> _meses = [
    'enero',
    'febrero',
    'marzo',
    'abril',
    'mayo',
    'junio',
    'julio',
    'agosto',
    'septiembre',
    'octubre',
    'noviembre',
    'diciembre',
  ];

  static const List<String> _diasCortos = [
    'Lun',
    'Mar',
    'Mié',
    'Jue',
    'Vie',
    'Sáb',
    'Dom',
  ];

  static const List<String> _inicialesDias = [
    'L',
    'M',
    'X',
    'J',
    'V',
    'S',
    'D',
  ];

  static const Color _colorTexto = Color(0xFF2B3347);
  static const Color _colorTextoSuave = Color(0xFF6B7385);
  static const Color _colorDeshabilitado = Color(0xFFB8BECC);
  static const Color _colorBorde = Color(0xFFE3E8F0);

  // Día elegido por el usuario.
  late DateTime _seleccionada;

  // Primer día del mes que se está mostrando.
  late DateTime _mesVisible;

  @override
  void initState() {
    super.initState();
    _sincronizarFechaInicial(widget.fechaInicial);
  }

  @override
  void didUpdateWidget(covariant Calendario oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_mismoDiaNullable(oldWidget.fechaInicial, widget.fechaInicial)) {
      _sincronizarFechaInicial(widget.fechaInicial);
    }
  }

  void _sincronizarFechaInicial(DateTime? fecha) {
    _seleccionada = _soloFecha(fecha ?? DateTime.now());
    _mesVisible = DateTime(_seleccionada.year, _seleccionada.month, 1);
  }

  bool _mismoDiaNullable(DateTime? a, DateTime? b) {
    if (a == null && b == null) return true;
    if (a == null || b == null) return false;
    return _mismoDia(_soloFecha(a), _soloFecha(b));
  }

  // Quita la hora para comparar solo año, mes y día.
  DateTime _soloFecha(DateTime fecha) {
    return DateTime(fecha.year, fecha.month, fecha.day);
  }

  bool _mismoDia(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _capitalizar(String texto) {
    return texto[0].toUpperCase() + texto.substring(1);
  }

  // Un día está habilitado si cae dentro del rango fechaMinima - fechaMaxima.
  bool _estaHabilitado(DateTime dia) {
    final DateTime? minima = widget.fechaMinima;
    final DateTime? maxima = widget.fechaMaxima;
    if (minima != null && dia.isBefore(_soloFecha(minima))) {
      return false;
    }
    if (maxima != null && dia.isAfter(_soloFecha(maxima))) {
      return false;
    }
    return true;
  }

  // Se puede ir al mes anterior si su último día no es anterior a fechaMinima.
  bool get _hayMesAnterior {
    final DateTime? minima = widget.fechaMinima;
    if (minima == null) {
      return true;
    }
    final DateTime ultimoDiaAnterior = DateTime(
      _mesVisible.year,
      _mesVisible.month,
      0,
    );
    return !ultimoDiaAnterior.isBefore(_soloFecha(minima));
  }

  // Se puede ir al mes siguiente si su primer día no es posterior a fechaMaxima.
  bool get _hayMesSiguiente {
    final DateTime? maxima = widget.fechaMaxima;
    if (maxima == null) {
      return true;
    }
    final DateTime primerDiaSiguiente = DateTime(
      _mesVisible.year,
      _mesVisible.month + 1,
      1,
    );
    return !primerDiaSiguiente.isAfter(_soloFecha(maxima));
  }

  void _seleccionar(DateTime dia) {
    setState(() {
      _seleccionada = dia;
    });
    widget.onFechaSeleccionada(dia);
  }

  void _cambiarMes(int cambio) {
    setState(() {
      _mesVisible = DateTime(_mesVisible.year, _mesVisible.month + cambio, 1);
    });
    widget.onMesCambiado?.call(_mesVisible);
  }

  @override
  Widget build(BuildContext context) {
    final String textoFecha =
        '${_diasCortos[_seleccionada.weekday - 1]}, ${_seleccionada.day} de ${_meses[_seleccionada.month - 1]}';
    final String textoMes =
        '${_capitalizar(_meses[_mesVisible.month - 1])} de ${_mesVisible.year}';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _colorBorde),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F111827),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Parte superior: título y fecha elegida.
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.titulo,
                  style: const TextStyle(fontSize: 13, color: _colorTextoSuave),
                ),
                const SizedBox(height: 6),
                Text(
                  textoFecha,
                  style: const TextStyle(fontSize: 24, color: _colorTexto),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: _colorBorde),
          // Parte inferior: mes con flechas, iniciales de los días y cuadrícula.
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
            child: Column(
              children: [
                _construirCabeceraMes(textoMes),
                const SizedBox(height: 8),
                _construirFilaIniciales(),
                const SizedBox(height: 4),
                ..._construirSemanas(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Fila con el nombre del mes y las flechas para cambiar de mes.
  Widget _construirCabeceraMes(String textoMes) {
    return Row(
      children: [
        Expanded(
          child: Text(
            textoMes,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: _colorTexto,
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_left, size: 20),
          tooltip: 'Mes anterior',
          color: _colorTexto,
          visualDensity: VisualDensity.compact,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          padding: EdgeInsets.zero,
          onPressed: _hayMesAnterior ? () => _cambiarMes(-1) : null,
        ),
        const SizedBox(width: 4),
        IconButton(
          icon: const Icon(Icons.chevron_right, size: 20),
          tooltip: 'Mes siguiente',
          color: _colorTexto,
          visualDensity: VisualDensity.compact,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          padding: EdgeInsets.zero,
          onPressed: _hayMesSiguiente ? () => _cambiarMes(1) : null,
        ),
      ],
    );
  }

  // Fila con L M X J V S D.
  Widget _construirFilaIniciales() {
    return Row(
      children: _inicialesDias.map((inicial) {
        return Expanded(
          child: Center(
            child: Text(
              inicial,
              style: const TextStyle(fontSize: 12, color: _colorTextoSuave),
            ),
          ),
        );
      }).toList(),
    );
  }

  // Construye las filas de semanas. Cada fila tiene siempre 7 celdas.
  List<Widget> _construirSemanas() {
    final DateTime primerDia = DateTime(_mesVisible.year, _mesVisible.month, 1);

    // weekday: lunes = 1 ... domingo = 7. El desfase es cuántas celdas vacías
    // hay antes del día 1 (con la semana empezando en lunes).
    final int desfase = primerDia.weekday - 1;

    // El día 0 del mes siguiente es el último día de este mes.
    final int diasEnMes = DateTime(
      _mesVisible.year,
      _mesVisible.month + 1,
      0,
    ).day;

    final int numeroFilas = (desfase + diasEnMes + 6) ~/ 7;

    final List<Widget> semanas = [];
    for (int fila = 0; fila < numeroFilas; fila++) {
      final List<Widget> celdas = [];
      for (int columna = 0; columna < 7; columna++) {
        final int numeroDia = fila * 7 + columna - desfase + 1;
        if (numeroDia < 1 || numeroDia > diasEnMes) {
          celdas.add(const Expanded(child: SizedBox(height: 40)));
        } else {
          final DateTime dia = DateTime(
            _mesVisible.year,
            _mesVisible.month,
            numeroDia,
          );
          celdas.add(Expanded(child: _construirDia(dia)));
        }
      }
      semanas.add(Row(children: celdas));
    }
    return semanas;
  }

  // Una celda de día: círculo de color si está seleccionado, gris si no se puede elegir.
  Widget _construirDia(DateTime dia) {
    final bool habilitado = _estaHabilitado(dia);
    final bool seleccionado = _mismoDia(dia, _seleccionada);

    Color colorTexto = _colorTexto;
    if (!habilitado) {
      colorTexto = _colorDeshabilitado;
    } else if (seleccionado) {
      colorTexto = Colors.white;
    }

    return GestureDetector(
      onTap: habilitado ? () => _seleccionar(dia) : null,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: 40,
        child: Center(
          child: Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: seleccionado ? widget.colorAcento : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Text(
              '${dia.day}',
              style: TextStyle(fontSize: 14, color: colorTexto),
            ),
          ),
        ),
      ),
    );
  }
}
