# Plan previo a la implementación. Las coordenadas 2D representan (x,z).
const TITULO := "Isla Nácar"
const TOTAL := 12
const SEGUNDOS := 150.0
const VIDAS := 3
const INICIO := Vector2(0,10)
const GEMAS := [Vector2(-11,8),Vector2(-5,11),Vector2(5,11),Vector2(11,7),Vector2(12,-1),Vector2(9,-9),Vector2(1,-12),Vector2(-7,-10),Vector2(-12,-3),Vector2(-6,0),Vector2(2,4),Vector2(6,-3)]
const PLATAFORMAS := {7:1.15,11:1.35}
const BEZIER := [Vector2(-12,4),Vector2(-10,-10),Vector2(-1,-8),Vector2(-3,6)]
const BSPLINE := [Vector2(3,5),Vector2(10,8),Vector2(14,1),Vector2(10,-8),Vector2(4,-5),Vector2(1,0)]
const ARBOLES := [Vector2(-13,5),Vector2(-11,-7),Vector2(-4,-12),Vector2(5,-12),Vector2(12,-6),Vector2(13,3),Vector2(7,12),Vector2(-8,12),Vector2(-4,-5)]
const NIVEL_FRACTAL := 3
