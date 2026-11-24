extends Node3D
const Plan:=preload("res://alumno/plan.gd")
const Terreno:=preload("res://alumno/terreno.gd")
const Coleccionable:=preload("res://alumno/recolectable.gd")
const Obstaculo:=preload("res://alumno/obstaculo.gd")
enum Estado { INICIO, JUGANDO, GANASTE, PERDISTE, PAUSA }
var estado_actual:=Estado.INICIO
var puntaje:=0
var restantes:=Plan.SEGUNDOS
var vidas:=Plan.VIDAS
var reloj:=0.0
var razon:=""
var mensaje:="Recoge los doce fragmentos y devuelve la luz al faro."
var mensaje_tiempo:=0.0
var objetos:Array=[]
var obstaculos:Array=[]
var audios:Dictionary={}
var silenciado:=false
var web_reloj:=0.0

func _ready() -> void:
	_configurar_entradas()
	for i in Plan.GEMAS.size():
		var item:=Coleccionable.new(); item.name="Fragmento%02d"%i; item.id=i
		var p:Vector2=Plan.GEMAS[i]
		item.position=Vector3(p.x,$Mundo.altura_objeto(i)+.93,p.y)
		$Objetos.add_child(item); item.recogido.connect(_sumar); objetos.append(item)
	for i in 2:
		var guardian:=Obstaculo.new(); guardian.name="Guardian"+str(i); guardian.tipo=i
		$Guardianes.add_child(guardian); obstaculos.append(guardian)
	for nombre in ["recoger","golpe","salto","ganar","perder"]:
		var audio:=AudioStreamPlayer.new(); audio.stream=load("res://alumno/recursos/"+nombre+".wav"); audio.volume_db=-12 if nombre!="salto" else -17; add_child(audio); audios[nombre]=audio
	_recolocar_jugador()
	$CamaraSeguidora.recentrar()
	$HUD.get_node("Interfaz").juego=self
	get_viewport().size_changed.connect(_redibujar)
	_publicar_estado_web()

func _configurar_entradas() -> void:
	var mapa:={"izquierda":[KEY_A,KEY_LEFT],"derecha":[KEY_D,KEY_RIGHT],"arriba":[KEY_W,KEY_UP],"abajo":[KEY_S,KEY_DOWN],"saltar":[KEY_SPACE],"correr":[KEY_SHIFT],"girar_izquierda":[KEY_Q],"girar_derecha":[KEY_E]}
	for accion in mapa:
		if not InputMap.has_action(accion):InputMap.add_action(accion)
		for tecla in mapa[accion]:
			var e:=InputEventKey.new();e.physical_keycode=tecla
			if not InputMap.action_has_event(accion,e):InputMap.action_add_event(accion,e)

func esta_jugando() -> bool:
	return estado_actual==Estado.JUGANDO

func iniciar() -> void:
	puntaje=0; restantes=Plan.SEGUNDOS; vidas=Plan.VIDAS; reloj=0
	razon=""; mensaje="Doce fragmentos. Dos guardianes. Una luz por encender.";mensaje_tiempo=4.0
	for o in objetos:o.reiniciar()
	for o in obstaculos:o.actualizar(0.0)
	$Mundo.luz_faro.light_energy=.7
	$Jugador.saltos_realizados=0
	_recolocar_jugador()
	$CamaraSeguidora.recentrar()
	estado_actual=Estado.JUGANDO
	_redibujar()

func _recolocar_jugador() -> void:
	var p:Vector2=Plan.INICIO
	$Jugador.reiniciar(Vector3(p.x,Terreno.altura(p.x,p.y)+.08,p.y))

func _process(delta:float) -> void:
	if esta_jugando():
		reloj+=delta
		restantes=maxf(0,restantes-delta)
		mensaje_tiempo=maxf(0,mensaje_tiempo-delta)
		for o in obstaculos:o.actualizar(reloj)
		if restantes<=0:terminar(false,"Se apagó la última luz. El tiempo terminó.")
	elif estado_actual==Estado.GANASTE:
		$Mundo.luz_faro.light_energy=2.2+sin(Time.get_ticks_msec()*.003)*.35
	web_reloj+=delta
	if web_reloj>.25:
		web_reloj=0;_publicar_estado_web()
	_redibujar()

func _unhandled_input(evento:InputEvent) -> void:
	if not (evento is InputEventKey and evento.pressed and not evento.echo):return
	if evento.keycode==KEY_ENTER and estado_actual==Estado.PAUSA:estado_actual=Estado.JUGANDO
	elif evento.keycode==KEY_ENTER and estado_actual!=Estado.JUGANDO:iniciar()
	elif evento.keycode==KEY_R:iniciar()
	elif evento.keycode==KEY_ESCAPE or evento.keycode==KEY_P:
		if estado_actual==Estado.JUGANDO:estado_actual=Estado.PAUSA
		elif estado_actual==Estado.PAUSA:estado_actual=Estado.JUGANDO
	elif evento.keycode==KEY_M:silenciado=not silenciado

func _sumar(_id:int) -> void:
	if not esta_jugando():return
	puntaje+=1; sonido("recoger")
	mensaje="Fragmento recuperado · %d de %d"%[puntaje,Plan.TOTAL]; mensaje_tiempo=2.0
	if puntaje>=Plan.TOTAL:terminar(true,"")

func golpear(desde:Vector3) -> void:
	if not esta_jugando() or $Jugador.invulnerable>0:return
	vidas-=1; $Jugador.invulnerable=1.6
	$Jugador.parpadea=true
	var alejamiento:Vector3=($Jugador.global_position-desde);alejamiento.y=0
	$Jugador.empuje=alejamiento.normalized()*6.0
	sonido("golpe");mensaje="¡Cuidado con los guardianes! Puedes saltar sobre ellos.";mensaje_tiempo=3.0
	if vidas<=0:terminar(false,"Los guardianes te dejaron sin energía.")

func caer_al_agua() -> void:
	if not esta_jugando():return
	vidas-=1;sonido("golpe")
	if vidas<=0:terminar(false,"La marea se llevó tu última oportunidad.")
	else:
		_recolocar_jugador();$CamaraSeguidora.recentrar()
		mensaje="La marea te devolvió a la orilla. Te quedan %d vidas."%vidas;mensaje_tiempo=4

func terminar(gano:bool,motivo:String) -> void:
	if not esta_jugando():return
	estado_actual=Estado.GANASTE if gano else Estado.PERDISTE
	razon=motivo
	$Jugador.velocity=Vector3.ZERO
	sonido("ganar" if gano else "perder")
	_publicar_estado_web()
	_redibujar()

func sonido(nombre:String) -> void:
	if not silenciado and audios.has(nombre):audios[nombre].play()

func _redibujar() -> void:
	$HUD/Interfaz.queue_redraw()

func datos() -> Dictionary:
	var p:Vector3=$Jugador.global_position
	return {"estado":Estado.keys()[estado_actual],"puntaje":puntaje,"tiempo":restantes,"vidas":vidas,"posicion":[p.x,p.y,p.z],"saltos":$Jugador.saltos_realizados,"objetos":objetos.size(),"obstaculos":obstaculos.size()}

func _publicar_estado_web() -> void:
	if OS.has_feature("web"):
		JavaScriptBridge.eval("window.islaEstado="+JSON.stringify(datos())+";",true)

func _exit_tree() -> void:
	for audio in audios.values():
		if is_instance_valid(audio):
			audio.stop()
			audio.stream=null
	audios.clear()
