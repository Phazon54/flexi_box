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

--####################################################################

-- basic polygons "lib" import
dofile(Path .. 'poly_shapes.lua')

--####################################################################

function gen_angle_chamfer(nb_faces,diameter,cutting_width,cutting_angle)
  local side = 2*(diameter/2)*sin(180/nb_faces)
  local angle = 360/nb_faces
  cut = {}
  for i = 1, nb_faces do
    cut[i] = rotate(0,0,i*angle)*translate(0,(diameter/2),0)*rotate(cutting_angle,0,0)*cube(side,cutting_width,cutting_width)
  end
  cut = union(cut)
  cut = rotate(0,0,180-angle/2)*cut -- correcting angle to match gen_polygon()
  return cut
end

--####################################################################

lock_meat = difference{
  gen_polygon(box_nb_faces,box_diameter-box_wall_th*2,lid_height),
  gen_polygon(box_nb_faces,box_diameter-box_wall_th*4,lid_height)
}

box = union{
  difference{
    gen_polygon(box_nb_faces,box_diameter,box_height),
    translate(0,0,box_wall_th)*gen_polygon(box_nb_faces,box_diameter-box_wall_th*2,box_height),
    translate(0,0,-25)*gen_angle_chamfer(box_nb_faces,box_diameter,30,45) -- angles chamfer
  },
  translate(0,0,box_height-lid_height)*lock_meat
}
--emit(box)

lid_cavity = gen_polygon(box_nb_faces,(box_diameter-box_wall_th*5),lid_height)

lid = difference{
  union{
    gen_polygon(box_nb_faces,(box_diameter-box_wall_th*4)-lid_clearance*2,lid_height),
    translate(0,0,lid_height)*gen_polygon(box_nb_faces,box_diameter,box_wall_th),
  },
  translate(0,0,33)*gen_angle_chamfer(box_nb_faces,box_diameter,30,45), -- angles chamfer
  translate(0,0,box_wall_th/2)*lid_cavity,
  cylinder(key_hole_diameter/2,lid_height+box_wall_th)
}
--emit(translate(0,0,box_height-lid_height)*lid)

--####################################################################

-- items to feed in the view
items = union{
  box,
  translate(0,0,box_height-lid_height)*lid
}
--emit(items)
emit(difference(items,translate(0,-115,0)*cube(230))) -- cross-section view
