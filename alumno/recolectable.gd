extends Area3D
signal recogido(id:int)
const G:=preload("res://alumno/geometria.gd")
var id:=0
var tomado:=false
var reloj:=0.0
var visual:MeshInstance3D
var halo:MeshInstance3D

func _ready() -> void:
	collision_layer=0; collision_mask=2
	var shape:=CollisionShape3D.new(); var esfera:=SphereShape3D.new(); esfera.radius=.72; shape.shape=esfera; add_child(shape)
	visual=G.figura(self,"Fragmento",G.cristal(),G.material(Color("91f1db"),.22,.36))
	halo=G.figura(self,"Zocalo",G.cilindro(.40,.06,12),G.material(Color("edd495"),.3),Vector3(0,-.76,0))
	body_entered.connect(_recoger)
	reloj=id*.48

func _process(delta:float) -> void:
	if tomado:return
	reloj+=delta
	visual.rotation.y+=delta*1.35
	visual.position.y=sin(reloj*2.2)*.13

func _recoger(cuerpo:Node) -> void:
	if tomado or not cuerpo.is_in_group("jugador"):return
	if not get_parent().get_parent().esta_jugando():return
	tomado=true; visible=false
	set_deferred("monitoring",false)
	recogido.emit(id)

func reiniciar() -> void:
	tomado=false; visible=true; set_deferred("monitoring",true)
