# Regla recursiva: cada rama termina en tres ramas nuevas, de longitud 0.64L.
# Para nivel 3: 1+3+9+27 = 40 ramas y 27 copas terminales.
static func ramas(nivel: int, largo: float = 2.15) -> Array:
	var resultado := []
	_crecer(resultado,Vector3.ZERO,Vector3.UP,largo,.20,nivel,0.0)
	return resultado

static func _crecer(salida: Array, inicio: Vector3, direccion: Vector3, largo: float, radio: float, nivel: int, fase: float) -> void:
	var fin := inicio+direccion*largo
	salida.append({"a":inicio,"b":fin,"radio":radio,"hoja":nivel==0})
	if nivel==0:
		return
	var lado := direccion.cross(Vector3.FORWARD).normalized()
	if lado.length()<.1: lado=Vector3.RIGHT
	var otro := direccion.cross(lado).normalized()
	for k in 3:
		var angulo := fase+TAU*k/3
		var nueva := (direccion*.8+(lado*cos(angulo)+otro*sin(angulo))*.65).normalized()
		_crecer(salida,fin,nueva,largo*.64,radio*.62,nivel-1,fase+.7)
