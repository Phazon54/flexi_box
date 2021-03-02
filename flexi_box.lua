dofile(Path .. 'poly_shapes.lua')

poly = gen_polygon(10,20,5)
emit(poly)

tr = gen_trapeze(51,20,40,5)
emit(tr)
