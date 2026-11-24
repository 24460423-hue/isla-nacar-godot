extends Control
# HUD 2D dibujado con rectángulos, líneas, polígonos y texto. Paleta RGB;
# el color del reloj se calcula en HSV: verde -> ámbar -> rojo según el tiempo.
const T:=preload("res://alumno/terreno.gd")
const Plan:=preload("res://alumno/plan.gd")
const TINTA:=Color("163747")
const PAPEL:=Color("f5f0df")
const MENTA:=Color("8be5ca")
const ORO:=Color("edca85")
var juego:Node
var fuente:Font
var boton:Button
var secundario:Button
var escala:=1.0
var ultimo_estado:=-1

func _ready() -> void:
	mouse_filter=Control.MOUSE_FILTER_IGNORE
	fuente=ThemeDB.fallback_font
	boton=_boton("COMENZAR",true)
	boton.pressed.connect(_accion)
	secundario=_boton("VOLVER AL INICIO",false)
	secundario.pressed.connect(func():juego.estado_actual=juego.Estado.INICIO;queue_redraw())

func _boton(texto:String,destacado:bool) -> Button:
	var b:=Button.new();b.text=texto;b.mouse_default_cursor_shape=Control.CURSOR_POINTING_HAND
	b.add_theme_font_size_override("font_size",18)
	b.add_theme_color_override("font_color",TINTA if destacado else PAPEL)
	b.add_theme_color_override("font_hover_color",TINTA)
	b.add_theme_color_override("font_pressed_color",TINTA)
	for estado in ["normal","hover","pressed","focus"]:
		var s:=StyleBoxFlat.new()
		s.bg_color=ORO if destacado else Color(1,1,1,.06)
		if estado=="hover" or estado=="pressed":s.bg_color=Color("a8ecd7")
		s.set_corner_radius_all(12)
		s.set_border_width_all(1 if not destacado else 0)
		s.border_color=Color(1,1,1,.25)
		b.add_theme_stylebox_override(estado,s)
	add_child(b)
	return b

func _accion() -> void:
	if juego.estado_actual==juego.Estado.PAUSA:juego.estado_actual=juego.Estado.JUGANDO
	else:juego.iniciar()
	queue_redraw()

func texto(pos:Vector2,cadena:String,tamano:int,color:Color=PAPEL) -> void:
	draw_string(fuente,pos,cadena,HORIZONTAL_ALIGNMENT_LEFT,-1,tamano,color)

func panel(rect:Rect2,color:Color,borde:Color=Color.TRANSPARENT) -> void:
	var s:=StyleBoxFlat.new();s.bg_color=color;s.set_corner_radius_all(16)
	if borde.a>0:s.set_border_width_all(1);s.border_color=borde
	draw_style_box(s,rect)

func cristal(p:Vector2,color:Color,t:float=1) -> void:
	draw_colored_polygon(PackedVector2Array([p+Vector2(0,-13)*t,p+Vector2(10,-2)*t,p+Vector2(6,10)*t,p+Vector2(-6,10)*t,p+Vector2(-10,-2)*t]),color)
	draw_line(p+Vector2(0,-12)*t,p+Vector2(-2,8)*t,Color(1,1,1,.5),1.2)

func corazon(p:Vector2,color:Color) -> void:
	var puntos:=PackedVector2Array()
	for v in [Vector2(-11,-3),Vector2(-10,-8),Vector2(-5,-10),Vector2(0,-6),Vector2(5,-10),Vector2(10,-8),Vector2(11,-3),Vector2(0,10)]:puntos.append(p+v)
	draw_colored_polygon(puntos,color)

func _draw() -> void:
	if juego==null or fuente==null:return
	escala=minf(size.x/1280.0,size.y/720.0)
	var offset:=(size-Vector2(1280,720)*escala)/2
	draw_set_transform(offset,0,Vector2.ONE*escala)
	var estado:int=juego.estado_actual
	if estado==juego.Estado.INICIO:
		_portada()
	elif estado==juego.Estado.JUGANDO:
		_jugando()
	else:
		_jugando()
		_resultado(estado)
	_layout_botones(estado,offset)
	draw_set_transform(Vector2.ZERO)

func _layout_botones(estado:int,offset:Vector2) -> void:
	boton.visible=estado!=juego.Estado.JUGANDO
	secundario.visible=estado!=juego.Estado.JUGANDO and estado!=juego.Estado.INICIO
	var p:=Vector2(72,493) if estado==juego.Estado.INICIO else Vector2(388,458)
	boton.position=offset+p*escala;boton.size=Vector2(250,57)*escala
	boton.add_theme_font_size_override("font_size",maxi(12,int(18*escala)))
	secundario.position=offset+Vector2(660,458)*escala;secundario.size=Vector2(250,57)*escala
	secundario.add_theme_font_size_override("font_size",maxi(11,int(16*escala)))
	boton.text="COMENZAR" if estado==juego.Estado.INICIO else ("CONTINUAR" if estado==juego.Estado.PAUSA else "VOLVER A JUGAR")
	if estado!=ultimo_estado:
		boton.release_focus();secundario.release_focus();ultimo_estado=estado

func _portada() -> void:
	draw_rect(Rect2(0,0,1280,720),Color(.025,.09,.13,.48))
	panel(Rect2(40,53,558,606),Color(.045,.13,.17,.88),Color(.7,.96,.9,.18))
	texto(Vector2(72,103),"UNA ISLA · UNA ÚLTIMA LUZ",16,MENTA)
	texto(Vector2(67,220),"ISLA",94,PAPEL)
	texto(Vector2(67,318),"NÁCAR",94,ORO)
	draw_line(Vector2(73,349),Vector2(153,349),MENTA,4)
	texto(Vector2(73,392),"Recupera doce fragmentos de luz.",23)
	texto(Vector2(73,428),"Esquiva a los guardianes de la marea",20,Color("bfd7d2"))
	texto(Vector2(73,457),"y enciende de nuevo el faro.",20,Color("bfd7d2"))
	texto(Vector2(74,589),"WASD / FLECHAS   mover    ESPACIO   saltar",16,Color("c7dcd4"))
	texto(Vector2(74,618),"SHIFT   correr    Q / E   cámara    M   sonido",16,Color("c7dcd4"))
	for i in 3:
		var y:=189+i*113
		panel(Rect2(957,y-52,260,91),Color(.04,.14,.18,.83),Color(.8,.95,.9,.13))
		texto(Vector2(979,y-10),["12","02","150"][i],36,ORO)
		texto(Vector2(1048,y-12),["FRAGMENTOS","GUARDIANES","SEGUNDOS"][i],15)
		texto(Vector2(1048,y+13),["Busca el brillo verde","Observa sus rutas","Cada salto cuenta"][i],12,Color("adc9c2"))
	texto(Vector2(982,656),"Un pequeño viaje entre las mareas",14,PAPEL)

func _jugando() -> void:
	panel(Rect2(28,25,274,85),Color(.045,.14,.18,.93),Color(.7,.95,.9,.14))
	cristal(Vector2(57,66),MENTA,1.1)
	texto(Vector2(84,53),"FRAGMENTOS DE LUZ",13,Color("bdd6cf"))
	texto(Vector2(82,91),"%02d / 12"%juego.puntaje,31)
	panel(Rect2(322,25,158,85),Color(.045,.14,.18,.93))
	texto(Vector2(340,51),"ENERGÍA",12,Color("bdd6cf"))
	for i in 3:corazon(Vector2(350+i*43,79),Color("eb9a88") if i<juego.vidas else Color(.3,.44,.45))
	panel(Rect2(1008,25,244,85),Color(.045,.14,.18,.94))
	var fraccion:float=clampf(juego.restantes/Plan.SEGUNDOS,0,1)
	var color:=Color.from_hsv(fraccion*.32,.57,.97)
	texto(Vector2(1028,51),"ANTES DE LA MAREA",12,Color("bdd6cf"))
	var segundos:=int(ceil(juego.restantes))
	texto(Vector2(1025,87),"%02d:%02d"%[segundos/60,segundos%60],30,color)
	draw_line(Vector2(1130,80),Vector2(1230,80),Color(.22,.37,.41),6)
	draw_line(Vector2(1130,80),Vector2(1130+100*fraccion,80),color,6)
	if juego.mensaje_tiempo>0:
		var m:String=juego.mensaje
		var ancho:float=fuente.get_string_size(m,HORIZONTAL_ALIGNMENT_LEFT,-1,17).x+40
		panel(Rect2((1280-ancho)/2,129,ancho,40),Color(.035,.14,.18,.88))
		texto(Vector2((1280-ancho)/2+20,155),m,17)
	panel(Rect2(28,622,674,70),Color(.045,.14,.18,.85))
	texto(Vector2(46,650),"WASD   mover      ESPACIO   saltar      SHIFT   correr",16)
	texto(Vector2(46,676),"Q / E   cámara      P / ESC   pausa      R   reiniciar      M   sonido",14,Color("b6d0c9"))
	_mapa()

func _mapa() -> void:
	panel(Rect2(1057,487,195,205),Color(.045,.14,.18,.94),Color(.7,.95,.9,.12))
	texto(Vector2(1077,515),"ISLA NÁCAR",12,ORO)
	var centro:=Vector2(1156,600)
	var puntos:=PackedVector2Array()
	for i in 49:
		var a:=TAU*i/48
		puntos.append(centro+Vector2(cos(a),sin(a))*T.costa(cos(a),sin(a))*3.8)
	draw_colored_polygon(puntos,Color("386e61"))
	for item in juego.objetos:
		if not item.tomado:
			draw_circle(centro+Vector2(item.position.x,item.position.z)*3.8,3.1,MENTA)
	for o in juego.obstaculos:draw_circle(centro+Vector2(o.position.x,o.position.z)*3.8,3.3,Color("ed9c92"))
	var p:Vector3=juego.get_node("Jugador").position
	var lugar:=centro+Vector2(p.x,p.z)*3.8
	var triangulo:=PackedVector2Array()
	var giro:float=-juego.get_node("Jugador").visual.rotation.y
	for v in [Vector2(0,-6),Vector2(-4,5),Vector2(4,5)]:triangulo.append(lugar+v.rotated(giro))
	draw_colored_polygon(triangulo,PAPEL)
	texto(Vector2(1077,680),"Luz",12,MENTA);texto(Vector2(1145,680),"Guardián",12,Color("ed9c92"))

func _resultado(estado:int) -> void:
	draw_rect(Rect2(0,0,1280,720),Color(.025,.08,.11,.70))
	panel(Rect2(329,175,621,380),Color(.04,.13,.17,.98),Color(.7,.95,.9,.24))
	var gano:bool=estado==juego.Estado.GANASTE
	var pausa:bool=estado==juego.Estado.PAUSA
	texto(Vector2(387,230),"LA LUZ PUEDE ESPERAR" if pausa else ("EL FARO VUELVE A BRILLAR" if gano else "LA MAREA NO ESPERA"),15,MENTA if gano or pausa else Color("ec9d8a"))
	texto(Vector2(383,302),"PAUSA" if pausa else ("GANASTE" if gano else "PERDISTE"),55,ORO if gano else PAPEL)
	if pausa:
		texto(Vector2(388,348),"Respira. Tu tiempo está detenido.",20,PAPEL)
	elif gano:
		texto(Vector2(388,348),"12 fragmentos recuperados. La isla tiene luz.",20,PAPEL)
		texto(Vector2(388,395),"Tiempo: %.1f s     Energía: %d / 3"%[Plan.SEGUNDOS-juego.restantes,juego.vidas],19,Color("b7d6cc"))
	else:
		texto(Vector2(388,348),juego.razon,18,PAPEL)
		texto(Vector2(388,395),"Recuperaste %d de 12. Puedes intentarlo otra vez."%juego.puntaje,19,Color("b7d6cc"))
