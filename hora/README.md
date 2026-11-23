# hora

Componente Flutter **SelectorHora**: tarjeta "Selecciona la hora" con dos cajas
(hora y minutos) y un chip para alternar entre 24 h y 12 h. Al pulsar una caja
se abre el `showTimePicker` de `material_ui`.

## Cómo funciona

1. `SelectorHora` es un `StatefulWidget`: guarda en su estado la hora actual
   (`_hora`) y el formato actual (`_formato24h`), que empiezan con los valores
   que le pasa la app (`horaInicial` y `formato24h`).
2. Dibuja una tarjeta con dos cajas (hora y minutos) y el chip "24 h" / "12 h".
   Las cajas son una clase privada reutilizable (`_Caja`).
3. Al pulsar la hora o los minutos se abre el selector de hora oficial
   (`showTimePicker`). Si el usuario acepta, se guarda la nueva hora, se redibuja
   la tarjeta y se llama al evento `onChanged`. Si cancela, no pasa nada.
4. Al pulsar el chip se cambia entre 24 h y 12 h, se redibuja (en 12 h aparece
   AM/PM) y se llama al evento `onFormatoChanged`.
5. Con `habilitado: false` las cajas y el chip no responden.

Archivos:

- `lib/hora.dart`: exporta el widget (lo único público del paquete).
- `lib/src/selector_hora.dart`: el código del componente, comentado.
- `test/hora_test.dart`: pruebas de widget, comentadas.

## Propiedades

| Propiedad | Tipo | Por defecto | Descripción |
|---|---|---|---|
| `horaInicial` | `TimeOfDay` | `09:30` | Hora mostrada al inicio |
| `titulo` | `String` | `'Selecciona la hora'` | Título de la tarjeta |
| `etiquetaHora` | `String` | `'Hora'` | Texto bajo la hora |
| `etiquetaMinutos` | `String` | `'Minutos'` | Texto bajo los minutos |
| `formato24h` | `bool` | `true` | Formato 24 h (`false` = 12 h con AM/PM) |
| `colorPrincipal` | `Color` | `0xFF3B59B6` | Color del selector de hora y del chip |
| `habilitado` | `bool` | `true` | Permite o bloquea la interacción |

## Eventos

- `onChanged(TimeOfDay)`: el usuario confirma una nueva hora.
- `onFormatoChanged(bool)`: el usuario alterna el formato (`true` = 24 h).

## Uso

En el `pubspec.yaml` de la app:

```yaml
dependencies:
  hora:
    path: ../hora
```

```dart
import 'package:hora/hora.dart';

SelectorHora(
  horaInicial: const TimeOfDay(hour: 9, minute: 30),
  onChanged: (t) => print('Hora: ${t.format(context)}'),
  onFormatoChanged: (es24h) => print('24h: $es24h'),
)
```

## Pruebas

```
flutter test
```

Hay 5 pruebas de widget: valores por defecto, chip de formato con
`onFormatoChanged`, selector con `onChanged`, cancelar el selector y estado
deshabilitado.
