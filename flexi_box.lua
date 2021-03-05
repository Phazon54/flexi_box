-- Polygonal box with flexible internal mechanism
-- Pierre Bedell 03/03/2021

-- Inspired by the amazing "Expanding Mechanism Lock Box"
-- from Maker's Muse
-- https://www.youtube.com/watch?v=LU77kPf25Yg
-- https://www.makersmuse.com/expanding-lock-box

-- The internal mechanism is intended to be printed in
-- flexible filament, using Phasor infill and 
-- oriented in a way to allow each locking peg to retract 
-- by themselves when twisting the "key" rod

box_nb_faces = 6
box_diameter = 200
box_height = 100

box_wall_th = 10

lid_height = 20
lid_clearance = 0.4

key_hole_diameter = 30

-- m3 screws
screw_diameter = 3
screw_head_diameter = 5.5
screw_head_height = 2
screw_thread_diameter = 2.5

screw_head_bridging = 0.2 -- layer height !

embossing_depth = 2

--####################################################################

-- Basic polygons "lib" import
dofile(Path .. 'poly_shapes.lua')

-- Assets
svg_logo = svg_contouring(Path .. 'logo.svg',90)
svg_qrcode = svg_contouring(Path .. 'qrcode.svg',90)

--####################################################################

--####################################################################

lock_meat = difference{
  gen_polygon(box_nb_faces,box_diameter-box_wall_th*2,lid_height),
  gen_polygon(box_nb_faces,box_diameter-box_wall_th*4,lid_height)
}

icesl_logo = {}
for _, contour in pairs(svg_logo) do
  icesl_logo[#icesl_logo+1] = linear_extrude_from_oriented(v(0,0,embossing_depth),contour:outline())
end
icesl_logo = rotate(-90,0,0)*scale(1.6,1.6,1)*union(icesl_logo)

icesl_qrcode = {}
for contour=2,#svg_qrcode do
  icesl_qrcode[#icesl_qrcode+1] = linear_extrude_from_oriented(v(0,0,embossing_depth),svg_qrcode[contour]:outline())
end
icesl_qrcode = rotate(-90,0,0)*union(icesl_qrcode)

box = union{
  difference{
    gen_polygon(box_nb_faces,box_diameter,box_height),
    translate(0,0,box_wall_th)*gen_polygon(box_nb_faces,box_diameter-box_wall_th*2,box_height)
  },
  translate(0,0,box_height-lid_height)*lock_meat
}

lid_screw_holes = union{
  place_on_all(-- screw head hole
    box_nb_faces,
    (box_diameter-box_wall_th*5),
    0,
    cylinder(screw_head_diameter/2,(screw_head_height-screw_head_bridging)),
    -(screw_head_diameter/4)-(box_wall_th/2)
  ), 
  translate(0,0,screw_head_height)*place_on_all(-- screw holes 
    box_nb_faces,
    (box_diameter-box_wall_th*5),
    0,
    cylinder(screw_diameter/2,(box_wall_th-screw_head_height)),
    -box_wall_th/2
  ) 
}

lid_screw_guides = difference{
  place_on_all(
    box_nb_faces,
    (box_diameter-box_wall_th*5),
    0,
    gen_polygon(box_nb_faces,screw_diameter*3,lid_height-box_wall_th/2),
    -screw_diameter*3
  ),
  place_on_all(
    box_nb_faces,
    (box_diameter-box_wall_th*5),
    0,
    cylinder(screw_diameter/2,lid_height-box_wall_th/2),
    -(screw_head_diameter/4)-(box_wall_th/2)
  )
}

lid_bottom = union{
  difference{
    gen_polygon(box_nb_faces,(box_diameter-box_wall_th*4)-lid_clearance*2,lid_height),-- body
    translate(0,0,box_wall_th/2)*gen_polygon(box_nb_faces,(box_diameter-box_wall_th*5),lid_height), -- cavity
    lid_screw_holes, -- screw holes
    cylinder(key_hole_diameter/2,box_wall_th/2) -- key hole
  },
  translate(0,0,box_wall_th/2)*lid_screw_guides
}

lid_top = difference{
  gen_polygon(box_nb_faces,box_diameter,box_wall_th/2),
  cylinder(key_hole_diameter/2,lid_height+box_wall_th), -- key hole
  place_on_all(-- screw holes 
    box_nb_faces,
    (box_diameter-box_wall_th*5),
    0,
    cylinder(screw_diameter/2,box_wall_th/3),
    -box_wall_th/2
  )
}

--####################################################################

splitting_factor = ui_number("splitting_factor", 0, 0, 50)

-- items to feed in the view
items = {
  --{shape,v(posx,posy,posz),brush}
  {box,v(0,0,0),0},
  {lid_bottom,v(0,0,(box_height-lid_height)+splitting_factor),2},
  {lid_top,v(0,0,box_height+splitting_factor*1.5),3},
}

cross_section = ui_bool("cross section view", false)

for i,item in pairs(items) do
  if cross_section then
    cut_x = bbox(items[i][1]):extent().x
    cut_y = bbox(items[i][1]):extent().y
    cut_z = bbox(items[i][1]):extent().z
    cut = cube(cut_x,cut_y,cut_z)
    out = difference{
      translate(items[i][2])*items[i][1], -- item
      --translate(0,-cut_y/2,0)*cut -- cross section cut
      translate(0,-cut_y/2,items[i][2].z)*cut -- cross section cut
    }
    emit(out,items[i][3])
  else
    out = translate(items[i][2])*items[i][1]
    emit(out,items[i][3])
  end
end
