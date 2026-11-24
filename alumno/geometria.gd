const Mallas := preload("res://alumno/mallas.gd")

static func material(color: Color, brillo: float = 0.7, emision: float = 0.0) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = color
	m.roughness = brillo
	if emision > 0.0:
		m.emission_enabled = true
		m.emission = color
		m.emission_energy_multiplier = emision
	return m

static func figura(padre: Node, nombre: String, mesh: Mesh, mat: Material, pos: Vector3 = Vector3.ZERO, escala: Vector3 = Vector3.ONE) -> MeshInstance3D:
	var n := MeshInstance3D.new()
	n.name = nombre
	n.mesh = mesh
	n.material_override = mat
	n.position = pos
	n.scale = escala
	padre.add_child(n)
	return n

static func caja(tamano: Vector3) -> ArrayMesh:
	return Mallas.a_arraymesh(Mallas.malla_caja(tamano))

static func esfera(radio: float, bandas: int = 8, segmentos: int = 12) -> ArrayMesh:
	return Mallas.a_arraymesh(Mallas.esfera(radio,bandas,segmentos))

static func cilindro(radio: float, alto: float, segmentos: int = 12, radio_arriba: float = -1.0) -> ArrayMesh:
	var rt := radio if radio_arriba < 0 else radio_arriba
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for i in segmentos:
		var a := TAU*i/segmentos
		var b := TAU*(i+1)/segmentos
		var p := Vector3(sin(a)*radio,-alto/2,cos(a)*radio)
		var q := Vector3(sin(b)*radio,-alto/2,cos(b)*radio)
		var r := Vector3(sin(a)*rt,alto/2,cos(a)*rt)
		var s := Vector3(sin(b)*rt,alto/2,cos(b)*rt)
		for tri in [[p,r,q],[q,r,s],[Vector3(0,alto/2,0),s,r],[Vector3(0,-alto/2,0),p,q]]:
			var n := Mallas.normal_cara(tri[0],tri[1],tri[2])
			for v in tri:
				st.set_normal(n)
				st.add_vertex(v)
	return st.commit()

static func cristal() -> ArrayMesh:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for i in 6:
		var a := TAU*i/6
		var b := TAU*(i+1)/6
		var p := Vector3(sin(a)*.31,0,cos(a)*.31)
		var q := Vector3(sin(b)*.31,0,cos(b)*.31)
		for tri in [[Vector3(0,.57,0),q,p],[Vector3(0,-.40,0),p,q]]:
			var n := Mallas.normal_cara(tri[0],tri[1],tri[2])
			for v in tri:
				st.set_normal(n)
				st.add_vertex(v)
	return st.commit()

static func colision_caja(padre: Node3D, tamano: Vector3, posicion: Vector3) -> StaticBody3D:
	var cuerpo := StaticBody3D.new()
	var forma := CollisionShape3D.new()
	var caja_shape := BoxShape3D.new()
	caja_shape.size = tamano
	forma.shape = caja_shape
	cuerpo.position = posicion
	cuerpo.add_child(forma)
	padre.add_child(cuerpo)
	return cuerpo
