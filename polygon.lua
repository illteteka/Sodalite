local polygon = {}

-- Init variables
polygon.data = {}

polygon.kind = "polygon"
polygon.segments = 25
polygon._angle = 0

-- Generators

function polygon.new(loc, color, kind, use_tm)

	local shape = {}
	local vertices = {}
	local line_cache = {}
	
	shape.kind = kind
	shape.color = color or {1, 1, 1, 1}
	shape.raw = vertices
	shape.cache = line_cache -- Each shape holds a cache of its perimeter in the form of a list of lines
	
	polygon.data[loc] = shape
	
	-- Record new shape into the undo stack
	if use_tm then
	tm.store(TM_NEW_POLYGON, shape.kind, shape.color)
	end

end

function polygon.calcVertex(x, y, loc, use_tm)

	local point_selected = -1
	
	-- Test if user clicked on a vertex
	if use_tm then
	
		local i = 1
		while i <= #polygon.data[tm.polygon_loc].raw do
			
			local vertex_radius = 10
			
			-- Scale selection radius if the camera is scaled
			if camera_zoom > 1 then
				vertex_radius = math.max(vertex_radius / camera_zoom, 1)
			elseif camera_zoom < 1 then
				vertex_radius = (vertex_radius / camera_zoom)
			end
			
			local vx, vy = polygon.data[tm.polygon_loc].raw[i].x, polygon.data[tm.polygon_loc].raw[i].y
			
			-- If check was successful
			if (lume.distance(x, y, vx, vy) < vertex_radius) then
				point_selected = i
				i = #polygon.data[tm.polygon_loc].raw + 1
				
				-- Add vertex to selection group
				local moved_point = {}
				moved_point.index = point_selected
				moved_point.x = x
				moved_point.y = y
				table.insert(vertex_selection, moved_point)
				
			end
			
			i = i + 1
			
		end
	
	end

	-- Stop ellipses from having more than 2 vertices
	local ellipse_limit = polygon.data[tm.polygon_loc].kind == "ellipse" and #polygon.data[tm.polygon_loc].raw == 2
	
	if point_selected == -1 and not ellipse_limit then
	
	local line_to_purge = -1
	
	local i = 1
	if polygon.data[tm.polygon_loc] ~= nil then
	
		-- Retrieve closest line segment to the new point
		for i = 1, #polygon.data[tm.polygon_loc].cache do
		
			local cc = polygon.data[tm.polygon_loc].cache[i]
			-- Line cache stores the lines index, so we need to get the actual x1, y1, x2, y2 of the line
			local xa, ya, xb, yb = polygon.data[tm.polygon_loc].raw[cc[1]].x, polygon.data[tm.polygon_loc].raw[cc[1]].y, polygon.data[tm.polygon_loc].raw[cc[2]].x, polygon.data[tm.polygon_loc].raw[cc[2]].y
			-- Calculate line distance to mouse position
			local dp = (math.abs(((xa + xb)/2) - x) + math.abs(((ya + yb)/2) - y))
			polygon.data[tm.polygon_loc].cache[i].dp = dp
		
		end
		
		closest_line = -1
		closest_dist = -1
		
		-- Loop line cache to find the closest segment based on lowest scoring 'dp' value
		for i = 1, #polygon.data[tm.polygon_loc].cache do
		
			if polygon.data[tm.polygon_loc].cache[i].dp ~= nil then
				
				if closest_dist == -1 or polygon.data[tm.polygon_loc].cache[i].dp < closest_dist then
					closest_line = i
					closest_dist = polygon.data[tm.polygon_loc].cache[i].dp
				end
				
				-- Remove dp from the cache since it's no longer needed
				polygon.data[tm.polygon_loc].cache[i].dp = nil
				
			end
		
		end
		
		line_to_purge = closest_line
	
	end
	
	this_point = polygon.addVertex(x, y, loc, line_to_purge, use_tm)
	
	end

end

function polygon.addVertex(x, y, loc, old_line, use_tm)

	local copy = polygon.data[loc]
	local point = {}
	
	point.x, point.y = x, y
	table.insert(copy.raw, point)
	
	tm.enabled = use_tm
	
	-- The first 3 vertices are stored in specific locations
	if #copy.raw == 1 then
		-- Time machine functions record vertex position, allows users to undo
		tm.store(TM_ADD_VERTEX, x, y, 1)
		
		if copy.kind == "ellipse" then
			copy.segments = polygon.segments
			copy._angle = polygon._angle
			tm.store(TM_ADD_ELLIPSE, polygon.segments, polygon._angle)
		end
		
	elseif #copy.raw == 2 then
		if copy.kind ~= "ellipse" then
			-- Link line 2 to line 1
			copy.raw[1].va = 2
			table.insert(copy.cache, {1, 2})
		end
		
		tm.store(TM_ADD_VERTEX, x, y, 2)
	elseif #copy.raw == 3 then
		-- Link line 3 to line 1
		copy.raw[1].vb = 3
		table.insert(copy.cache, {1, 3})
		
		-- Link line 2 to line 3
		copy.raw[3].va = 2
		table.insert(copy.cache, {3, 2})
		
		tm.store(TM_ADD_VERTEX, x, y, 3)
	else
		-- Create a new triangle using points: va, vb, and the cursor position
		
		local old_a, old_b = polygon.data[loc].cache[old_line][1], polygon.data[loc].cache[old_line][2]
		
		-- Link new vertex to va and vb
		copy.raw[#copy.raw].va = old_a
		copy.raw[#copy.raw].vb = old_b
		
		-- Remove the old line (va <-> vb) as it now resides inside the new shape
		table.remove(copy.cache, old_line)
		
		-- Add two new lines to the perimeter cache
		table.insert(copy.cache, {#copy.raw, old_a})
		table.insert(copy.cache, {#copy.raw, old_b})
		
		tm.store(TM_ADD_VERTEX, x, y, 4)
		tm.store(TM_DEL_LINE,   old_line, old_a, old_b)
	end
	
	-- Add new vertex to selection group
	if tm.enabled then
		local moved_point = {}
		moved_point.index = #copy.raw
		moved_point.x = x
		moved_point.y = y
		table.insert(vertex_selection, moved_point)
	end
	
	tm.enabled = true

end

function polygon.redo()

	-- Skip editor specific functions (layer switching)
	local repeat_redo = false

	if tm.data[1] ~= nil and tm.cursor + 1 < tm.length then
	
		tm.cursor = tm.cursor + 1
		tm.location = tm.location + 1
		
		local moment = tm.data[tm.cursor]
		local move_moment = moment[#moment]
		
		if moment[1].action == TM_NEW_POLYGON then
			polygon.new(tm.polygon_loc, moment[1].color, moment[1].kind, false)
			polygon.calcVertex(moment[2].x, moment[2].y, tm.polygon_loc, false)
			
			local pp = polygon.data[tm.polygon_loc].raw[move_moment.index]
			pp.x, pp.y = move_moment.x, move_moment.y
			
			if moment[1].kind == "ellipse" then
				polygon.data[tm.polygon_loc].segments = moment[3].segments
				polygon.data[tm.polygon_loc]._angle = moment[3]._angle
			end
			
		elseif moment[1].action == TM_ADD_VERTEX then
			polygon.calcVertex(moment[1].x, moment[1].y, tm.polygon_loc, false)
			
			local pp = polygon.data[tm.polygon_loc].raw[move_moment.index]
			pp.x, pp.y = move_moment.x, move_moment.y
		elseif moment[1].action == TM_MOVE_VERTEX then
		
			local i
			for i = 1, #moment do
			
				local pp = polygon.data[tm.polygon_loc].raw[moment[i].index]
				pp.x, pp.y = moment[i].x, moment[i].y
			
			end
			
		elseif moment[1].action == TM_CHANGE_COLOR then
		
			polygon.data[tm.polygon_loc].color = moment[1].new
		
		elseif moment[1].action == TM_PICK_LAYER then
		
			tm.polygon_loc = moment[1].new
			
			if moment[1].created_layer == true then
				ui.addLayer()
			else
				repeat_redo = true
			end
		
		elseif moment[1].action == TM_MOVE_LAYER then
		
			ui.moveLayer(moment[1].original, moment[1].new)
		
		elseif moment[1].action == TM_ELLIPSE_SEG then
		
			polygon.data[tm.polygon_loc].segments = moment[1].new
			
		elseif moment[1].action == TM_ELLIPSE_ANGLE then
		
			polygon.data[tm.polygon_loc]._angle = moment[1].new
			
		end
	
	end
	
	return repeat_redo

end

function polygon.undo()
	
	-- Skip editor specific functions (layer switching)
	local repeat_undo = false
	
	-- Retrieve undo sequence from time machine
	if tm.data[1] ~= nil and tm.cursor > 0 then
		
		local moment = tm.data[tm.cursor]
		
		if moment[1].action == TM_NEW_POLYGON then
		
			polygon.data[tm.polygon_loc] = nil
		
		elseif moment[1].action == TM_ADD_VERTEX then
		
			local copy = polygon.data[tm.polygon_loc]
		
			local seq = moment[1].sequence
			if seq == 2 then
			
				table.remove(copy.cache)
				copy.raw[1].va = nil
				table.remove(copy.raw)
			
			elseif seq == 3 then
			
				table.remove(copy.cache)
				table.remove(copy.cache)
				copy.raw[1].vb = nil
				table.remove(copy.raw)
			
			elseif seq == 4 then
			
				table.remove(copy.cache)
				table.remove(copy.cache)
				table.insert(copy.cache, moment[2].index, {moment[2].va, moment[2].vb})
				table.remove(copy.raw)
			
			end
		
		elseif moment[1].action == TM_MOVE_VERTEX then
		
			local i
			for i = 1, #moment do
			
				local copy = polygon.data[tm.polygon_loc]
				local pp = copy.raw[moment[i].index]
				pp.x, pp.y = moment[i].ox, moment[i].oy
			
			end
		
		elseif moment[1].action == TM_CHANGE_COLOR then
		
			polygon.data[tm.polygon_loc].color = moment[1].original
		
		elseif moment[1].action == TM_PICK_LAYER then
		
			tm.polygon_loc = moment[1].original
			
			if moment[1].created_layer == true then
				table.remove(ui.layer)
			else
				repeat_undo = true
			end
		
		elseif moment[1].action == TM_MOVE_LAYER then
		
			ui.moveLayer(moment[1].new, moment[1].original)
		
		elseif moment[1].action == TM_ELLIPSE_SEG then
		
			polygon.data[tm.polygon_loc].segments = moment[1].original
			
		elseif moment[1].action == TM_ELLIPSE_ANGLE then
		
			polygon.data[tm.polygon_loc]._angle = moment[1].original
			
		end
		
		tm.cursor = tm.cursor - 1
		tm.location = tm.location - 1
		
	end
	
	return repeat_undo

end

function polygon.lengthdir_x(length, dir)
	return length * math.cos(dir)
end

function polygon.lengthdir_y(length, dir)
	return -length * math.sin(dir)
end

function polygon.rotateX(x, y, px, py, c, s)
	return (c * (x - px) + s * (y - py) + px)
end

function polygon.rotateY(x, y, px, py, c, s)
	return (s * (x - px) - c * (y - py) + py)
end

function polygon.draw()

	local i = 1
	
	while i <= #ui.layer do
		
		if polygon.data[ui.layer[i].count] ~= nil and ui.layer[i].visible then
			local clone = polygon.data[ui.layer[i].count]
			
			lg.setColor(clone.color)
			
			-- Draw the shape
			if clone.kind == "polygon" then
			
				local j = 1
				while j <= #clone.raw do
				
					-- Draw triangle if the vertex[i] contains references to two other vertices (va and vb)
					if clone.raw[j].vb ~= nil then
						
						local sc = camera_zoom
						local a_loc, b_loc = clone.raw[j].va, clone.raw[j].vb
						local aa, bb, cc = clone.raw[j], clone.raw[a_loc], clone.raw[b_loc]
						lg.polygon("fill", aa.x * sc, aa.y * sc, bb.x * sc, bb.y * sc, cc.x * sc, cc.y * sc)
						
					end
					
					j = j + 1
				
				end
			
			elseif clone.kind == "ellipse" then
			
				local sc = camera_zoom
				if #clone.raw > 1 then
				
					-- Load points from raw
					local aa, bb = clone.raw[1], clone.raw[2]
					local cx, cy, cw, ch
					
					-- Calculate w/h
					cw = math.abs(aa.x - bb.x) / 2
					ch = math.abs(aa.y - bb.y) / 2
					
					-- Make x/y the points closest to the north west
					if bb.x < aa.x then cx = bb.x else cx = aa.x end
					if bb.y < aa.y then cy = bb.y else cy = aa.y end
					
					cx = cx + cw
					cy = cy + ch
					
					local cseg, cang = clone.segments, clone._angle
					
					-- Ellipse vars
					local v, i = 0, 0
					local cinc = (360 / cseg)
					local _rad, _cos, _sin = math.rad, math.cos, math.sin
					
					while i < cseg do
		
						local cx2, cy2, cx3, cy3, cxx2, cyy2, cxx3, cyy3
						cx2 = polygon.lengthdir_x(cw, _rad(v))
						cy2 = polygon.lengthdir_y(ch, _rad(v))
						cx3 = polygon.lengthdir_x(cw, _rad(v + cinc))
						cy3 = polygon.lengthdir_y(ch, _rad(v + cinc))
						
						if (cang % 360 ~= 0) then
							local cang2 = _rad(-cang)
							local cc, ss = _cos(cang2), _sin(cang2)
							cxx2 = polygon.rotateX(cx2, cy2, 0, 0, cc, ss)
							cyy2 = polygon.rotateY(cx2, cy2, 0, 0, cc, ss)
							cxx3 = polygon.rotateX(cx3, cy3, 0, 0, cc, ss)
							cyy3 = polygon.rotateY(cx3, cy3, 0, 0, cc, ss)
						else -- Do less math if not rotating
							cxx2, cyy2, cxx3, cyy3 = cx2, cy2, cx3, cy3
						end
						
						lg.polygon("fill", cx * sc, cy * sc, (cx + cxx2) * sc, (cy + cyy2) * sc, (cx + cxx3) * sc, (cy + cyy3) * sc)
						--lg.line(cx + cxx2, cy + cyy2, cx + cxx3, cy + cyy3) -- Draw outline
						
						v = v + cinc
						i = i + 1
					
					end
				
				end
			
			end
		end
		-- End of drawing the shape
		
		i = i + 1
	end

end

return polygon