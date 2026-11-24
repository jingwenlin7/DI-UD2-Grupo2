# boton_grupal

Paquete de Flutter con un **botón reutilizable** que guarda un **payload
dinámico** en un **archivo JSON de nombre configurable**, y permite leerlo
desde cualquier otra página de la aplicación.

## Instalación local

En el `pubspec.yaml` de la app:

```yaml
dependencies:
  boton_grupal:
    path: ../boton_grupal
```

## Uso básico

```dart
import 'package:boton_grupal/boton_grupal.dart';

BotonGrupal(
  label: 'Guardar cita',
  icon: Icons.event_available_rounded,
  payload: {
    'titulo': 'Cita con Ana',
    'fecha': {'dia': 23, 'mes': 11, 'anio': 2026},
    'hora': {'hora': 14, 'minutos': 30},
  },
  jsonFileName: 'citas.json', // el archivo puede llamarse como quieras
  appendToList: true,          // acumula citas en una lista
  backgroundColor: const Color(0xFF5B5BD6),
  onPressed: (payload) {
    // Opcional: hacer algo más con el payload dinámico.
  },
);
```

Al pulsar, se escribe en `citas.json`:

```json
[
  {
    "titulo": "Cita con Ana",
    "fecha": { "dia": 23, "mes": 11, "anio": 2026 },
    "hora": { "hora": 14, "minutos": 30 }
  }
]
```

## Leer el JSON desde otra página

```dart
import 'package:boton_grupal/boton_grupal.dart';

final store = JsonStore(fileName: 'citas.json');
final citas = await store.readList(); // List<dynamic>
final todoElContenido = await store.read(); // dynamic
final texto = await store.readAsPrettyJson();

// En web, descarga un archivo .json real con ese nombre:
await store.download();
```

## Atributos del botón

| Atributo | Tipo | Descripción |
| --- | --- | --- |
| `label` | `String` | Texto visible (obligatorio). |
| `payload` | `dynamic` | Cualquier dato codificable como JSON. |
| `jsonFileName` | `String?` | Nombre del archivo JSON de destino. |
| `appendToList` | `bool` | Acumula en lista (`true`) o sobrescribe (`false`). |
| `jsonKey` | `String?` | Guarda el payload bajo una clave de un objeto. |
| `autoSave` | `bool` | Desactiva el guardado automático. |
| `onPressed` | `FutureOr<void> Function(dynamic)?` | Callback externo. |
| `enabled` | `bool` | Habilita o deshabilita el botón. |
| `icon` | `IconData?` | Icono opcional. |
| `width` | `double?` | Ancho fijo opcional. |
| `backgroundColor` / `foregroundColor` | `Color?` | Colores externos. |
| `borderRadius` / `padding` / `elevation` | varios | Estilo. |
| `textStyle` / `tooltip` | varios | Estilo y ayuda. |
| `showSnackBar` | `bool` | Avisos de éxito/error. |
| `successMessage` / `errorMessage` | `String?` | Textos de aviso. |

## Persistencia

- **Web:** el documento vive en `localStorage` (a través de
  `shared_preferences`) bajo el nombre del archivo. `download()` genera y
  descarga un `.json` real.
- **Android, iOS, escritorio:** se usa el almacenamiento de
  `shared_preferences`; la descarga directa no está disponible
  (`JsonStore.canDownload == false`).
