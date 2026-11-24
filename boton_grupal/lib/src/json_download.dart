// Implementación de descarga según la plataforma.
//
// En web se genera un archivo `.json` real y se descarga. En el resto de
// plataformas la persistencia sigue funcionando, pero la descarga directa no
// está disponible.
export 'json_download_stub.dart'
    if (dart.library.js_interop) 'json_download_web.dart';
