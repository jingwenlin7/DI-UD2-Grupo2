# CalendarioReserva

Widget de calendario mensual en Flutter para seleccionar una fecha. Muestra la fecha elegida en la cabecera, flechas para moverse entre meses y la cuadrícula de días empezando en lunes. También permite bloquear días fuera de un rango.

## Propiedades

| Nombre | Tipo | Por defecto | Para qué sirve |
| :--- | :--- | :--- | :--- |

| `onFechaSeleccionada` | `ValueChanged<DateTime>` | *Obligatoria* | Función que se llama cuando el usuario pulsa un día válido. |
| `onMesCambiado` | `ValueChanged<DateTime>?` | `null` | Función que se llama al cambiar de mes con las flechas. |
| `fechaInicial` | `DateTime?` | `null` (día actual) | Día que aparece marcado al abrir el componente. |
| `fechaMinima` | `DateTime?` | `null` (sin límite) | Primer día seleccionable. Los anteriores salen deshabilitados. |
| `fechaMaxima` | `DateTime?` | `null` (sin límite) | Último día seleccionable. Los posteriores salen deshabilitados. |
| `titulo` | `String` | `'Selecciona la fecha'` | Texto pequeño que aparece arriba del todo. |
| `colorAcento` | `Color` | `Color(0xFF3B59B6)` | Color del círculo del día seleccionado. |

## Eventos

* `onFechaSeleccionada`: recibe el `DateTime` del día que ha tocado el usuario (con la hora a `00:00:00`).
* `onMesCambiado`: recibe el `DateTime` correspondiente al día `1` del nuevo mes visible.

## Ejemplo de uso

```dart
import 'package:flutter/material.dart';
import 'package:calendario_reserva/calendario_reserva.dart';

class EjemploCalendario extends StatefulWidget {
  const EjemploCalendario({super.key});

  @override
  State<EjemploCalendario> createState() => _EjemploCalendarioState();
}

class _EjemploCalendarioState extends State<EjemploCalendario> {
  DateTime _fecha = DateTime(2026, 11, 17);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: CalendarioReserva(
          fechaInicial: _fecha,
          fechaMinima: DateTime(2026, 11, 1),
          fechaMaxima: DateTime(2026, 12, 31),
          onFechaSeleccionada: (nuevaFecha) {
            setState(() {
              _fecha = nuevaFecha;
            });
          },
        ),
      ),
    );
  }
}