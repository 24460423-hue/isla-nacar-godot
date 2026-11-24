# Guía de defensa de Isla Nácar

Prepara una demostración de unos diez minutos. Debes poder explicar el código y hacer el cambio que te pida el docente. Esta guía cubre los tres roles implementados; el reparto que registres en Academia determina qué debes defender personalmente.

## Demostración

1. Abre el enlace del juego y pulsa Comenzar. Mueve al personaje en horizontal y diagonal, salta y gira la cámara.
2. Recoge un fragmento y muestra que suma un punto una sola vez. Enseña una de las dos ruinas que requiere saltar.
3. Señala las rutas rosa y lila: una es Bézier de ida y vuelta y la otra es una B-spline cerrada.
4. Muestra una sombra, la textura del suelo y las ondas del agua. Abre el código de una rama fractal.
5. Pausa el juego y comprueba que el reloj se detiene. Continúa y muestra la pantalla de victoria o derrota, seguida del reinicio.
6. Abre las funciones que correspondan a tu rol y explica una decisión y una alternativa.

## Mundo

`terreno.gd` evalúa una altura para cada punto de una cuadrícula de 81 por 81 vértices. Cada celda se divide en dos triángulos, así que hay 80·80·2 = 12800 triángulos. Los índices se recorren en sentido horario visto desde arriba, la convención frontal de Godot. Las normales aproximan la pendiente mediante diferencias de altura en x y z. La colisión se crea a partir de los triángulos de esa misma malla.

La altura combina una zona interior suave con una caída hacia el agua. El borde depende del ángulo para evitar una isla perfectamente circular. Los UV repiten la textura SVG de arena; el color por vértice mezcla arena y pasto según la altura.

`fractal3d.gd` añade una rama y, si quedan niveles, llama tres veces a la misma regla con longitud multiplicada por 0.64. En nivel 3 cada árbol tiene 1+3+9+27 = 40 ramas y 27 copas terminales. Los nueve árboles suman 360 ramas y 243 copas. MultiMesh agrupa sus instancias para reducir llamadas de dibujo.

La luz direccional representa al sol: su dirección determina la dirección de las sombras; el color y la energía modifican la iluminación. La luz puntual del faro ilumina su entorno cercano y aumenta al ganar. El material del agua desplaza los vértices con seno y coseno en función de TIME y recalcula una normal aproximada. El shader de los guardianes cuantiza el producto punto normal-luz para formar bandas.

Cambios para practicar:

- Cambia `Sol.rotation` y `light_color`, y explica el desplazamiento de la sombra.
- Cambia `bandas` de 3 a 4 en el ShaderMaterial de un guardián y explica la cuantización de la luz.
- Cambia `NIVEL_FRACTAL` de 3 a 4: cada árbol pasará de 40 a 121 ramas y de 27 a 81 copas. El número de ramas nuevas se triplica; el total suma todos los niveles.

## Personaje

`direccion_normalizada` limita la longitud del vector de entrada a 1 y lo gira según la orientación horizontal de la cámara. Así (1,1) no produce una rapidez de raíz de dos veces la de (1,0). La velocidad se expresa en metros por segundo. `move_and_slide` ya utiliza el paso de física; no hay que multiplicar la velocidad por dt otra vez.

La gravedad es una aceleración: se resta gravedad·dt a la velocidad vertical. Al saltar se asigna el impulso vertical 10. Con gravedad 24, la altura ideal es v²/(2g) = 100/48, aproximadamente 2.08 metros. La simulación discreta y la posición inicial sobre el suelo explican pequeñas diferencias medidas. El salto sólo se acepta desde el suelo o en un margen de 0.12 segundos al abandonar el borde.

La cámara persigue el foco con `1-exp(-rapidez*dt)`. Al subdividir un segundo en 30, 60 o 144 pasos, el error restante se multiplica por el mismo exp(-rapidez). Usar un factor fijo por cuadro cambiaría la suavidad con el framerate. Q y E modifican el azimut y la cámara mira al personaje desde una perspectiva de 52 grados.

AnimationPlayer reproduce cinco pistas de cuadros clave: rotación de dos piernas y dos brazos, y posición del cuerpo. Reposo, caminar, correr y saltar son animaciones distintas. El pivote Visual orienta todo el personaje y los pivotes de cada extremidad conservan su movimiento local.

Cambios para practicar:

- Duplica `rapidez_seguimiento` de 7 a 14 y conserva el factor exponencial con dt.
- Reduce `impulso_salto` de 10 a 8 sin cambiar la gravedad. La altura ideal baja a 64/48, aproximadamente 1.33 metros. Comprueba si todavía llegas a las ruinas.
- Cambia la velocidad al mantener Shift y enseña la transición a la animación correr.

## Juego

El primer guardián evalúa la Bézier mediante la biblioteca de la misión 8. La curva se muestrea y se recorre por distancia acumulada; el período de ida y vuelta refleja la distancia al llegar al final. El segundo guardián evalúa la B-spline cerrada de la misión 9 y usa módulo para repetir la vuelta. En ambos casos la altura se toma del terreno para que los guardianes no se hundan ni floten.

Cada fragmento es un Area3D con una forma esférica. Al entrar un cuerpo del grupo jugador se marca `tomado`, se desactiva su monitorización y se emite una señal. Esa marca evita duplicar el puntaje. Los guardianes también detectan Area3D; después de un golpe hay 1.6 segundos de protección para no quitar una vida por cuadro.

El HUD dibuja sus paneles con rectángulos, líneas, polígonos y texto. Su paleta se especifica en RGB. El reloj usa HSV: el tono es la fracción de tiempo restante multiplicada por 0.32; al agotarse pasa de verde a rojo. La escala y el desplazamiento del HUD son una transformación 2D, por lo que mantiene su composición al cambiar el tamaño de pantalla.

El controlador sólo avanza tiempo y obstáculos en JUGANDO. Doce fragmentos producen GANASTE; cero vidas o cero segundos producen PERDISTE. INICIO y PAUSA son estados adicionales. Reiniciar restaura los doce objetos, las vidas, el reloj y la posición del personaje.

Cambios para practicar:

- Sustituye una ruta Bézier por `bspline_cerrada` y muestra los controles nuevos. Bézier interpola sus extremos; una B-spline uniforme aproxima los controles y tiene soporte local.
- Cambia el color del reloj desde HSV modificando tono o saturación, sin reemplazarlo por una cadena arbitraria de colores.
- Mueve el HUD variando la transformación de dibujo o las coordenadas de los paneles y conserva visibles los botones.
