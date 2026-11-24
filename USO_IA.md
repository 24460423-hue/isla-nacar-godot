# Uso de IA en el proyecto final

Este proyecto fue creado con asistencia de ChatGPT/Codex. El registro distingue lo que hizo la herramienta de lo que debes revisar y explicar personalmente.

## Qué se pidió

Se pidió leer la página de Isla de recolección de Academia EmCode, crear el proyecto completo de Godot, usar las herramientas necesarias y preparar el juego para entregarlo en web con su código.

## Qué produjo la asistencia

La herramienta propuso Isla Nácar, creó el plan y el boceto de distribución, programó el terreno, los árboles fractales, los shaders, los guardianes y sus curvas, el personaje, la cámara, la animación, las colisiones, el HUD y los estados. También generó los SVG, sintetizó los efectos de sonido, preparó pruebas y exportó el juego para Web.

## Qué se aceptó o se cambió

Se conservaron las bibliotecas de Bézier, B-spline y mallas de las misiones anteriores. Se eligió una isla con doce fragmentos y dos guardianes, cumpliendo las piezas de los tres roles. Durante la revisión se cambió la protección inicial para que el personaje se vea desde el comienzo, y se corrigió la liberación de las reproducciones de audio al cerrar.

## Qué se verificó

Las comprobaciones automáticas ejecutadas por la herramienta validaron geometría, recursión, curvas, normalización de la entrada, salto, seguimiento de cámara con dt, animaciones, colisiones, estados y reinicio. Un recorrido con física condujo al personaje por los doce objetos sin teletransportes ni vidas extra. La exportación Web se abrió en un navegador y se probó con teclado: caminar, recoger, saltar, pausar, continuar y reiniciar. La consola no mostró errores.

## Qué debes comprobar personalmente

Juega la versión publicada desde otro navegador, revisa los archivos de los tres roles y practica los cambios de `GUIA_DEFENSA.md`. Al llenar la sección Uso de IA en Academia, describe qué aceptaste y qué verificaste tú. No marques «No usé IA» para este proyecto ni atribuyas a una prueba personal lo que sólo ejecutó la herramienta.
