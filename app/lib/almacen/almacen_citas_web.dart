import 'dart:convert';

import 'package:flutter/services.dart';

import 'almacen_citas_base.dart';

/// Versión web: el navegador solo puede leer el JSON incluido.
class AlmacenCitas {
  AlmacenCitas({this.ruta = rutaArchivoCitas});

  final String ruta;

  /// Lee el JSON empaquetado como asset.
  Future<List<dynamic>> leer() async {
    try {
      final texto = await rootBundle.loadString(ruta);
      if (texto.trim().isEmpty) return <dynamic>[];
      final datos = jsonDecode(texto);
      return datos is List ? datos : <dynamic>[];
    } catch (_) {
      return <dynamic>[];
    }
  }

  /// En web no se puede escribir en assets.
  Future<void> guardar(Map<String, dynamic> cita) async {
    throw UnsupportedError(
      'En web no se puede escribir en $ruta. Ejecuta la app de escritorio '
      'con "flutter run -d linux" para guardar en el archivo real.',
    );
  }
}
