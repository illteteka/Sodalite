local polygon = {}

-- Init variables
polygon.data = {}

-- Generators

function ccw(ax, ay, bx, by, cx, cy)
	return ((cy-ay) * (bx-ax)) > ((by-ay) * (cx-ax))
end

function polygon.intersect(ax, ay, bx, by, cx, cy, dx, dy)
	return (ccw(ax, ay, cx, cy, dx, dy) ~= ccw(bx, by, cx, cy, dx, dy)) and (ccw(ax, ay, bx, by, cx, cy) ~= ccw(ax, ay, bx, by, dx, dy))
end

function polygon.new(color)

	local shape = {}
	local vertices = {}
	local _lines = {}
	
	shape.kind = "polygon"
	shape.color = color or {1, 1, 1, 1}
	shape.raw = vertices
	shape.cache = _lines
	
	table.insert(polygon.data, shape)

end

function polygon.addVertex(x, y, loc)

	local copy = polygon.data[loc]
	local point = {}
	
	point.x, point.y = x, y
	table.insert(copy.raw, point)
	
	-- Connect the first 3 vertices
	if #copy.raw == 1 then
	elseif #copy.raw == 2 then
		copy.raw[1].va = 2
		table.insert(copy.cache, {1, 2})
	elseif #copy.raw == 3 then
		copy.raw[1].vb = 3
		table.insert(copy.cache, {1, 3})
		
		copy.raw[3].va = 2
		table.insert(copy.cache, {3, 2})
	else
		print(#copy.raw)
		--find intersection of va, vb in lines and delete
		local old_a, old_b = polygon.data[1].cache[global_close][1], polygon.data[1].cache[global_close][2]
		
		copy.raw[#copy.raw].va = old_a
		copy.raw[#copy.raw].vb = old_b
		
		table.remove(polygon.data[1].cache, global_close)
		
		--add lines for new segment
		table.insert(copy.cache, {#copy.raw, old_a})
		table.insert(copy.cache, {#copy.raw, old_b})
	end

end

function polygon.draw()

	local i = 1
	
	while i <= #polygon.data do
		
		-- Make a copy of the new shape
		local clone = polygon.data[i]
		
		lg.setColor(clone.color)
		
		-- Draw the shape
		if clone.kind == "polygon" then
		
			local j = 1
			while j < #clone.raw do
			
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