polygon = require "polygon"
input = require "input"
palette = require "palette"
ui = require "ui"
tm = require "timemachine"
lume = require "lume"
import = require "import"
export = require "export"
artboard = require "artboard"
autosave = require "autosave"

lg = love.graphics
screen_width = 1280
screen_height = 700

vertex_selection = {}
shape_selection = {}

-- debug buttons
one_button = _OFF
two_button = _OFF

ctrl_name = "ctrl"
ctrl_id = "Ctrl"
ctrl_cursor = "b"
mac_string = false
win_string = false
fs_enable_save = true
empty_document = true

a_key = _OFF
lctrl_key = _OFF
rctrl_key = _OFF
lshift_key = _OFF
rshift_key = _OFF
z_key = _OFF
y_key = _OFF
c_key = _OFF
v_key = _OFF
w_key = _OFF
s_key = _OFF
d_key = _OFF
n_key = _OFF
p_key = _OFF
o_key = _OFF
i_key = _OFF
u_key = _OFF
t_key = _OFF
r_key = _OFF
e_key = _OFF
g_key = _OFF
j_key = _OFF
k_key = _OFF
f2_key = _OFF
num_1_key = _OFF
num_2_key = _OFF
num_3_key = _OFF
num_4_key = _OFF
num_5_key = _OFF
num_6_key = _OFF
num_7_key = _OFF
num_8_key = _OFF
num_9_key = _OFF
space_key = _OFF
tab_key = _OFF
enter_key = _OFF
period_key = _OFF
comma_key = _OFF
minus_key = _OFF
plus_key = _OFF
scz_key = _OFF
undo_key = _OFF
delete_key = _OFF

up_key = _OFF
down_key = _OFF
left_key = _OFF
right_key = _OFF

camera_moved = false
camera_x = 0
camera_y = 0
camera_zoom = 1
camera_round = 0

box_selection_active = false
box_selection_x = 0
box_selection_y = 0
selection_mouse_x = 0
selection_mouse_y = 0
selection_rmb = false
selection_previously_active = false

document_name = "Untitled"
document_w = 0
document_h = 0

grid_x = 0
grid_y = 0
grid_w = 32
grid_h = 32
grid_snap = true
pixel_perfect = true

mouse_x = -1
mouse_y = -1
mouse_x_previous = -1
mouse_y_previous = -1
mouse_wheel_x = 0
mouse_wheel_y = 0
mouse_x_offset = -1
mouse_y_offset = -1
middle_x = -1
middle_y = -1

scrub_timer = 0
hz_key = 0
vt_key = 0
hz_dir = 0
vt_dir = 0

splash_timer = 0
splash_active = true

ui_off_mouse_down = false
ui_on_mouse_up = false

artboard_is_drawing = false

color_grabber = false
zoom_grabber = false
select_grabber = false
shape_grabber = false

selection_and_ui_active = false
vertex_selection_mode = false
shape_selection_mode = false
multi_shape_selection = false
arrow_key_selection = false

h_out = nil -- Shaders
h_out2 = nil
h_out3 = nil
v_out = nil
v_out2 = nil

last_shape_grabbed = -1
double_click_timer = 0
double_click_timer_deselect = 0
double_click_timer_rename = 0
lock_preview_vertices = false

global_message = ""
global_message_timer = 0

safe_to_quit = false
can_overwrite = false
is_trying_to_quit = false
overwrite_name = ""
overwrite_type = 0
OVERWRITE_LOL = 0
OVERWRITE_SVG = 1
OVERWRITE_PNG = 2

total_triangles = 0

line_x = 0
line_y = 0
line_active = false
line_disable = false

bad_is_dev = false

function resetEditor(exit_popup, add_layer, reset_cam)

	can_overwrite = false

	if reset_cam then
		ui.preview_zoom = 1
		ui.preview_window_x = 0
		ui.preview_window_y = 0
	
		camera_zoom = 1
		resetCamera()
	end
	
	vertex_selection_mode = false
	vertex_selection = {}

	shape_selection_mode = false
	shape_selection = {}
	multi_shape_selection = false
	
	color_grabber = false
	zoom_grabber = false
	select_grabber = false
	shape_grabber = false
	
	love.mouse.setCursor()
	
	artboard.init()
	tm.init()
	polygon.data = {}
	ui.layer = {}
	ui.layer_deleted = {}
	ui.lyr_count = 1
	if add_layer then
		ui.addLayer()
	end
	
	if exit_popup then
		-- Exit popup
		ui.popup = {}
		ui_active = true
		ui.context_menu = {}
		ui.title_active = false
	end
	
	ui.toolbar[ui.toolbar_grid].active = true
	ui.toolbar[ui.toolbar_pick].active = true
	ui.toolbar[ui.toolbar_preview].active = true
	ui.toolbar[ui.toolbar_zoom].active = true
	ui.toolbar[ui.toolbar_select].active = true
	ui.toolbar[ui.toolbar_shape].active = true
	
	if autosave.timer == 0 then
		autosave.timer = autosave.INTERVAL
	end

end

function updateTitle()
	if fs_enable_save then
		love.window.setTitle(document_name .. " - Sodalite")
	else
		love.window.setTitle("DOCUMENT SAVING DISABLED! - Sodalite")
	end
end

function updateCamera(w, h, zo, zn)

	-- Stop scale factor from being less than 0
	if zn < 0 then
		zn = zo
	end
	
	-- Calculate expected center at old resolution
	local old_x = (((screen_width  - document_w * zo) / 2) / zo) - (72 / zo)
	local old_y = (((screen_height - document_h * zo) / 2) / zo) + (54 / 2 / zo)

	-- Get offset from center
	local xm, ym = camera_x - old_x, camera_y - old_y

	-- Update screen size and zoom
	screen_width, screen_height = w, h
	camera_zoom = zn
	
	-- Update camera and add offset
	camera_x = (((screen_width  - document_w * zn) / 2) / zn) - (72 / zn) + xm
	camera_y = (((screen_height - document_h * zn) / 2) / zn) + (54 / 2 / zn) + ym
	
	-- math.floor camera once you're done scaling/resizing
	camera_round = 2
	camera_moved = true
	
end

function resetCamera()
	camera_x = math.floor(((screen_width  - document_w * camera_zoom) / 2) / camera_zoom) - math.floor(72 / camera_zoom) -- right bar (- 208) (+ 64) (208/2 - 64/2)
	camera_y = math.floor(((screen_height - document_h * camera_zoom) / 2) / camera_zoom) + math.floor(54 / 2 / camera_zoom) -- top bar (+ 54)
end

function editorUndo()
	if ui.primary_textbox ~= -1 then
		ui.popupLoseFocus("toolbar")
	end

	storeMovedShapes()
	shape_selection_mode = false
	shape_selection = {}
	multi_shape_selection = false
	
	storeMovedVertices()
	vertex_selection_mode = false
	vertex_selection = {}
	palette.activeIsEditable = false
	local repeat_undo = polygon.undo()
	
	while (repeat_undo) do
		repeat_undo = polygon.undo()
	end
end

function editorRedo()
	if ui.primary_textbox ~= -1 then
		ui.popupLoseFocus("toolbar")
	end

	storeMovedShapes()
	shape_selection_mode = false
	shape_selection = {}
	multi_shape_selection = false
	
	storeMovedVertices()
	vertex_selection_mode = false
	vertex_selection = {}
	palette.activeIsEditable = false
	local repeat_redo = polygon.redo()
	
	while (repeat_redo) do
		repeat_redo = polygon.redo()
	end
end

function editorSelectAll()

	local i
	for i = 1, #polygon.data[tm.polygon_loc].raw do
	
		local clone = polygon.data[tm.polygon_loc]
		local tx, ty = polygon.data[tm.polygon_loc].raw[i].x, polygon.data[tm.polygon_loc].raw[i].y
		local moved_point = {}
		moved_point.index = i
		moved_point.x = tx
		moved_point.y = ty
		table.insert(vertex_selection, moved_point)
		vertex_selection_mode = true
		
		-- Add vertex sibling if it's a line
		if clone.raw[i].l ~= nil and clone.raw[i].l == "+" then
			
			local sib_1 = clone.raw[i]
			local sib_2 = clone.raw[i - 1]
			
			local moved_point_sister = {}
			moved_point_sister.index = i - 1
			moved_point_sister.t = math.ceil(lume.distance(sib_1.x, sib_1.y, sib_2.x, sib_2.y))
			moved_point_sister.a = -lume.angle(sib_1.x, sib_1.y, sib_2.x, sib_2.y)
			moved_point_sister.x = math.floor(tx + polygon.lengthdir_x(moved_point_sister.t, moved_point_sister.a))
			moved_point_sister.y = math.floor(ty + polygon.lengthdir_y(moved_point_sister.t, moved_point_sister.a))
			
			table.insert(vertex_selection, moved_point_sister)
			
		end
	
	end

end

function editorSelectAllShapes()

	shape_selection = {}
			
	local n = 1
	while n <= #ui.layer do
		if ui.layer[n].visible then
			local copy_shape = {}
			copy_shape.index = n
			copy_shape.x = 0
			copy_shape.y = 0
			table.insert(shape_selection, copy_shape)
			shape_selection_mode = true
			multi_shape_selection = true
		end
		n = n + 1
	end
	
end

function storeMovedVertices()

	local needs_update = false

	if vertex_selection[1] ~= nil then
		local i
		for i = 1, #vertex_selection do
			local pp = polygon.data[tm.polygon_loc].raw[vertex_selection[i].index]
			if pp.x ~= vertex_selection[i].x or pp.y ~= vertex_selection[i].y then
				needs_update = true
			end
			
			if vertex_selection[i].new ~= nil and vertex_selection[i].new then
				needs_update = true
			end
		end
	end
	
	if needs_update then
	
		local i
		for i = 1, #vertex_selection do
		
			local pp = polygon.data[tm.polygon_loc].raw[vertex_selection[i].index]
			tm.store(TM_MOVE_VERTEX, vertex_selection[i].index, pp.x, pp.y, vertex_selection[i].x, vertex_selection[i].y)
		
		end
		
		if #vertex_selection ~= 0 then
			tm.step()
		end
		
		local i
		for i = 1, #vertex_selection do
			local vert_copy = vertex_selection[i].index
			vertex_selection[i].x = polygon.data[tm.polygon_loc].raw[vert_copy].x
			vertex_selection[i].y = polygon.data[tm.polygon_loc].raw[vert_copy].y
		end
		
	end

end

function storeMovedShapes()

	local needs_update = false
	
	if shape_selection[1] ~= nil then
		local i = 1
		while i <= #shape_selection do
			needs_update = needs_update or (shape_selection[i].x ~= 0) or (shape_selection[i].y ~= 0)
			
			if needs_update then
				i = #shape_selection + 1
			end
			i = i + 1
		end
	end
	
	if needs_update then
	
		local i = 1
		while i <= #shape_selection do
		
			tm.store(TM_MOVE_SHAPE, ui.layer[shape_selection[i].index].count, shape_selection[i].x, shape_selection[i].y)
			
			shape_selection[i].x = 0
			shape_selection[i].y = 0
			
			i = i + 1
			
		end
		
		if #shape_selection ~= 0 then
			tm.step()
		end
	
	end

end

function pixelFloor(x)
	if pixel_perfect then
		return math.floor(x)
	else
		return x
	end
end

function love.load()
	
	if love.system.getOS() == "OS X" then
		ctrl_name = "gui"
		ctrl_id = "Cmd"
		ctrl_cursor = "w"
		mac_string = true
	end
	
	if love.system.getOS() == "Windows" then
		win_string = true
	end

	math.randomseed(os.time())
	-- Check if being run in dev environment, set vsync on
	local a = io.open(".git/config")
	bad_is_dev = a ~= nil
	if bad_is_dev then io.close(a) end
	
	love.window.setMode(screen_width, screen_height, {vsync=love.window.getVSync(), resizable=true, minwidth=800, minheight=600})
	lg.setLineWidth(1)
	lg.setLineStyle("rough")
	love.keyboard.setKeyRepeat(true)
	
	font = lg.newFont("opensans.ttf", 13)
	font_big = lg.newFont("opensans.ttf", 23)
	lg.setFont(font)
	
	export.testSave()
	
	if fs_enable_save then
		love.window.setTitle("Sodalite")
	else
		love.window.setTitle("DOCUMENT SAVING DISABLED! - Sodalite")
	end
	
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
	icon_circle = lg.newImage("textures/icon_circle.png")
	icon_cursorw = lg.newImage("textures/icon_cursorw.png")
	icon_draw = lg.newImage("textures/icon_draw.png")
	icon_grid = lg.newImage("textures/icon_grid.png")
	icon_pick = lg.newImage("textures/icon_pick.png")
	icon_redo = lg.newImage("textures/icon_redo.png")
	icon_triangle = lg.newImage("textures/icon_triangle.png")
	icon_undo = lg.newImage("textures/icon_undo.png")
	icon_zoom = lg.newImage("textures/icon_zoom.png")
	icon_zoom_in = lg.newImage("textures/icon_zoom_in.png")
	icon_zoom_out = lg.newImage("textures/icon_zoom_out.png")
	icon_reset = lg.newImage("textures/icon_reset.png")
	icon_fit = lg.newImage("textures/icon_fit.png")
	icon_close = lg.newImage("textures/icon_close.png")
	icon_look = lg.newImage("textures/icon_look.png")
	icon_art_above = lg.newImage("textures/icon_art_above.png")
	icon_art_below = lg.newImage("textures/icon_art_below.png")
	icon_magnet = lg.newImage("textures/icon_magnet.png")
	icon_splash = lg.newImage("textures/splash.png")
	icon_select = lg.newImage("textures/icon_selection.png")
	icon_polyline = lg.newImage("textures/icon_polyline.png")
	icon_clone = lg.newImage("textures/icon_clone.png")
	icon_sodalite = lg.newImage("textures/icon_sodalite.png")
	icon_pixel = lg.newImage("textures/icon_pixel.png")
	icon_polyline = lg.newImage("textures/icon_polyline.png")
	icon_flip_h = lg.newImage("textures/icon_flip_h.png")
	icon_flip_v = lg.newImage("textures/icon_flip_v.png")
	
	cursor_typing = love.mouse.getSystemCursor("ibeam")
	cursor_size_h = love.mouse.getSystemCursor("sizewe")
	cursor_size_v = love.mouse.getSystemCursor("sizens")
	cursor_size_rise = love.mouse.getSystemCursor("sizenesw")
	cursor_size_fall = love.mouse.getSystemCursor("sizenwse")
	cursor_pick = love.mouse.newCursor("textures/cursor_pick.png", 5, 21)
	cursor_zoom = love.mouse.newCursor("textures/cursor_zoom.png", 7, 8)
	cursor_shape = love.mouse.newCursor("textures/icon_cursor" .. ctrl_cursor .. ".png", 7, 5)
	
	-- Import shaders
	h_out = lg.newShader("shaders/h_outline.frag")
	h_out:send("_mod",8)
	h_out:send("_lt",4)
	h_out:send("_off",8)
	
	v_out = lg.newShader("shaders/v_outline.frag")
	v_out:send("_mod",8)
	v_out:send("_lt",4)
	v_out:send("_off",8)
	
	h_out2 = lg.newShader("shaders/h_outline.frag")
	h_out2:send("_mod",8)
	h_out2:send("_lt",4)
	h_out2:send("_off",12)
	
	v_out2 = lg.newShader("shaders/v_outline.frag")
	v_out2:send("_mod",8)
	v_out2:send("_lt",4)
	v_out2:send("_off",12)
	
	h_out3 = lg.newShader("shaders/h_outline.frag")
	h_out3:send("_mod",8)
	h_out3:send("_lt",4)
	h_out3:send("_off",8)
	
	autosave.init()
	ui.init()
	palette.init()
	tm.init()
	
end

function love.mousefocus(f)
	ui.preview_dragging = false
	if ui.preview_action ~= "background" then
		ui.preview_action = ""
	end
end

function love.resize(w, h)
	updateCamera(w, h, camera_zoom, camera_zoom)
	ui.resizeWindow()
end

function love.wheelmoved(x, y)
	mouse_wheel_x = x
	mouse_wheel_y = y
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
	local mx, my = pixelFloor(love.mouse.getX() / camera_zoom), pixelFloor(love.mouse.getY() / camera_zoom)
	mouse_x, mouse_y = mx, my
	
	global_message_timer = math.max(global_message_timer - (dt * 60), 0)
	autosave.timer = math.max(autosave.timer - (dt * 60), 0)

	-- Update input
	input.update(dt)
	a_key = input.pullSwitch(love.keyboard.isDown("a"), a_key)
	c_key = input.pullSwitch(love.keyboard.isDown("c"), c_key)
	d_key = input.pullSwitch(love.keyboard.isDown("d"), d_key)
	e_key = input.pullSwitch(love.keyboard.isDown("e"), e_key)
	g_key = input.pullSwitch(love.keyboard.isDown("g"), g_key)
	i_key = input.pullSwitch(love.keyboard.isDown("i"), i_key)
	j_key = input.pullSwitch(love.keyboard.isDown("j"), j_key)
	k_key = input.pullSwitch(love.keyboard.isDown("k"), k_key)
	o_key = input.pullSwitch(love.keyboard.isDown("o"), o_key)
	n_key = input.pullSwitch(love.keyboard.isDown("n"), n_key)
	p_key = input.pullSwitch(love.keyboard.isDown("p"), p_key)
	r_key = input.pullSwitch(love.keyboard.isDown("r"), r_key)
	s_key = input.pullSwitch(love.keyboard.isDown("s"), s_key)
	t_key = input.pullSwitch(love.keyboard.isDown("t"), t_key)
	u_key = input.pullSwitch(love.keyboard.isDown("u"), u_key)
	v_key = input.pullSwitch(love.keyboard.isDown("v"), v_key)
	w_key = input.pullSwitch(love.keyboard.isDown("w"), w_key)
	y_key = input.pullSwitch(love.keyboard.isDown("y"), y_key)
	z_key = input.pullSwitch(love.keyboard.isDown("z"), z_key)
	
	num_1_key = input.pullSwitch(love.keyboard.isDown("1"), num_1_key)
	num_2_key = input.pullSwitch(love.keyboard.isDown("2"), num_2_key)
	num_3_key = input.pullSwitch(love.keyboard.isDown("3"), num_3_key)
	num_4_key = input.pullSwitch(love.keyboard.isDown("4"), num_4_key)
	num_5_key = input.pullSwitch(love.keyboard.isDown("5"), num_5_key)
	num_6_key = input.pullSwitch(love.keyboard.isDown("6"), num_6_key)
	num_7_key = input.pullSwitch(love.keyboard.isDown("7"), num_7_key)
	num_8_key = input.pullSwitch(love.keyboard.isDown("8"), num_8_key)
	num_9_key = input.pullSwitch(love.keyboard.isDown("9"), num_9_key)
	
	up_key = input.pullSwitch(love.keyboard.isDown("up"), up_key)
	down_key = input.pullSwitch(love.keyboard.isDown("down"), down_key)
	left_key = input.pullSwitch(love.keyboard.isDown("left"), left_key)
	right_key = input.pullSwitch(love.keyboard.isDown("right"), right_key)
	
	f2_key = input.pullSwitch(love.keyboard.isDown("f2"), f2_key)
	delete_key = input.pullSwitch(love.keyboard.isDown("delete"), delete_key)
	lctrl_key = input.pullSwitch(love.keyboard.isDown("l" .. ctrl_name), lctrl_key)
	rctrl_key = input.pullSwitch(love.keyboard.isDown("r" .. ctrl_name), rctrl_key)
	lshift_key = input.pullSwitch(love.keyboard.isDown("lshift"), lshift_key)
	rshift_key = input.pullSwitch(love.keyboard.isDown("rshift"), rshift_key)
	space_key = input.pullSwitch(love.keyboard.isDown("space"), space_key)
	tab_key = input.pullSwitch(love.keyboard.isDown("tab"), tab_key)
	enter_key = input.pullSwitch(love.keyboard.isDown("return"), enter_key)
	period_key = input.pullSwitch(love.keyboard.isDown("."), period_key)
	comma_key = input.pullSwitch(love.keyboard.isDown(","), comma_key)
	minus_key = input.pullSwitch(love.keyboard.isDown("-"), minus_key)
	plus_key = input.pullSwitch(love.keyboard.isDown("="), plus_key)
	scz_key = input.pullSwitch(input.shiftEither() and input.ctrlEither() and (z_key == _ON), scz_key)
	undo_key = input.pullSwitch(input.ctrlCombo(z_key) and not input.shiftEither(), undo_key)
	
	-- debug buttons
	if bad_is_dev then
	one_button = input.pullSwitch(love.keyboard.isDown("f3"), one_button)
	two_button = input.pullSwitch(love.keyboard.isDown("f4"), two_button)
	if one_button == _PRESS then print_r(polygon.data) end
	if two_button == _PRESS then tm.print() end
	end
	-- end debug block
	
	if splash_active then
	
		splash_timer = splash_timer + (60 * dt)
		if splash_timer > 60 * 6 or mouse_switch == _PRESS then
			splash_active = false
		end
	
	end
	
	-- Update horizontal scrubbing

	if (left_key == _PRESS) or ((right_key == _RELEASE) and (left_key == _ON)) then
		hz_dir = -1
	end

	if (right_key == _PRESS) or ((left_key == _RELEASE) and (right_key == _ON)) then
		hz_dir = 1
	end

	if (left_key == _OFF) and (right_key == _OFF) then
		hz_dir = 0
	end

	-- Update vertical scrubbing

	if (up_key == _PRESS) or ((down_key == _RELEASE) and (up_key == _ON)) then
		vt_dir = 1
	end

	if (down_key == _PRESS) or ((up_key == _RELEASE) and (down_key == _ON)) then
		vt_dir = -1
	end

	if (up_key == _OFF) and (down_key == _OFF) then
		vt_dir = 0
	end
		
	-- Update scrub
	
	if hz_dir ~= 0 or vt_dir ~= 0 then
	
		scrub_timer = scrub_timer + (dt * 60)
		
		-- Always move on key trigger event
		if (up_key == _PRESS) or (down_key == _PRESS) or (left_key == _PRESS) or (right_key == _PRESS) then
			if hz_dir ~= 0 then
				hz_key = 1
			end
			
			if vt_dir ~= 0 then
				vt_key = 1
			end
		else
		
			local floor_timer = math.floor(scrub_timer)
			if (floor_timer > 25) then
			
				if hz_dir ~= 0 then
					hz_key = 1
				else
					hz_key = 0
				end
				
				if vt_dir ~= 0 then
					vt_key = 1
				else
					vt_key = 0
				end
				
				scrub_timer = 24.5
			
			else
				hz_key = 0
				vt_key = 0
			end
		
		end
	
	elseif hz_dir == 0 or vt_dir == 0 then
		scrub_timer = 0
	end
	
	-- Camera movement
	local camera_spd = 4 / camera_zoom
	
	-- Scale camera movement over 100% scale
	local cas = 1
	if (camera_zoom > 1) then
		cas = camera_zoom
	end
	
	local ui_active = false
	
	if color_grabber then
	
		if (mouse_switch == _PRESS) then
		
			local test_x, test_y = mx - pixelFloor(camera_x), my - pixelFloor(camera_y)
			local test_hit_polygon = polygon.click(test_x, test_y, false)
			local use_color = nil
			
			local cr, cb, cg, ca = 0,0,0,0
			if artboard.opacity ~= 0 then
				if test_x >= 0 and test_x <= document_w - 1 and test_y >= 0 and test_y <= document_h - 1 then
					cr, cb, cg, ca = artboard.canvas:newImageData():getPixel(test_x, test_y)
				end
			end
			
			if artboard.draw_top then
			
				if test_hit_polygon ~= -1 then
					use_color = polygon.data[ui.layer[test_hit_polygon].count].color
				elseif ca ~= 0 then
					use_color = {cr, cb, cg, 1}
				end
			
			else
			
				if ca ~= 0 then
					use_color = {cr, cb, cg, 1}
				elseif test_hit_polygon ~= -1 then
					use_color = polygon.data[ui.layer[test_hit_polygon].count].color
				end
			
			end
			
			if use_color ~= nil then
				palette.activeIsEditable = false
				palette.colors[palette.slot+1] = {use_color[1], use_color[2], use_color[3], use_color[4]}
				palette.active = palette.colors[palette.slot+1]
				palette.updateFromBoxes()
				palette.updateAccentColor()
			end
			
			ui.toolbar[ui.toolbar_pick].active = true
			love.mouse.setCursor()
			color_grabber = false
		
		end
	
		ui_active = true
	else
		ui_active = ui.update(dt)
	end
	
	local disabled_prompt = (ui.popup[1] ~= nil and ui.popup[1][1].kind == "save.disabled")
	
	if mouse_switch == _OFF and (ui_active == false) and not disabled_prompt then
	
		if input.ctrlCombo(n_key) then
			splash_active = false
			ui.loadPopup("f.new")
			ui.preview_palette_enabled = false
			ui.context_menu = {}
			ui.title_active = false
			ui_active = true
		end
	
	end
	
	if mouse_switch == _PRESS then
		
		if vertex_selection[1] ~= nil or shape_selection[1] ~= nil then
		
			local raw_x, raw_y = love.mouse.getX(), love.mouse.getY()
			
			if (raw_x < 64) or (raw_x > screen_width - 208) or (raw_y < 58) then
				selection_and_ui_active = true
			end
		
		end
	
	end
	
	if (ui.popup[1] == nil) and (ui.context_menu[1] == nil) and (ui.active_textbox == "") and mouse_switch == _OFF and ui.textbox_selection_origin ~= "rename" then
	
		if num_1_key == _PRESS then
			ui.pickColorButton()
			ui_active = true
		end
		
		if num_2_key == _PRESS then
			ui.zoomButton()
			ui_active = true
		end
		
		if num_3_key == _PRESS then
			ui.gridButton()
			ui_active = true
		end
		
		if num_4_key == _PRESS then
			ui.selectionButton(true, true)
			ui_active = true
		end
		
		if num_5_key == _PRESS then
			ui.previewButton()
			ui_active = true
		end
		
		if num_6_key == _PRESS then
			ui.shapeSelectButton()
			ui_active = true
		end
		
		if num_7_key == _PRESS then
			ui.triangleButton()
			ui_active = true
		end
		
		if num_8_key == _PRESS then
			ui.ellipseButton()
			ui_active = true
		end
		
		if num_9_key == _PRESS then
			ui.artboardButton()
			ui_active = true
		end
		
		if input.ctrlCombo(k_key) then
			ui.layerAddButton()
		end
		
		if input.ctrlCombo(j_key) and polygon.data[tm.polygon_loc] ~= nil then
			storeMovedVertices()
			vertex_selection_mode = false
			vertex_selection = {}

			storeMovedShapes()
			shape_selection_mode = false
			shape_selection = {}
			multi_shape_selection = false

			ui.layerCloneButton(true)

			ui.lyr_scroll_percent = 0
		end
		
		if input.ctrlCombo(delete_key) and (#ui.layer > 1) then
			ui.layerDeleteButton()
		end
		
		if f2_key == _PRESS then
			ui.layerRenameButton()
		end
	
	end
	
	ui_on_mouse_up = (ui_active == true) and (mouse_switch == _OFF)

	local ignore_click_from_preview = false
		
	if ui.preview_active then
		local uimx, uimy = love.mouse.getX(), love.mouse.getY()
		local upx, upy, upw, uph = ui.preview_x, ui.preview_y, ui.preview_w, ui.preview_h
		
		if uimx >= upx and uimx <= upx + upw and uimy >= upy and uimy <= upy + uph then
			ignore_click_from_preview = true
		end
	end
	
	if ui.popup[1] == nil and document_w ~= 0 and ui.textbox_selection_origin ~= "rename" then
	
	if shape_grabber and not select_grabber and artboard.active == false and not zoom_grabber and not color_grabber and ((ui_active == false) or (ui_off_mouse_down)) then
	
		if last_shape_grabbed ~= -1 then
			double_click_timer = double_click_timer + (60 * dt)
			
			if double_click_timer > 30 then
				last_shape_grabbed = -1
				double_click_timer = 0
			end
			
		end
	
		if love.mouse.getCursor() == nil then
			love.mouse.setCursor(cursor_shape)
		end
		
		if polygon.data[tm.polygon_loc] ~= nil and input.ctrlCombo(a_key) then
			
			editorSelectAllShapes()
		
		end
	
		if (mouse_switch == _PRESS) and not ignore_click_from_preview then
		
			local use_shape_sel = shape_selection[1] ~= nil
			local test_x, test_y = mx - pixelFloor(camera_x), my - pixelFloor(camera_y)
			local test_hit_polygon = polygon.click(test_x, test_y, use_shape_sel)
			local test_double_click = polygon.click(test_x, test_y, false)
			
			selection_mouse_x = test_x
			selection_mouse_y = test_y
			
			if test_double_click ~= -1 then
				local old_shape = last_shape_grabbed
				last_shape_grabbed = test_double_click
				if last_shape_grabbed ~= old_shape then
					double_click_timer = 0
				end
				
				if double_click_timer > 0 and double_click_timer < 14 then
					ui.shapeSelectButton()
				
					ui.swapLayer(test_double_click, false)
					
					last_shape_grabbed = -1
					double_click_timer = 0
					test_hit_polygon = -1
					ui_active = true
				else
					double_click_timer = 0
				end
			end
			
			if test_double_click == -1 then
				last_shape_grabbed = -1
				double_click_timer = 0
			end
			
			if test_hit_polygon ~= -1 then
			
				local allow_multi_select = input.shiftEither()
				if allow_multi_select then
					multi_shape_selection = true
				end
				
				if shape_selection[1] == nil or allow_multi_select then
					local copy_shape = {}
					copy_shape.index = test_hit_polygon
					copy_shape.x = 0
					copy_shape.y = 0
					table.insert(shape_selection, copy_shape)
					shape_selection_mode = true
				end
			end
			
			mouse_x_offset, mouse_y_offset = -selection_mouse_x, -selection_mouse_y
			
		end
		
		if mouse_switch == _ON and selection_and_ui_active == false then
		
			calc_mouse_x, calc_mouse_y = mx + mouse_x_offset, my + mouse_y_offset
		
			if shape_selection[1] ~= nil then
			
				local cx, cy
				if ui.toolbar[ui.toolbar_grid].active == false and grid_snap then
					cx = ((math.floor((calc_mouse_x - camera_x) / grid_w) * grid_w) + (grid_x % grid_w))
					cy = ((math.floor((calc_mouse_y - camera_y) / grid_h) * grid_h) + (grid_y % grid_h))
				else
					cx = calc_mouse_x - pixelFloor(camera_x)
					cy = calc_mouse_y - pixelFloor(camera_y)
				end
				
				local n = 1
				while n <= #shape_selection do
				
					local shape_index = ui.layer[shape_selection[n].index].count
					local o = 1
					local this_shape = polygon.data[shape_index].raw
					while o <= #this_shape do
						local pp = this_shape[o]
						pp.x = pp.x + cx
						pp.y = pp.y + cy
						
						o = o + 1
					end
					
					shape_selection[n].x = shape_selection[n].x + cx
					shape_selection[n].y = shape_selection[n].y + cy
					
					n = n + 1
				end
				
				local test_x, test_y = 0,0
				if ui.toolbar[ui.toolbar_grid].active == false and grid_snap then
					test_x = ((math.floor((mx - camera_x) / grid_w) * grid_w) + (grid_x % grid_w))
					test_y = ((math.floor((my - camera_y) / grid_h) * grid_h) + (grid_y % grid_h))
				else
					test_x, test_y = mx - pixelFloor(camera_x), my - pixelFloor(camera_y)
				end
				
				mouse_x_offset, mouse_y_offset = -test_x, -test_y
			
			end
		
		end
		
		if mouse_switch == _RELEASE then
		
			line_active = false
			line_disable = false
			
			if selection_and_ui_active then
				selection_and_ui_active = false
			end
		
			storeMovedShapes()
		
			if not multi_shape_selection then
				shape_selection_mode = false
				shape_selection = {}
			end
			
		end
		
		if mouse_switch == _OFF and ((hz_dir * hz_key ~= 0) or (vt_dir * vt_key ~= 0)) and shape_selection_mode and ui.active_textbox == "" then
			
			if shape_selection[1] ~= nil then
				
				local cx, cy
				
				if ui.toolbar[ui.toolbar_grid].active == false and grid_snap then
					cx, cy = (hz_dir * hz_key * grid_w), (-vt_dir * vt_key * grid_h)
				else
					cx, cy = (hz_dir * hz_key), (-vt_dir * vt_key)
				end
				
				arrow_key_selection = true
				
				local n = 1
				while n <= #shape_selection do
				
					local shape_index = ui.layer[shape_selection[n].index].count
					local o = 1
					local this_shape = polygon.data[shape_index].raw
					while o <= #this_shape do
						local pp = this_shape[o]
						pp.x = pp.x + cx
						pp.y = pp.y + cy
						
						o = o + 1
					end
					
					shape_selection[n].x = shape_selection[n].x + cx
					shape_selection[n].y = shape_selection[n].y + cy
					
					n = n + 1
				end
			
			end

		end

		if ((hz_dir == 0) and (vt_dir == 0)) and arrow_key_selection then
			storeMovedShapes()
			arrow_key_selection = false
		end
	
	end
	
	if mouse_switch == _PRESS and ignore_click_from_preview and vertex_selection_mode then
		lock_preview_vertices = true
	end
	
	if artboard.active == false and ((ui_active == false) or (ui_off_mouse_down)) then
	
		if shape_grabber == false and not select_grabber and not zoom_grabber and not color_grabber then
	
			if polygon.data[tm.polygon_loc] ~= nil and input.ctrlCombo(a_key) and vertex_selection_mode == false then
			
				editorSelectAll()
			
			end
			
			if mouse_switch == _PRESS then
			
				-- Create a new shape if one doesn't exist
				if polygon.data[tm.polygon_loc] == nil then
					local new_col = {palette.active[1], palette.active[2], palette.active[3], palette.active[4]}
					polygon.new(tm.polygon_loc, new_col, polygon.kind, true)
				end
				
				selection_mouse_x = mx - pixelFloor(camera_x)
				selection_mouse_y = my - pixelFloor(camera_y)
				
				-- Test if we are placing a vertex or moving a vertex
				polygon.calcVertex(selection_mouse_x, selection_mouse_y, tm.polygon_loc, not ui.toolbar[ui.toolbar_grid].active)
				
				if vertex_selection_mode and vertex_selection[1] ~= nil then
					
					local i
					for i = 1, #vertex_selection do
						local vert_copy = vertex_selection[i].index
						vertex_selection[i].x = polygon.data[tm.polygon_loc].raw[vert_copy].x
						vertex_selection[i].y = polygon.data[tm.polygon_loc].raw[vert_copy].y
					end
					
					mouse_x_offset, mouse_y_offset = vertex_selection[1].x - selection_mouse_x, vertex_selection[1].y - selection_mouse_y
					
				end
			
			end
			
			if mouse_switch == _ON and selection_and_ui_active == false and lock_preview_vertices == false then
			
				ui_off_mouse_down = true
			
				local i
				local calc_mouse_x, calc_mouse_y
				
				if not vertex_selection_mode then
					calc_mouse_x, calc_mouse_y = mx, my
				else
					calc_mouse_x, calc_mouse_y = mx + mouse_x_offset, my + mouse_y_offset
				end
				
				if polygon.data[tm.polygon_loc] ~= nil and polygon.line and #vertex_selection == 0 and (ui_active == false) then
				
					local grid_is_on = ui.toolbar[ui.toolbar_grid].active == false and grid_snap
				
					local lx, ly
					if grid_is_on then
						lx = ((math.floor((calc_mouse_x - camera_x) / grid_w) * grid_w) + (grid_x % grid_w))
						ly = ((math.floor((calc_mouse_y - camera_y) / grid_h) * grid_h) + (grid_y % grid_h))
					else
						lx = calc_mouse_x - pixelFloor(camera_x)
						ly = calc_mouse_y - pixelFloor(camera_y)
					end
				
					local mouse_to_last_line = lume.distance(line_x, line_y, lx, ly, true)
					
					if mouse_to_last_line >= polygon.thickness * polygon.thickness and not line_disable then
						
						-- Do first when using line tool
						if line_active == false then
						
							if polygon.data[tm.polygon_loc].raw[1] == nil then
								-- Create a new line
								polygon.beginLine(tm.polygon_loc, line_x, line_y, lx, ly, true)
								line_active = true
								line_x, line_y = lx, ly
							else
							
								-- Detect where to place a new line
								local temp_max_dist = polygon.thickness * polygon.thickness * polygon.thickness * 7
								local larger_grid = math.max(grid_w * grid_w, grid_h * grid_h)
								--print(mouse_to_last_line, temp_max_dist, larger_grid)
								
								if (mouse_to_last_line <= temp_max_dist) or ((mouse_to_last_line <= larger_grid) and grid_is_on) then
									line_active = true
								else
									-- Find closest line segment to mouse
									local closest_line_to_mouse = nil
									local closest_line = -1
									
									local j = 1
									if polygon.data[tm.polygon_loc] ~= nil then
									
										local closest_dist = -1
										
										-- Retrieve closest line segment to the new point
										for j = 1, #polygon.data[tm.polygon_loc].cache do
										
											local cc = polygon.data[tm.polygon_loc].cache[j]
											-- Line cache stores the lines index, so we need to get the actual x1, y1, x2, y2 of the line
											local xa, ya, xb, yb = polygon.data[tm.polygon_loc].raw[cc[1]].x, polygon.data[tm.polygon_loc].raw[cc[1]].y, polygon.data[tm.polygon_loc].raw[cc[2]].x, polygon.data[tm.polygon_loc].raw[cc[2]].y
											-- Calculate line distance to mouse position
											local dp = (math.abs(((xa + xb)/2) - lx) + math.abs(((ya + yb)/2) - ly))
											
											if closest_dist == -1 or dp < closest_dist then
												closest_line = j
												closest_dist = dp
											end
										
										end
										
										closest_line_to_mouse = polygon.data[tm.polygon_loc].cache[closest_line]
									
									end
									
									if closest_line_to_mouse ~= nil then
									
										local la, lb = closest_line_to_mouse[1], closest_line_to_mouse[2]
										local clone = polygon.data[tm.polygon_loc]
										local segment_dist = lume.distance(clone.raw[la].x, clone.raw[la].y, clone.raw[lb].x, clone.raw[lb].y, false)
										local pthick = polygon.thickness
										local size_variation = 1
										
										if (segment_dist <= pthick + size_variation) and (segment_dist >= pthick - size_variation) then
											-- jmp back to that location instead of making a new one
											print("sounds good")
										else
										
											-- Find the point where the mouse ray intersects the triangle side
											local ax, ay, bx, by = clone.raw[la].x, clone.raw[la].y, clone.raw[lb].x, clone.raw[lb].y
											local ph, pk = 0,0
											
											local horizontal_line_test = (ay ~= by)
											local vertical_line_test = (ax ~= bx)
										
											if horizontal_line_test and vertical_line_test then -- It's not a horizontal or vertical line
												local ab_slope = (ay - by) / (ax - bx)
												local ab_b = ay - (ab_slope * ax)
												local m_slope = -1/ab_slope
												local m_b = ly - (m_slope * lx)
												
												ph = (ab_b - m_b) / (m_slope - ab_slope)
												pk = (ab_slope * ph) + ab_b
											elseif horizontal_line_test then -- It's a vertical line
												ph = ax
												pk = ly
											else -- It's a horizontal line
												ph = lx
												pk = ay
											end
											
											-- Make two adjacent points
											local temp_thick = (pthick/2)
											local seg_ang = -lume.angle(ax, ay, bx, by)
											local pax, pay = ph + polygon.lengthdir_x(-temp_thick, seg_ang), pk + polygon.lengthdir_y(-temp_thick, seg_ang)
											local pbx, pby = ph + polygon.lengthdir_x(temp_thick, seg_ang), pk + polygon.lengthdir_y(temp_thick, seg_ang)
										
											print("extending")
											
											-- new research suggests reversing pax,pay with pbx, pby results in inverting the broken rotated thingy
											-- maybe we could detect and flip?
											
											polygon.addVertex(pbx, pby, tm.polygon_loc, closest_line, false, false)
											polygon.addVertex(pax, pay, tm.polygon_loc, #polygon.data[tm.polygon_loc].cache, false, false)
											
											polygon.beginLine(tm.polygon_loc, ph, pk, lx, ly, false)
											line_active = true
											line_x, line_y = lx, ly
											
											--line_disable = true
										end
									
									else
										line_disable = true
									end
									
								end
								
							end
							
						else -- Do while line tool is _ON
						
							local line_copy = polygon.data[tm.polygon_loc].raw[#polygon.data[tm.polygon_loc].raw]
							polygon.beginLine(tm.polygon_loc, line_copy.x, line_copy.y, lx, ly, false)
							line_x, line_y = lx, ly
						
						end
						
						--line_x, line_y = lx, ly
					
					end
				
				end
				
				-- If a point is selected, have it follow the mouse
				for i = 1, #vertex_selection do
				
					local cx, cy
					local pp = polygon.data[tm.polygon_loc].raw[vertex_selection[i].index]
					local pp_one = polygon.data[tm.polygon_loc].raw[vertex_selection[1].index]
					
					if i == 1 then
					
						if ui.toolbar[ui.toolbar_grid].active == false and grid_snap then
							cx = ((math.floor((calc_mouse_x - camera_x) / grid_w) * grid_w) + (grid_x % grid_w))
							cy = ((math.floor((calc_mouse_y - camera_y) / grid_h) * grid_h) + (grid_y % grid_h))
						else
							cx = calc_mouse_x - pixelFloor(camera_x)
							cy = calc_mouse_y - pixelFloor(camera_y)
						end
						
						-- Move verices by offset of selection_mouse_*
						pp.x, pp.y = cx, cy
					
					else
					
						pp.x, pp.y = vertex_selection[i].x + (pp_one.x - vertex_selection[1].x), vertex_selection[i].y + (pp_one.y - vertex_selection[1].y)
					
					end
				
				end
			
			end
			
			if mouse_switch == _RELEASE then
			
				line_active = false
				line_disable = false
			
				lock_preview_vertices = false
			
				if selection_and_ui_active then
					selection_and_ui_active = false
				end
				
				ui_off_mouse_down = false
			
				-- If a point was selected, add TM_MOVE_VERTEX to time machine
				storeMovedVertices()
			
				if vertex_selection_mode == false then
					vertex_selection = {}
				end
				
			end
			
			if mouse_switch == _OFF and ((hz_dir * hz_key ~= 0) or (vt_dir * vt_key ~= 0)) and vertex_selection_mode and ui.active_textbox == "" then
			
				local i
				
				for i = 1, #vertex_selection do
				
					local pp = polygon.data[tm.polygon_loc].raw[vertex_selection[i].index]
					local pp_one = polygon.data[tm.polygon_loc].raw[vertex_selection[1].index]
					
					-- Check if we're performing a special action on a line
					if (lctrl_key == _ON or rctrl_key == _ON) then -- and selection contains line
						
						if vertex_selection[i].t ~= nil then
							
							vertex_selection[i].t = math.max(math.min(vertex_selection[i].t + (vt_dir * vt_key), polygon.max_thickness), polygon.min_thickness)
							vertex_selection[i].a = vertex_selection[i].a + ((math.pi/180) * -hz_dir * hz_key)
							
							-- Keep angle in range of 0-359 deg
							if vertex_selection[i].a > math.pi*2 then vertex_selection[i].a = vertex_selection[i].a - math.pi * 2 end
							if vertex_selection[i].a < 0 then vertex_selection[i].a = vertex_selection[i].a + math.pi * 2 end
							
							vertex_selection[i].x = pixelFloor(vertex_selection[i - 1].x + polygon.lengthdir_x(vertex_selection[i].t, vertex_selection[i].a))
							vertex_selection[i].y = pixelFloor(vertex_selection[i - 1].y + polygon.lengthdir_y(vertex_selection[i].t, vertex_selection[i].a))
							pp.x, pp.y = vertex_selection[i].x, vertex_selection[i].y
							
						end
					
					else
					
						if i == 1 then
							
							if arrow_key_selection == false then
							
								local j
								for j = 1, #vertex_selection do
									local vert_copy = vertex_selection[j].index
									vertex_selection[j].x = polygon.data[tm.polygon_loc].raw[vert_copy].x
									vertex_selection[j].y = polygon.data[tm.polygon_loc].raw[vert_copy].y
								end
								
								arrow_key_selection = true
								
							end
							
							if ui.toolbar[ui.toolbar_grid].active == false and grid_snap then
								pp.x, pp.y = pp.x + (hz_dir * hz_key * grid_w), pp.y + (-vt_dir * vt_key * grid_h)
							else
								pp.x, pp.y = pp.x + (hz_dir * hz_key), pp.y + (-vt_dir * vt_key)
							end
						
						else
						
							pp.x, pp.y = vertex_selection[i].x + (pp_one.x - vertex_selection[1].x), vertex_selection[i].y + (pp_one.y - vertex_selection[1].y)
						
						end
					
					end
				
				end
			
			end
			
			if ((hz_dir == 0) and (vt_dir == 0)) and arrow_key_selection then
				storeMovedVertices()
				arrow_key_selection = false
			end
			
		end
		
	else -- artboard is active
	
		if ((ui_active == false) or (ui_off_mouse_down)) then
		
			local ax, ay = mx - camera_x, my - camera_y
		
			if mouse_switch == _PRESS or rmb_switch == _PRESS then
				-- Check if mouse press was on the workable canvas
				artboard_is_drawing = (ax >= 0 and ax <= document_w) and (ay >= 0 and ay <= document_h)
			end
		
			if artboard_is_drawing then
				if mouse_switch == _ON then
					if artboard.canvas ~= nil then
						ui_off_mouse_down = true
						artboard.add(math.floor(mx - camera_x), math.floor(my - camera_y), math.floor(mouse_x_previous - camera_x), math.floor(mouse_y_previous - camera_y))
					end
				end
				
				if rmb_switch == _ON then
					if artboard.canvas ~= nil then
						ui_off_mouse_down = true
						artboard.add(math.floor(mx - camera_x), math.floor(my - camera_y), math.floor(mouse_x_previous - camera_x), math.floor(mouse_y_previous - camera_y), true)
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
		
				if undo_key == _PRESS then
					artboard.undo()
				end
				
				if input.ctrlCombo(y_key) then
					artboard.redo()
				end
				
				if scz_key == _PRESS then
					artboard.redo()
				end
				
			end
		
		end
		
	end
	
	if mouse_switch == _OFF and artboard.active == false and ((ui_active == false) or (ui_on_mouse_up)) then
	
		if input.ctrlCombo(d_key) and shape_selection_mode then
			shape_selection_mode = false
			shape_selection = {}
			multi_shape_selection = false
		end
	
		if input.ctrlCombo(d_key) and vertex_selection_mode then
			vertex_selection_mode = false
			vertex_selection = {}
		end
	
		if undo_key == _PRESS then
			editorUndo()
		end
		
		if input.ctrlCombo(y_key) then
			editorRedo()
		end
		
		if scz_key == _PRESS then
			editorRedo()
		end
		
		if document_w ~= 0 and input.ctrlCombo(s_key) then
			
			if fs_enable_save then
			
				-- Only make a save file if the vector data has been edited
				if tm.data[1] ~= nil then
					local test_save = export.test(OVERWRITE_LOL)
					if test_save and can_overwrite == false then
						ui.loadPopup("f.overwrite")
					else
						export.saveLOL()
						export.saveArtboard()
						can_overwrite = true
					end
				end
			
			end
			
		end
	
	end
	
	if ((ui_active == false) or (ui_on_mouse_up)) then
	
		if artboard.active then
			
			if artboard.active then
				palette.activeIsEditable = false
			end
			
			if input.ctrlCombo(r_key) then
				artboard.clear()
			end
		
		end
		
		local smx, smy = love.mouse.getX(), love.mouse.getY()
		local rx, ry, rw, rh = ui.preview_x, ui.preview_y, ui.preview_w, ui.preview_h
		local bx, by, bw, bh = rx + 3, ry + 27, rw - 5, rh - 29 - 28
		if ui.preview_active == false or (not (smx >= bx and smx <= bx + bw and smy >= by and smy <= by + bh)) then
			if mouse_wheel_y ~= 0 then
				local temp_zoom = camera_zoom + (mouse_wheel_y * 0.1 * 60 * dt)
				local larger_window_bound = math.max(document_w, document_h)
				temp_zoom = math.max(temp_zoom, 0.05)
				temp_zoom = math.min(temp_zoom, math.min(99999/larger_window_bound, 999.99))
				updateCamera(screen_width, screen_height, camera_zoom, temp_zoom)
			end
		end

	end
	
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

	if mouse_wheel_x == 0 and mouse_wheel_y == 0 then

		if middle_switch == _PRESS then
			middle_x = mx
			middle_y = my
		end

		if middle_switch == _ON then
			camera_x = camera_x + mx - middle_x
			camera_y = camera_y + my - middle_y

			middle_x = mx
			middle_y = my
		end

	else
		middle_switch = _RELEASE
	end
	
	if camera_moved and camera_round == 0 and w_key == _OFF and s_key == _OFF and a_key == _OFF and d_key == _OFF then
		camera_x = math.floor(camera_x)
		camera_y = math.floor(camera_y)
		camera_moved = false
	end
	
	if camera_moved and camera_round > 0 then
		camera_round = camera_round - 1
		if camera_round == 0 then
			camera_x = math.floor(camera_x)
			camera_y = math.floor(camera_y)
		end
	end
	
	if input.ctrlCombo(g_key) then
		resetCamera()
	end
	-- End camera controls
	
	end
	
	if ui_active == false and ui.popup[1] == nil and document_w ~= 0 and mouse_switch == _OFF and rmb_switch == _OFF and autosave.timer == 0 then
	
		if fs_enable_save then
	
			if tm.data[1] ~= nil then
				export.saveLOL(true, false)
			end
			
			autosave.timer = autosave.INTERVAL
		
		end
	
	end
	
	mouse_wheel_x, mouse_wheel_y = 0, 0

end

function love.draw()

	local mx, my = math.floor(love.mouse.getX() / camera_zoom), math.floor(love.mouse.getY() / camera_zoom)
	
	lg.setColor(c_background)
	lg.rectangle("fill", 0, 0, screen_width, screen_height)
	
	lg.push()
	lg.translate(math.floor(camera_x * camera_zoom), math.floor(camera_y * camera_zoom))
	
	if document_w ~= 0 then
	
		if artboard.draw_top and artboard.canvas ~= nil then
			local artcol = {1, 1, 1, artboard.opacity}
			lg.setColor(artcol)
			lg.draw(artboard.canvas, 0, 0, 0, camera_zoom)
		end
	
		polygon.draw(true)
	
		if not artboard.draw_top and artboard.canvas ~= nil then
			local artcol = {1, 1, 1, artboard.opacity}
			
			lg.setColor(artcol)
			lg.draw(artboard.canvas, 0, 0, 0, camera_zoom)
		end
	
		if ui.toolbar[ui.toolbar_grid].active == false then
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
	
	-- Draw lines while editing a shape
	local polygons_exist = polygon.data[tm.polygon_loc] ~= nil
	local mouse_down     = mouse_switch == _ON
	local verts_selected = vertex_selection[1] ~= nil and #vertex_selection == 1
	
	if polygons_exist and mouse_down and verts_selected then
		local i = 1
		local clone = polygon.data[tm.polygon_loc].raw
		
		while i <= #clone do
		
			lg.setColor(palette.lines)
		
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
		
			lg.setColor(palette.lines)
			local aa, bb = polygon.data[tm.polygon_loc].cache[i][1], polygon.data[tm.polygon_loc].cache[i][2]
			local line_a, line_b = polygon.data[tm.polygon_loc].raw[aa], polygon.data[tm.polygon_loc].raw[bb]
			local sc = camera_zoom
			lg.line(line_a.x * sc, line_a.y * sc, line_b.x * sc, line_b.y * sc)
		
		end
	
	end
	
	if polygons_exist and shape_selection[1] ~= nil then
	
		local n = 1
		while n <= #shape_selection do
		
			local shape_index = ui.layer[shape_selection[n].index].count
			
			if polygon.data[shape_index].kind == "polygon" then
			
				local o = 1
				local this_shape = polygon.data[shape_index].cache
				while o <= #this_shape do
					
					lg.setColor(c_white)
					local aa, bb = this_shape[o][1], this_shape[o][2]
					local line_a, line_b = polygon.data[shape_index].raw[aa], polygon.data[shape_index].raw[bb]
					local sc = camera_zoom
					lg.line(line_a.x * sc, line_a.y * sc, line_b.x * sc, line_b.y * sc)
					
					lg.setShader(h_out3)
					lg.setColor(c_black)
					lg.line(line_a.x * sc, line_a.y * sc, line_b.x * sc, line_b.y * sc)
					lg.setShader()
					
					o = o + 1
				end
			
			elseif polygon.data[shape_index].kind == "ellipse" then
			
				local clone = polygon.data[shape_index]
			
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
						
						lg.setColor(c_white)
						lg.line((cx + cxx2) * sc, (cy + cyy2) * sc, (cx + cxx3) * sc, (cy + cyy3) * sc)
						
						lg.setShader(h_out3)
						lg.setColor(c_black)
						lg.line((cx + cxx2) * sc, (cy + cyy2) * sc, (cx + cxx3) * sc, (cy + cyy3) * sc)
						lg.setShader()
						
						v = v + cinc
						k = k + 1
					
					end
				
				end
			
			end
			
			n = n + 1
		end
	
	end
	
	-- Draw spr_vertex on vertex locations
	if polygon.data[tm.polygon_loc] ~= nil and artboard.active == false and ui.popup[1] == nil and shape_grabber == false then
		
		local clone = polygon.data[tm.polygon_loc]
		
		lg.setColor({1, 1, 1, 1})
		
		local j = 1
		while j <= #clone.raw do
			
			local vertex_radius = 100 / camera_zoom
			local tx, ty = clone.raw[j].x, clone.raw[j].y
			local sc = camera_zoom
			local if_line_is_valid = true
			if clone.raw[j].l ~= nil and clone.raw[j].l == "-" then
				if_line_is_valid = false
			end

			if ((#clone.raw < 3) or (lume.distance(mx - math.floor(camera_x), my - math.floor(camera_y), tx, ty) < vertex_radius) or (select_grabber)) and if_line_is_valid then
				lg.draw(spr_vertex, math.floor(tx * sc) - 5, math.floor(ty * sc) - 5)
			end
			
			j = j + 1
		
		end
		
	end
	
	if polygon.data[tm.polygon_loc] ~= nil and artboard.active == false and ui.popup[1] == nil and #vertex_selection >= 1 and shape_grabber == false then
	
		local clone = polygon.data[tm.polygon_loc]
		
		lg.setColor({1, 1, 1, 1})
		
		local j = 1
		while j <= #vertex_selection do
			
			local tx, ty = clone.raw[vertex_selection[j].index].x, clone.raw[vertex_selection[j].index].y
			local sc = camera_zoom
			
			lg.draw(spr_vertex, math.floor(tx * sc) - 5, math.floor(ty * sc) - 5)
			
			j = j + 1
		
		end
	
	end
	
	if select_grabber and box_selection_active then
	
		local sx, sy, sx2, sy2 = (box_selection_x - camera_x) * camera_zoom, (box_selection_y - camera_y) * camera_zoom, (mx - camera_x) * camera_zoom, (my - camera_y) * camera_zoom
		if sx2 < sx then sx, sx2 = sx2, sx end
		if sy2 < sy then sy, sy2 = sy2, sy end
		lg.setColor(c_black)
		drawRect(0, sx, sy, sx2 - sx, sy2 - sy)
		lg.setColor(c_white)
		drawRect(1, sx, sy, sx2 - sx, sy2 - sy)
	
	end
	
	lg.pop()
	
	ui.draw()
	
	if splash_active then
	
		lg.draw(icon_splash, math.floor((screen_width-500)/2), math.floor((screen_height-320)/2))
	
	end

end

function drawRect(s,x,y,w,h)
	local s1, s2 = h_out, v_out
	if s == 1 then
		s1, s2 = h_out2, v_out2
	end
	lg.setShader(s1)
	lg.rectangle("fill",x,y,w-1,1)
	lg.rectangle("fill",x+1,y+h-1,w-1,1)
	lg.setShader(s2)
	lg.rectangle("fill",x,y+1,1,h-1)
	lg.rectangle("fill",x+w-1,y,1,h-1)
	lg.setShader()
end

function love.quit()
	if fs_enable_save then
	
		if not safe_to_quit then
			is_trying_to_quit = true
			overwrite_type = OVERWRITE_LOL
			ui.loadPopup("f.exit")
		end
	
	else
	
		safe_to_quit = true
	
	end

	if ui.popup[1] == nil and safe_to_quit then
		recursivelyDelete("cache")
	end
	
	return not (ui.popup[1] == nil and safe_to_quit)
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