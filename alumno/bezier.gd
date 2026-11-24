# Curvas de Bézier por De Casteljau, para cualquier número de puntos.
# La matemática es propia. Curve2D solo se utiliza en ruta.gd para comparar.

# Un nivel: interpolar cada pareja de puntos vecinos.
static func _siguiente_nivel(nivel: Array, t: float) -> Array:
	var resultado := []
	for i in range(nivel.size() - 1):
		resultado.append(nivel[i] * (1.0 - t) + nivel[i + 1] * t)
	return resultado


# Repetir los niveles hasta obtener el punto de la curva.
static func bezier(puntos: Array, t: float) -> Vector2:
	if puntos.is_empty():
		return Vector2.ZERO
	var nivel := puntos.duplicate()
	for _paso in range(puntos.size() - 1):
		nivel = _siguiente_nivel(nivel, t)
	return nivel[0]


# n tramos requieren n+1 muestras, incluyendo los extremos.
static func muestrear(puntos: Array, n: int) -> PackedVector2Array:
	var polilinea := PackedVector2Array()
	if n <= 0:
		polilinea.append(bezier(puntos, 0.0))
		return polilinea
	for i in range(n + 1):
		polilinea.append(bezier(puntos, float(i) / n))
	return polilinea


static func largo(polilinea: PackedVector2Array) -> float:
	var total := 0.0
	for i in range(1, polilinea.size()):
		total += polilinea[i].distance_to(polilinea[i - 1])
	return total


# Recorrer los segmentos hasta gastar d; el final se limita al último punto.
static func punto_a_distancia(polilinea: PackedVector2Array, d: float) -> Vector2:
	if polilinea.is_empty():
		return Vector2.ZERO
	if d <= 0.0:
		return polilinea[0]
	var recorrido := 0.0
	for i in range(1, polilinea.size()):
		var tramo := polilinea[i].distance_to(polilinea[i - 1])
		if tramo > 0.0 and recorrido + tramo >= d:
			var fraccion := (d - recorrido) / tramo
			return polilinea[i - 1] + (polilinea[i] - polilinea[i - 1]) * fraccion
		recorrido += tramo
	return polilinea[polilinea.size() - 1]


# El último segmento de De Casteljau da la dirección tangente.
# Si no hay dirección, normalized() devuelve el vector cero.
static func tangente(puntos: Array, t: float) -> Vector2:
	if puntos.size() < 2:
		return Vector2.ZERO
	var nivel := puntos.duplicate()
	for _paso in range(puntos.size() - 2):
		nivel = _siguiente_nivel(nivel, t)
	return (nivel[1] - nivel[0]).normalized()
