svg_dpi = 90

function prepare_svg(file)
  return svg_contouring(file,svg_dpi)
end

function contour_to_mesh(svg_contour,start_countour,height)
  local mesh = {}
  for c = start_countour, #svg_contour do
    mesh[#mesh+1] = linear_extrude_from_oriented(v(0,0,height),svg_contour[c]:outline())
  end
  return union(mesh)
end
