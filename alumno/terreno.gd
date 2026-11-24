# Terreno propio: cuadrícula indexada, UV y colores por altura. No usa PlaneMesh.
const PASOS := 80
const TAMANO := 48.0

static func costa(x: float, z: float) -> float:
	var a := atan2(z,x)
	return 17.4+1.5*sin(a*3)+.8*cos(a*5+.4)

static func altura(x: float, z: float) -> float:
	var radio := Vector2(x,z).length()
	var interior := .8+.20*sin(x*.4)*cos(z*.3)+.65*exp(-Vector2(x+3,z+5).length_squared()/45.0)
	var borde := smoothstep(costa(x,z)-3.4,costa(x,z)+1.2,radio)
	return lerpf(interior,-2.6,borde)

static func crear() -> ArrayMesh:
	var v := PackedVector3Array()
	var uv := PackedVector2Array()
	var colores := PackedColorArray()
	var idx := PackedInt32Array()
	for j in PASOS+1:
		for i in PASOS+1:
			var x := -TAMANO/2+TAMANO*i/PASOS
			var z := -TAMANO/2+TAMANO*j/PASOS
			var y := altura(x,z)
			v.append(Vector3(x,y,z))
			uv.append(Vector2(x,z)/3.5)
			var arena := Color("d4bb79")
			var pasto := Color("4f9971")
			var color := arena.lerp(pasto,smoothstep(.12,.74,y))
			color = color.lerp(Color("3f8462"),smoothstep(1.0,1.5,y)*.55)
			colores.append(color)
	for j in PASOS:
		for i in PASOS:
			var a := j*(PASOS+1)+i
			var b := a+1
			var c := a+PASOS+1
			idx.append_array([a,b,c,b,c+1,c])
	# Índices horarios vistos desde arriba: normal de la cara hacia +y.
	var normales := PackedVector3Array()
	for p in v:
		var h := .05
		normales.append(Vector3(altura(p.x-h,p.z)-altura(p.x+h,p.z),2*h,altura(p.x,p.z-h)-altura(p.x,p.z+h)).normalized())
	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX]=v
	arrays[Mesh.ARRAY_NORMAL]=normales
	arrays[Mesh.ARRAY_TEX_UV]=uv
	arrays[Mesh.ARRAY_COLOR]=colores
	arrays[Mesh.ARRAY_INDEX]=idx
	var m := ArrayMesh.new()
	m.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,arrays)
	return m
