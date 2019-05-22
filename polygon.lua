local polygon = {}

-- Init variables
polygon.data = {}

-- Generators

function polygon.new(loc, color, use_tm)

	local shape = {}
	local vertices = {}
	local line_cache = {}
	
	shape.kind = "polygon"
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

	if point_selected == -1 then
	
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
	elseif #copy.raw == 2 then
		-- Link line 2 to line 1
		copy.raw[1].va = 2
		table.insert(copy.cache, {1, 2})
		
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

	if tm.data[1] ~= nil and tm.cursor + 1 < tm.length then
	
		tm.cursor = tm.cursor + 1
		tm.location = tm.location + 1
		
		local moment = tm.data[tm.cursor]
		local move_moment = moment[#moment]
		
		if moment[1].action == TM_NEW_POLYGON then
			polygon.new(tm.polygon_loc, moment[1].color, false)
			polygon.calcVertex(moment[2].x, moment[2].y, tm.polygon_loc, false)
			
			local pp = polygon.data[tm.polygon_loc].raw[move_moment.index]
			pp.x, pp.y = move_moment.x, move_moment.y
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
		
		elseif moment[1].action == TM_SWITCH_LAYER then
		
			tm.polygon_loc = moment[1].new
		
		end
	
	end

end

function polygon.undo()
	
	-- Retrieve undo sequence from time machine
	if tm.data[1] ~= nil and tm.cursor > 0 then
		
		local moment = tm.data[tm.cursor]
		
		if moment[1].action == TM_NEW_POLYGON then
		
			--table.remove(polygon.data, tm.polygon_loc)
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
		
		elseif moment[1].action == TM_SWITCH_LAYER then
		
			tm.polygon_loc = moment[1].original
		
		end
		
		tm.cursor = tm.cursor - 1
		tm.location = tm.location - 1
		
		--print(tm.cursor, tm.location,tm.length)
		
	end

end

function polygon.draw()

	local i = 1
	
	while i <= shape_count do
		
		if polygon.data[i] ~= nil then
			local clone = polygon.data[i]
			
			lg.setColor(clone.color)
			
			-- Draw the shape
			if clone.kind == "polygon" then
			
				local j = 1
				while j <= #clone.raw do
				
					-- Draw triangle if the vertex[i] contains references to two other vertices (va and vb)
					if clone.raw[j].vb ~= nil then
						
						local a_loc, b_loc = clone.raw[j].va, clone.raw[j].vb
						local aa, bb, cc = clone.raw[j], clone.raw[a_loc], clone.raw[b_loc]
						lg.polygon("fill", aa.x, aa.y, bb.x, bb.y, cc.x, cc.y)
						
					end
					
					j = j + 1
				
				end
			
			end
		end
		-- End of drawing the shape
		
		i = i + 1
	end

end

return polygon