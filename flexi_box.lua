-- Polygonal box with flexible internal mechanism
-- Pierre Bedell 07/03/2021

-- Inspired by the amazing "Expanding Mechanism Lock Box"
-- from Maker's Muse
-- https://www.youtube.com/watch?v=LU77kPf25Yg
-- https://www.makersmuse.com/expanding-lock-box

-- The internal mechanism is intended to be printed in
-- flexible filament, using Phasor infill and 
-- oriented in a way to allow each locking peg to retract 
-- by themselves when twisting the "key" rod

box_nb_faces = 6
box_diameter = 100
box_height = 50

box_wall_th = 2.5

lid_height = 10
lid_clearance = 0.4

use_key = false
if use_key then
  key_diameter = 12 
  key_nb_faces = 6
  key_length = 25
  key_cross_length = 38
else
  key_diameter = 6 -- m6 screw
end

key_hole_diameter = key_diameter*1.2

-- m3 screws
screw_diameter = 3
screw_head_diameter = 5.5
screw_head_height = 2
screw_thread_diameter = 2.5

screw_head_bridging = 0.2 -- layer height !

relief = 0.7

--####################################################################

-- Basic polygons "lib" import
dofile(Path .. 'poly_shapes.lua')

-- Assets
svg_logo = svg_contouring(Path .. 'assets/logo.svg',90)
svg_qrcode = svg_contouring(Path .. 'assets/qrcode.svg',90)

--####################################################################

function setup_default()
  --set_setting_value('infill_type_0', 'Default');
  set_setting_value('infill_type_0', 'Gyroid')
  set_setting_value('num_shells_0', 2)
  set_setting_value('cover_thickness_mm_0', 2)
  set_setting_value('print_perimeter_0', true)
  set_setting_value('infill_percentage_0', 20)
end

function setup_phasor(lock_shape)
  set_setting_value('printer', 'CR10S_Pro')
  set_setting_value('infill_type_0', 'Phasor')
  set_setting_value('num_shells_0', 0)
  set_setting_value('cover_thickness_mm_0', 0)
  set_setting_value('print_perimeter_0', false)

  set_setting_value('filament_priming_mm_0',0.0)
  set_setting_value('flow_multiplier_0',1.35)
  set_setting_value('speed_multiplier_0',1.35)

  set_setting_value('extruder_temp_degree_c_0',240.0)
  set_setting_value('bed_temp_degree_c',50.0)

  set_setting_value('print_speed_mm_per_sec',35.0)
  set_setting_value('first_layer_print_speed_mm_per_sec',20.0)

  local inner_density = 0.25
  local outer_density = 0.35

  local inner_iso = 0.0
  local outer_iso = 0.5

  local bx = bbox(lock_shape)
  -- Allocate the field as a 3D texture
  local ratios = tex3d_rgb8f(64,64,64)
  local iso = tex3d_rgb8f(64,64,64)
  local density = tex3d_rgb8f(64,64,64)

  for i = 0,63 do
    for j = 0,63 do
      for k = 0,63 do
        x = i - 33
        y = j - 33
        z = k / 64
        -- defining borders
        --l = (length(v(x,y))/32.0 - 1/6) / (11/12)
        l = (length(v(x,y))/32.0 - 1/16) / (7/8)
        
        -- defining an horizontal V shape for the fields
        z = math.abs(0.5-z) * 2.0
        l = math.abs(0.5-l) * 2.0
        z = z * 0.5 + 0.25
        
        -- apply infill_isotropy & infill_percentage
        if l>z then
          iso:set(i,j,k, v(outer_iso,0,0))
          density:set(i,j,k, v(outer_density,0,0))
        else
          iso:set(i,j,k, v(inner_iso,0,0))
          density:set(i,j,k, v(inner_density,0,0))
        end
        
        -- infill_theta
        lt = length(v(x,y))/32.0
        a = (atan2(y,x) / 360 + lt/6)%1.0;
        ratios:set(i,j,k, v(a,0,0))
      end
    end
  end  
  
  set_setting_value('phasor_infill_theta_0', ratios, bx:min_corner(), bx:max_corner())
  set_setting_value('phasor_infill_iso_0', iso, bx:min_corner(), bx:max_corner())
  set_setting_value('infill_percentage_0', density, bx:min_corner(), bx:max_corner())
end

--####################################################################
box_side_length = get_polygon_side(box_nb_faces,box_diameter)
indent_out = v(box_side_length-box_wall_th*4,box_height-lid_height-box_wall_th)
indent_in = v(indent_out.x-box_wall_th*2, indent_out.y - box_wall_th*2)

icesl_logo = {}
for _, contour in pairs(svg_logo) do
  icesl_logo[#icesl_logo+1] = linear_extrude_from_oriented(v(0,0,relief),contour:outline())
end
icesl_logo = rotate(-90,0,0)*union(icesl_logo)

logo_to_box = (indent_in.y - box_wall_th*2) / bbox(icesl_logo):extent().z
icesl_logo = scale(logo_to_box,1,logo_to_box)*icesl_logo

logo = place_on_polygon(
  box_nb_faces,
  box_diameter,
  1, 
  0, 
  translate(-(box_side_length/2)+(bbox(icesl_logo):extent().x),0,(bbox(icesl_logo):extent().z)+(box_height-lid_height-box_wall_th*3)/4)*icesl_logo, 
  -box_wall_th/2
)

icesl_qrcode = {}
for contour=2,#svg_qrcode do
  icesl_qrcode[#icesl_qrcode+1] = linear_extrude_from_oriented(v(0,0,relief),svg_qrcode[contour]:outline())
end
icesl_qrcode = rotate(-90,0,0)*union(icesl_qrcode)

qrcode_to_box = (indent_in.y - box_wall_th*2) / bbox(icesl_qrcode):extent().z
icesl_qrcode = scale(qrcode_to_box,1,qrcode_to_box)*icesl_qrcode

qrcode = place_on_polygon(
  box_nb_faces,
  box_diameter,
  1, 
  3, 
  translate(-(box_side_length/2)+(bbox(icesl_qrcode):extent().x/2.6),0,(bbox(icesl_qrcode):extent().z)+(box_height-lid_height-box_wall_th*2)/4)*icesl_qrcode, 
  -box_wall_th/2
)

-- chamfers
box_corner_chamfer = place_on_all(
  box_nb_faces,
  box_diameter,
  0,
  cube(box_wall_th*2,box_wall_th*2,box_height),
  -box_wall_th/2
)

box_edge_chamfer = place_on_all(
  box_nb_faces,
  box_diameter,
  1,
  rotate(45,0,0)*cube(box_side_length,box_wall_th*2,box_wall_th*2),
  -box_wall_th/1.5
)

lid_corner_chamfer = place_on_all(
  box_nb_faces,
  box_diameter,
  0,
  cube(box_wall_th*2,box_wall_th*2,box_wall_th),
  -box_wall_th/2
)

-- locking pegs holes 
box_peg_holes = place_on_all(
  box_nb_faces,
  box_diameter,
  1,
  translate(box_side_length/6,0,0)*cube(box_side_length/4,box_wall_th*2,lid_height-box_wall_th*2),
  -box_wall_th*2
)

lid_peg_holes = place_on_all(
  box_nb_faces,
  box_diameter-box_wall_th*4,
  1,
  translate(box_side_length/6,0,0)*cube(box_side_length/4,box_wall_th,lid_height-box_wall_th*2),
  -box_wall_th
)

-- lid 'vents'
lid_vents = place_on_all( -- TODO : rework base shape dimension to accomodate all types of n-gons box (currently on works for hexagonal box)
  box_nb_faces,
  box_diameter,
  1,
  --rotate(180,0,0)*gen_polygon(3,box_side_length-box_wall_th*7,box_wall_th*2),
  gen_trapeze(box_side_length-box_wall_th*7, box_wall_th*2.5, box_side_length-box_wall_th*11, box_wall_th*2),
  -box_diameter/3.1
)

-- lid
screw_pos = (screw_diameter/2)+(box_wall_th/2)

lid_bottom_screw_holes = union{
  place_on_all(-- screw head hole
    box_nb_faces,
    (box_diameter-box_wall_th*5),
    0,
    cylinder(screw_head_diameter/2,screw_head_height),
    -screw_pos-screw_head_diameter/4
  ), 
  translate(0,0,screw_head_height+screw_head_bridging)*place_on_all(-- screw holes 
    box_nb_faces,
    (box_diameter-box_wall_th*5),
    0,
    cylinder(screw_diameter/2,lid_height-screw_head_bridging),
    -screw_pos
  ) 
}

lid_top_screw_holes = place_on_all( 
  box_nb_faces,
  (box_diameter-box_wall_th*5),
  0,
  cylinder(screw_thread_diameter/2,box_wall_th/3),
  -screw_pos+(screw_diameter/2-screw_thread_diameter/2)
)

lid_screw_guides = place_on_all(
  box_nb_faces,
  (box_diameter-box_wall_th*5),
  0,
  gen_polygon(box_nb_faces,screw_diameter*3,lid_height-box_wall_th),
  -screw_pos-screw_diameter
)

lid_screw_guides_cut = place_on_all(
  box_nb_faces,
  (box_diameter-box_wall_th*5),
  0,
  gen_polygon(box_nb_faces,(screw_diameter*3)+lid_clearance*2,box_wall_th),
  -screw_pos-screw_diameter-lid_clearance
)

lid_bottom = union{
  difference{
    gen_polygon(box_nb_faces,(box_diameter-box_wall_th*4)-lid_clearance*2,lid_height),-- body
    translate(0,0,box_wall_th)*gen_polygon(box_nb_faces,(box_diameter-box_wall_th*6)-lid_clearance*2,lid_height-box_wall_th), -- cavity    
  },
  translate(0,0,box_wall_th)*lid_screw_guides,
}

lid_bottom = difference{
  lid_bottom,
  cylinder(key_hole_diameter/2,box_wall_th), -- key hole
  lid_bottom_screw_holes, -- screw holes
  translate(0,0,box_wall_th)*lid_peg_holes -- locking pegs holes
}

lid_top = difference{
  union{
    gen_polygon(box_nb_faces,box_diameter,box_wall_th),
    translate(0,0,-box_wall_th)*gen_polygon(box_nb_faces,(box_diameter-box_wall_th*6)-lid_clearance*4,box_wall_th),
  },
  translate(0,0,-box_wall_th)*lid_screw_guides_cut,
  translate(0,0,-box_wall_th)*cylinder(key_hole_diameter/2,box_wall_th*2), -- key hole
  lid_top_screw_holes, -- screw holes
  translate(0,0,box_wall_th/3)*box_edge_chamfer, -- edges chamfer
  lid_corner_chamfer, -- corner chamfer
  translate(0,0,-box_wall_th)*lid_vents, -- lid 'vents'
}

-- box indents
indent = gen_flat_pyramid(indent_out, indent_in, box_wall_th/2)

indents = place_on_all(
  box_nb_faces,
  box_diameter,
  1,
  translate(0,0,(indent_out.y/2)+box_wall_th)*rotate(-90,0,0)*indent,
  -box_wall_th/2
)

-- box
box = difference{
  gen_polygon(box_nb_faces,box_diameter,box_height),
  translate(0,0,box_wall_th)*gen_polygon(box_nb_faces,box_diameter-box_wall_th*2,box_height-lid_height-box_wall_th),
  translate(0,0,box_height-lid_height-box_wall_th)*gen_polygon(box_nb_faces,box_diameter-box_wall_th*4,lid_height+box_wall_th),
  translate(0,0,-box_wall_th/1.5)*box_edge_chamfer, -- edges chamfer
  box_corner_chamfer, -- corner chamfer
  translate(0,0,box_height-box_wall_th*3)*box_peg_holes,-- locking pegs holes
  indents, -- cosmetic indents
}

-- locking 'mechanism'
locking_pegs = place_on_all(
  box_nb_faces,
  box_diameter,
  0,
  translate(-20,0,0)*rotate(0,0,-60)*cube(box_side_length/4,box_side_length/2,(lid_height-box_wall_th*2)-lid_clearance),
  -box_wall_th*12
)

if use_key then
  key_footprint = gen_polygon(key_nb_faces,key_diameter+lid_clearance,(lid_height-box_wall_th*2)-lid_clearance)-- keyhole
else
  key_footprint = cylinder(key_diameter/2+lid_clearance,(lid_height-box_wall_th*2)-lid_clearance)-- screw hole
end

lock = difference{ -- TODO: rework to not rely on box_wall_th ! (doesn't work if the box is resized !)
  union{
    cylinder((box_diameter/2)-(box_wall_th*8),(lid_height-box_wall_th*2)-lid_clearance),-- body
    locking_pegs,
  },
  key_footprint  
}

-- key
if use_key then
  key = union{
    gen_polygon(key_nb_faces,key_diameter,key_length),
    translate(0,0,key_length)*cube(key_cross_length,key_diameter,key_diameter/2)
  }
else
  key = cube(0)
end

--####################################################################

use_logo_and_qrcode = ui_bool("Use IceSL's logo and QRcode?", true)
if use_logo_and_qrcode then 
  box = union{
    box,  
    logo, -- icesl logo
    qrcode, -- icesl qrcode
  }
end

display_modes = {
  {1, "Assembly mode"},
  {2, "Printing mode"},
}
display_mode = ui_radio("Display mode",display_modes)
--display_mode = 2

if display_mode == 1 then
  splitting_factor = ui_number("Splitting_factor", 0, 0, 50)
  cross_section = ui_bool("Cross section view", false) 

  -- items to feed in the view
  items = {
    --{shape,v(posx,posy,posz),brush}
    {box,v(0,0,0),0},
    {lid_bottom,v(0,0,(box_height-lid_height)+splitting_factor),9},
    {lid_top,v(0,0,box_height+splitting_factor*3),2},
    {lock,v(0,0,(box_height-lid_height+box_wall_th)+splitting_factor*2),5},
    {key,v(0,0,(box_height-lid_height)+splitting_factor*4),7}
  } 
    
  if cross_section then
    u_items = {}
    for i,item in pairs(items) do
      u_items[i] = translate(items[i][2])*items[i][1]
    end
    u_items = union(u_items)

    cross_section_cut = cube(bbox(u_items):extent())
    cross_section_pos = bbox(cross_section_cut):extent().y
  end
  
  for i,item in pairs(items) do
    if cross_section then
      out = difference{
        translate(items[i][2])*items[i][1], -- item
        translate(0,-cross_section_pos/2,0)*cross_section_cut -- cross section cut
      }
      emit(out,items[i][3])
    else
      out = translate(items[i][2])*items[i][1]
      emit(out,items[i][3])
    end
  end
elseif display_mode == 2 then
  items = {
    {1,"Box body"},
    {2,"Bottom of the lid"},
    {3,"Top of the lid"},
    {4,"Flexible mechanism"},
    {5,"Key"},
  }
  item = ui_radio("Item to print",items)
  --item = 4
  if item == 1 then
    emit(box)
    setup_default()
  elseif item == 2 then
    emit(lid_bottom)
    setup_default()
  elseif item == 3 then
    emit(rotate(180,0,0)*lid_top)
    setup_default()
  elseif item == 4 then
    emit(translate(box_wall_th*0.8,box_wall_th*0.8,0)*lock) -- dirty way to compensate the infill field offset
    setup_phasor(lock)
  elseif item == 5 then
    emit(rotate(180,0,0)*key)
    setup_default()
  end
end
