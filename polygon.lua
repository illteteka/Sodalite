local polygon = {}

-- Init variables
polygon.data = {}

polygon.kind = "polygon"
-- Ellipse vars
polygon.segments = 25
polygon._angle = 0
-- Polyline vars
polygon.thickness = 10
polygon.ruler = false

polygon.min_thickness = 10
polygon.max_thickness = 512

polygon.line = false
polygon.polyline_cache = {}

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
	
	palette.updateAccentColor()

end

function polygon.calcVertex(x, y, loc, use_grid)

	local point_selected = -1
	
	-- Test if user clicked on a vertex
	local i = 1
	while i <= #polygon.data[tm.polygon_loc].raw do
		
		local vertex_radius = 10
		if use_grid and grid_snap then
			vertex_radius = 20
		end
		
		-- Scale selection radius if the camera is scaled
		if camera_zoom > 1 then
			vertex_radius = math.max(vertex_radius / camera_zoom, 2)
		elseif camera_zoom < 1 then
			vertex_radius = (vertex_radius / camera_zoom)
		end
		
		local vx, vy = polygon.data[tm.polygon_loc].raw[i].x, polygon.data[tm.polygon_loc].raw[i].y
		
		-- If check was successful
		
		local add_to_selection = true
		local j = 1
		for j = 1, #vertex_selection do
		
			if vertex_selection[j].index == i then
				add_to_selection = false
			end
		
		end
		
		local if_line_is_valid = true
		local clone = polygon.data[tm.polygon_loc].raw
		if clone[i].l ~= nil and clone[i].l == "-" then
			if_line_is_valid = false
		end
		
		if (lume.distance(x, y, vx, vy) < vertex_radius) and add_to_selection and if_line_is_valid then
			point_selected = i
			i = #polygon.data[tm.polygon_loc].raw + 1
			
			-- Add vertex to selection group
			local moved_point = {}
			moved_point.index = point_selected
			moved_point.x = vx
			moved_point.y = vy
			table.insert(vertex_selection, moved_point)
			
			-- Add vertex sibling if it's a line
			if clone[point_selected].l ~= nil and clone[point_selected].l == "+" then
				
				local sibling_copy = polygon.data[tm.polygon_loc].raw
				local sib_1 = sibling_copy[point_selected]
				local sib_2 = sibling_copy[point_selected - 1]
				
				local moved_point_sister = {}
				moved_point_sister.index = point_selected - 1
				moved_point_sister.t = math.ceil(lume.distance(sib_1.x, sib_1.y, sib_2.x, sib_2.y))
				moved_point_sister.a = -lume.angle(sib_1.x, sib_1.y, sib_2.x, sib_2.y)
				moved_point_sister.x = math.floor(vx + polygon.lengthdir_x(moved_point_sister.t, moved_point_sister.a))
				moved_point_sister.y = math.floor(vy + polygon.lengthdir_y(moved_point_sister.t, moved_point_sister.a))
				
				table.insert(vertex_selection, moved_point_sister)
				
			end
			
		end
		
		i = i + 1
		
	end
	
	if input.shiftEither() and #polygon.data[tm.polygon_loc].raw >= 1 and point_selected ~= -1 then
		vertex_selection_mode = true
	end

	-- Stop ellipses from having more than 2 vertices
	local ellipse_limit = polygon.data[tm.polygon_loc].kind == "ellipse" and #polygon.data[tm.polygon_loc].raw == 2
	
	local is_line = polygon.line
	
	if is_line and polygon.data[tm.polygon_loc].raw[1] == nil then
		
		line_x = x
		line_y = y
		
	end
	
	if point_selected == -1 and not ellipse_limit and not vertex_selection_mode and not is_line then
	
	local line_to_purge = -1
	
	local i = 1
	if polygon.data[tm.polygon_loc] ~= nil then
	
		local closest_line = -1
		local closest_dist = -1
	
		-- Retrieve closest line segment to the new point
		for i = 1, #polygon.data[tm.polygon_loc].cache do
		
			local cc = polygon.data[tm.polygon_loc].cache[i]
			-- Line cache stores the lines index, so we need to get the actual x1, y1, x2, y2 of the line
			local xa, ya, xb, yb = polygon.data[tm.polygon_loc].raw[cc[1]].x, polygon.data[tm.polygon_loc].raw[cc[1]].y, polygon.data[tm.polygon_loc].raw[cc[2]].x, polygon.data[tm.polygon_loc].raw[cc[2]].y
			-- Calculate line distance to mouse position
			local dp = (math.abs(((xa + xb)/2) - x) + math.abs(((ya + yb)/2) - y))
			
			if closest_dist == -1 or dp < closest_dist then
				closest_line = i
				closest_dist = dp
			end
		
		end
		
		line_to_purge = closest_line
	
	end
	
	polygon.addVertex(x, y, loc, line_to_purge, true, polygon.line)
	
	end

end

function polygon.addLine(loc, x1, y1, x2, y2, new_polyline, extending_line, old_line)

	local thick = polygon.thickness/2
	
	-- get angle of p1 to p2
	local l_ang = -lume.angle(x1, y1, x2, y2)
	
	-- get perpendicular of angle
	local a_pos, a_neg = l_ang + (math.pi/2), l_ang - (math.pi/2)
	
	local ldx_pos, ldy_pos = polygon.lengthdir_x(thick, a_pos), polygon.lengthdir_y(thick, a_pos)
	local ldx_neg, ldy_neg = polygon.lengthdir_x(thick, a_neg), polygon.lengthdir_y(thick, a_neg)
	
	-- calculate 4 new points
	local pf = pixelFloor
	
	local a, b = pf(x1 + ldx_pos),     pf(y1 + ldy_pos)
	local c, d = pf(x1 + ldx_neg),     pf(y1 + ldy_neg)
	
	local e, f = pf(x2 + ldx_pos),     pf(y2 + ldy_pos)
	local g, h = pf(x2 + ldx_neg),     pf(y2 + ldy_neg)
	
	if new_polyline then
		polygon.addVertex(a, b, loc, 0, false, true)
		polygon.addVertex(c, d, loc, 0, false, true)
		polygon.addVertex(e, f, loc, 0, false, true)
		polygon.addVertex(g, h, loc, 3, false, true)
	elseif not extending_line then
		polygon.addVertex(e, f, loc, #polygon.data[loc].cache - 1, false, true)
		polygon.addVertex(g, h, loc, #polygon.data[loc].cache - 1, false, true)
	else
		polygon.addVertex(e, f, loc, old_line, false, true)
		polygon.addVertex(g, h, loc, #polygon.data[loc].cache - 1, false, true)
	end

end

function polygon.editLine(loc, x1, y1, x2, y2)

	local clone = polygon.data[loc]
	
	local thick = polygon.thickness/2
	
	-- get angle of p1 to p2
	local l_ang = -lume.angle(x1, y1, x2, y2)
	
	-- get perpendicular of angle
	local a_pos, a_neg = l_ang + (math.pi/2), l_ang - (math.pi/2)
	
	local ldx_pos, ldy_pos = polygon.lengthdir_x(thick, a_pos), polygon.lengthdir_y(thick, a_pos)
	local ldx_neg, ldy_neg = polygon.lengthdir_x(thick, a_neg), polygon.lengthdir_y(thick, a_neg)
	
	-- calculate 4 new points
	local pf = pixelFloor
	
	local e, f = pf(x2 + ldx_pos),     pf(y2 + ldy_pos)
	local g, h = pf(x2 + ldx_neg),     pf(y2 + ldy_neg)
	
	clone.raw[#clone.raw-1].x = e
	clone.raw[#clone.raw-1].y = f
	clone.raw[#clone.raw].x = g
	clone.raw[#clone.raw].y = h

end

function polygon.polylineCompare()
	
	-- This method takes the state of polygon.data[tm.polygon_loc] BEFORE any lines are drawn
	-- It uses this state to compile a list of before and after changes
	-- In the tables before: tbl_changes, after: tbl_new
	-- This is used to pass data on to the time machine for undo/redo
	
	local this_layer = tm.polygon_loc
	local current_copy = polygon.data[this_layer]
	
	local tbl_changes = {}
	tbl_changes.cache = {}
	tbl_changes.raw = {}
	
	local tbl_new = {}
	tbl_new.cache = {}
	tbl_new.raw = {}

	-- Detect changes in the line cache: polygon.data[x].cache
	local clc = 1
	while clc <= #current_copy.cache do
		local new_cache = current_copy.cache[clc]
		local old_cache = polygon.polyline_cache[1].cache
		
		-- If we're making a new line
		if old_cache[clc] == nil then
		
			local cache_tbl = {}
			table.insert(cache_tbl, new_cache[1])
			table.insert(cache_tbl, new_cache[2])
			cache_tbl.index = clc
			table.insert(tbl_new.cache, cache_tbl)
		
		else -- Any other changes
		
			local first_correct = old_cache[clc][1] == new_cache[1]

			local second_exists = new_cache[2] ~= nil and old_cache[clc][2] ~= nil and old_cache[clc][2] == new_cache[2]
			local second_correct = false
			if second_exists then
				second_correct = old_cache[clc][2] == new_cache[2]
			end
			
			local cache_tbl = {}
			local change_tbl = {}
			
			if not (first_correct and second_correct) then
				table.insert(cache_tbl, new_cache[1])
				table.insert(cache_tbl, new_cache[2])
				cache_tbl.index = clc
				table.insert(tbl_new.cache, cache_tbl)
				
				table.insert(change_tbl, old_cache[clc][1])
				table.insert(change_tbl, old_cache[clc][2])
				change_tbl.index = clc
				table.insert(tbl_changes.cache, change_tbl)
			end
		
		end
		
		clc = clc + 1
	end

	-- Detect changes in the vertex data: polygon.data[x].raw
	local clc = 1
	while clc <= #current_copy.raw do
		local new_raw = current_copy.raw[clc]
		local old_raw = polygon.polyline_cache[1].raw
		
		-- If we're making a new line
		if old_raw[clc] == nil then
		
			local new_tbl = {}
			if new_raw.x ~= nil then new_tbl.x, new_tbl.y = new_raw.x, new_raw.y end
			if new_raw.va ~= nil then new_tbl.va = new_raw.va end
			if new_raw.vb ~= nil then new_tbl.vb = new_raw.vb end
			if new_raw.l ~= nil then new_tbl.l = new_raw.l end
			new_tbl.index = clc
			table.insert(tbl_new.raw, new_tbl)
		
		else -- Any other changes
		
			local new_tbl = {}
			local change_tbl = {}
			new_tbl.index = clc
			change_tbl.index = clc
			local new_edited = false
			local change_edited = false
		
			if old_raw[clc].x ~= new_raw.x or old_raw[clc].y ~= new_raw.y then
				new_edited, change_edited = true, true
				new_tbl.x, new_tbl.y = new_raw.x, new_raw.y
				change_tbl.x, change_tbl.y = old_raw[clc].x, old_raw[clc].y
			end
			
			if (old_raw[clc].va == nil or old_raw[clc].va ~= new_raw.va) and new_raw.va ~= nil then
				new_edited = true
				new_tbl.va = new_raw.va
				
				if old_raw[clc].va ~= nil then
					change_edited = true
					change_tbl.va = old_raw[clc].va
				end
			end
			
			if (old_raw[clc].vb == nil or old_raw[clc].vb ~= new_raw.vb) and new_raw.vb ~= nil then
				new_edited = true
				new_tbl.vb = new_raw.vb
				
				if old_raw[clc].vb ~= nil then
					change_edited = true
					change_tbl.vb = old_raw[clc].vb
				end
			end
			
			if (old_raw[clc].l == nil or old_raw[clc].l ~= new_raw.l) and new_raw.l ~= nil then
				new_edited = true
				new_tbl.l = new_raw.l
				
				if old_raw[clc].l ~= nil then
					change_edited = true
					change_tbl.l = old_raw[clc].l
				end
			end
			
			if new_edited then
				table.insert(tbl_new.raw, new_tbl)
			end
			
			if change_edited then
				table.insert(tbl_changes.raw, change_tbl)
			end
		
		end
		
		clc = clc + 1
	end
	
	-- tbl_changes and tbl_new are now populated with the appropriate data
	
	-- If a table was blank before and after the changes, nil out tbl_changes
	if tbl_changes.cache[1] == nil then
		tbl_changes.cache = nil
	end
	
	if tbl_changes.raw[1] == nil then
		tbl_changes.raw = nil
	end
	
	if tbl_new.raw[1] ~= nil or tbl_new.cache[1] ~= nil or tbl_changes.cache ~= nil or tbl_changes.raw ~= nil then
		tm.store(TM_LINE_BLOCK, tbl_changes, tbl_new)
		tm.step()
	end

end

function polygon.polylineRepair(undo, tbl_changes, tbl_new)
	
	if tbl_changes.cache == nil then
		tbl_changes.cache = {}
	end
	
	local clc = 1
	while clc <= #tbl_new.cache do
		local new_cache = tbl_new.cache[clc]
		
		if undo then
			polygon.data[tm.polygon_loc].cache[new_cache.index] = nil
		else
		
			local new_cache = tbl_new.cache[clc]
			
			if polygon.data[tm.polygon_loc].cache[new_cache.index] == nil then
				polygon.data[tm.polygon_loc].cache[new_cache.index] = {}
			end
			polygon.data[tm.polygon_loc].cache[new_cache.index][1] = new_cache[1]
			polygon.data[tm.polygon_loc].cache[new_cache.index][2] = new_cache[2]
		
		end
		
		clc = clc + 1
	end
	
	if undo then
		local clc = 1
		while clc <= #tbl_changes.cache do
			local old_cache = tbl_changes.cache[clc]
			
			if polygon.data[tm.polygon_loc].cache[old_cache.index] == nil then
				polygon.data[tm.polygon_loc].cache[old_cache.index] = {}
			end
			polygon.data[tm.polygon_loc].cache[old_cache.index][1] = old_cache[1]
			polygon.data[tm.polygon_loc].cache[old_cache.index][2] = old_cache[2]
			
			clc = clc + 1
		end
	end

	local clc = 1
	while clc <= #tbl_new.raw do
		local new_raw = tbl_new.raw[clc]
		
		if undo then
			polygon.data[tm.polygon_loc].raw[new_raw.index] = nil
		else
		
			local new_raw = tbl_new.raw[clc]
			
			local this_shape = polygon.data[tm.polygon_loc].raw[new_raw.index]
			if this_shape == nil then
				polygon.data[tm.polygon_loc].raw[new_raw.index] = {}
			end
			polygon.data[tm.polygon_loc].raw[new_raw.index].x = new_raw.x
			polygon.data[tm.polygon_loc].raw[new_raw.index].y = new_raw.y
			
			if new_raw.va ~= nil then polygon.data[tm.polygon_loc].raw[new_raw.index].va = new_raw.va end
			if new_raw.vb ~= nil then polygon.data[tm.polygon_loc].raw[new_raw.index].vb = new_raw.vb end
			if new_raw.l ~= nil then polygon.data[tm.polygon_loc].raw[new_raw.index].l = new_raw.l end
		
		end
		
		clc = clc + 1
	end
	
	if undo then
		if tbl_changes.raw ~= nil then
			local clc = 1
			while clc <= #tbl_new.raw do
				local old_raw = tbl_changes.raw[clc]
				
				local this_shape = polygon.data[tm.polygon_loc].raw[old_raw.index]
				if this_shape == nil then
					polygon.data[tm.polygon_loc].raw[old_raw.index] = {}
				end
				polygon.data[tm.polygon_loc].raw[old_raw.index].x = old_raw.x
				polygon.data[tm.polygon_loc].raw[old_raw.index].y = old_raw.y
				
				if old_raw.va ~= nil then polygon.data[tm.polygon_loc].raw[old_raw.index].va = old_raw.va end
				if old_raw.vb ~= nil then polygon.data[tm.polygon_loc].raw[old_raw.index].vb = old_raw.vb end
				if old_raw.l ~= nil then polygon.data[tm.polygon_loc].raw[old_raw.index].l = old_raw.l end
				
				clc = clc + 1
			end
		end
	end

end

function polygon.addVertex(x, y, loc, old_line, use_tm, is_line)

	local copy = polygon.data[loc]
	local point = {}
	
	point.x, point.y = x, y
	table.insert(copy.raw, point)
	
	tm.enabled = use_tm
	
	-- The first 3 vertices are stored in specific locations
	if #copy.raw == 1 then
		-- Time machine functions record vertex position, allows users to undo
		tm.store(TM_ADD_VERTEX, x, y, 1, -1)
		
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
		
		tm.store(TM_ADD_VERTEX, x, y, 2, -1)
	elseif #copy.raw == 3 then
		-- Link line 3 to line 1
		copy.raw[1].vb = 3
		table.insert(copy.cache, {1, 3})
		
		-- Link line 2 to line 3
		copy.raw[3].va = 2
		table.insert(copy.cache, {3, 2})
		
		tm.store(TM_ADD_VERTEX, x, y, 3, -1)
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
		
		tm.store(TM_ADD_VERTEX, x, y, 4, old_line)
		tm.store(TM_DEL_LINE,   old_line, old_a, old_b)
	end
	
	if is_line then
		
		copy.raw[#copy.raw].l = "-"
		
		if copy.raw[#copy.raw - 1] ~= nil and copy.raw[#copy.raw - 1].l == "-" then
			copy.raw[#copy.raw].l = "+"
		end
		
	end
	
	-- Add new vertex to selection group
	if tm.enabled then
		local moved_point = {}
		moved_point.index = #copy.raw
		moved_point.x = x
		moved_point.y = y
		moved_point.new = true
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
		
		if moment[1].action == TM_NEW_POLYGON and moment[2].action ~= TM_LINE_BLOCK then
			polygon.new(tm.polygon_loc, moment[1].color, moment[1].kind, false)
			polygon.addVertex(move_moment.x, move_moment.y, tm.polygon_loc, -1, false, false)
			
			if moment[1].kind == "ellipse" then
				polygon.data[tm.polygon_loc].segments = moment[3].segments
				polygon.data[tm.polygon_loc]._angle = moment[3]._angle
			end
			
			palette.updateAccentColor()
			
		elseif moment[1].action == TM_ADD_VERTEX then
		
			polygon.addVertex(move_moment.x, move_moment.y, tm.polygon_loc, moment[1].old_line, false, false)
			
		elseif moment[1].action == TM_MOVE_VERTEX then
		
			local i
			for i = 1, #moment do
			
				local pp = polygon.data[tm.polygon_loc].raw[moment[i].index]
				pp.x, pp.y = moment[i].x, moment[i].y
			
			end
			
		elseif moment[1].action == TM_CHANGE_COLOR then
		
			polygon.data[tm.polygon_loc].color = moment[1].new
			palette.updateAccentColor()
		
		elseif moment[1].action == TM_PICK_LAYER then
		
			tm.polygon_loc = moment[1].new
			
			if moment[1].trash_layer == true then
			
				ui.deleteLayer(moment[1].original)
				tm.polygon_loc = ui.layer[#ui.layer].count
				
			elseif moment[1].created_layer == true then
				ui.addLayer()
			else
				repeat_redo = true
			end
			
			palette.updateAccentColor()
		
		elseif moment[1].action == TM_MOVE_LAYER then
		
			ui.moveLayer(moment[1].original, moment[1].new)
		
		elseif moment[1].action == TM_ELLIPSE_SEG then
		
			polygon.data[tm.polygon_loc].segments = moment[1].new
			
		elseif moment[1].action == TM_ELLIPSE_ANGLE then
		
			polygon.data[tm.polygon_loc]._angle = moment[1].new
			
		elseif moment[1].action == TM_MOVE_SHAPE then
		
			local i
			for i = 1, #moment do

				local shape_copy = polygon.data[moment[i].index]
				
				local j
				for j = 1, #shape_copy.raw do
					local pp = shape_copy.raw[j]
					pp.x, pp.y = pp.x + moment[i].x, pp.y + moment[i].y
				end

			end
		
		elseif moment[1].action == TM_CLONE_LAYER then
		
			ui.layerCloneButton(false, false)
			palette.updateAccentColor()
		
		elseif moment[1].action == TM_LAYER_RENAME then
	
			ui.layer[moment[1].layer].name = moment[1].new
		
		elseif (moment[2] ~= nil and moment[2].action == TM_LINE_BLOCK) or moment[1].action == TM_LINE_BLOCK then
		
			local mom_loc = 1
			if (moment[2] ~= nil and moment[2].action == TM_LINE_BLOCK) then mom_loc = 2 end
			
			if mom_loc == 2 then
				polygon.new(tm.polygon_loc, moment[1].color, moment[1].kind, false)
				palette.updateAccentColor()
			end
			
			polygon.polylineRepair(false, moment[mom_loc].original, moment[mom_loc].new)
		
		elseif moment[1].action == TM_LINE_CONVERT then
		
			-- Convert all active lines into polygons
			local clone = polygon.data[tm.polygon_loc].raw
			local i = 1
			for i = 1, #clone do
				clone[i].l = nil
			end
		
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
		
		if moment[1].action == TM_NEW_POLYGON and moment[2].action ~= TM_LINE_BLOCK then
		
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

				local pp = polygon.data[tm.polygon_loc].raw[moment[i].index]
				pp.x, pp.y = moment[i].ox, moment[i].oy

			end
		
		elseif moment[1].action == TM_CHANGE_COLOR then
		
			polygon.data[tm.polygon_loc].color = moment[1].original
			palette.updateAccentColor()
		
		elseif moment[1].action == TM_PICK_LAYER then
		
			tm.polygon_loc = moment[1].original
			
			if moment[1].trash_layer == true then
				tm.polygon_loc = moment[1].new
				table.insert(ui.layer, moment[1].original, ui.layer_trash[#ui.layer_trash])
				table.remove(ui.layer_trash)
			elseif moment[1].created_layer == true then
				table.remove(ui.layer)
			else
				repeat_undo = true
			end
			
			palette.updateAccentColor()
		
		elseif moment[1].action == TM_MOVE_LAYER then
		
			ui.moveLayer(moment[1].new, moment[1].original)
		
		elseif moment[1].action == TM_ELLIPSE_SEG then
		
			polygon.data[tm.polygon_loc].segments = moment[1].original
			
		elseif moment[1].action == TM_ELLIPSE_ANGLE then
		
			polygon.data[tm.polygon_loc]._angle = moment[1].original
			
		elseif moment[1].action == TM_MOVE_SHAPE then
		
			local i
			for i = 1, #moment do

				local shape_copy = polygon.data[moment[i].index]
				
				local j
				for j = 1, #shape_copy.raw do
					local pp = shape_copy.raw[j]
					pp.x, pp.y = pp.x - moment[i].x, pp.y - moment[i].y
				end

			end
		
		elseif moment[1].action == TM_CLONE_LAYER then
		
			tm.polygon_loc = moment[1].original
			table.remove(ui.layer)
			table.remove(polygon.data)
			palette.updateAccentColor()
		
		elseif moment[1].action == TM_LAYER_RENAME then
	
			ui.layer[moment[1].layer].name = moment[1].original
		
		elseif (moment[2] ~= nil and moment[2].action == TM_LINE_BLOCK) or moment[1].action == TM_LINE_BLOCK then
		
			if moment[2] ~= nil and moment[2].action == TM_LINE_BLOCK then
				polygon.data[tm.polygon_loc] = nil
			else
				polygon.polylineRepair(true, moment[1].original, moment[1].new)
			end
		
		elseif moment[1].action == TM_LINE_CONVERT then
		
			-- Convert all old lines back into real lines
			local clone = polygon.data[tm.polygon_loc].raw
			local i = 1
			for i = 1, #moment[1].original.raw do
				polygon.data[tm.polygon_loc].raw[moment[1].original.raw[i].index].l = moment[1].original.raw[i].l
			end
		
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

function polygon.point_triangle(mx, my, ax, ay, bx, by, cx, cy)
	offset_mx = mx - ax
	offset_my = my - ay
	
	ab = ((bx - ax)*offset_my-(by-ay)*offset_mx) > 0
	
	local first_check  = ((cx - ax)*offset_my-(cy-ay)*offset_mx > 0 == ab)
	local second_check = ((cx-bx)*(my-by)-(cy-by)*(mx-bx) > 0 ~= ab)
	
	return not (first_check or second_check)
end

function polygon.click(mx, my, skip_selection)

	local triangle_hit = false
	local layer_hit = -1
	
	local i = #ui.layer
	
	while i >= 1 do
		
		if polygon.data[ui.layer[i].count] ~= nil and ui.layer[i].visible then
			
			local clone = polygon.data[ui.layer[i].count]
			
			-- Draw the shape
			if clone.kind == "polygon" then
			
				local j = 1
				while j <= #clone.raw do
				
					-- Draw triangle if the vertex[i] contains references to two other vertices (va and vb)
					if clone.raw[j].vb ~= nil then
						
						local a_loc, b_loc = clone.raw[j].va, clone.raw[j].vb
						local aa, bb, cc = clone.raw[j], clone.raw[a_loc], clone.raw[b_loc]
						triangle_hit = polygon.point_triangle(mx, my, aa.x, aa.y, bb.x, bb.y, cc.x, cc.y)
						
						if triangle_hit then
						
							if skip_selection then
							
								local hit_twice = false
								local n = 1
								while n <= #shape_selection do
									
									if shape_selection[n].index == i then
										hit_twice = true
										n = #shape_selection + 1
									end
									
									n = n + 1
								end
								
								if hit_twice == false then
									layer_hit = i
									i = 0
									j = #clone.raw + 1
								end
							
							else
								layer_hit = i
								i = 0
								j = #clone.raw + 1
							end
							
						end
						
					end
					
					j = j + 1
				
				end
			
			elseif clone.kind == "ellipse" then
			
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
					local v, k = 0, 0
					local cinc = (360 / cseg)
					local _rad, _cos, _sin = math.rad, math.cos, math.sin
					
					while k < cseg do
		
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
						
						triangle_hit = polygon.point_triangle(mx, my, cx, cy, (cx + cxx2), (cy + cyy2), (cx + cxx3), (cy + cyy3))
						if triangle_hit then
							
							if skip_selection then
							
								local hit_twice = false
								local n = 1
								while n <= #shape_selection do
									
									if shape_selection[n].index == i then
										hit_twice = true
										n = #shape_selection + 1
									end
									
									n = n + 1
								end
								
								if hit_twice == false then
									layer_hit = i
									i = 0
									k = cseg + 1
								end
							
							else
								layer_hit = i
								i = 0
								k = cseg + 1
							end
							
						end
						
						v = v + cinc
						k = k + 1
					
					end
				
				end
			
			end
		end
		
		-- End of drawing the shape
		
		i = i - 1
	end
	
	return layer_hit

end

function polygon.draw(skip_in_preview)

	local tri_count = 0
	local i = 1
	
	while i <= #ui.layer do
		
		if polygon.data[ui.layer[i].count] ~= nil and ui.layer[i].visible then
		
			local active_clone = polygon.data[tm.polygon_loc]
			
			-- Draw selected vertices
			local verts_selected = vertex_selection[1] ~= nil
			local mx, my = mouse_x, mouse_y
			if ui.layer[i].count == tm.polygon_loc and verts_selected and skip_in_preview and shape_grabber == false and artboard.active == false then
			
				-- Draw spr_vertex_mask on vertex locations
				
				lg.setColor(palette.select)
				
				local j = 1
				while j <= #vertex_selection do
					
					local vertex_radius = 100 / camera_zoom
					local copy_vert = vertex_selection[j].index
					local tx, ty = active_clone.raw[copy_vert].x, active_clone.raw[copy_vert].y
					local sc = camera_zoom
					
					lg.draw(spr_vertex_mask, math.floor(tx * sc) - 9, math.floor(ty * sc) - 9)
					
					j = j + 1
				
				end
			
			end
			
			local clone = polygon.data[ui.layer[i].count]
			
			if ui.palette_textbox ~= 0 and ui.layer[i].count == tm.polygon_loc then
				lg.setColor(palette.active)
			else
				lg.setColor(clone.color)
			end
			
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
						tri_count = tri_count + 1
						
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
					local v, k = 0, 0
					local cinc = (360 / cseg)
					local _rad, _cos, _sin = math.rad, math.cos, math.sin
					
					while k < cseg do
		
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
						tri_count = tri_count + 1
						--lg.line(cx + cxx2, cy + cyy2, cx + cxx3, cy + cyy3) -- Draw outline
						
						v = v + cinc
						k = k + 1
					
					end
				
				end
			
			end
		end
		
		-- End of drawing the shape
		
		i = i + 1
	end
	
	total_triangles = tri_count

end

return polygon