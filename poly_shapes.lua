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

function get_polygon_side(polygon_nb_faces, polygon_diameter)
	return 2*(polygon_diameter/2)*sin(180/polygon_nb_faces)
end

function place_on_polygon(polygon_nb_faces, polygon_diameter, element_id, element_type, shape)
	-- the element_id is determined counter-clockwise, 
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
	-- element_type refers to where the shape is placed:
	--						- 1/true: on the face
	--						- 0/false: on the corner
	if element_type == 1 then element_type = true else element_type = false end
	local a = 360/polygon_nb_faces
	local angle_offset = 0
	local r = polygon_diameter/2
	if element_type then
		angle_offset = a/2
	end
	local position = v(r*sin(angle_offset+a*element_id),-r*cos(angle_offset+a*element_id)) -- TODO: revise position to eliminate offset due to rotation

	return translate(position)*rotate(0,0,0)*shape
end

function place_on_all(polygon_nb_faces, polygon_diameter, element_type,shape)
	-- element_type refers to where the shape is placed:
	--						- 1/true: on the face
	--						- 0/false: on the corner
	shapes = {}
	for i = 0, polygon_nb_faces-1 do
		shapes[i] = place_on_polygon(polygon_nb_faces,polygon_diameter,i,element_type,shape)
	end
	return union(shapes)
end

function gen_trapeze(base1, base2, height, thickness)
	local trapeze  = {
		v(-base1/2,0),
		v(base1/2,0),
		v(base2/2,height),
		v(-base2/2,height)
	}
	return linear_extrude(v(0,0,thickness),trapeze)
end
