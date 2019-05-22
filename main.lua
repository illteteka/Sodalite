polygon = require "polygon"
input = require "input"
palette = require "palette"
ui = require "ui"
tm = require "timemachine"
lume = require "lume"

lg = love.graphics
screen_width = 1280
screen_height = 700

shape_count = 1
vertex_selection = {}

-- debug buttons
one_button = _OFF
two_button = _OFF

ctrl_name = "ctrl"

a_key = _OFF
lctrl_key = _OFF
rctrl_key = _OFF
z_key = _OFF
y_key = _OFF
c_key = _OFF
v_key = _OFF
w_key = _OFF
s_key = _OFF
d_key = _OFF
space_key = _OFF

k_key = _OFF
l_key = _OFF

camera_moved = false
camera_x = 0
camera_y = 0

selection_mouse_x = 0
selection_mouse_y = 0

document_name = "Untitled"
document_w = 0
document_h = 0

function resetCamera()
	camera_x = math.floor((screen_width  - 208 - document_w) / 2) -- right bar (- 208)
	camera_y = math.floor((screen_height + 25  - document_h) / 2) -- top bar (+ 25)
end

function love.load()

	if love.system.getOS() == "OS X" then
		ctrl_name = "gui"
	end

	math.randomseed(os.time())
	-- Check if being run in dev environment, set vsync on
	local bad_is_dev = false
	local a = io.open(".git/config")
	bad_is_dev = a ~= nil
	if bad_is_dev then io.close(a) end
	
	love.window.setMode(screen_width, screen_height, {resizable=true, vsync=bad_is_dev, minwidth=640, minheight=480})
	lg.setLineWidth(1)
	lg.setLineStyle("rough")
	love.keyboard.setKeyRepeat(true)
	
	font = lg.newFont("opensans.ttf", 13)
	lg.setFont(font)
	
	ui.init()
	palette.init()
	tm.init()
	
	grad_large = love.graphics.newImage("textures/gradient_large.png")
	grad_active = love.graphics.newImage("textures/gradient_active.png")
	grad_inactive = love.graphics.newImage("textures/gradient_inactive.png")
	grad_slider = love.graphics.newImage("textures/gradient_slider.png")
	
	spr_vertex = love.graphics.newImage("textures/vertex.png")
	spr_vertex_mask = love.graphics.newImage("textures/vertex_mask.png")
	
	spr_slider_1 = love.graphics.newImage("textures/slider_1.png")
	spr_slider_2 = love.graphics.newImage("textures/slider_2.png")
	spr_slider_3 = love.graphics.newImage("textures/slider_3.png")
	spr_slider_button = love.graphics.newImage("textures/slider_button.png")
	spr_arrow_up = love.graphics.newImage("textures/arrow_up.png")
	spr_arrow_down = love.graphics.newImage("textures/arrow_down.png")
	
	icon_add = love.graphics.newImage("textures/icon_add.png")
	icon_trash = love.graphics.newImage("textures/icon_trash.png")
	icon_eye = love.graphics.newImage("textures/icon_eye.png")
	icon_blink = love.graphics.newImage("textures/icon_blink.png")

end

function love.resize(w, h)
	local old_x, old_y = (screen_width - 208) / 2, (screen_height + 25) / 2
	screen_width, screen_height = w, h
	local new_x, new_y = (screen_width - 208) / 2, (screen_height + 25) / 2
	
	camera_x = math.floor(camera_x + new_x - old_x)
	camera_y = math.floor(camera_y + new_y - old_y)
end

function love.textinput(x)
	ui.keyboardHit(x or "")
end

function love.keypressed(x)
	if (x == "backspace") or (x == "return") then
		ui.keyboardHit(x)
	end
end

function love.update(dt)

	-- Update input
	input.update(dt)
	a_key = input.pullSwitch(love.keyboard.isDown("a"), a_key)
	c_key = input.pullSwitch(love.keyboard.isDown("c"), c_key)
	d_key = input.pullSwitch(love.keyboard.isDown("d"), d_key)
	s_key = input.pullSwitch(love.keyboard.isDown("s"), s_key)
	v_key = input.pullSwitch(love.keyboard.isDown("v"), v_key)
	w_key = input.pullSwitch(love.keyboard.isDown("w"), w_key)
	y_key = input.pullSwitch(love.keyboard.isDown("y"), y_key)
	z_key = input.pullSwitch(love.keyboard.isDown("z"), z_key)
	
	lctrl_key = input.pullSwitch(love.keyboard.isDown("l" .. ctrl_name), lctrl_key)
	rctrl_key = input.pullSwitch(love.keyboard.isDown("r" .. ctrl_name), rctrl_key)
	space_key = input.pullSwitch(love.keyboard.isDown("space"), space_key)
	
	-- debug buttons
	one_button = input.pullSwitch(love.keyboard.isDown("f3"), one_button)
	two_button = input.pullSwitch(love.keyboard.isDown("f4"), two_button)
	
	k_key = input.pullSwitch(love.keyboard.isDown("k"), k_key)
	l_key = input.pullSwitch(love.keyboard.isDown("l"), l_key)
	-- End of input
	
	if l_key == _PRESS then
		local old_layer = tm.polygon_loc
		tm.polygon_loc = tm.polygon_loc + 1
		shape_count = math.max(shape_count, tm.polygon_loc)
		
		tm.store(TM_SWITCH_LAYER, old_layer, tm.polygon_loc)
		tm.step()
		--print("current layer " .. tm.polygon_loc)
		--print("shape count " .. shape_count)
	end
	
	if k_key == _PRESS then
		local old_layer = tm.polygon_loc
		tm.polygon_loc = tm.polygon_loc - 1
		if tm.polygon_loc == 0 then
			tm.polygon_loc = #polygon.data
		end
		tm.store(TM_SWITCH_LAYER, old_layer, tm.polygon_loc)
		tm.step()
		--print("current layer " .. tm.polygon_loc)
	end
	
	-- debug block
	
	if one_button == _PRESS then print_r(polygon.data) end
	if two_button == _PRESS then print_r(tm.data) end
	
	-- end debug block
	
	-- Camera movement
	local camera_spd = 4
	if lctrl_key == _OFF and rctrl_key == _OFF then
	
		if w_key == _ON then
			camera_y = camera_y + (camera_spd * 60 * dt)
			camera_moved = true
		elseif s_key == _ON then
			camera_y = camera_y - (camera_spd * 60 * dt)
			camera_moved = true
		end
		
		if a_key == _ON then
			camera_x = camera_x + (camera_spd * 60 * dt)
			camera_moved = true
		elseif d_key == _ON then
			camera_x = camera_x - (camera_spd * 60 * dt)
			camera_moved = true
		end
	
	end
	
	if camera_moved and w_key == _OFF and s_key == _OFF and a_key == _OFF and d_key == _OFF then
		camera_x = math.floor(camera_x)
		camera_y = math.floor(camera_y)
		camera_moved = false
	end
	
	if input.ctrlCombo(space_key) then
		resetCamera()
	end
	
	local ui_active
	ui_active = ui.update(dt)
	
	if ui_active == false and document_w ~= 0 then
	
	if polygon.data[tm.polygon_loc] ~= nil and input.ctrlCombo(a_key) then
	
		local i
		for i = 1, #polygon.data[tm.polygon_loc].raw do
		
			local moved_point = {}
			moved_point.index = i
			moved_point.x = polygon.data[tm.polygon_loc].raw[i].x
			moved_point.y = polygon.data[tm.polygon_loc].raw[i].y
			table.insert(vertex_selection, moved_point)
		
		end
	
	end
	
	if mouse_switch == _PRESS then
	
		-- Create a new shape if one doesn't exist
		if polygon.data[tm.polygon_loc] == nil then
			local new_col = {palette.active[1], palette.active[2], palette.active[3], palette.active[4]}
			polygon.new(tm.polygon_loc, new_col, true)
		end
		
		selection_mouse_x = love.mouse.getX() - math.floor(camera_x)
		selection_mouse_y = love.mouse.getY() - math.floor(camera_y)
		
		-- Test if we are placing a vertex or moving a vertex
		if vertex_selection[1] == nil then -- If selection is empty
		polygon.calcVertex(selection_mouse_x, selection_mouse_y, tm.polygon_loc, true)
		end
	
	end
	
	if mouse_switch == _ON then
	
		-- If a point is selected, have it follow the mouse
		local i
		for i = 1, #vertex_selection do
		
			-- Move verices by offset of selection_mouse_*
			local pp = polygon.data[tm.polygon_loc].raw[vertex_selection[i].index]
			pp.x, pp.y = vertex_selection[i].x + (love.mouse.getX() - selection_mouse_x - math.floor(camera_x)), vertex_selection[i].y + (love.mouse.getY() - selection_mouse_y - math.floor(camera_y))
		
		end
	
	end
	
	if mouse_switch == _RELEASE then
	
		-- If a point was selected, add TM_MOVE_VERTEX to time machine
		local i
		for i = 1, #vertex_selection do
		
			local pp = polygon.data[tm.polygon_loc].raw[vertex_selection[i].index]
			tm.store(TM_MOVE_VERTEX, vertex_selection[i].index, pp.x, pp.y, vertex_selection[i].x, vertex_selection[i].y)
		
		end
		
		if #vertex_selection ~= 0 then
			tm.step()
		end
	
		vertex_selection = {}
	end
	
	if mouse_switch == _OFF then
	
		if input.ctrlCombo(z_key) then
			vertex_selection = {}
			palette.activeIsEditable = false
			polygon.undo()
		end
		
		if input.ctrlCombo(y_key) then
			vertex_selection = {}
			palette.activeIsEditable = false
			polygon.redo()
		end
	
	end
	
	end

end

function love.draw()

	lg.setColor(c_background)
	lg.rectangle("fill", 0, 0, screen_width, screen_height)
	
	lg.push()
	lg.translate(camera_x, camera_y)
	
	if document_w ~= 0 then
	lg.setColor(c_off_white)
	lg.rectangle("line", 0, 0, document_w, document_h)
	lg.setColor(c_white)
	end
	
	polygon.draw()
	
	-- Draw lines while editing a shape
	local polygons_exist = polygon.data[tm.polygon_loc] ~= nil
	local mouse_down     = mouse_switch == _ON
	local verts_selected = vertex_selection[1] ~= nil and #vertex_selection == 1
	
	if polygons_exist and mouse_down and verts_selected then
		local i = 1
		local clone = polygon.data[tm.polygon_loc].raw
		
		while i <= #clone do
		
			lg.setColor({0,0,0,1})
		
			local first_vert_sel = vertex_selection[1].index
			
			if clone[i].vb ~= nil then
				
				local a_loc, b_loc = clone[i].va, clone[i].vb
				local aa, bb, cc = clone[i], clone[a_loc], clone[b_loc]
				
				if (first_vert_sel == i) then
					lg.line(aa.x, aa.y, bb.x, bb.y)
					lg.line(cc.x, cc.y, aa.x, aa.y)
				elseif (first_vert_sel == a_loc) then
					lg.line(aa.x, aa.y, bb.x, bb.y)
					lg.line(bb.x, bb.y, cc.x, cc.y)
				elseif (first_vert_sel == b_loc) then
					lg.line(bb.x, bb.y, cc.x, cc.y)
					lg.line(cc.x, cc.y, aa.x, aa.y)
				end
				
				
			end
			
			i = i + 1
		
		end
	end
	
	-- Draw perimeter when select all
	local all_verts_selected = vertex_selection[1] ~= nil and #vertex_selection == #polygon.data[tm.polygon_loc].raw
	
	if polygons_exist and all_verts_selected then
	
		local i
		for i = 1, #polygon.data[tm.polygon_loc].cache do
		
			lg.setColor({1, 1, 1, 1})
			local aa, bb = polygon.data[tm.polygon_loc].cache[i][1], polygon.data[tm.polygon_loc].cache[i][2]
			local line_a, line_b = polygon.data[tm.polygon_loc].raw[aa], polygon.data[tm.polygon_loc].raw[bb]
			lg.line(line_a.x, line_a.y, line_b.x, line_b.y)
		
		end
	
	end
	
	-- Draw spr_vertex on vertex locations
	if polygon.data[tm.polygon_loc] ~= nil then
		
		local clone = polygon.data[tm.polygon_loc]
		
		lg.setColor({1, 1, 1, 1})
		
		local j = 1
		while j <= #clone.raw do
			
			lg.draw(spr_vertex, clone.raw[j].x - 5, clone.raw[j].y - 5)
			
			j = j + 1
		
		end
		
	end
	
	lg.pop()
	
	ui.draw()

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