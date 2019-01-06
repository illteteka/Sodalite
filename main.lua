polygon = require "polygon"

mouse_x = 0
mouse_y = 0

lg = love.graphics

triangle_shape_counter = 1
triangle_vertex_counter = 0
buffer = ""

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

function love.load()

end

function love.update(dt)

end

function love.mousepressed( x, y, button, istouch, presses )

	if button == 1 then
	
		buffer = buffer .. " . "
		if triangle_vertex_counter == 0 then
			polygon.new({1, 0, 0, 1})
		end
		
		polygon.addVertex(x, y, triangle_shape_counter)
		
		-- Reset counter
		triangle_vertex_counter = triangle_vertex_counter + 1
		if triangle_vertex_counter == 3 then
			triangle_shape_counter = triangle_shape_counter + 1
			triangle_vertex_counter = 0
		end
	
	end
	
	if button == 2 then
		print_r(polygon.data)
	end

end

function love.draw()

	lg.setColor(0.4, 0.4, 0.4, 1)
	lg.rectangle("fill", 0, 0, 1000, 1000)
	lg.setColor(1, 1, 1, 1)
	lg.print(love.mouse.getX() .. " " .. love.mouse.getY() .. " " .. buffer, 100, 100)
	polygon.draw()

end