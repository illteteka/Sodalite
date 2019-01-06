local polygon = {}

-- Init variables
polygon.data = {}

-- Generators

function polygon.new(color)

	local shape = {}
	local vertices = {}
	shape.kind = "polygon"
	shape.color = color or {1, 1, 1, 1}
	shape.raw = vertices
	table.insert(polygon.data, shape)

end

function polygon.addVertex(x, y, loc)

	local point = {}
	point.x, point.y = x, y
	table.insert(polygon.data[loc].raw, point)

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
			
				if j + 2 <= #clone.raw then
					if clone.raw[j].x ~= nil and clone.raw[j + 1].x ~= nil and clone.raw[j + 2] ~= nil then
						local aa, bb, cc = clone.raw[j], clone.raw[j + 1], clone.raw[j + 2]
						lg.polygon("fill", aa.x, aa.y, bb.x, bb.y, cc.x, cc.y)
						j = j + 2
					end
				else
					j = #clone.raw -- Not enough vertex data to draw, jump to end of shape
				end
			
			end
		
		end
		-- End of drawing the shape
		
		i = i + 1
	end

end

return polygon