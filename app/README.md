# app_citas

Aplicación de escritorio en Flutter que usa el paquete local
[`boton_grupal`](../boton_grupal/README.md).

## Funcionalidad

- Calendario reutilizable `Calendario` (copiado de
  `DI-UD2-Grupo2-develop/calendario`): fecha elegida en grande, meses con
  flechas y cuadrícula de lunes a domingo.
- Selector de hora `SelectorHora` (copiado de
  `DI-UD2-Grupo2-develop/hora`): cajas de hora y minutos con el
  `showTimePicker` de Flutter y chip para alternar 12 h / 24 h.
- Límites de fecha: desde hoy hasta el mismo día del próximo año. Los días
  fuera del rango se ven deshabilitados y las flechas de mes se bloquean en los
  extremos.
- Campo para el título de la cita.
- Archivo JSON fijo, sin nombre editable: `assets/data/citas.json`.
- Lista de citas guardadas en la misma página, leída del archivo real.
- Botón **Info** del paquete `boton_grupal` en la esquina superior derecha, con
  un cuarto del ancho de la pantalla. Muestra u oculta un párrafo explicativo
  superpuesto; el párrafo no ocupa espacio mientras está oculto.
- Sin rutas y sin pantallas adicionales.

## Ejecutar

El guardado real necesita `dart:io`, así que hay que ejecutar la app de
escritorio desde la carpeta `app_citas`:

```bash
flutter pub get
flutter run -d linux
```

La ruta `assets/data/citas.json` es relativa a la carpeta desde la que se
ejecuta la app, por lo que el archivo que se modifica es el del proyecto.

En web la app se puede compilar y abrir, pero **no puede escribir** en
`assets/data/citas.json`: los assets son de solo lectura en el navegador.

## Pruebas

```bash
flutter test
```

Las pruebas usan un archivo temporal y comprueban que aparecen el calendario, el
selector de hora y los botones, que al pulsar «Guardar cita» se guardan día,
mes, año, hora y minutos en el JSON, que el botón Info mide un cuarto del ancho,
que el párrafo aparece superpuesto sin mover el contenido y que la página se
adapta a una pantalla estrecha.

## Estructura

```text
assets/
└── data/
    └── citas.json               # archivo JSON real (se declara en pubspec)
lib/
├── main.dart                    # MaterialApp, Scaffold, Stack y página única
├── almacen/
│   ├── almacen_citas.dart       # elige la versión IO o web
│   ├── almacen_citas_base.dart  # ruta fija del archivo
│   ├── almacen_citas_io.dart    # lectura y escritura real (escritorio)
│   └── almacen_citas_web.dart   # solo lectura en web
└── widgets/
    ├── calendario.dart          # Calendario del proyecto de grupo
    └── selector_hora.dart       # SelectorHora del proyecto de grupo
```

La app no usa el `JsonStore` del paquete: guarda directamente en el archivo
`assets/data/citas.json` mediante `dart:io`. Del paquete usa `BotonGrupal` para
el botón de guardar y para el botón Info.

## Botón Info

El cuerpo de la página es un `Stack`:

1. El contenido con `SingleChildScrollView`.
2. El párrafo explicativo, solo cuando está visible, en un `Positioned`.
3. El botón Info como último hijo, de modo que queda por encima de todo.

El botón mide `MediaQuery.sizeOf(context).width / 4` y está en
`Positioned(top: 8, right: 8)`. El párrafo aparece debajo, superpuesto al
contenido, y se puede cerrar pulsando otra vez el botón o la «X».
