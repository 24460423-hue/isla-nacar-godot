# Isla Nácar

Juego 3D de recolección creado con Godot 4.7.2 para el proyecto final de Graficación. Explora una isla, recupera doce fragmentos de luz y evita a dos guardianes antes de que termine la marea. Incluye el código editable y la exportación web.

[Jugar en el navegador](https://24460423-hue.github.io/isla-nacar-godot/) · [Código del proyecto](https://github.com/24460423-hue/isla-nacar-godot) · [Boceto](https://24460423-hue.github.io/isla-nacar-godot/boceto.svg)

## Jugar

Abre el juego publicado o importa `project.godot` en Godot 4.7.2 y pulsa F5. Pulsa Comenzar o Enter para iniciar. Debes recoger los doce fragmentos; los dos que están sobre ruinas requieren saltar. Puedes ver los fragmentos y guardianes en el minimapa.

La primera carga descarga unos 10 MB del motor comprimido. Espera a que termine la barra de carga; el tiempo depende de la conexión.

| Control | Acción |
|---|---|
| WASD o flechas | Caminar |
| Espacio | Saltar |
| Shift | Correr |
| Q y E | Girar la cámara |
| P o Escape | Pausar y continuar |
| R | Reiniciar |
| M | Silenciar o activar los efectos |

La partida empieza con tres vidas y 150 segundos. Tocar un guardián quita una vida y da un breve período de protección. Caer al agua quita una vida y devuelve al personaje a la orilla. Recoger los doce fragmentos activa la pantalla Ganaste; agotar las vidas o el tiempo activa Perdiste.

## Requisitos técnicos

| Unidad y rol | Implementación |
|---|---|
| Unidad 1 y Juego | HUD 2D con rectángulos, líneas, polígonos y texto; paleta RGB y reloj que cambia de verde a rojo en HSV |
| Unidad 2 y Mundo y Juego | Árboles recursivos de tres ramas por nivel; una Bézier y una B-spline evaluadas en código |
| Unidad 3 y Mundo y Personaje | Terreno ArrayMesh de 6561 vértices y 12800 triángulos, colisión de la malla, movimiento y salto 3D, cámara en perspectiva |
| Unidad 4 y Mundo | Textura propia de arena, materiales de color y brillo, luz direccional con sombras y shaders de agua y bandas de iluminación |
| Unidad 5 y Personaje y Juego | AnimationPlayer con cuadros clave para reposo, caminar, correr y saltar; gravedad y seguimiento de cámara calculados con dt; estados de juego |

Las tres piezas están implementadas. La modalidad de trabajo y los roles deben registrarse personalmente en Academia: el proyecto no modifica ese registro definitivo.

## Archivos principales

- `alumno/plan.gd`: distribución y reglas del diseño.
- `alumno/principal.gd`: puntaje, tiempo, vidas, estados, recolección y reinicio.
- `alumno/terreno.gd` y `mundo.gd`: malla propia, colisión, iluminación, materiales y decoración.
- `alumno/fractal3d.gd`: regla recursiva de los árboles.
- `alumno/jugador.gd`: movimiento, salto y animación por cuadros clave.
- `alumno/camara_seguidora.gd`: seguimiento exponencial y perspectiva.
- `alumno/recolectable.gd` y `obstaculo.gd`: Areas3D y recorridos.
- `alumno/hud.gd`: interfaz dibujada con primitivas 2D.
- `alumno/agua.gdshader` y `bandas.gdshader`: shaders escritos para el juego.
- `alumno/recursos`: textura e icono SVG propios, efectos de sonido sintetizados y shell HTML.
- `alumno/bezier.gd`, `bspline.gd` y `mallas.gd`: bibliotecas de las misiones anteriores, reutilizadas sin cambios.
- `pruebas/verificar.gd`: comprobación reproducible y recorrido completo con física.
- `Boceto-Isla-Nacar.svg`: esquema de la distribución del plan.
- `GUIA_DEFENSA.md`, `BITACORA.md` y `USO_IA.md`: preparación y registro del proyecto.

## Exportar a web

El preset Web usa Compatibility y un solo hilo. Instala las plantillas oficiales de exportación 4.7.2, abre Proyecto → Exportar → Web y exporta como `index.html` en una carpeta vacía. Conserva juntos los archivos HTML, JavaScript, WASM, PCK y los demás archivos generados. Puedes subir esa carpeta comprimida a itch.io o servirla con GitHub Pages.

Para probar una exportación local se necesita un servidor HTTP; no basta con abrir el HTML por doble clic:

```powershell
python -m http.server 8064 --directory docs
```

Después abre `http://localhost:8064`. La carpeta `docs` contiene la exportación preparada para GitHub Pages. El código del juego sigue estando en la raíz del repositorio.

## Verificar

Con Godot disponible en la terminal:

```powershell
godot --headless --path . --script res://pruebas/verificar.gd --audio-driver Dummy --fixed-fps 60
```

La prueba comprueba las mallas, las curvas, el fractal, el movimiento diagonal normalizado, el salto, la cámara con dt, la recolección con colisiones, la protección y el retroceso tras un golpe, victoria, derrota, pausa y reinicio. El recorrido final conduce al personaje por los doce objetos sin teletransportarlo ni darle vidas extra. En la versión entregada se obtuvieron 557 comprobaciones sin fallos.

También se probó la exportación Web en un navegador: cargó la escena, respondió al teclado, recogió un fragmento, saltó, pausó, continuó y reinició sin errores de consola. Estas comprobaciones técnicas no sustituyen la defensa individual ante el docente.

## Autoría y recursos

El proyecto se construyó con asistencia de ChatGPT/Codex; el alcance y la verificación están descritos en `USO_IA.md`. Las mallas, los SVG y los sonidos se generan por código y no requieren paquetes de arte externos. El motor Godot conserva su propia licencia MIT.
