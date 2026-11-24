# Bitácora de Isla Nácar

## Plan y alcance

Se definieron doce posiciones de fragmentos, dos rutas para guardianes, dos ruinas que requieren salto y un inicio en la orilla sur. El plan quedó guardado en `alumno/plan.gd`; el boceto representa esa distribución. Se implementaron las piezas de Mundo, Personaje y Juego sin modificar el registro de modalidad en Academia.

## Problema observado al exportar

Godot estaba instalado, pero faltaban las plantillas Web de su versión 4.7.2. Se inició la descarga oficial y después se extrajeron únicamente las plantillas Web mediante solicitudes parciales del archivo ZIP. La exportación final usa Compatibility y no requiere hilos ni cabeceras especiales para SharedArrayBuffer.

## Problema observado en la primera revisión visual

El personaje empezaba con un período de protección que también lo hacía parpadear. En algunas imágenes del comienzo parecía que el personaje no existía. Se separó la protección de la señal visual: al iniciar permanece visible y sólo parpadea después de un golpe. Se comprobó de nuevo la vista de juego.

## Problema observado al cerrar las pruebas

Las pruebas completaban el recorrido y salían con código de éxito, pero Godot avisaba que quedaban AudioStreamWAV y reproducciones en uso. La salida detallada identificó los sonidos. Se añadió una limpieza en `_exit_tree` que detiene los reproductores, quita sus streams y libera el diccionario; la prueba espera brevemente el cierre del servidor de audio. Después dejó de aparecer la advertencia.

## Cómo se comprobó el juego

La validación local terminó con 557 comprobaciones y cero fallos. El recorrido jugable recogió doce fragmentos en 1014 cuadros de física, hizo tres saltos y terminó con tres vidas. Las pruebas independientes verificaron derrota por tiempo y por daños, pausa, reanudación y reinicio. Se midieron desplazamientos horizontal y diagonal equivalentes y se comparó el suavizado de cámara a 30, 60 y 144 pasos por segundo. El retroceso de los golpes se mantiene separado de la velocidad de marcha para no sumarlo repetidamente como aceleración.

Se abrió la exportación Web mediante un servidor HTTP local. El personaje respondió al teclado, recogió un fragmento, saltó, pausó y reinició. No hubo errores de consola. La publicación requiere una cuenta autorizada y la comprobación del enlace final en otro navegador.

## Publicación y comprobación del enlace final

Se autorizó GitHub CLI con la cuenta 24460423-hue y se creó el repositorio público isla-nacar-godot. GitHub Pages publica la carpeta docs de main. El servidor confirmó el estado built y HTTPS activo. Se abrió el enlace público, se inició una partida, se caminó hasta recoger un fragmento, se saltó y se pausó; la consola no mostró errores. La primera descarga del motor comprimido fue de aproximadamente 10 MB y tardó alrededor de 91 segundos en la conexión de prueba.

## Siguiente comprobación concreta

Abrir el enlace HTTPS publicado desde otro navegador y jugar una partida completa personalmente. Revisar la distancia de seguimiento de la cámara y practicar las modificaciones de cada rol antes de la defensa.
