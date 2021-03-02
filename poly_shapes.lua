function gen_polygon(nb_faces,diameter,height)
  local a = 360/nb_faces
  local r = diameter/2
  
  local poly = {v(0,-r)}
  for i = 1, nb_faces do
    point = v(r*sin(a*i),-r*cos(a*i))
    table.insert(poly,point)
  end
  return linear_extrude(v(0,0,height),poly)
end

function gen_trapeze(base1,base2,height,thickness)
	local trapeze  = {
		v(-base1/2,0),
		v(base1/2,0),
		v(base2/2,height),
		v(-base2/2,height)
	}
	return linear_extrude(v(0,0,thickness),trapeze)
end
