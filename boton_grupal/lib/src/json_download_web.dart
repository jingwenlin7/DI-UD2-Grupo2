import 'dart:js_interop';

import 'package:web/web.dart' as web;

/// En web sí se puede descargar un archivo generado en el navegador.
bool get downloadJsonSupported => true;

/// Genera un `Blob` con el contenido y lanza la descarga con el nombre dado.
Future<bool> downloadJsonFile(String fileName, String contents) async {
  final blob = web.Blob(
    <JSAny>[contents.toJS].toJS,
    web.BlobPropertyBag(type: 'application/json;charset=utf-8'),
  );
  final url = web.URL.createObjectURL(blob);
  final anchor = web.HTMLAnchorElement()
    ..href = url
    ..download = fileName
    ..style.display = 'none';

  web.document.body?.appendChild(anchor);
  anchor.click();
  anchor.remove();
  web.URL.revokeObjectURL(url);
  return true;
}
