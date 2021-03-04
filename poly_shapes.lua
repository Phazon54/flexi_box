function gen_polygon(nb_faces, diameter, height)
  local a = 360/nb_faces
  local r = diameter/2
  
  local poly = {v(0,-r)}
  for i = 1, nb_faces do
    point = v(r*sin(a*i),-r*cos(a*i))
    table.insert(poly,point)
  end

  return linear_extrude(v(0,0,height),poly)
end

--####################################################################

function get_polygon_side(polygon_nb_faces, polygon_diameter)
	return 2*(polygon_diameter/2)*sin(180/polygon_nb_faces)
end

--####################################################################

function place_on_polygon(polygon_nb_faces, polygon_diameter,placement, location_id, shape, offset_to_polygon)
	-- the location_id is determined counter-clockwise, 
	-- with the first face being the on bottom-right of the polygon
	-- (and the first corner on the bottom)
	--	
	--							 		top (x)
	--		  						  *
	--							3	  *   * 	2
	--								*       *
	--	left(-y)	4 	*       * 	1
	--								*       *
	--		  				5	  *   * 	0	<- first side
	--		    						*
	--
	-- placement refers to where the shape is placed:
	--						- 1/true: on the face
	--						- 0/false: on the corner
	if placement == 1 then placement = true else placement = false end

	local a = 360/polygon_nb_faces
	local correction_angle = a*location_id
	local dist = (polygon_diameter/2) + bbox(shape):max_corner().y

	if placement then
		correction_angle = (a/2)+a*location_id
		dist = math.sqrt((polygon_diameter/2)^2 - (get_polygon_side(polygon_nb_faces,polygon_diameter)/2)^2) + bbox(shape):max_corner().y
	end

	local position = v((dist+offset_to_polygon)*sin(correction_angle),-(dist+offset_to_polygon)*cos(correction_angle))

	return translate(position)*rotate(0,0,correction_angle)*shape
end

--####################################################################

function place_on_all(polygon_nb_faces, polygon_diameter, placement, shape, offset_to_polygon)
	-- placement refers to where the shape is placed:
	--						- 1/true: on the face
	--						- 0/false: on the corner
	shapes = {}
	for i = 0, polygon_nb_faces-1 do
		shapes[i] = place_on_polygon(polygon_nb_faces,polygon_diameter,placement,i,shape,offset_to_polygon)
	end

	return union(shapes)
end

--####################################################################

function gen_trapeze(base1, base2, height, thickness)
	local trapeze  = {
		v(-base1/2,0),
		v(base1/2,0),
		v(base2/2,height),
		v(-base2/2,height)
	}

	return linear_extrude(v(0,0,thickness),trapeze)
end
