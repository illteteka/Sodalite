polygon = require "polygon"
input = require "input"
tm = require "timemachine"

lg = love.graphics

triangle_shape_counter = 1
triangle_vertex_counter = 0 --TODO remove and make into something better
this_point = -1

-- debug buttons
one_button = _OFF
two_button = _OFF

undo_button = _OFF

function love.load()

	tm.init()

end

function love.update(dt)

	-- Update input
	input.update(dt)
	undo_button = input.pullSwitch(love.keyboard.isDown("z"), undo_button)
	
	-- debug buttons
	one_button = input.pullSwitch(love.keyboard.isDown("1"), one_button)
	two_button = input.pullSwitch(love.keyboard.isDown("2"), two_button)
	-- End of input
	
	-- debug block
	
	if one_button == _PRESS then print_r(polygon.data) end
	if two_button == _PRESS then print_r(tm.data) end
	
	-- end debug block
	
	if undo_button == _PRESS then
	
		polygon.undoVertex()
	
	end
	
	if mouse_switch == _PRESS then
	
		-- Create a new shape if one doesn't exist
		if triangle_vertex_counter == 0 then
			polygon.new({1, 0, 0, 1})
		end
		
		local line_to_purge = -1
		
		local i = 1
		if polygon.data[1] ~= nil then
		
			-- Retrieve closest line segment to the new point
			for i = 1, #polygon.data[1].cache do
			
				local cc = polygon.data[1].cache[i]
				-- Line cache stores the lines index, so we need to get the actual x1, y1, x2, y2 of the line
				local xa, ya, xb, yb = polygon.data[1].raw[cc[1]].x, polygon.data[1].raw[cc[1]].y, polygon.data[1].raw[cc[2]].x, polygon.data[1].raw[cc[2]].y
				-- Calculate line distance to mouse position
				local dp = (math.abs(((xa + xb)/2) - love.mouse.getX()) + math.abs(((ya + yb)/2) - love.mouse.getY()))
				polygon.data[1].cache[i].dp = dp
			
			end
			
			closest_line = -1
			closest_dist = -1
			
			-- Loop line cache to find the closest segment based on lowest scoring 'dp' value
			for i = 1, #polygon.data[1].cache do
			
				if polygon.data[1].cache[i].dp ~= nil then
					
					if closest_dist == -1 or polygon.data[1].cache[i].dp < closest_dist then
						closest_line = i
						closest_dist = polygon.data[1].cache[i].dp
					end
					
					-- Remove dp from the cache since it's no longer needed
					polygon.data[1].cache[i].dp = nil
					
				end
			
			end
			
			line_to_purge = closest_line
		
		end
		
		this_point = polygon.addVertex(love.mouse.getX(), love.mouse.getY(), triangle_shape_counter, line_to_purge)
		
		-- Reset counter
		triangle_vertex_counter = triangle_vertex_counter + 1
		--[[if triangle_vertex_counter == 3 then
			triangle_shape_counter = triangle_shape_counter + 1
			triangle_vertex_counter = 0
		end--]]
	
	end
	
	--[[
	if mouse_switch == _ON then
	
		if this_point ~= -1 then
		
			local pp = polygon.data[1].raw[this_point]
			pp.x, pp.y = love.mouse.getX(), love.mouse.getY()
		
		end
	
	end--]]

end

function love.draw()

	lg.setColor(0.4, 0.4, 0.4, 1)
	lg.rectangle("fill", 0, 0, 1000, 1000)
	lg.setColor(1, 1, 1, 1)
	lg.print(love.mouse.getX() .. " " .. love.mouse.getY(), 100, 100)
	
	polygon.draw()

end

function print_r ( t )
	local print_r_cache={}
	local function sub_print_r(t,indent)
		if (print_r_cache[tostring(t)]) then
			print(indent.."*"..tostring(t))
		else
			print_r_cache[tostring(t)]=true
			if (type(t)=="table") then
				for pos,val in pairs(t) do
					if (type(val)=="table") then
						print(indent.."["..pos.."] => "..tostring(t).." {")
						sub_print_r(val,indent..string.rep(" ",string.len(pos)+8))
						print(indent..string.rep(" ",string.len(pos)+6).."}")
					elseif (type(val)=="string") then
						print(indent.."["..pos..'] => "'..val..'"')
					else
						print(indent.."["..pos.."] => "..tostring(val))
					end
				end
			else
				print(indent..tostring(t))
			end
		end
	end
	if (type(t)=="table") then
		print(tostring(t).." {")
		sub_print_r(t,"  ")
		print("}")
	else
		sub_print_r(t,"  ")
	end
	print()
end