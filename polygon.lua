local polygon = {}

-- Init variables
polygon.data = {}

-- Generators

function polygon.new(color)

	local shape = {}
	local vertices = {}
	local line_cache = {}
	
	shape.kind = "polygon"
	shape.color = color or {1, 1, 1, 1}
	shape.raw = vertices
	shape.cache = line_cache -- Each shape holds a cache of its perimeter in the form of a list of lines
	
	table.insert(polygon.data, shape)
	
	-- Record new shape into the undo stack
	tm.store(TM_NEW_POLYGON, #polygon.data, shape.kind, shape.color)

end

function polygon.undoVertex()
	
	--[[
	
	we could have another function do this and feed these
	actions to this function
	
	--]]
	
	-- Retrieve undo sequence from time machine
	if tm.data[1] ~= nil then
		local i = 1
		for i = 1, #tm.data[#tm.data] do
		
			local moment = tm.data[#tm.data][i]
			local action = moment.action
			
			if (action == TM_NEW_POLYGON) then
			print("TM_NEW_POLYGON")
			elseif (action == TM_ADD_VERTEX) then
			print("TM_ADD_VERTEX")
			elseif (action == TM_ADD_LINE) then
			print("TM_ADD_LINE")
			elseif (action == TM_ADD_TRIANGLE) then
			print("TM_ADD_TRIANGLE")
			elseif (action == TM_DEL_LINE) then
			print("TM_DEL_LINE")
			end
		
		end
	end

end

function polygon.addVertex(x, y, loc, old_line)

	local copy = polygon.data[loc]
	local point = {}
	
	point.x, point.y = x, y
	table.insert(copy.raw, point)
	
	-- The first 3 vertices are stored in specific locations
	if #copy.raw == 1 then
		-- Time machine functions record vertex position, allows users to undo
		tm.store(TM_ADD_VERTEX, loc, #copy.raw, x, y)
		tm.step()
	elseif #copy.raw == 2 then
		-- Link line 2 to line 1
		copy.raw[1].va = 2
		table.insert(copy.cache, {1, 2})
		
		tm.store(TM_ADD_LINE, loc, 1, 2)
		tm.step()
	elseif #copy.raw == 3 then
		-- Link line 3 to line 1
		copy.raw[1].vb = 3
		table.insert(copy.cache, {1, 3})
		
		-- Link line 2 to line 3
		copy.raw[3].va = 2
		table.insert(copy.cache, {3, 2})
		
		tm.store(TM_ADD_TRIANGLE, loc, 1, 3)
		tm.store(TM_ADD_LINE,     loc, 3, 2)
		tm.step()
	else
		-- Create a new triangle using points: va, vb, and the cursor position
		
		local old_a, old_b = polygon.data[1].cache[old_line][1], polygon.data[1].cache[old_line][2]
		
		-- Link new vertex to va and vb
		copy.raw[#copy.raw].va = old_a
		copy.raw[#copy.raw].vb = old_b
		
		-- Remove the old line (va <-> vb) as it now resides inside the new shape
		table.remove(polygon.data[1].cache, old_line)
		
		-- Add two new lines to the perimeter cache
		table.insert(copy.cache, {#copy.raw, old_a})
		table.insert(copy.cache, {#copy.raw, old_b})
		
		tm.store(TM_DEL_LINE,     loc, old_line, old_a, old_b)
		tm.store(TM_ADD_TRIANGLE, loc, #copy.raw, old_a)
		tm.store(TM_ADD_LINE,     loc, #copy.raw, old_b)
		tm.step()
	end
	
	return #copy.raw

end

function polygon.draw()

	local i = 1
	
	while i <= #polygon.data do
		
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
		-- End of drawing the shape
		
		i = i + 1
	end

end

return polygon