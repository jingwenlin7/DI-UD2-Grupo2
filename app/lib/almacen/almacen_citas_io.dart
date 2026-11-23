import 'dart:convert';
import 'dart:io';

import 'almacen_citas_base.dart';

/// Lee y escribe el archivo real assets/data/citas.json (escritorio).
class AlmacenCitas {
  AlmacenCitas({this.ruta = rutaArchivoCitas});

  /// Ruta del JSON, relativa a la carpeta app_citas.
  final String ruta;

  File get _archivo => File(ruta);

  /// Devuelve las citas; lista vacía si el archivo no existe.
  Future<List<dynamic>> leer() async {
    if (!_archivo.existsSync()) return <dynamic>[];

    final texto = _archivo.readAsStringSync();
    if (texto.trim().isEmpty) return <dynamic>[];

    final datos = jsonDecode(texto);
    if (datos is List) return datos;

    throw const FormatException(
      'El archivo de citas debe contener una lista JSON.',
    );
  }

  /// Añade una cita al final del JSON.
  Future<void> guardar(Map<String, dynamic> cita) async {
    final citas = await leer();
    citas.add(cita);

    // Crea assets/data si todavía no existe.
    _archivo.parent.createSync(recursive: true);
    _archivo.writeAsStringSync(
      const JsonEncoder.withIndent('  ').convert(citas),
    );
  }
}
