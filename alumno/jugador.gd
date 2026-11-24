extends CharacterBody3D
const G:=preload("res://alumno/geometria.gd")
@export var velocidad_caminar:=5.8
@export var velocidad_correr:=8.0
@export var impulso_salto:=10.0
@export var gravedad:=24.0
const ACELERACION:=34.0
var visual:Node3D
var animacion:AnimationPlayer
var invulnerable:=0.0
var parpadea:=false
var coyote:=0.0
var salto_pendiente:=0.0
var empuje:=Vector3.ZERO
var velocidad_horizontal:=Vector3.ZERO
var control_prueba:=Vector2.INF
var saltar_prueba:=false
var saltos_realizados:=0

func _ready() -> void:
	add_to_group("jugador")
	collision_layer=2; collision_mask=1
	floor_snap_length=.45
	floor_max_angle=deg_to_rad(48)
	var forma:=CollisionShape3D.new(); var capsule:=CapsuleShape3D.new(); capsule.radius=.34; capsule.height=1.75; forma.shape=capsule; forma.position.y=.88; add_child(forma)
	_crear_avatar()
	_crear_animaciones()

func _crear_avatar() -> void:
	visual=Node3D.new(); visual.name="Visual"; add_child(visual)
	var crema:=G.material(Color("f0e9d4"),.8)
	var amarillo:=G.material(Color("eab85f"),.4)
	var azul:=G.material(Color("28566a"),.65)
	var oscuro:=G.material(Color("183a4b"),.3)
	var cuerpo:=Node3D.new(); cuerpo.name="Cuerpo"; cuerpo.position.y=1.0; visual.add_child(cuerpo)
	G.figura(cuerpo,"Chamarra",G.caja(Vector3(.72,.64,.48)),amarillo)
	G.figura(cuerpo,"Mochila",G.caja(Vector3(.55,.51,.27)),azul,Vector3(0,.02,.35))
	G.figura(cuerpo,"Cabeza",G.esfera(.31,6,10),crema,Vector3(0,.57,0))
	G.figura(cuerpo,"Casco",G.esfera(.34,5,10),amarillo,Vector3(0,.68,.015),Vector3(1,.60,1))
	G.figura(cuerpo,"Visera",G.caja(Vector3(.51,.17,.12)),oscuro,Vector3(0,.58,-.28))
	G.figura(cuerpo,"CristalVisera",G.caja(Vector3(.30,.08,.02)),G.material(Color("9de5df"),.12,.25),Vector3(-.04,.60,-.35))
	for lado in [-1,1]:
		var sufijo:="I" if lado<0 else "D"
		var pierna:=Node3D.new(); pierna.name="Pierna"+sufijo; pierna.position=Vector3(lado*.22,.66,0); visual.add_child(pierna)
		G.figura(pierna,"Pantalon",G.caja(Vector3(.28,.54,.30)),azul,Vector3(0,-.24,0))
		G.figura(pierna,"Bota",G.caja(Vector3(.30,.18,.43)),oscuro,Vector3(0,-.50,-.055))
		var brazo:=Node3D.new(); brazo.name="Brazo"+sufijo; brazo.position=Vector3(lado*.48,1.21,0); visual.add_child(brazo)
		G.figura(brazo,"Manga",G.caja(Vector3(.23,.44,.28)),amarillo,Vector3(0,-.18,0))
		G.figura(brazo,"Guante",G.esfera(.14,4,7),crema,Vector3(0,-.43,0))

func _crear_animaciones() -> void:
	animacion=AnimationPlayer.new(); animacion.name="AnimationPlayer"; add_child(animacion)
	var biblioteca:=AnimationLibrary.new()
	for nombre in ["reposo","caminar","correr","saltar"]:
		var a:=Animation.new()
		a.length=.9 if nombre=="reposo" else (.42 if nombre=="correr" else .70)
		a.loop_mode=Animation.LOOP_LINEAR
		var amplitud:=0.0 if nombre=="reposo" else (.72 if nombre=="correr" else .48)
		for parte in ["PiernaI","PiernaD","BrazoI","BrazoD"]:
			var pista:=a.add_track(Animation.TYPE_VALUE)
			a.track_set_path(pista,NodePath("Visual/"+parte+":rotation"))
			var signo:=-1.0 if parte.ends_with("I") else 1.0
			if parte.begins_with("Brazo"): signo=-signo
			for k in 5:
				var x:=sin(TAU*k/4.0)*amplitud*signo
				if nombre=="saltar":x=-.7 if parte.begins_with("Brazo") else .2
				a.track_insert_key(pista,a.length*k/4.0,Vector3(x,0,0))
		var cuerpo:=a.add_track(Animation.TYPE_VALUE)
		a.track_set_path(cuerpo,NodePath("Visual/Cuerpo:position"))
		for k in 5:
			var y:=1.0+(.025 if nombre=="reposo" else .055)*sin(TAU*k/4.0)
			a.track_insert_key(cuerpo,a.length*k/4.0,Vector3(0,y,0))
		biblioteca.add_animation(nombre,a)
	animacion.add_animation_library("",biblioteca)
	animacion.play("reposo")

static func direccion_normalizada(entrada:Vector2,giro:float) -> Vector3:
	return Vector3(entrada.x,0,entrada.y).limit_length(1.0).rotated(Vector3.UP,giro)

func _physics_process(delta:float) -> void:
	invulnerable=maxf(0,invulnerable-delta)
	if invulnerable>0 and parpadea: visual.visible=fmod(invulnerable,.18)<.11
	else:
		visual.visible=true
		if invulnerable<=0:parpadea=false
	if not get_parent().esta_jugando():
		velocity=Vector3.ZERO
		_elegir_animacion("reposo")
		return
	var entrada:=Input.get_vector("izquierda","derecha","arriba","abajo") if control_prueba==Vector2.INF else control_prueba
	var direccion:=direccion_normalizada(entrada,get_parent().get_node("CamaraSeguidora").giro)
	var rapidez:=velocidad_correr if Input.is_action_pressed("correr") else velocidad_caminar
	velocidad_horizontal=velocidad_horizontal.move_toward(direccion*rapidez,ACELERACION*delta)
	var horizontal:=velocidad_horizontal
	empuje=empuje.move_toward(Vector3.ZERO,14*delta)
	velocity.x=horizontal.x+empuje.x
	velocity.z=horizontal.z+empuje.z
	if is_on_floor():
		coyote=.12
		if velocity.y<0:velocity.y=-.5
	else:
		coyote-=delta
		velocity.y-=gravedad*delta
	salto_pendiente=maxf(0,salto_pendiente-delta)
	if Input.is_action_just_pressed("saltar") or saltar_prueba:salto_pendiente=.12
	saltar_prueba=false
	if salto_pendiente>0 and coyote>0:
		velocity.y=impulso_salto
		salto_pendiente=0; coyote=0; saltos_realizados+=1
		get_parent().sonido("salto")
	move_and_slide()
	if direccion.length()>.1:
		visual.rotation.y=lerp_angle(visual.rotation.y,atan2(-direccion.x,-direccion.z),1-exp(-12*delta))
	_elegir_animacion("saltar" if not is_on_floor() else ("correr" if horizontal.length()>6.3 else ("caminar" if horizontal.length()>.25 else "reposo")))
	if global_position.y<-.55:get_parent().caer_al_agua()

func _elegir_animacion(nombre:String) -> void:
	if animacion.current_animation!=nombre:animacion.play(nombre,.12)

func reiniciar(donde:Vector3) -> void:
	global_position=donde
	velocity=Vector3.ZERO; empuje=Vector3.ZERO; velocidad_horizontal=Vector3.ZERO
	invulnerable=1.4
	parpadea=false
	visual.visible=true
	control_prueba=Vector2.INF
	salto_pendiente=0; coyote=0
