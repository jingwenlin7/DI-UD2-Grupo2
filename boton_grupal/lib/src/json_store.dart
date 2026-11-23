import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'json_download.dart';

/// Guarda y recupera documentos JSON con un nombre de archivo libre.
///
/// En web el contenido se persiste en `localStorage` (vía
/// `shared_preferences`) usando el nombre del archivo como clave lógica, por
/// lo que cualquier otra página de la misma aplicación puede leerlo. Además,
/// en web se puede descargar un `.json` real con [download].
///
/// En Android, iOS, escritorio, etc. se usa el almacenamiento local de
/// `shared_preferences`; [download] devuelve `false` porque no existe un
/// navegador que descargue el archivo.
class JsonStore {
  /// Crea (o referencia) un archivo JSON llamado [fileName].
  ///
  /// Si el nombre no termina en `.json`, se añade automáticamente. Por
  /// ejemplo: `JsonStore(fileName: 'citas')` usa `citas.json`.
  JsonStore({required String fileName})
      : fileName = normalizeFileName(fileName);

  /// Nombre normalizado del archivo, por ejemplo `citas.json`.
  final String fileName;

  /// Prefijo interno para no mezclar los datos con otras preferencias.
  static const String keyPrefix = 'boton_grupal::json_file::';

  /// Indica si la plataforma actual permite descargar archivos desde la app.
  static bool get canDownload => downloadJsonSupported;

  /// Normaliza el nombre de archivo: quita espacios y garantiza la extensión.
  static String normalizeFileName(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError.value(
        name,
        'fileName',
        'El nombre del archivo JSON no puede estar vacío.',
      );
    }
    return trimmed.toLowerCase().endsWith('.json') ? trimmed : '$trimmed.json';
  }

  String get _storageKey => '$keyPrefix$fileName';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  /// Devuelve el contenido decodificado o `null` si el archivo no existe.
  Future<dynamic> read() async {
    final raw = (await _prefs).getString(_storageKey);
    if (raw == null || raw.isEmpty) return null;
    return jsonDecode(raw);
  }

  /// Indica si el archivo lógico ya tiene contenido.
  Future<bool> exists() async {
    final prefs = await _prefs;
    return prefs.containsKey(_storageKey);
  }

  /// Sobrescribe el archivo completo con [value].
  ///
  /// [value] debe ser codificable como JSON (mapas, listas, strings, números,
  /// booleanos o `null`).
  Future<void> write(dynamic value) async {
    final encoded = const JsonEncoder.withIndent('  ').convert(value);
    await (await _prefs).setString(_storageKey, encoded);
  }

  /// Guarda [value] en el archivo.
  ///
  /// * Con `append: true` (por defecto) añade el valor al final de una lista.
  /// * Con `append: false` reemplaza todo el contenido del archivo.
  /// * Si se indica [key], guarda el valor dentro de un mapa bajo esa clave.
  Future<void> save(
    dynamic value, {
    bool append = true,
    String? key,
  }) async {
    dynamic data;

    if (key != null) {
      final current = await read();
      final map = current == null
          ? <String, dynamic>{}
          : current is Map
              ? Map<String, dynamic>.from(current)
              : throw StateError(
                  'El archivo $fileName no contiene un objeto JSON; no se '
                  'puede guardar bajo la clave "$key".',
                );

      if (append) {
        final existing = map[key];
        final list = existing == null
            ? <dynamic>[]
            : existing is List
                ? List<dynamic>.from(existing)
                : throw StateError(
                    'La clave "$key" del archivo $fileName no contiene una '
                    'lista. Usa append: false para reemplazarla.',
                  );
        list.add(value);
        map[key] = list;
      } else {
        map[key] = value;
      }
      data = map;
    } else if (append) {
      final current = await read();
      final list = current == null
          ? <dynamic>[]
          : current is List
              ? List<dynamic>.from(current)
              : throw StateError(
                  'El archivo $fileName no contiene una lista. Usa '
                  'append: false para sobrescribirlo.',
                );
      list.add(value);
      data = list;
    } else {
      data = value;
    }

    await write(data);
  }

  /// Lee el archivo como lista. Devuelve una lista vacía si no existe.
  ///
  /// Lanza [FormatException] si el archivo contiene un valor que no es lista.
  Future<List<dynamic>> readList() async {
    final data = await read();
    if (data == null) return <dynamic>[];
    if (data is List) return data;
    throw FormatException('El archivo $fileName no contiene una lista JSON.');
  }

  /// Lee el archivo como objeto. Devuelve `null` si no existe.
  ///
  /// Lanza [FormatException] si el archivo contiene un valor que no es objeto.
  Future<Map<String, dynamic>?> readMap() async {
    final data = await read();
    if (data == null) return null;
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    throw FormatException('El archivo $fileName no contiene un objeto JSON.');
  }

  /// Devuelve el contenido formateado para mostrarlo o descargarlo.
  Future<String> readAsPrettyJson() async {
    final data = await read();
    if (data == null) return '{}';
    return const JsonEncoder.withIndent('  ').convert(data);
  }

  /// Borra el contenido del archivo.
  Future<void> clear() async {
    await (await _prefs).remove(_storageKey);
  }

  /// Descarga el archivo como `.json` real (solo disponible en web).
  ///
  /// Devuelve `true` si se lanzó la descarga. Si el archivo está vacío o la
  /// plataforma no es web, devuelve `false`.
  Future<bool> download() async {
    if (!downloadJsonSupported) return false;
    final data = await read();
    if (data == null) return false;
    final contents = const JsonEncoder.withIndent('  ').convert(data);
    return downloadJsonFile(fileName, contents);
  }

  /// Lista los nombres de todos los archivos JSON creados con [JsonStore].
  static Future<List<String>> listFiles() async {
    final prefs = await SharedPreferences.getInstance();
    final files = prefs
        .getKeys()
        .where((key) => key.startsWith(keyPrefix))
        .map((key) => key.substring(keyPrefix.length))
        .toList()
      ..sort();
    return files;
  }

  /// Elimina un archivo JSON por su nombre.
  static Future<void> deleteFile(String fileName) async {
    final normalized = normalizeFileName(fileName);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$keyPrefix$normalized');
  }

  @override
  String toString() => 'JsonStore($fileName)';
}
