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

end

function polygon.addVertex(x, y, loc)

	local copy = polygon.data[loc]
	local point = {}
	
	point.x, point.y = x, y
	table.insert(copy.raw, point)
	
	-- The first 3 vertices are stored in specific locations
	if #copy.raw == 1 then
	elseif #copy.raw == 2 then
		-- Link line 2 to line 1
		copy.raw[1].va = 2
		table.insert(copy.cache, {1, 2})
	elseif #copy.raw == 3 then
		-- Link line 3 to line 1
		copy.raw[1].vb = 3
		table.insert(copy.cache, {1, 3})
		
		-- Link line 2 to line 3
		copy.raw[3].va = 2
		table.insert(copy.cache, {3, 2})
	else
		-- Create a new triangle using points: va, vb, and the cursor position
		local old_a, old_b = polygon.data[1].cache[global_close][1], polygon.data[1].cache[global_close][2]
		
		-- Link new vertex to va and vb
		copy.raw[#copy.raw].va = old_a
		copy.raw[#copy.raw].vb = old_b
		
		-- Remove the old line (va <-> vb) as it now resides inside the new shape
		table.remove(polygon.data[1].cache, global_close)
		
		-- Add two new lines to the perimeter cache
		table.insert(copy.cache, {#copy.raw, old_a})
		table.insert(copy.cache, {#copy.raw, old_b})
	end

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