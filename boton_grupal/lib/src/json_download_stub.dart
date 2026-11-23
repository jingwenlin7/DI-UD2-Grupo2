/// Fuera de web no se puede descargar un archivo desde el navegador.
bool get downloadJsonSupported => false;

/// Devuelve `false` porque esta plataforma no soporta la descarga directa.
Future<bool> downloadJsonFile(String fileName, String contents) async => false;
