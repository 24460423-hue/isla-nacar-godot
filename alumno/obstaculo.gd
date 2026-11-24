extends Area3D
const G:=preload("res://alumno/geometria.gd")
const T:=preload("res://alumno/terreno.gd")
const B:=preload("res://alumno/bezier.gd")
const S:=preload("res://alumno/bspline.gd")
const Plan:=preload("res://alumno/plan.gd")
var tipo:=0
var ruta:=PackedVector2Array()
var largo:=0.0
var velocidad:=2.8
var fase:=0.0
var cuerpo_visual:Node3D
var color:=Color("e68679")

func _ready() -> void:
	collision_layer=0; collision_mask=2
	ruta=B.muestrear(Plan.BEZIER,140) if tipo==0 else S.bspline_cerrada(Plan.BSPLINE,24)
	largo=B.largo(ruta)
	velocidad=2.7 if tipo==0 else 3.1
	color=Color("e68679") if tipo==0 else Color("bd97df")
	var forma:=CollisionShape3D.new(); var esfera:=SphereShape3D.new(); esfera.radius=.86; forma.shape=esfera; add_child(forma)
	cuerpo_visual=Node3D.new(); cuerpo_visual.name="Guardian"; add_child(cuerpo_visual)
	var material:=ShaderMaterial.new(); material.shader=preload("res://alumno/bandas.gdshader"); material.set_shader_parameter("color",color)
	G.figura(cuerpo_visual,"Coraza",G.esfera(.77,5,10),material)
	var oscuro:=G.material(Color("253b50"),.4)
	for signo in [-1.0,1.0]:
		G.figura(cuerpo_visual,"Pata"+str(signo),G.caja(Vector3(.3,.24,.4)),oscuro,Vector3(signo*.65,-.4,0))
		G.figura(cuerpo_visual,"Ojo"+str(signo),G.esfera(.14,4,8),G.material(Color("fbe7aa"),.1,.7),Vector3(signo*.24,.22,-.65))
	body_entered.connect(_contacto)
	body_exited.connect(_salio)
	marcar_recorrido()
	actualizar(0.0)

func actualizar(segundos:float) -> void:
	var d:=fposmod(segundos*velocidad,largo*2 if tipo==0 else largo)
	if tipo==0 and d>largo:d=2*largo-d
	var p:=B.punto_a_distancia(ruta,d)
	position=Vector3(p.x,T.altura(p.x,p.y)+.85,p.y)
	cuerpo_visual.rotation.y=segundos*.6
	cuerpo_visual.position.y=sin(segundos*3)*.10

func _contacto(n:Node) -> void:
	if n.is_in_group("jugador"): get_parent().get_parent().golpear(global_position)

func _salio(_n:Node) -> void:
	pass

func marcar_recorrido() -> void:
	var st:=SurfaceTool.new(); st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for i in range(0,ruta.size()-1,3):
		var a:=ruta[i]; var b:=ruta[mini(i+1,ruta.size()-1)]
		var lado:Vector2=(b-a).normalized().orthogonal()*.055
		var puntos:=[a-lado,a+lado,b-lado,b+lado]
		var v:=[]
		for p:Vector2 in puntos:v.append(Vector3(p.x,T.altura(p.x,p.y)+.035,p.y))
		for k in [0,1,2,1,3,2]:
			st.set_normal(Vector3.UP); st.add_vertex(v[k])
	var lineas:=G.figura(get_parent(),"Ruta_Bezier" if tipo==0 else "Ruta_Bspline",st.commit(),G.material(color.darkened(.18)))
	lineas.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
