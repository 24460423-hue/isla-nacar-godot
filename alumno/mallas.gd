# M13: vértices y normales por vértice, índices de triángulos horarios.
static func normal_cara(a: Vector3, b: Vector3, c: Vector3) -> Vector3:
	return (c-a).cross(b-a).normalized()

static func cara_visible(a: Vector3, b: Vector3, c: Vector3, ojo: Vector3) -> bool:
	return normal_cara(a,b,c).dot(ojo-a) > 0.0

static func malla_caja(tamano: Vector3) -> Dictionary:
	var h := tamano/2.0
	# Normal, u, v: u x v = normal.
	var caras := [
		[Vector3(1,0,0),Vector3(0,1,0),Vector3(0,0,1)],
		[Vector3(-1,0,0),Vector3(0,0,1),Vector3(0,1,0)],
		[Vector3(0,1,0),Vector3(0,0,1),Vector3(1,0,0)],
		[Vector3(0,-1,0),Vector3(1,0,0),Vector3(0,0,1)],
		[Vector3(0,0,1),Vector3(1,0,0),Vector3(0,1,0)],
		[Vector3(0,0,-1),Vector3(0,1,0),Vector3(1,0,0)]]
	var vertices := PackedVector3Array()
	var normales := PackedVector3Array()
	var indices := PackedInt32Array()
	for cara in caras:
		var n: Vector3 = cara[0]
		var u: Vector3 = cara[1]*h
		var w: Vector3 = cara[2]*h
		var centro := n*h
		var base := vertices.size()
		for p in [centro-u-w,centro+u-w,centro+u+w,centro-u+w]:
			vertices.append(p)
			normales.append(n)
		indices.append_array([base,base+2,base+1,base,base+3,base+2])
	return {"vertices":vertices,"normales":normales,"indices":indices}

static func esfera(radio: float, bandas: int, segmentos: int) -> Dictionary:
	var vertices := PackedVector3Array()
	var normales := PackedVector3Array()
	var indices := PackedInt32Array()
	for i in bandas+1:
		var phi := PI*i/bandas
		for j in segmentos+1:
			var theta := TAU*j/segmentos
			var n := Vector3(sin(phi)*sin(theta),cos(phi),sin(phi)*cos(theta))
			vertices.append(n*radio)
			normales.append(n)
	for i in bandas:
		for j in segmentos:
			var a := i*(segmentos+1)+j
			var b := a+1
			var c := a+segmentos+1
			var d := c+1
			if i != 0:
				indices.append_array([a,b,c])
			if i != bandas-1:
				indices.append_array([b,d,c])
	return {"vertices":vertices,"normales":normales,"indices":indices}

static func revolucion(perfil: PackedVector2Array, segmentos: int) -> Dictionary:
	var vertices := PackedVector3Array()
	var indices := PackedInt32Array()
	for q in perfil:
		for j in segmentos+1:
			var theta := TAU*j/segmentos
			vertices.append(Vector3(q.x*sin(theta),q.y,q.x*cos(theta)))
	for i in perfil.size()-1:
		for j in segmentos:
			var a := i*(segmentos+1)+j
			var b := a+1
			var c := a+segmentos+1
			var d := c+1
			indices.append_array([a,c,b,b,c,d])
	return {"vertices":vertices,"normales":normales_suaves(vertices,indices),"indices":indices}

static func normales_suaves(vertices: PackedVector3Array, indices: PackedInt32Array) -> PackedVector3Array:
	var suma := PackedVector3Array()
	suma.resize(vertices.size())
	for t in range(0,indices.size(),3):
		var n := (vertices[indices[t+2]]-vertices[indices[t]]).cross(vertices[indices[t+1]]-vertices[indices[t]])
		for k in 3:
			suma[indices[t+k]] += n
	for i in suma.size():
		suma[i] = suma[i].normalized()
	return suma

static func a_arraymesh(malla: Dictionary) -> ArrayMesh:
	var arreglos := []
	arreglos.resize(Mesh.ARRAY_MAX)
	arreglos[Mesh.ARRAY_VERTEX] = malla["vertices"]
	arreglos[Mesh.ARRAY_NORMAL] = malla["normales"]
	arreglos[Mesh.ARRAY_INDEX] = malla["indices"]
	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,arreglos)
	return mesh
