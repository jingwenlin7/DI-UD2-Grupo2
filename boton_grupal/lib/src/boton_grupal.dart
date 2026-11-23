import 'dart:async';

import 'package:flutter/material.dart';

import 'json_store.dart';

/// Recibe el payload cuando se pulsa el botón.
typedef BotonGrupalCallback = FutureOr<void> Function(dynamic payload);

/// Botón reutilizable que guarda un payload dinámico en JSON.
///
/// ```dart
/// BotonGrupal(
///   label: 'Guardar',
///   payload: {'dia': 1, 'hora': 9},
///   jsonFileName: 'datos.json',
///   onPressed: (payload) {},
/// );
/// ```
class BotonGrupal extends StatefulWidget {
  const BotonGrupal({
    super.key,
    required this.label,
    this.onPressed,
    this.payload,
    this.jsonFileName,
    this.appendToList = true,
    this.jsonKey,
    this.autoSave = true,
    this.showSnackBar = true,
    this.successMessage,
    this.errorMessage,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation = 3,
    this.borderRadius = 14,
    this.padding = const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
    this.textStyle,
    this.width,
    this.enabled = true,
    this.tooltip,
  }) : assert(
          jsonKey == null || jsonFileName != null,
          'jsonKey solo tiene sentido cuando se indica jsonFileName.',
        );

  /// Texto visible del botón.
  final String label;

  /// Se ejecuta después de guardar y recibe el mismo [payload].
  final BotonGrupalCallback? onPressed;

  /// Dato que se guarda y se entrega al callback: mapa, lista, texto...
  final dynamic payload;

  /// Nombre del JSON de destino. Si es `null`, no se guarda nada.
  final String? jsonFileName;

  /// `true` añade a una lista; `false` reemplaza el archivo.
  final bool appendToList;

  /// Clave opcional para guardar el payload dentro de un objeto JSON.
  final String? jsonKey;

  /// Desactiva el guardado automático para hacerlo en [onPressed].
  final bool autoSave;

  /// Muestra un aviso al guardar o al fallar.
  final bool showSnackBar;

  /// Mensaje de éxito personalizado.
  final String? successMessage;

  /// Mensaje de error personalizado.
  final String? errorMessage;

  /// Icono opcional a la izquierda del texto.
  final IconData? icon;

  /// Color de fondo; por defecto, el primario del tema.
  final Color? backgroundColor;

  /// Color del texto y del icono.
  final Color? foregroundColor;

  /// Elevación del botón.
  final double elevation;

  /// Radio de las esquinas.
  final double borderRadius;

  /// Espaciado interno.
  final EdgeInsetsGeometry padding;

  /// Estilo del texto.
  final TextStyle? textStyle;

  /// Ancho fijo opcional.
  final double? width;

  /// Permite deshabilitar el botón.
  final bool enabled;

  /// Texto del tooltip; por defecto usa [label].
  final String? tooltip;

  @override
  State<BotonGrupal> createState() => _BotonGrupalState();
}

class _BotonGrupalState extends State<BotonGrupal> {
  bool _saving = false;

  Future<void> _handlePressed() async {
    if (!widget.enabled || _saving) return;

    final messenger =
        widget.showSnackBar ? ScaffoldMessenger.maybeOf(context) : null;
    final theme = Theme.of(context);

    setState(() => _saving = true); // evita dobles pulsaciones
    try {
      String? savedFileName;

      // 1. Guarda el payload en el JSON, si hay archivo configurado.
      if (widget.autoSave && widget.jsonFileName != null) {
        final store = JsonStore(fileName: widget.jsonFileName!);
        await store.save(
          widget.payload,
          append: widget.appendToList,
          key: widget.jsonKey,
        );
        savedFileName = store.fileName;
      }

      // 2. Ejecuta el callback externo con el mismo payload.
      await widget.onPressed?.call(widget.payload);

      // 3. Avisa de que se guardó correctamente.
      if (savedFileName != null && messenger != null && mounted) {
        messenger
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(
                widget.successMessage ?? 'Datos guardados en $savedFileName',
              ),
            ),
          );
      }
    } catch (error) {
      // Si falla el guardado, avisa del error.
      if (messenger != null && mounted) {
        messenger
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              backgroundColor: theme.colorScheme.error,
              content: Text(
                widget.errorMessage ?? 'No se pudo completar la acción: $error',
              ),
            ),
          );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final background = widget.backgroundColor ?? theme.colorScheme.primary;
    final foreground = widget.foregroundColor ?? theme.colorScheme.onPrimary;

    // Estilo del botón.
    final style = ElevatedButton.styleFrom(
      backgroundColor: background,
      foregroundColor: foreground,
      disabledBackgroundColor: background.withValues(alpha: 0.4),
      disabledForegroundColor: foreground.withValues(alpha: 0.7),
      elevation: widget.elevation,
      shadowColor: background.withValues(alpha: 0.35),
      padding: widget.padding,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(widget.borderRadius),
      ),
      textStyle: widget.textStyle ??
          theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
    );

    final etiqueta = Text(
      widget.label,
      textAlign: TextAlign.center,
      overflow: TextOverflow.ellipsis,
    );

    final child = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Mientras guarda muestra un spinner; si no, su icono opcional.
        if (_saving) ...[
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(foreground),
            ),
          ),
          const SizedBox(width: 10),
        ] else if (widget.icon != null) ...[
          Icon(widget.icon, size: 20),
          const SizedBox(width: 10),
        ],
        // Con ancho fijo, Flexible evita que el texto desborde.
        if (widget.width == null) etiqueta else Flexible(child: etiqueta),
      ],
    );

    final button = ElevatedButton(
      onPressed: widget.enabled ? _handlePressed : null,
      style: style,
      child: child,
    );

    return SizedBox(
      width: widget.width,
      child: Tooltip(
        message: widget.tooltip ?? widget.label,
        child: button,
      ),
    );
  }
}
