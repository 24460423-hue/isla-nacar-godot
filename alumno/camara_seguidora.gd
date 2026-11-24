extends Node3D
@export var rapidez_seguimiento:=7.0
@export var altura:=12.4
@export var distancia:=13.5
var giro:=0.0
var foco:=Vector3.ZERO
var camara:Camera3D

func _ready() -> void:
	camara=Camera3D.new(); camara.name="Camara"; camara.fov=52; camara.near=.15; camara.far=160; camara.current=true; add_child(camara)
	recentrar()

static func factor_dt(rapidez:float,delta:float) -> float:
	return 1.0-exp(-rapidez*delta)

func recentrar() -> void:
	foco=get_parent().get_node("Jugador").global_position+Vector3(0,.8,0)
	_colocar()

func _process(delta:float) -> void:
	if get_parent().estado_actual==0:
		camara.global_position=Vector3(23,24,28)
		camara.look_at(Vector3(0,1.0,0),Vector3.UP)
		return
	if get_parent().esta_jugando():
		giro+=Input.get_axis("girar_izquierda","girar_derecha")*1.35*delta
	var objetivo:Vector3=get_parent().get_node("Jugador").global_position+Vector3(0,.8,0)
	foco=foco.lerp(objetivo,factor_dt(rapidez_seguimiento,delta))
	_colocar()

func _colocar() -> void:
	camara.global_position=foco+Vector3(sin(giro)*distancia,altura,cos(giro)*distancia)
	camara.look_at(foco,Vector3.UP)
