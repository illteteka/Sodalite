polygon = require "polygon"
input = require "input"
palette = require "palette"
ui = require "ui"
tm = require "timemachine"
lume = require "lume"
import = require "import"
export = require "export"
artboard = require "artboard"

lg = love.graphics
screen_width = 1280
screen_height = 700

shape_count = 1
vertex_selection = {}

-- debug buttons
one_button = _OFF
two_button = _OFF
debug_mode = "zoom"

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
p_key = _OFF
o_key = _OFF
i_key = _OFF
u_key = _OFF
t_key = _OFF
r_key = _OFF
space_key = _OFF
tab_key = _OFF
enter_key = _OFF
period_key = _OFF
comma_key = _OFF
minus_key = _OFF
plus_key = _OFF

up_key = _OFF
down_key = _OFF
left_key = _OFF
right_key = _OFF

camera_moved = false
camera_x = 0
camera_y = 0
camera_zoom = 1

selection_mouse_x = 0
selection_mouse_y = 0

document_name = "Untitled"
document_w = 0
document_h = 0

grid_x = 0
grid_y = 0
grid_w = 32
grid_h = 32
debug_grid = "resize"

mouse_x = -1
mouse_y = -1
mouse_x_previous = -1
mouse_y_previous = -1

ui_off_mouse_down = false
ui_on_mouse_up = false

artboard_is_drawing = false

function updateCamera(w, h, zo, zn)

	-- Stop scale factor from being less than 0
	if zn < 0 then
		zn = zo
	end

	-- Calculate expected center at old resolution
	local old_x = (((screen_width  - document_w * zo) / 2) / zo) - (104 / zo)
	local old_y = (((screen_height - document_h * zo) / 2) / zo) + (25 / 2 / zo)

	-- Get offset from center
	local xm, ym = camera_x - old_x, camera_y - old_y

	-- Update screen size and zoom
	screen_width, screen_height = w, h
	camera_zoom = zn
	
	-- Update camera and add offset
	camera_x = (((screen_width  - document_w * zn) / 2) / zn) - (104 / zn) + xm
	camera_y = (((screen_height - document_h * zn) / 2) / zn) + (25 / 2 / zn) + ym
	
	-- math.floor camera once you're done scaling/resizing
	camera_moved = true
	
end

function resetCamera()
	camera_x = math.floor(((screen_width  - document_w * camera_zoom) / 2) / camera_zoom) - math.floor(104 / camera_zoom) -- right bar (- 208)
	camera_y = math.floor(((screen_height - document_h * camera_zoom) / 2) / camera_zoom) + math.floor(25 / 2 / camera_zoom) -- top bar (+ 25)
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
	
	grad_large = lg.newImage("textures/gradient_large.png")
	grad_active = lg.newImage("textures/gradient_active.png")
	grad_inactive = lg.newImage("textures/gradient_inactive.png")
	grad_slider = lg.newImage("textures/gradient_slider.png")
	
	spr_vertex = lg.newImage("textures/vertex.png")
	spr_vertex_mask = lg.newImage("textures/vertex_mask.png")
	
	spr_slider_1 = lg.newImage("textures/slider_1.png")
	spr_slider_2 = lg.newImage("textures/slider_2.png")
	spr_slider_3 = lg.newImage("textures/slider_3.png")
	spr_slider_button = lg.newImage("textures/slider_button.png")
	spr_arrow_up = lg.newImage("textures/arrow_up.png")
	spr_arrow_down = lg.newImage("textures/arrow_down.png")
	
	art_grad_slider = lg.newImage("textures/art_gradient_slider.png")
	art_slider_1 = lg.newImage("textures/art_slider_1.png")
	art_slider_2 = lg.newImage("textures/art_slider_2.png")
	art_slider_3 = lg.newImage("textures/art_slider_3.png")
	art_slider_button = lg.newImage("textures/art_slider_button.png")
	
	icon_add = lg.newImage("textures/icon_add.png")
	icon_trash = lg.newImage("textures/icon_trash.png")
	icon_eye = lg.newImage("textures/icon_eye.png")
	icon_blink = lg.newImage("textures/icon_blink.png")
	
end

function love.resize(w, h)
	updateCamera(w, h, camera_zoom, camera_zoom)
end

function love.textinput(x)
	if x == "," or x == ":" or x == ";" or x == "/" or x == "\\" or x == "*" or x == "?" or x == "\"" or x == "<" or x == ">" or x == "|" then
		x = ""
	end
	ui.keyboardHit(x or "")
end

function love.keypressed(x)
	if (x == "backspace") or (x == "return") then
		ui.keyboardHit(x)
	end
end

function love.filedropped(file)

	local fname = file:getFilename()
	local file_dot = string.find(fname,"%.")
	
	if (file_dot ~= nil) then
	
		local file_ext = fname:sub(file_dot + 1)
		local supported_images = (file_ext == "bmp") or (file_ext == "jpg") or (file_ext == "jpe") or (file_ext == "jpeg") or (file_ext == "png") or (file_ext == "tga")
		
		if (file_ext == FILE_EXTENSION) then
			import.open(file)
		elseif (document_w ~= 0) and (supported_images) then
			artboard.loadFile(fname, true)
		end
	
	end
end

function love.update(dt)

	mouse_x_previous, mouse_y_previous = mouse_x, mouse_y
	local mx, my = math.floor(love.mouse.getX() / camera_zoom), math.floor(love.mouse.getY() / camera_zoom)
	mouse_x, mouse_y = mx, my

	-- Update input
	input.update(dt)
	a_key = input.pullSwitch(love.keyboard.isDown("a"), a_key)
	c_key = input.pullSwitch(love.keyboard.isDown("c"), c_key)
	d_key = input.pullSwitch(love.keyboard.isDown("d"), d_key)
	i_key = input.pullSwitch(love.keyboard.isDown("i"), i_key) --*
	o_key = input.pullSwitch(love.keyboard.isDown("o"), o_key) --*
	p_key = input.pullSwitch(love.keyboard.isDown("p"), p_key) --*
	r_key = input.pullSwitch(love.keyboard.isDown("r"), r_key) --*
	s_key = input.pullSwitch(love.keyboard.isDown("s"), s_key)
	t_key = input.pullSwitch(love.keyboard.isDown("t"), t_key) --*
	u_key = input.pullSwitch(love.keyboard.isDown("u"), u_key) --*
	v_key = input.pullSwitch(love.keyboard.isDown("v"), v_key)
	w_key = input.pullSwitch(love.keyboard.isDown("w"), w_key)
	y_key = input.pullSwitch(love.keyboard.isDown("y"), y_key)
	z_key = input.pullSwitch(love.keyboard.isDown("z"), z_key)
	
	up_key = input.pullSwitch(love.keyboard.isDown("up"), up_key)
	down_key = input.pullSwitch(love.keyboard.isDown("down"), down_key)
	left_key = input.pullSwitch(love.keyboard.isDown("left"), left_key)
	right_key = input.pullSwitch(love.keyboard.isDown("right"), right_key)
	
	lctrl_key = input.pullSwitch(love.keyboard.isDown("l" .. ctrl_name), lctrl_key)
	rctrl_key = input.pullSwitch(love.keyboard.isDown("r" .. ctrl_name), rctrl_key)
	space_key = input.pullSwitch(love.keyboard.isDown("space"), space_key)
	tab_key = input.pullSwitch(love.keyboard.isDown("tab"), tab_key)
	enter_key = input.pullSwitch(love.keyboard.isDown("return"), enter_key)
	period_key = input.pullSwitch(love.keyboard.isDown("."), period_key)
	comma_key = input.pullSwitch(love.keyboard.isDown(","), comma_key)
	minus_key = input.pullSwitch(love.keyboard.isDown("-"), minus_key)
	plus_key = input.pullSwitch(love.keyboard.isDown("="), plus_key)
	
	-- debug buttons
	one_button = input.pullSwitch(love.keyboard.isDown("f3"), one_button)
	two_button = input.pullSwitch(love.keyboard.isDown("f4"), two_button)
	-- End of input
	
	-- debug block
	
	if one_button == _PRESS then print_r(polygon.data) end
	if two_button == _PRESS then print_r(tm.data) end
	
	-- end debug block
	
	-- Camera movement
	local camera_spd = 4 / camera_zoom
	
	-- Scale camera movement over 100% scale
	local cas = 1
	if (camera_zoom > 1) then
		cas = camera_zoom
	end
	
	local ui_active
	ui_active = ui.update(dt)
	ui_on_mouse_up = (ui_active == true) and (mouse_switch == _OFF)

	if ui.popup[1] == nil and document_w ~= 0 then
	
	if artboard.active == false and ((ui_active == false) or (ui_off_mouse_down)) then
	
		if polygon.data[tm.polygon_loc] ~= nil and input.ctrlCombo(a_key) then
		
			--[[
			local i
			for i = 1, #polygon.data[tm.polygon_loc].raw do
			
				local moved_point = {}
				moved_point.index = i
				moved_point.x = polygon.data[tm.polygon_loc].raw[i].x
				moved_point.y = polygon.data[tm.polygon_loc].raw[i].y
				table.insert(vertex_selection, moved_point)
			
			end--]]
		
		end
		
		if mouse_switch == _PRESS then
		
			-- Create a new shape if one doesn't exist
			if polygon.data[tm.polygon_loc] == nil then
				local new_col = {palette.active[1], palette.active[2], palette.active[3], palette.active[4]}
				polygon.new(tm.polygon_loc, new_col, polygon.kind, true)
			end
			
			if debug_mode ~= "grid" then
				selection_mouse_x = mx - math.floor(camera_x)
				selection_mouse_y = my - math.floor(camera_y)
			else
				selection_mouse_x = ((math.floor((mx - camera_x) / grid_w) * grid_w) + (grid_x % grid_w))
				selection_mouse_y = ((math.floor((my - camera_y) / grid_h) * grid_h) + (grid_y % grid_h))
			end
			
			-- Test if we are placing a vertex or moving a vertex
			if vertex_selection[1] == nil then -- If selection is empty
			polygon.calcVertex(selection_mouse_x, selection_mouse_y, tm.polygon_loc, true)
			end
		
		end
		
		if mouse_switch == _ON then
		
			ui_off_mouse_down = true
		
			-- If a point is selected, have it follow the mouse
			local i
			for i = 1, #vertex_selection do
			
				local cx, cy
				if debug_mode ~= "grid" then
					cx = mx
					cy = my
				else
					cx = ((math.floor((mx - camera_x) / grid_w) * grid_w) + (grid_x % grid_w) + math.floor(camera_x))
					cy = ((math.floor((my - camera_y) / grid_h) * grid_h) + (grid_y % grid_h) + math.floor(camera_y))
				end
			
				-- Move verices by offset of selection_mouse_*
				local pp = polygon.data[tm.polygon_loc].raw[vertex_selection[i].index]
				pp.x, pp.y = vertex_selection[i].x + (cx - selection_mouse_x - math.floor(camera_x)), vertex_selection[i].y + (cy - selection_mouse_y - math.floor(camera_y))
			
			end
		
		end
		
		if mouse_switch == _RELEASE then
		
			ui_off_mouse_down = false
		
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
		
	else -- artboard is active
	
		if minus_key == _PRESS then
			artboard.brush_size = math.max(artboard.brush_size - 1, 1)
		end
		
		if plus_key == _PRESS then
			artboard.brush_size = artboard.brush_size + 1
		end
	
		if ((ui_active == false) or (ui_off_mouse_down)) then
		
			local ax, ay = mx - camera_x, my - camera_y
		
			if mouse_switch == _PRESS or rmb_switch == _PRESS then
				-- Check if mouse press was on the workable canvas
				artboard_is_drawing = (ax >= 0 and ax <= document_w) and (ay >= 0 and ay <= document_h)
			end
		
			if artboard_is_drawing then
				if mouse_switch == _ON then
					if artboard.visible and artboard.canvas ~= nil then
						ui_off_mouse_down = true
						artboard.add(mx - math.floor(camera_x), my - math.floor(camera_y), mouse_x_previous - math.floor(camera_x), mouse_y_previous - math.floor(camera_y))
					end
				end
				
				if rmb_switch == _ON then
					if artboard.visible and artboard.canvas ~= nil then
						ui_off_mouse_down = true
						artboard.add(mx - math.floor(camera_x), my - math.floor(camera_y), mouse_x_previous - math.floor(camera_x), mouse_y_previous - math.floor(camera_y), true)
					end
				end
				
				if mouse_switch == _RELEASE or rmb_switch == _RELEASE then
					ui_off_mouse_down = false
					artboard.saveCache()
					artboard_is_drawing = false
				end
			end
		
		end
		
		if ((ui_active == false) or (ui_on_mouse_up)) then
		
			if mouse_switch == _OFF then
		
				if input.ctrlCombo(z_key) then
					artboard.undo()
				end
				
				if input.ctrlCombo(y_key) then
					artboard.redo()
				end
				
			end
		
		end
		
	end
	
	if mouse_switch == _OFF and debug_mode ~= "artboard" and ((ui_active == false) or (ui_on_mouse_up)) then
	
		if input.ctrlCombo(z_key) then
			vertex_selection = {}
			palette.activeIsEditable = false
			local repeat_undo = polygon.undo()
			
			while (repeat_undo) do
				repeat_undo = polygon.undo()
			end
		end
		
		if input.ctrlCombo(y_key) then
			vertex_selection = {}
			palette.activeIsEditable = false
			local repeat_redo = polygon.redo()
			
			while (repeat_redo) do
				repeat_redo = polygon.redo()
			end
		end
		
		if document_w ~= 0 and input.ctrlCombo(s_key) then
			export.saveLOL()
			export.saveSVG()
			export.saveArtboard()
		end
	
	end
	
	-- Debug keys
	
	if ((ui_active == false) or (ui_on_mouse_up)) then
	
		if r_key == _PRESS then debug_mode = "artboard" end
		if t_key == _PRESS then debug_mode = "polygon" end
		if y_key == _PRESS and input.ctrlCombo(y_key) == false then debug_mode = "ellipse" end
		if u_key == _PRESS then debug_mode = "line" end
		if i_key == _PRESS then debug_mode = "mirror" end
		if o_key == _PRESS then debug_mode = "grid" end
		if p_key == _PRESS then debug_mode = "zoom" end
		
		if debug_mode == "artboard" then
		
			if up_key == _PRESS then artboard.active = not artboard.active end
			if down_key == _PRESS then artboard.visible = not artboard.visible end
			if left_key == _PRESS then artboard.draw_top = not artboard.draw_top end
			if right_key == _PRESS then artboard.transparent = not artboard.transparent end
			
			if artboard.active then
				palette.activeIsEditable = false
			end
			
			if c_key == _PRESS then
				artboard.clear()
			end
		
		end
		
		if debug_mode == "zoom" then
			if up_key == _ON then
				updateCamera(screen_width, screen_height, camera_zoom, camera_zoom + (0.01 * 60 * dt))
			end
			
			if down_key == _ON then
				updateCamera(screen_width, screen_height, camera_zoom, camera_zoom - (0.01 * 60 * dt))
			end
		end
		
		if debug_mode == "grid" then
			if debug_grid == "shift" then
			if up_key == _ON then grid_y = grid_y - 1 end
			if down_key == _ON then grid_y = grid_y + 1 end
			if left_key == _ON then grid_x = grid_x - 1 end
			if right_key == _ON then grid_x = grid_x + 1 end
			end
			
			if debug_grid == "resize" then
			if up_key == _PRESS then grid_h = grid_h - 1 end
			if down_key == _PRESS then grid_h = grid_h + 1 end
			if left_key == _PRESS then grid_w = grid_w - 1 end
			if right_key == _PRESS then grid_w = grid_w + 1 end
			end
			
			if comma_key == _PRESS then debug_grid = "shift" end
			if period_key == _PRESS then debug_grid = "resize" end
			
			grid_w = math.max(grid_w, 2)
			grid_h = math.max(grid_h, 2)
		end
		
		if debug_mode == "ellipse" then
		
			if polygon.data[1] ~= nil and polygon.data[tm.polygon_loc] ~= nil and polygon.data[tm.polygon_loc].kind == "ellipse" then
				local myshape = polygon.data[tm.polygon_loc]
				local old_seg = myshape.segments
				if up_key == _PRESS then myshape.segments = myshape.segments + 1   myshape.segments = math.max(myshape.segments, 3) tm.store(TM_ELLIPSE_SEG, old_seg, myshape.segments) tm.step() end
				if down_key == _PRESS then myshape.segments = myshape.segments - 1 myshape.segments = math.max(myshape.segments, 3) tm.store(TM_ELLIPSE_SEG, old_seg, myshape.segments) tm.step() end
				if left_key == _PRESS then myshape._angle = myshape._angle - 1     tm.store(TM_ELLIPSE_ANGLE, myshape._angle + 1,   myshape._angle) tm.step() end
				if right_key == _PRESS then myshape._angle = myshape._angle + 1    tm.store(TM_ELLIPSE_ANGLE, myshape._angle - 1,   myshape._angle) tm.step() end
			else
				if up_key == _PRESS then polygon.segments = polygon.segments + 1 end
				if down_key == _PRESS then polygon.segments = polygon.segments - 1 end
				if left_key == _PRESS then polygon._angle = polygon._angle - 1 end
				if right_key == _PRESS then polygon._angle = polygon._angle + 1 end
				
				polygon.segments = math.max(polygon.segments, 3)
			end
		
		end
	
	end
	
	-- End debug keys
	
	-- Camera controls
	if lctrl_key == _OFF and rctrl_key == _OFF then
	
		if w_key == _ON then
			camera_y = camera_y + (camera_spd * 60 * cas * dt)
			camera_moved = true
		elseif s_key == _ON then
			camera_y = camera_y - (camera_spd * 60 * cas * dt)
			camera_moved = true
		end
		
		if a_key == _ON then
			camera_x = camera_x + (camera_spd * 60 * cas * dt)
			camera_moved = true
		elseif d_key == _ON then
			camera_x = camera_x - (camera_spd * 60 * cas * dt)
			camera_moved = true
		end
	
	end
	
	if camera_moved and up_key == _OFF and down_key == _OFF and w_key == _OFF and s_key == _OFF and a_key == _OFF and d_key == _OFF then
		camera_x = math.floor(camera_x)
		camera_y = math.floor(camera_y)
		camera_moved = false
	end
	
	if input.ctrlCombo(space_key) then
		resetCamera()
	end
	-- End camera controls
	
	end

end

function love.draw()

	local mx, my = math.floor(love.mouse.getX() / camera_zoom), math.floor(love.mouse.getY() / camera_zoom)
	
	lg.setColor(c_background)
	lg.rectangle("fill", 0, 0, screen_width, screen_height)
	
	lg.push()
	lg.translate(math.floor(camera_x * camera_zoom), math.floor(camera_y * camera_zoom))
	
	if document_w ~= 0 then
	
		if artboard.draw_top and artboard.visible and artboard.canvas ~= nil then
			local artcol = c_white
			if artboard.transparent then
				artcol = {1, 1, 1, 0.5}
			end
			
			lg.setColor(artcol)
			lg.draw(artboard.canvas, 0, 0, 0, camera_zoom)
		end
	
		if debug_mode == "grid" then
			lg.setColor(1,1,1,0.25)
		
			local xx, yy
			
			for xx = (grid_x % grid_w) * camera_zoom, document_w * camera_zoom, grid_w * camera_zoom do
				lg.rectangle("fill", xx, 0, 1, document_h * camera_zoom)
			end
			
			for yy = (grid_y % grid_h) * camera_zoom, document_h * camera_zoom, grid_h * camera_zoom do
				lg.rectangle("fill", 0, yy, document_w * camera_zoom, 1)
			end
		
		end
		
		lg.setColor(c_off_white)
		lg.rectangle("line", 0, 0, document_w * camera_zoom, document_h * camera_zoom)
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
				local sc = camera_zoom
				
				if (first_vert_sel == i) then
					lg.line(aa.x * sc, aa.y * sc, bb.x * sc, bb.y * sc)
					lg.line(cc.x * sc, cc.y * sc, aa.x * sc, aa.y * sc)
				elseif (first_vert_sel == a_loc) then
					lg.line(aa.x * sc, aa.y * sc, bb.x * sc, bb.y * sc)
					lg.line(bb.x * sc, bb.y * sc, cc.x * sc, cc.y * sc)
				elseif (first_vert_sel == b_loc) then
					lg.line(bb.x * sc, bb.y * sc, cc.x * sc, cc.y * sc)
					lg.line(cc.x * sc, cc.y * sc, aa.x * sc, aa.y * sc)
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
			local sc = camera_zoom
			lg.line(line_a.x * sc, line_a.y * sc, line_b.x * sc, line_b.y * sc)
		
		end
	
	end
	
	-- Draw spr_vertex on vertex locations
	if polygon.data[tm.polygon_loc] ~= nil then
		
		local clone = polygon.data[tm.polygon_loc]
		
		lg.setColor({1, 1, 1, 1})
		
		local j = 1
		while j <= #clone.raw do
			
			local vertex_radius = 100 / camera_zoom
			local tx, ty = clone.raw[j].x, clone.raw[j].y
			local sc = camera_zoom
			
			if (#clone.raw < 3 and clone.kind == "polygon") or (lume.distance(mx - math.floor(camera_x), my - math.floor(camera_y), tx, ty) < vertex_radius) then
				lg.draw(spr_vertex, math.floor(tx * sc) - 5, math.floor(ty * sc) - 5)
			end
			
			j = j + 1
		
		end
		
	end
	
	if not artboard.draw_top and artboard.visible and artboard.canvas ~= nil then
		local artcol = c_white
		if artboard.transparent then
			artcol = {1, 1, 1, 0.5}
		end
		
		lg.setColor(artcol)
		lg.draw(artboard.canvas, 0, 0, 0, camera_zoom)
	end
	
	lg.pop()
	
	ui.draw()
	
	-- Debug UI
	
	lg.setColor(1,1,1,0.6)
	local debug_info = ""
	
	if debug_mode == "artboard" then
		local av = "false"
		if artboard.visible then av = "true" end
		
		local aa = "false"
		if artboard.active then aa = "true" end
		
		local at = "bottom"
		if artboard.draw_top then at = "top" end
		
		local ar = "no"
		if artboard.transparent then ar = "yes" end
		
		debug_info = " visible:" .. av .. ", drawable:" .. aa .. ", position: " .. at .. ", transparent: " .. ar
	end
	
	if debug_mode == "line" or debug_mode == "mirror" then
		lg.setColor(1,0,0,0.6)
		debug_info = " not implemented"
	end
	
	if debug_mode == "grid" then
		debug_info = " " .. debug_grid .. " x:" .. grid_x .. " y:" .. grid_y .. " w:" .. grid_w ..  " h:" .. grid_h
	end
	
	if debug_mode == "polygon" then
		polygon.kind = "polygon"
	end
	
	if debug_mode == "ellipse" then
		polygon.kind = "ellipse"
	end
	
	lg.print("Debug mode: " .. debug_mode .. debug_info, 30, screen_height - 50)
	
	-- End Debug UI

end

function love.quit()
	recursivelyDelete("cache")
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