// Usa dart:io en escritorio y la versión de solo lectura en web.
export 'almacen_citas_base.dart';
export 'almacen_citas_io.dart'
    if (dart.library.js_interop) 'almacen_citas_web.dart';
