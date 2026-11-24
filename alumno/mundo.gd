extends Node3D
const G := preload("res://alumno/geometria.gd")
const T := preload("res://alumno/terreno.gd")
const F := preload("res://alumno/fractal3d.gd")
const Plan := preload("res://alumno/plan.gd")
var terreno: MeshInstance3D
var ramas_generadas := 0
var hojas_generadas := 0
var luz_faro: OmniLight3D

func _ready() -> void:
	_crear_terreno()
	_crear_agua()
	_crear_fractales()
	_crear_faro()
	_crear_decoracion()

func _crear_terreno() -> void:
	var mat := G.material(Color.WHITE,.92)
	mat.vertex_color_use_as_albedo = true
	mat.vertex_color_is_srgb = true
	mat.albedo_texture = preload("res://alumno/recursos/arena.svg")
	mat.uv1_scale = Vector3(1,1,1)
	terreno = G.figura(self,"Terreno_ArrayMesh",T.crear(),mat)
	var suelo := StaticBody3D.new()
	suelo.name="ColisionTerreno"
	var forma:=CollisionShape3D.new()
	forma.shape=terreno.mesh.create_trimesh_shape()
	suelo.add_child(forma)
	add_child(suelo)

func _crear_agua() -> void:
	var v:=PackedVector3Array()
	var idx:=PackedInt32Array()
	const N:=90
	for j in N+1:
		for i in N+1:
			v.append(Vector3(-90.0+180.0*i/N,-.08,-90.0+180.0*j/N))
	for j in N:
		for i in N:
			var a:=j*(N+1)+i
			idx.append_array([a,a+1,a+N+1,a+1,a+N+2,a+N+1])
	var arrays:=[]; arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX]=v; arrays[Mesh.ARRAY_INDEX]=idx
	var mesh:=ArrayMesh.new(); mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,arrays)
	var mat:=ShaderMaterial.new(); mat.shader=preload("res://alumno/agua.gdshader")
	var agua:=G.figura(self,"Agua_Shader",mesh,mat)
	agua.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

func _crear_fractales() -> void:
	var ramas:=[]
	var hojas:=[]
	for i in Plan.ARBOLES.size():
		var punto:Vector2=Plan.ARBOLES[i]
		var origen:=Vector3(punto.x,T.altura(punto.x,punto.y),punto.y)
		var giro:=float(i)*1.17
		for rama in F.ramas(Plan.NIVEL_FRACTAL):
			var a:Vector3=origen+rama["a"].rotated(Vector3.UP,giro)
			var b:Vector3=origen+rama["b"].rotated(Vector3.UP,giro)
			var r:float=rama["radio"]
			var basis:=Basis(Quaternion(Vector3.UP,(b-a).normalized())).scaled_local(Vector3(r,(b-a).length(),r))
			ramas.append(Transform3D(basis,(a+b)/2))
			if rama["hoja"]:
				hojas.append(Transform3D(Basis.from_euler(Vector3(0,giro,0)).scaled_local(Vector3(.68,.52,.68)),b))
	ramas_generadas=ramas.size(); hojas_generadas=hojas.size()
	_multimesh("Ramas_Fractal",G.cilindro(1,1,6,.65),G.material(Color("82684c")),ramas,false)
	_multimesh("Copas_Fractal",G.esfera(1,4,7),G.material(Color.WHITE),hojas,true)

func _multimesh(nombre:String,mesh:Mesh,mat:StandardMaterial3D,poses:Array,colores:bool) -> void:
	var mm:=MultiMesh.new()
	mm.transform_format=MultiMesh.TRANSFORM_3D
	mm.use_colors=colores
	mm.mesh=mesh
	mm.instance_count=poses.size()
	mat.vertex_color_use_as_albedo=colores
	mat.vertex_color_is_srgb=colores
	for i in poses.size():
		mm.set_instance_transform(i,poses[i])
		if colores: mm.set_instance_color(i,[Color("287e6c"),Color("3eab87"),Color("73bfa0")][i%3])
	var n:=MultiMeshInstance3D.new(); n.name=nombre; n.multimesh=mm; n.material_override=mat; add_child(n)

func _crear_faro() -> void:
	var p:=Vector3(0,T.altura(0,0),0)
	var faro:=Node3D.new(); faro.name="Faro"; faro.position=p; add_child(faro)
	var crema:=G.material(Color("efe9d1"))
	var azul:=G.material(Color("264b61"),.35)
	G.figura(faro,"Base",G.cilindro(1.45,.4,12),azul,Vector3(0,.2,0))
	G.figura(faro,"Torre",G.cilindro(.85,3.5,12,.63),crema,Vector3(0,2.1,0))
	G.figura(faro,"Banda",G.cilindro(.79,.40,12,.77),azul,Vector3(0,1.85,0))
	G.figura(faro,"Galeria",G.cilindro(1.04,.15,12),azul,Vector3(0,3.9,0))
	G.figura(faro,"Cristal",G.cilindro(.59,.75,12),G.material(Color("69dad0"),.15,.65),Vector3(0,4.4,0))
	G.figura(faro,"Techo",G.cilindro(1.10,.65,12,.0),azul,Vector3(0,5.0,0))
	G.colision_caja(faro,Vector3(1.5,3.8,1.5),Vector3(0,1.9,0))
	luz_faro=OmniLight3D.new(); luz_faro.position=Vector3(0,4.5,0); luz_faro.light_color=Color("8dfcec"); luz_faro.light_energy=.7; luz_faro.omni_range=7; faro.add_child(luz_faro)

func _crear_decoracion() -> void:
	var piedra:=G.material(Color("94aca6"),.93)
	var borde:=G.material(Color("ddd6bb"),.8)
	for id in Plan.PLATAFORMAS:
		var punto:Vector2=Plan.GEMAS[id]
		var alto:float=Plan.PLATAFORMAS[id]
		var base:=Vector3(punto.x,T.altura(punto.x,punto.y),punto.y)
		G.figura(self,"Ruina"+str(id),G.caja(Vector3(2.1,alto,2.1)),piedra,base+Vector3(0,alto/2,0))
		G.colision_caja(self,Vector3(2.1,alto,2.1),base+Vector3(0,alto/2,0))
		G.figura(self,"BordeRuina"+str(id),G.caja(Vector3(2.2,.10,2.2)),borde,base+Vector3(0,alto+.03,0))
	var rng:=RandomNumberGenerator.new(); rng.seed=22705
	for i in 24:
		var a:=TAU*i/24
		var r:=T.costa(cos(a),sin(a))-1.7
		var x:=cos(a)*r; var z:=sin(a)*r
		var mesh:=G.figura(self,"RocaCosta"+str(i),G.esfera(.7,3,6),piedra,Vector3(x,T.altura(x,z)+.14,z),Vector3(1.3,.5,1.0)*rng.randf_range(.7,1.3))
		mesh.rotation.y=a
	var mat_camino:=G.material(Color("c1bd96"))
	for i in 26:
		var a:=TAU*i/26
		var p:=Vector2(sin(a)*4,cos(a)*4)
		var n:=G.figura(self,"Sendero"+str(i),G.cilindro(.24,.07,6),mat_camino,Vector3(p.x,T.altura(p.x,p.y)+.03,p.y),Vector3(1.1,1,.8))
		n.rotation.y=a
	var inicio:Vector2=Plan.INICIO
	G.figura(self,"PuntoDeLlegada",G.cilindro(.95,.06,12),G.material(Color("ecdc99")),Vector3(inicio.x,T.altura(inicio.x,inicio.y)+.035,inicio.y))

func altura_objeto(id:int) -> float:
	var p:Vector2=Plan.GEMAS[id]
	return T.altura(p.x,p.y)+float(Plan.PLATAFORMAS.get(id,0.0))
