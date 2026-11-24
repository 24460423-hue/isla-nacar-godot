# B-splines cúbicas uniformes. Cada tramo usa cuatro controles consecutivos.
# Los índices periódicos permiten construir tanto curvas abiertas como cerradas.

# Base cúbica uniforme: los cuatro pesos suman uno.
static func base(t: float) -> Array:
	var u := 1.0 - t
	return [
		u * u * u / 6.0,
		(3.0 * t * t * t - 6.0 * t * t + 4.0) / 6.0,
		(-3.0 * t * t * t + 3.0 * t * t + 3.0 * t + 1.0) / 6.0,
		t * t * t / 6.0,
	]


static func bspline(P: Array, i: int, t: float) -> Vector2:
	if P.is_empty():
		return Vector2.ZERO
	var b := base(t)
	var punto := Vector2.ZERO
	for k in range(4):
		punto += P[(i + k) % P.size()] * b[k]
	return punto


static func numero_de_tramos(P: Array, cerrada: bool = false) -> int:
	if cerrada:
		return P.size()
	return maxi(P.size() - 3, 0)


# n muestras por tramo, más el punto final.
static func _polilinea(P: Array, tramos: int, n: int) -> PackedVector2Array:
	var polilinea := PackedVector2Array()
	if tramos < 1:
		return polilinea
	for i in range(tramos):
		for k in range(n):
			polilinea.append(bspline(P, i, float(k) / n))
	polilinea.append(bspline(P, tramos - 1, 1.0))
	return polilinea


static func bspline_abierta(P: Array, n: int) -> PackedVector2Array:
	return _polilinea(P, numero_de_tramos(P, false), n)


static func bspline_cerrada(P: Array, n: int) -> PackedVector2Array:
	return _polilinea(P, numero_de_tramos(P, true), n)


# Dirección de avance: la derivada de la base, normalizada.
static func tangente_bspline(P: Array, i: int, t: float) -> Vector2:
	if P.is_empty():
		return Vector2.ZERO
	var d := [
		-(1.0 - t) * (1.0 - t) / 2.0,
		(3.0 * t * t - 4.0 * t) / 2.0,
		(-3.0 * t * t + 2.0 * t + 1.0) / 2.0,
		t * t / 2.0,
	]
	var v := Vector2.ZERO
	for k in range(4):
		v += P[(i + k) % P.size()] * d[k]
	return v.normalized()


# Medir el cambio en una copia, comparando cinco valores de t por tramo.
static func tramos_afectados(P: Array, indice: int, desplazamiento: Vector2, cerrada: bool = false) -> Array:
	var movidos := P.duplicate()
	movidos[indice] = P[indice] + desplazamiento
	var afectados := []
	for i in range(numero_de_tramos(P, cerrada)):
		var cambia := false
		for paso in range(5):
			var t := paso / 4.0
			if bspline(P, i, t).distance_to(bspline(movidos, i, t)) > 0.000001:
				cambia = true
		if cambia:
			afectados.append(i)
	return afectados
