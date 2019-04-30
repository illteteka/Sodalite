polygon = require "polygon"
input = require "input"
tm = require "timemachine"
lume = require "lume"

lg = love.graphics

shape_count = 1
vertex_selection = {}

-- debug buttons
one_button = _OFF
two_button = _OFF

undo_button = _OFF
redo_button = _OFF

function love.load()

	tm.init()
	
	spr_vertex = love.graphics.newImage("textures/vertex.png")
	spr_vertex_mask = love.graphics.newImage("textures/vertex_mask.png")

end

function love.update(dt)

	-- Update input
	input.update(dt)
	undo_button = input.pullSwitch(love.keyboard.isDown("z"), undo_button)
	redo_button = input.pullSwitch(love.keyboard.isDown("a"), redo_button)
	
	-- debug buttons
	one_button = input.pullSwitch(love.keyboard.isDown("1"), one_button)
	two_button = input.pullSwitch(love.keyboard.isDown("2"), two_button)
	-- End of input
	
	-- debug block
	
	if one_button == _PRESS then print_r(polygon.data) end
	if two_button == _PRESS then print_r(tm.data) end
	
	-- end debug block
	
	if mouse_switch == _PRESS then
	
		-- Create a new shape if one doesn't exist
		if polygon.data[1] == nil then
			polygon.new({1, 0, 0, 1}, true)
		end
		
		-- Test if we are placing a vertex or moving a vertex
		polygon.calcVertex(love.mouse.getX(), love.mouse.getY(), shape_count, true)
	
	end
	
	if mouse_switch == _ON then
	
		-- If a point is selected, have it follow the mouse
		local i
		for i = 1, #vertex_selection do
		
			local pp = polygon.data[1].raw[vertex_selection[i].index]
			pp.x, pp.y = love.mouse.getX(), love.mouse.getY()
		
		end
	
	end
	
	if mouse_switch == _RELEASE then
	
		-- If a point was selected, add TM_MOVE_VERTEX to time machine
		local i
		for i = 1, #vertex_selection do
		
			local pp = polygon.data[1].raw[vertex_selection[i].index]
			tm.store(TM_MOVE_VERTEX, vertex_selection[i].index, pp.x, pp.y, vertex_selection[i].x, vertex_selection[i].y)
		
		end
		tm.step()
	
		vertex_selection = {}
	end
	
	if mouse_switch == _OFF then
	
		if undo_button == _PRESS then
			polygon.undo()
		end
		
		if redo_button == _PRESS then
			polygon.redo()
		end
	
	end

end

function love.draw()

	lg.setColor(0.4, 0.4, 0.4, 1)
	lg.rectangle("fill", 0, 0, 1000, 1000)
	lg.setColor(1, 1, 1, 1)
	lg.print(love.mouse.getX() .. " " .. love.mouse.getY(), 100, 100)
	
	polygon.draw()
	
	-- Draw spr_vertex on vertex locations
	local i = 1
	while i <= #polygon.data do
		
		local clone = polygon.data[i]
		
		lg.setColor({1, 1, 1, 1})
		
		local j = 1
		while j <= #clone.raw do
			
			lg.draw(spr_vertex, clone.raw[j].x - 5, clone.raw[j].y - 5)
			
			j = j + 1
		
		end
		
		i = i + 1
	end

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