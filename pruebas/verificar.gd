extends SceneTree
var juego:Node3D
var jugador:CharacterBody3D
var comprobaciones:=0
var fallos:=0
var area:=""
var areas:={}
const Plan:=preload("res://alumno/plan.gd")
const T:=preload("res://alumno/terreno.gd")
const Fractal:=preload("res://alumno/fractal3d.gd")
const B:=preload("res://alumno/bezier.gd")
const S:=preload("res://alumno/bspline.gd")
const J:=preload("res://alumno/jugador.gd")
const C:=preload("res://alumno/camara_seguidora.gd")

func _initialize() -> void:
	call_deferred("correr")

func verificar(ok:bool,texto:String) -> void:
	comprobaciones+=1;areas[area]=int(areas.get(area,0))+1
	if not ok:
		fallos+=1
		print("FALLO [",area,"]: ",texto)

func pasos(n:int) -> void:
	for i in n:await physics_frame
	await process_frame

func colocar(p:Vector3) -> void:
	jugador.reiniciar(p)
	jugador.control_prueba=Vector2.ZERO
	await pasos(6)

func correr() -> void:
	Engine.physics_ticks_per_second=60
	var vp:=SubViewport.new();vp.size=Vector2i(1280,720);vp.own_world_3d=true;root.add_child(vp)
	juego=load("res://alumno/principal.tscn").instantiate();vp.add_child(juego)
	juego.set_process(false)
	jugador=juego.get_node("Jugador")
	juego.get_node("CamaraSeguidora").set_process(false)
	await pasos(4)
	probar_geometria()
	probar_curvas()
	juego.iniciar()
	await pasos(6)
	await probar_personaje()
	await probar_coleccion()
	await probar_reglas()
	await probar_recorrido()
	print("AREAS: ",areas)
	print("RESULTADO: ",comprobaciones," comprobaciones; ",fallos," fallos.")
	root.remove_child(vp);vp.queue_free();juego=null;jugador=null
	await process_frame
	await process_frame
	OS.delay_msec(80)
	quit(0 if fallos==0 else 1)

func probar_geometria() -> void:
	area="mundo y fractal"
	var mundo:Node3D=juego.get_node("Mundo")
	verificar(mundo.terreno.mesh is ArrayMesh,"terreno ArrayMesh propio")
	var datos:Array=mundo.terreno.mesh.surface_get_arrays(0)
	verificar(datos[Mesh.ARRAY_VERTEX].size()==81*81,"cuadrícula 81 por 81")
	verificar(datos[Mesh.ARRAY_INDEX].size()==80*80*6,"12800 triángulos")
	verificar(datos[Mesh.ARRAY_TEX_UV].size()==81*81,"UV por vértice")
	var vertices:PackedVector3Array=datos[Mesh.ARRAY_VERTEX]
	var indices:PackedInt32Array=datos[Mesh.ARRAY_INDEX]
	for i in range(0,indices.size(),159):
		var a:Vector3=vertices[indices[i]];var b:Vector3=vertices[indices[i+1]];var c:Vector3=vertices[indices[i+2]]
		verificar((c-a).cross(b-a).y>0,"triángulo del terreno orientado arriba")
	verificar(mundo.terreno.material_override.albedo_texture!=null,"textura propia asignada")
	verificar(juego.get_node("Sol").shadow_enabled,"luz principal con sombras")
	verificar(mundo.get_node("Agua_Shader").material_override is ShaderMaterial,"shader de agua")
	verificar(mundo.get_node("ColisionTerreno").get_child(0).shape is ConcavePolygonShape3D,"colisión de la malla")
	for nivel in range(0,5):
		var ramas:Array=Fractal.ramas(nivel)
		var esperadas:=int((pow(3,nivel+1)-1)/2)
		verificar(ramas.size()==esperadas,"número recursivo nivel "+str(nivel))
		var hojas:=0
		for r in ramas:
			if r["hoja"]:hojas+=1
			verificar(r["a"].distance_to(r["b"])>0,"rama no degenerada")
		verificar(hojas==int(pow(3,nivel)),"tres ramas nuevas por nivel")
	verificar(mundo.ramas_generadas==360 and mundo.hojas_generadas==243,"9 árboles: 360 ramas, 243 copas")
	print("Mundo: 6561 vértices, 12800 triángulos, 360 ramas y 243 copas.")

func probar_curvas() -> void:
	area="curvas y obstáculos"
	verificar(juego.obstaculos.size()==2,"dos obstáculos móviles")
	for k in 21:
		var t:=float(k)/20
		var p:Vector2=Plan.BEZIER[0]*pow(1-t,3)+Plan.BEZIER[1]*3*t*pow(1-t,2)+Plan.BEZIER[2]*3*t*t*(1-t)+Plan.BEZIER[3]*pow(t,3)
		verificar(B.bezier(Plan.BEZIER,t).distance_to(p)<.0001,"Bézier vs Bernstein")
	for o in juego.obstaculos:
		verificar(o.largo>10,"ruta no degenerada")
		var p:Vector3=o.position
		o.actualizar(3.2)
		verificar(o.position.distance_to(p)>1,"recorre su curva")
		verificar(absf(o.position.y-(T.altura(o.position.x,o.position.z)+.85))<.0001,"ruta sigue el terreno")
		o.actualizar(0)
	var cerrada:PackedVector2Array=S.bspline_cerrada(Plan.BSPLINE,24)
	verificar(cerrada[0].distance_to(cerrada[-1])<.0001,"B-spline cerrada")
	verificar(B.muestrear(Plan.BEZIER,140).size()==141,"muestreo explícito Bézier")

func probar_personaje() -> void:
	area="personaje, animación y cámara"
	var inicio:=Vector3(0,T.altura(0,10)+.08,10)
	await colocar(inicio)
	verificar(jugador.is_on_floor(),"CharacterBody3D descansa sobre el ArrayMesh")
	for giro in [0.0,.3,1.5,PI]:
		var a:=J.direccion_normalizada(Vector2(1,0),giro)
		var b:=J.direccion_normalizada(Vector2(1,1),giro)
		verificar(absf(a.length()-b.length())<.000001,"diagonal normalizada en cámara girada")
	var distancias:=[]
	for dir in [Vector2.RIGHT,Vector2(1,-1).normalized()]:
		await colocar(inicio)
		var antes:Vector3=jugador.position
		jugador.control_prueba=dir
		await pasos(60)
		var despues:Vector3=jugador.position
		distancias.append(Vector2(antes.x,antes.z).distance_to(Vector2(despues.x,despues.z)))
	verificar(absf(distancias[0]-distancias[1])<.15,"desplazamiento diagonal y horizontal iguales")
	verificar(distancias[0]>5 and distancias[0]<6.1,"velocidad en metros por segundo")
	await colocar(inicio)
	var y0:=jugador.position.y
	jugador.saltar_prueba=true
	var pico:=y0
	for i in 90:
		await physics_frame
		pico=maxf(pico,jugador.position.y)
	verificar(pico-y0>1.8 and pico-y0<2.3,"salto con gravedad, altura prevista")
	verificar(jugador.is_on_floor(),"aterriza tras saltar")
	verificar(jugador.saltos_realizados>0,"salto ejecutado")
	for nombre in ["reposo","caminar","correr","saltar"]:
		verificar(jugador.animacion.has_animation(nombre),"AnimationPlayer "+nombre)
		verificar(jugador.animacion.get_animation(nombre).get_track_count()==5,"cinco pistas de cuadros clave")
	var finales:=[]
	for fps in [30,60,144]:
		var x:=0.0
		for k in fps:x=lerpf(x,10,C.factor_dt(7,1.0/fps))
		finales.append(x)
	verificar(absf(finales[0]-finales[2])<.00001,"suavizado exponencial independiente del framerate")
	var cam=juego.get_node("CamaraSeguidora")
	cam.foco=Vector3.ZERO
	jugador.position=Vector3(6,T.altura(6,5)+.01,5)
	for k in 60:cam._process(1.0/60)
	verificar(cam.foco.distance_to(jugador.position+Vector3(0,.8,0))<.03,"cámara alcanza al personaje con dt")
	print("Personaje: desplazamientos ",distancias,"; salto ",pico-y0," m; cámara a 30/60/144 FPS equivalente.")

func probar_coleccion() -> void:
	area="colección con colisiones"
	juego.iniciar();jugador.control_prueba=Vector2.ZERO
	verificar(juego.objetos.size()==12,"12 Area3D recolectables")
	for i in 12:
		var item:Area3D=juego.objetos[i]
		await colocar(item.global_position-Vector3(0,.85,0))
		verificar(item.tomado,"entrada física en objeto "+str(i))
		verificar(juego.puntaje==i+1,"suma exactamente un punto por objeto")
		item._recoger(jugador)
		verificar(juego.puntaje==i+1,"no duplica recolección")
	verificar(juego.estado_actual==juego.Estado.GANASTE,"12 objetos disparan victoria")
	verificar(juego.datos()["puntaje"]==12,"estado publicado coincide")
	juego.iniciar()
	verificar(juego.puntaje==0 and juego.vidas==3 and juego.restantes==150,"reinicio limpia estado")
	for item in juego.objetos:verificar(not item.tomado and item.visible,"reinicio restaura objeto")

func probar_reglas() -> void:
	area="daño, derrota, pausa y reinicio"
	var inicio:=Vector3(0,T.altura(0,10)+.08,10)
	await colocar(inicio)
	var empuje_controlado:=true
	for golpe in 3:
		await colocar(inicio)
		jugador.invulnerable=0
		var obstaculo:Area3D=juego.obstaculos[0]
		jugador.position=obstaculo.global_position-Vector3(0,.75,0)
		jugador.velocity=Vector3.ZERO
		await pasos(4)
		empuje_controlado=empuje_controlado and Vector2(jugador.velocity.x,jugador.velocity.z).length()<12.0
		verificar(juego.vidas==2-golpe,"contacto físico quita una vida")
		juego.golpear(obstaculo.global_position)
		verificar(juego.vidas==2-golpe,"invulnerabilidad evita daño repetido")
	verificar(juego.estado_actual==juego.Estado.PERDISTE,"tres contactos: derrota")
	verificar(empuje_controlado,"retroceso no se acumula como aceleración por cuadro")
	juego.get_node("HUD/Interfaz").boton.pressed.emit()
	verificar(juego.esta_jugando() and juego.vidas==3,"botón vuelve a jugar")
	juego.restantes=.05;juego._process(.1)
	verificar(juego.estado_actual==juego.Estado.PERDISTE and juego.restantes==0,"derrota por tiempo")
	juego.iniciar()
	var e:=InputEventKey.new();e.keycode=KEY_P;e.pressed=true;juego._unhandled_input(e)
	var tiempo:float=juego.restantes;juego._process(2.0)
	verificar(juego.estado_actual==juego.Estado.PAUSA and juego.restantes==tiempo,"pausa detiene el reloj")
	e=InputEventKey.new();e.keycode=KEY_ENTER;e.pressed=true;juego._unhandled_input(e)
	verificar(juego.esta_jugando(),"Enter continúa la pausa")
	juego.caer_al_agua()
	verificar(juego.vidas==2 and jugador.position.z==10,"agua quita vida y devuelve a la orilla")
	juego.caer_al_agua();juego.caer_al_agua()
	verificar(juego.estado_actual==juego.Estado.PERDISTE,"agua agota las tres vidas")

func probar_recorrido() -> void:
	area="recorrido jugable"
	juego.iniciar()
	jugador.control_prueba=Vector2.ZERO
	await pasos(8)
	var orden:=[1,0,8,7,6,5,4,3,2,10,11,9]
	var objetivo:=0
	var cuadros:=0
	while objetivo<orden.size() and juego.esta_jugando() and cuadros<3600:
		var item:Area3D=juego.objetos[orden[objetivo]]
		if item.tomado:objetivo+=1;continue
		var hacia:Vector3=item.global_position-jugador.global_position
		var dir:=Vector2(hacia.x,hacia.z)
		jugador.control_prueba=dir.normalized()
		var peligro:=false
		for o in juego.obstaculos:
			var d:Vector3=o.global_position-jugador.global_position
			if Vector2(d.x,d.z).length()<2.8:peligro=true
		var plataforma:bool=Plan.PLATAFORMAS.has(orden[objetivo])
		if jugador.is_on_floor() and (peligro or (plataforma and dir.length()<3.0)):jugador.saltar_prueba=true
		juego._process(1.0/60)
		await physics_frame
		cuadros+=1
	verificar(juego.estado_actual==juego.Estado.GANASTE,"recorrido completo sin teletransportes ni vidas extra")
	print("RECORRIDO: ",juego.datos(),"; cuadros ",cuadros,"; destino ",objetivo)
