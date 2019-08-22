local ui = {}

ui.title = {}

ui.context_menu = {}
ui.context_x = 0
ui.context_y = 0
ui.context_w = 0
ui.context_h = 0

ui.title_active = false
ui.title_x = 0
ui.title_y = 0
ui.title_w = 0
ui.title_h = 0

ui.popup = {}
ui.popup_x = 0
ui.popup_y = 0
ui.popup_w = 0
ui.popup_h = 0
ui.popup_x_offset = 0

ui.keyboard_test = ""
ui.keyboard_last = ""
ui.keyboard_timer = 0
ui.keyboard_timer_hit = false

ui.input_cursor = 0
ui.input_cursor_visible = false

ui.sel_start = ""
ui.sel_type = ""

ui.allow_keyboard_input = false

ui.popup_sel_a = 0
ui.popup_sel_b = 0
ui.popup_enter = false

ui.palette_mode = "RGB"
ui.palette_text = 0
ui.palette_slider = 0
ui.palette = {}

ui.layer = {}
ui.lyr_scroll_percent = 0
ui.lyr_scroll = false
ui.lyr_dir = ""
ui.lyr_spd = 1
ui.lyr_timer = 0
ui.lyr_clicked = 0
ui.lyr_click_y = 0

function ui.init()
	-- Add palette sliders
	ui.addPS("R")
	ui.addPS("G")
	ui.addPS("B")
	ui.addPS("H")
	ui.addPS("S")
	ui.addPS("L")

	-- Add title bar items
	ui.addTitle("File",     ".file")
	ui.addTitle("Edit",     ".edit")
	ui.addTitle("Search",   ".search")
	ui.addTitle("View",     ".view")
	ui.addTitle("Encoding", ".encoding")
end

function ui.loadCM(x, y, ref)

	ui.context_menu = {}
	
	if ref == ".file" then
	
		ui.addCM("New",         true, "f.new")
		ui.addCM("Open...",    false, "f.open")
		ui.addCMBreak()
		ui.addCM("Close",      false, "f.close")
		ui.addCM("Save",       false, "f.save")
		ui.addCM("Save As...", false, "f.as")
		ui.addCMBreak()
		ui.addCM("Exit",       false, "f.exit")
		ui.generateCM(x, y)
	
	elseif ref == ".edit" then
		ui.addCM("Bum", true, "e.new")
		ui.generateCM(x, y)
	elseif ref == ".search" then
		ui.addCM("On", true, "s.new")
		ui.generateCM(x, y)
	elseif ref == ".view" then
		ui.addCM("A", true, "v.new")
		ui.generateCM(x, y)
	elseif ref == ".encoding" then
		ui.addCM("Crumb!!!", true, "en.new")
		ui.generateCM(x, y)
	end

end

function ui.loadPopup(ref)

	if ui.popup[1] ~= nil and ui.popup[1][1].kind == ref then
		-- Don't make duplicate popup
	else
		
		ui.popup = {}
		
		if ref == "f.new" then
			ui.addPopup("New document", "f.new", "col")
			ui.addPopup("Name:", "text", "col")
			ui.addPopup("Untitled", "textbox", "row")
			ui.addPopup("Width:", "text", "col")
			ui.addPopup("512", "number", "row")
			ui.addPopup("Height:", "text", "col")
			ui.addPopup("512", "number", "row")
			ui.addPopup("OK", "ok", "col")
			ui.addPopup("Cancel", "cancel", "row")
			ui.generatePopup()
		end
	
	end

end

function ui.addTitle(name, ref)

	local item = {}
	item.name = name
	item.ref = ref
	
	table.insert(ui.title, item)

end

-- Context menu
function ui.addCM(name, active, ref)

	local item = {}
	item.name = name
	item.ref = ref
	item.active = active
	
	table.insert(ui.context_menu, item)

end

-- Palette slider
function ui.addPS(name)

	local item = {}
	item.name = name
	item.value = "0"
	
	table.insert(ui.palette, item)

end

function ui.addPopup(name, kind, loc)

	local col, row
	
	if (loc == "col") then
	
		-- Always adds a new column
		col = #ui.popup + 1
		
		if (ui.popup[col] == nil) then
			ui.popup[col] = {}
		end
		
	elseif (loc == "row") then
	
		col = #ui.popup
		
		-- Add the first column if no columns exist
		if (ui.popup[col] == nil) then
			ui.popup[col + 1] = {}
			col = col + 1
		end
		
	end
	
	row = #ui.popup[col] + 1
	
	if (ui.popup[col][row] == nil) then
		ui.popup[col][row] = {}
	end
	
	ui.popup[col][row].name = name
	ui.popup[col][row].kind = kind

end

function ui.addCMBreak()

	local item = {}
	item._break = true
	table.insert(ui.context_menu, item)

end

function ui.addLayer()

	local layer = {}
	layer.visible = true
	
	if ui.layer[1] == nil then
		layer.count = 1
	else
		layer.count = #ui.layer + 1
	end
	
	layer.name = "Layer " .. layer.count
	
	table.insert(ui.layer, layer)

end

function ui.importLayer(v, n)

	local layer = {}
	layer.visible = v
	
	if ui.layer[1] == nil then
		layer.count = 1
	else
		layer.count = #ui.layer + 1
	end
	
	layer.name = n
	
	table.insert(ui.layer, layer)

end

function ui.generateCM(x, y)

	local i
	local h, w = 0, 0
	for i = 1, #ui.context_menu do
	
		-- If entry in the menu
		if ui.context_menu[i]._break == nil then
			w = math.max(w, font:getWidth(ui.context_menu[i].name))
			h = h + 22
		else -- If entry is a break
			h = h + 11
		end
	
	end
	
	ui.context_x = x
	ui.context_y = y
	ui.context_w = w + 110
	ui.context_h = h + 15

end

function ui.generatePopup()

	local i
	local w = 0
	local h = 28 * (#ui.popup + 1)
	for i = 2, #ui.popup do
	
		local temp_w = 0
		local j
		for j = 1, #ui.popup[i] do
		
			if ui.popup[i][j].kind == "text" then
				temp_w = temp_w + font:getWidth(ui.popup[i][j].name) + 6
			elseif ui.popup[i][j].kind == "textbox" then
				temp_w = temp_w + 251
			elseif ui.popup[i][j].kind == "number" then
				temp_w = temp_w + 46
			end
		
		end
		
		if temp_w > w then
			w = temp_w
		end
	
	end
	
	ui.popup_w = w + 120
	ui.popup_h = h
	
	ui.popup_x_offset = -(((ui.popup_w/2) + (w/2)) / 4)
	
	ui.popup_x = math.floor((screen_width / 2) - (ui.popup_w / 2))
	ui.popup_y = math.floor((screen_height / 2) - (ui.popup_h / 2))

end

function ui.popupLoseFocus(kind)
	
	if ui.popup_sel_a ~= 0 then 
	
	-- Reset value to previous value if textbox is empty
	local name = ui.popup[ui.popup_sel_a][ui.popup_sel_b]
	
	if name.name == "" then
		name.name = ui.sel_start
	end
	
	-- Don't let width or height be less than 8 when making a new document
	if kind == "f.new" then
		if name.kind == "number" then
			if tonumber(name.name) < 8 then
				name.name = "8"
			else
				name.name = tostring(tonumber(name.name))
			end
		end
	end
	
	end
	
	ui.popup_sel_a = 0
	ui.popup_sel_b = 0
	ui.sel_type = ""
	
end

function ui.keyboardHit(key)
	if ui.sel_type == "popup" then
	
		local this_menu = ui.popup[ui.popup_sel_a][ui.popup_sel_b]
		if string.len(key) == 1 then
		
			if ui.popup[1][1].kind == "f.new" then
			
				if this_menu.kind == "number" then
					if tonumber(key) ~= nil and string.len(this_menu.name) < 5 then
						this_menu.name = this_menu.name .. key
					end
				elseif string.len(this_menu.name) < 20 then
					this_menu.name = this_menu.name .. key
				end
				
			end
			
		else
			if (key == "backspace") then
				this_menu.name = string.sub(this_menu.name, 0, string.len(this_menu.name) - 1)
			elseif (key == "return") then
				ui.popupLoseFocus(ui.popup[1][1].kind)
				ui.keyboard_last = ""
				ui.keyboard_test = ""
				ui.popup_enter = true
			end
		end
	
	end
end

function ui.keyboardRepeat(dt)
	local hit, pause, pause2, repeater
	hit = 6
	pause = 35
	pause2 = pause + 2
	repeater = 2

	ui.keyboard_timer = ui.keyboard_timer + (1 * dt * 60)
	
	if (not ui.keyboard_timer_hit) and (ui.keyboard_timer > hit) then
		ui.keyboardHit(ui.keyboard_last)
		ui.keyboard_timer_hit = true
	end
	
	if ((ui.keyboard_timer > pause) and (ui.keyboard_timer < pause2)) or (ui.keyboard_timer > pause2 + repeater) then
		ui.keyboardHit(ui.keyboard_last)
		ui.keyboard_timer = pause2
	end
end

function ui.moveLayer(old, new)

	local lyr_copy = ui.layer[old]
	table.remove(ui.layer, old)
	table.insert(ui.layer, new, lyr_copy)

end

function ui.update(dt)

	local mx, my = love.mouse.getX(), love.mouse.getY()
	local ui_active = false
	local has_interaction = (mouse_switch == _PRESS or ui.context_menu[1] ~= nil)
	
	-- Check collision on title bar
	if my < 24 then
	
		-- Clear selection on interaction
		if has_interaction and #vertex_selection ~= 0 then
			vertex_selection = {}
		end
	
		local i
		local title_len = 12
		local hit_item = false
		for i = 1, #ui.title do
			
			local title_size = font:getWidth(ui.title[i].name)
			
			-- If mouse is on top of menu item
			if mx >= title_len - 4 and mx <= title_len + title_size + 3 then
			
				-- If menu item was interacted with
				if has_interaction then
					-- Close context menu if its already open
					if mouse_switch == _PRESS and ui.context_menu[1] ~= nil then
						ui.context_menu = {}
					else -- Otherwise, open the context menu
						ui.loadCM(title_len - 6, 24, ui.title[i].ref)
					end
				end
			
				-- Highlight portion of menu where the mouse is
				ui.title_active = true
				ui.title_x = title_len - 6
				ui.title_y = 2
				ui.title_w = title_size + 12
				ui.title_h = 21
				hit_item = true
			end
			
			title_len = title_len + title_size + 15
		end
		
		-- Remove menu selection if not touching a button on the menu
		if ui.context_menu[1] == nil and not hit_item then
			ui.title_active = false
		end
		
		ui_active = true
	
	elseif ui.context_menu[1] == nil then
		-- Remove menu selection when not highlighting the menu
		ui.title_active = false
	end
	-- End check collision on title bar
	
	-- Check collision on context menu
	if ui.context_menu[1] ~= nil then
		
		local mx_on_menu, my_on_menu
		local exit_cm = false
		
		mx_on_menu = (mx >= ui.context_x) and (mx <= ui.context_x + ui.context_w)
		my_on_menu = (my >= ui.context_y) and (my <= ui.context_y + ui.context_h)
		
		-- If context menu was interacted with
		if mx_on_menu and my_on_menu then
		
			if mouse_switch == _PRESS then
				local i
				local h = 0
				for i = 1, #ui.context_menu do
				
					-- If entry in the menu
					if ui.context_menu[i]._break == nil then
					
						local low = ui.context_y + h + 8
						local upp = low + 20
						
						if my >= low and my <= upp then
							if ui.context_menu[i].active then
								ui.loadPopup(ui.context_menu[i].ref)
							end
							exit_cm = ui.context_menu[i].active
						end
						
						h = h + 22
					else -- If entry is a break
						h = h + 11
					end
				end
			end
		
			ui_active = true
		end
		
		if exit_cm then
			ui.context_menu = {}
			ui.title_active = false
		end
	
	end
	
	ui.allow_keyboard_input = (ui.sel_type ~= "")
	
	-- Add keyboard input if interacting with a textbox
	if ui.allow_keyboard_input then
		-- Update cursor flashing
		ui.input_cursor = ui.input_cursor + (60 * dt)

		if ui.input_cursor > 37 then
			ui.input_cursor = 0
			ui.input_cursor_visible = not ui.input_cursor_visible
		end
	
		ui.keyboardRepeat(dt)
	end
	
	-- Copy and paste for palette
	if input.ctrlCombo(c_key) then
		local new_col = {palette.active[1], palette.active[2], palette.active[3], palette.active[4]}
		palette.copy = new_col
	end
	
	if input.ctrlCombo(v_key) and palette.canPaste and palette.copy ~= nil then	
		palette.colors[palette.slot + 1] = palette.copy
		palette.active = palette.colors[palette.slot + 1]
		palette.updateFromBoxes()
		
		local copy_again = palette.colors[palette.slot + 1]
		local new_col = {copy_again[1], copy_again[2], copy_again[3], copy_again[4]}
		palette.copy = new_col
	end
	
	-- Check collision of palette
	local psize = 16
	local palw = (13 * psize)
	local palx, paly = screen_width - palw, 26
	local palh = 300
	local mx_on_menu, my_on_menu
	mx_on_menu = (mx >= palx) and (mx <= palx + palw)
	my_on_menu = (my >= paly) and (my <= paly + palh)
	if mouse_switch == _PRESS and mx_on_menu and my_on_menu then
		
		if my >= 42 and my <= 42 + 18 then -- RGB/HSL buttons
			
			if mx >= palx - 4 + 8 and mx <= palx - 4 + 25 + 10 + 8 then
				ui.palette_mode = "RGB"
				palette.canPaste = false
			elseif mx >= palx + 36 + 8 and mx <= palx + 36 + 24 + 10 + 8 then
				ui.palette_mode = "HSL"
				palette.canPaste = false
			end
			
		elseif my > 181 and my < 181 + (psize * palette.h) then -- Color picker
			local raw_x = mx - palx - 8
			local raw_y = my - 181
			local sel_x, sel_y
			sel_x = math.floor(raw_x / 16)
			if sel_x > -1 and sel_x < 12 then
				sel_y = math.floor(raw_y / 16)
				local final_col = (sel_y * palette.w) + sel_x
				palette.slot = final_col
				
				if palette.active == palette.colors[final_col + 1] then
					palette.activeIsEditable = true
					
					if polygon.data[tm.polygon_loc] ~= nil then --and debug_mode ~= "artboard"
						tm.store(TM_CHANGE_COLOR, polygon.data[tm.polygon_loc].color, palette.active)
						tm.step()
						
						palette.startingColor = polygon.data[tm.polygon_loc].color
						
						local copy_col = {palette.active[1], palette.active[2], palette.active[3], palette.active[4]}
						polygon.data[tm.polygon_loc].color = copy_col
					end
				else
					palette.active = palette.colors[final_col + 1]
					palette.updateFromBoxes()
					palette.activeIsEditable = false
				end
				
				palette.canPaste = true
			end
		end
		
		-- Scroll bar
		local ix, iy = screen_width - 50, 52
		if mx >= ix - 147 and mx <= ix - 147 + 122 then
			local i
			for i = 1, 3 do
				local ypos = iy + 25 + (28 * (i - 1)) - 1
				if my >= ypos and my <= ypos + 21 then
					local hsl = 0
					if ui.palette_mode == "HSL" then hsl = 3 end
					ui.palette_slider = i + hsl
					palette.canPaste = false
					
					if palette.activeIsEditable and polygon.data[tm.polygon_loc] ~= nil then
						palette.startingColor = polygon.data[tm.polygon_loc].color
					end
					
				end
			end
		end
		
		ui_active = true
	end
	
	if mouse_switch == _ON and ui.palette_slider ~= 0 then
		local ix = screen_width - 50
		ui.palette[ui.palette_slider].value = math.floor(lume.clamp(mx - ix + 147, 0, 122)/122 * 255)
		if ui.palette_slider < 4 then
			palette.updateFromRGB()
		else
			palette.updateFromHSL()
		end
		
		if palette.activeIsEditable and polygon.data[tm.polygon_loc] ~= nil then
			polygon.data[tm.polygon_loc].color = palette.active
		end
		
	elseif mouse_switch == _RELEASE and ui.palette_slider ~= 0 then
		if palette.activeIsEditable and polygon.data[tm.polygon_loc] ~= nil then
			tm.store(TM_CHANGE_COLOR, palette.startingColor, palette.active)
			tm.step()
					
			local copy_col = {palette.active[1], palette.active[2], palette.active[3], palette.active[4]}
			polygon.data[tm.polygon_loc].color = copy_col
		end
	
		ui.palette_slider = 0
	end
	
	-- Check collision on layer menu
	local layx, layy = screen_width - 208, 325
	local layw = 208 - 2 - 16
	local layh = screen_height - 376
	if (mouse_switch == _PRESS) and (mx >= screen_width - 208) and (my >= layy) then
	
		-- Scroll bar
		if (mx >= screen_width - 16) and (my >= layy + 41 + 14) and (my <= 14 + screen_height - 34) then
			ui.lyr_scroll = true
		end
		
		-- Top scroll button
		if (mx >= screen_width - 16) and (mx <= screen_width - 1) and (my >= layy + 41) and (my <= layy + 41 + 14) then
			ui.lyr_dir = "up"
			ui.lyr_spd = 1
			ui.scrollButton()
		end
		
		-- Bottom scroll button
		if (mx >= screen_width - 16) and (mx <= screen_width - 1) and (my >= screen_height - 24) and (my <= screen_height - 10) then
			ui.lyr_dir = "down"
			ui.lyr_spd = 1
			ui.scrollButton()
		end
		
		if (document_w ~= 0) then
		
			-- Add layer button
			if (mx >= layx + 4) and (mx <= layx + 4 + 24) and (my >= layy + 13) and (my <= layy + 13 + 24) then
				
				local old_layer = tm.polygon_loc
				tm.polygon_loc = #ui.layer + 1
				shape_count = math.max(shape_count, tm.polygon_loc)
				
				tm.store(TM_PICK_LAYER, old_layer, tm.polygon_loc, true)
				tm.step()
				
				ui.addLayer()
				ui.lyr_scroll_percent = 0
			end
			
			-- Delete layer button
			if (mx >= layx + 4 + 24 + 8) and (mx <= layx + 4 + 24 + 24 + 8) and (my >= layy + 13) and (my <= layy + 13 + 24) then
				
				if (#ui.layer > 1) then
					--print(tm.polygon_loc)
					--ui.deleteLayer(ui.lyr_ref)
					--tm.store(TM_DELETE_LAYER, ui.lyr_ref)
					--local old_layer = tm.polygon_loc
					--tm.polygon_loc = ui.layer[1].count
					--tm.store(TM_PICK_LAYER, old_layer, tm.polygon_loc, true)
					--tm.step()
					--[[ui.deleteLayer(ui.layer[tm.polygon_loc].count)
					tm.store(TM_DELETE_LAYER, ui.layer[tm.polygon_loc].count)
					tm.step()--]]
				end
				
			end
			
			-- Check if layer was clicked on
			if (mx >= layx + 32) and (mx <= layx + layw) and (my >= layy + 40) and (my <= layy + 40 + layh) then
			
				local moffset = my - 365
			
				local layer_amt = #ui.layer
				local layer_element_size = math.max((25 * layer_amt) - layh - 1, 0)
				local scroll_offset = math.floor(ui.lyr_scroll_percent * layer_element_size)
				
				local layer_hit = layer_amt - math.floor((moffset + scroll_offset) / 25)
				
				-- Layer was clicked on, switch layers
				if ui.layer[layer_hit] ~= nil then
					ui.lyr_clicked = layer_hit
					ui.lyr_click_y = my
					
					local old_layer = tm.polygon_loc
					tm.polygon_loc = ui.layer[layer_hit].count
					
					local _tm_copy, skip_tm
					
					if (tm.data[tm.location - 1] ~= nil) then
						_tm_copy = tm.data[tm.location - 1][1]
						skip_tm = false
					else
						skip_tm = true
					end
					
					-- To reduce undo/redo ram usage, change previous swap to new layer instead of making another swap
					if (not skip_tm) and (_tm_copy.action == TM_PICK_LAYER) and (_tm_copy.created_layer == false) then
						_tm_copy.new = tm.polygon_loc
					else
						if old_layer ~= tm.polygon_loc then -- If we swap to the current active layer, don't register the swap
							tm.store(TM_PICK_LAYER, old_layer, tm.polygon_loc, false)
							tm.step()
						end
					end	
					
				end
				
			end
			
			-- Check if layer hide button was clicked on
			if (mx >= layx + 1) and (mx <= layx + 31) and (my >= layy + 40) and (my <= layy + 40 + layh) then
			
				local moffset = my - 365
			
				local layer_amt = #ui.layer
				local layer_element_size = math.max((25 * layer_amt) - layh - 1, 0)
				local scroll_offset = math.floor(ui.lyr_scroll_percent * layer_element_size)
				
				local layer_hit = layer_amt - math.floor((moffset + scroll_offset) / 25)
				
				-- Layer was clicked on, switch layers
				if ui.layer[layer_hit] ~= nil then
					ui.layer[layer_hit].visible = not ui.layer[layer_hit].visible
				end
				
			end
			
		end
		
		ui_active = true
			
	end
	
	if (ui.lyr_scroll) then
		ui.lyr_scroll_percent = lume.clamp(my - 4 - layy - 40 - 16, 0, layh - 32)/(layh - 32)
		ui_active = true
	end
	
	if (ui.lyr_scroll) and ((mouse_switch == _OFF) or (mouse_switch == _RELEASE)) then
		ui.lyr_scroll = false
	end
	
	-- Rearrage layers
	if (ui.lyr_clicked ~= 0) and ((mouse_switch == _OFF) or (mouse_switch == _RELEASE)) then
		
		local layer_amt = #ui.layer
		local layer_element_size = math.max((25 * layer_amt) - layh - 1, 0)
			
		if (layer_element_size == 0 and not ui.lyr_scroll) then
			ui.lyr_scroll_percent = 0
		end
		
		local scroll_offset = math.floor(ui.lyr_scroll_percent * layer_element_size)
	
		local moffset = my - 365
		local y_test = (moffset + scroll_offset)
		local layer_top = math.floor((moffset + scroll_offset) / 25) * 25
		local layer_num = layer_amt - math.floor((moffset + scroll_offset) / 25)
	
		-- Make it so we can't swap with layers that are not visible on screen (above the layer window)
		if (my >= 365-6) then
	
			-- If layer move is within bounds
			if (layer_num >= 0 and layer_num <= layer_amt) then
				
				-- And within 8 pixels of the layer being moved to
				if (math.abs(y_test - layer_top) < 8) or (math.abs(y_test - layer_top + 24) < 8) then
					
					-- Swap layers
					local swap_pos = layer_num + 1
					if layer_num >= ui.lyr_clicked then
						swap_pos = layer_num
					end
					
					if (ui.lyr_clicked ~= swap_pos) then
						ui.moveLayer(ui.lyr_clicked, swap_pos)
						tm.store(TM_MOVE_LAYER, ui.lyr_clicked, swap_pos)
						tm.step()
					end
					
				end
				
			elseif (layer_num >= 0) and (y_test >= -6) then -- Trying to move 6 pixels above top layer
			
				-- Swap to top position
				if (ui.lyr_clicked ~= layer_num - 1) then
					ui.moveLayer(ui.lyr_clicked, layer_num - 1)
					tm.store(TM_MOVE_LAYER, ui.lyr_clicked, layer_num - 1)
					tm.step()
				end
			
			end
		
		end
	
		ui.lyr_clicked = 0
		ui.lyr_click_y = 0
	end
	
	-- Timer for scroll buttons
	if (ui.lyr_dir ~= "") and ((mouse_switch ~= _OFF) and (mouse_switch ~= _RELEASE)) then
		ui.lyr_timer = ui.lyr_timer + (60 * dt)
		
		if ui.lyr_timer > 26 then
			ui.scrollButton()
			ui.lyr_timer = ui.lyr_timer - (5 * ui.lyr_spd)
		end
		
	else
		ui.lyr_dir = ""
		ui.lyr_timer = 0
	end
	
	-- Check collision on popup box
	if ui.popup[1] ~= nil then
		
		local exit_pop = false
		
		-- Scroll inputs with tab
		if tab_key == _PRESS then
			
			if ui.popup[1][1].kind == "f.new" then
			
				local oa = ui.popup_sel_a
				ui.popupLoseFocus(ui.popup[1][1].kind)
				
				ui.popup_sel_a, ui.popup_sel_b = oa + 1, 2
				
				if ui.popup_sel_a > #ui.popup - 1 then
					ui.popup_sel_a = 2
				end
				
				ui.sel_start = ui.popup[ui.popup_sel_a][ui.popup_sel_b].name
				ui.sel_type = "popup"
			
			end
			
		end
		
		-- Accept input with enter
		if enter_key == _PRESS then
		
			if ui.popup[1][1].kind == "f.new" and ui.popup_enter == false then
				-- OK button
				ui.popupLoseFocus(ui.popup[1][1].kind)
				document_name = ui.popup[2][2].name
				document_w = tonumber(ui.popup[3][2].name)
				document_h = tonumber(ui.popup[4][2].name)
				
				camera_zoom = 1
				resetCamera()
				
				artboard.init()
				tm.init()
				polygon.data = {}
				ui.layer = {}
				ui.addLayer()
				
				-- Exit popup
				ui.popup = {}
				ui_active = true
				ui.context_menu = {}
				ui.title_active = false
			end
		
		end
		
		local mx_on_menu, my_on_menu
		mx_on_menu = (mx >= ui.popup_x) and (mx <= ui.popup_x + ui.popup_w)
		my_on_menu = (my >= ui.popup_y) and (my <= ui.popup_y + ui.popup_h)
		
		-- If the popup box was clicked on
		if mx_on_menu and my_on_menu then
			
			if mouse_switch == _PRESS then
			
				local px, py, pw, ph, pxo = ui.popup_x, ui.popup_y, ui.popup_w, ui.popup_h, ui.popup_x_offset
				local popup_clicked = false
			
				local i
				local h = 12
				for i = 2, #ui.popup do
			
					local j
					for j = 1, #ui.popup[i] do
					
						local name = ui.popup[i][j].name
						local kind = ui.popup[i][j].kind
						local bx, by, bw, bh = -9999, 0, 0, 0
						
						-- Get bounding box of element clicked
						if kind == "textbox" then
							bx = px + (pw / 2) - 5 + pxo
							by = py + 25 + h - 1
							bw = 251
							bh = 20
						elseif kind == "number" then
							bx = px + (pw / 2) - 5 + pxo
							by = py + 25 + h - 1
							bw = 46
							bh = 20
						elseif kind == "ok" then
							bx = px + (pw / 2) - 32 - 19 - 8
							by = py + 25 + h + 6 - 3
							bw = 35
							bh = 25
						elseif kind == "cancel" then
							bx = px + (pw / 2) + 32 - 19 - 8
							by = py + 25 + h + 6 - 3
							bw = 55
							bh = 25
						end
						
						-- If bounding box is valid
						if bx ~= -9999 then
							local mx_box, my_box
							mx_box = (mx >= bx) and (mx <= bx + bw)
							my_box = (my >= by) and (my <= by + bh)
							
							-- If bounding box was clicked on
							if mx_box and my_box then
								
								popup_clicked = true
								
								if kind == "textbox" or kind == "number" then
									ui.popupLoseFocus(ui.popup[1][1].kind)
									ui.sel_start = ui.popup[i][j].name
									ui.sel_type = "popup"
									ui.popup_sel_a, ui.popup_sel_b = i, j
								elseif kind == "ok" and ui.popup[1][1].kind == "f.new" then -- OK button for f.new (new document)
									ui.popupLoseFocus(ui.popup[1][1].kind)
									document_name = ui.popup[2][2].name
									document_w = tonumber(ui.popup[3][2].name)
									document_h = tonumber(ui.popup[4][2].name)
									
									camera_zoom = 1
									resetCamera()
									
									artboard.init()
									tm.init()
									polygon.data = {}
									ui.layer = {}
									ui.addLayer()
									
									exit_pop = true
								elseif kind == "cancel" then
									exit_pop = true
								end
								
							end
						end
						
					end
					
					h = h + 28
				end
				
				if not popup_clicked then
					ui.popupLoseFocus(ui.popup[1][1].kind)
				end
				
				if exit_pop then
					ui.popupLoseFocus(ui.popup[1][1].kind)
					ui.popup = {}
					ui_active = true
					ui.context_menu = {}
					ui.title_active = false
				end
				
			end
			
			ui_active = true
			
		elseif mouse_switch == _PRESS then
			ui.popupLoseFocus(ui.popup[1][1].kind)
			ui_active = true
		end
		
	end
	
	-- Last step in UI code, check if mouse exited UI elements
	local ui_has_active_elements = (ui.context_menu[1] ~= nil or ui.title_active or ui.popup[1] ~= nil)
	
	if mouse_switch == _PRESS and ui_active == false and ui_has_active_elements then
		ui_active = true
		ui.context_menu = {}
		ui.title_active = false
	end
	
	ui.popup_enter = false
	
	-- Make ui active if interacting with palette/layer window
	ui_active = ui_active or (mx >= screen_width - 208)
	
	return ui_active

end

function ui.scrollButton()

	local layh = screen_height - 376
	local layer_amt = #ui.layer
	local layer_element_size = math.max((25 * layer_amt) - layh - 1, 0)
	local calc_pos

	if ui.lyr_dir == "up" then
		calc_pos = (math.floor((ui.lyr_scroll_percent * layer_element_size)/25) * 25) / layer_element_size
			
		if ui.lyr_scroll_percent == calc_pos then
			local new_calc = (math.floor((ui.lyr_scroll_percent * (layer_element_size - 25))/25) * 25) / layer_element_size
			ui.lyr_scroll_percent = lume.clamp(new_calc, 0, 1)
		else
			ui.lyr_scroll_percent = calc_pos
		end
	elseif ui.lyr_dir == "down" then
		calc_pos = (math.ceil((ui.lyr_scroll_percent * (layer_element_size + 25))/25) * 25) / layer_element_size
			
		if calc_pos == 0 then
			local new_calc = 25 / layer_element_size
			ui.lyr_scroll_percent = lume.clamp(new_calc, 0, 1)
		else
			ui.lyr_scroll_percent = lume.clamp(calc_pos, 0, 1)
		end
	end

end

function ui.drawOutline(x, y, w, h, invert)
	local ca, cb = c_outline_dark, c_outline_light
	if invert then ca, cb = cb, ca end

	lg.setColor(ca)
	lg.rectangle("fill", x, y, w - 1, 1)
	lg.rectangle("fill", x, y, 1, h)
	lg.setColor(cb)
	lg.rectangle("fill", x + w - 1, y, 1, h)
	lg.rectangle("fill", x + 1, y + h - 1, w - 1, 1)
end

function ui.drawOutlinePal(x, y, w, h, invert)

	lg.setColor(c_outline_dark)
	
	local gap = 35
	if invert then
		gap = 74
		lg.rectangle("fill", x, y, gap - 34, 1)
		lg.rectangle("fill", x + gap - 34, y - 29, 1, 30)
		lg.rectangle("fill", x + gap - 34, y - 29, 33, 1)
	else
		lg.rectangle("fill", x, y - 29, 1, 29)
		lg.rectangle("fill", x, y - 29, gap - 1, 1)
	end
	
	lg.rectangle("fill", x + gap, y, w - 1 - gap, 1)
	lg.rectangle("fill", x, y, 1, h)
	lg.setColor(c_outline_light)
	lg.rectangle("fill", x + w - 1, y, 1, h)
	lg.rectangle("fill", x + 1, y + h - 1, w - 1, 1)
	lg.rectangle("fill", x + gap - 1, y - 29, 1, 30)
end

function ui.draw()

	-- Local vars for palette swapping the editor
	local col_box, col_inactive = c_box, c_highlight_inactive
	local tex_btn, tex_slide_1, tex_slide_2, tex_slide_3, tex_gradient = spr_slider_button, spr_slider_1, spr_slider_2, spr_slider_3, grad_slider
	
	if debug_mode == "artboard" then
	
	col_box, col_inactive = c_art_box, c_art_inactive
	tex_btn, tex_slide_1, tex_slide_2, tex_slide_3, tex_gradient = art_slider_button, art_slider_1, art_slider_2, art_slider_3, art_grad_slider
	
	end
	-- End palette swap

	local mx, my = love.mouse.getX(), love.mouse.getY()
	lg.setColor(col_box)
	lg.rectangle("fill", 0, 0, screen_width, 25)
	lg.setColor(c_white)
	lg.draw(grad_large, 0, 1, 0, screen_width/256, 23)
	
	-- Draw title bar
	
	-- Draw background color of menu item
	if ui.context_menu[1] ~= nil and ui.title_active then
		lg.setColor(c_header_active)
		lg.rectangle("fill", ui.title_x, ui.title_y, ui.title_w, ui.title_h)
	end
	
	-- Draw text of menu item
	lg.setColor(c_white)
	local i
	local title_len = 0
	for i = 1, #ui.title do
		lg.print(ui.title[i].name, 12 + title_len, 3)
		title_len = title_len + font:getWidth(ui.title[i].name) + 15
	end
	
	-- Draw outline around menu item
	if ui.title_active then
		ui.drawOutline(ui.title_x, ui.title_y, ui.title_w, ui.title_h, ui.context_menu[1] == nil)
	end
	
	-- Draw palette
	local psize = 16
	local palw = (13 * psize)
	local palx, paly = screen_width - palw + 8, 165
	
	lg.setColor(col_box)
	lg.rectangle("fill", palx - 8, 25, palw, 300)
	ui.drawOutline(palx - 7, 25, palw - 2, 299, false)
	
	-- Color picker
	ui.drawOutlinePal(palx - 4, 65, palw - 9, 99, ui.palette_mode == "HSL")
	
	lg.setColor(c_black)
	lg.print("RGB", palx + 1, 42)
	lg.print("HSL", palx + 1 + 40, 42)
	
	if my >= 42 and my <= 42 + 18 then
		if ui.palette_mode == "RGB" and mx >= palx + 36 and mx <= palx + 36 + 24 + 10 then
			ui.drawOutline(palx + 41 - 5, 42, 24 + 10, 18,true)
		elseif ui.palette_mode == "HSL" and mx >= palx - 4 and mx <= palx - 4 + 25 + 10 then
			ui.drawOutline(palx + 1 - 5,  42, 25 + 10, 18,true)
		end
	end
	
	local ix, iy = screen_width - 50, 52
	local i
	h = 0
	local ioff = 0
	
	-- Shift index over to HSL values
	if ui.palette_mode == "HSL" then ioff = 3 end
	
	for i = 1 + ioff, 3 + ioff do
	
		lg.setColor(c_off_white)
		lg.rectangle("fill", ix - 5, iy + 25 + h - 1, 46, 20)
		lg.setColor(col_inactive)
		lg.rectangle("line", ix - 5, iy + 25 + h - 1, 46, 20)
		lg.setColor(c_black)
		lg.print(ui.palette[i].name, ix - font:getWidth(ui.palette[i].name) - 12, iy + 25 + h)
		lg.print(ui.palette[i].value, ix, iy + 25 + h)
		
		local slide_pos = (tonumber(ui.palette[i].value) / 255) * 111
		
		local slx, sly, slw = ix - 147, iy + 25 + h - 1, 122
		
		lg.setColor(c_white)
		lg.draw(tex_slide_1, slx, sly + 9)
		lg.draw(tex_slide_2, slx + 1, sly + 9, 0, (slw - 3)/1, 1)
		lg.draw(tex_slide_3, slx + slw - 2, sly + 9)
		lg.draw(tex_btn, slx + slide_pos, sly)
		
		h = h + 28
	
	end
	
	-- Palette
	ui.drawOutline(palx - 4, paly - 7 + 16, palw - 9, (16 * 7) - 3, false)
	local i
	local sel_i, sel_j = -1, -1
	for i = 1, palette.h do
	
		local j
		for j = 1, palette.w do
		
			local index = (j - 1) + ((i - 1) * palette.w)
			if index < #palette.colors then
			lg.setColor(palette.colors[index + 1])
			else
			lg.setColor(c_black)
			end
			
			lg.rectangle("fill", palx + (j - 1) * psize, paly + i * psize, psize - 1, psize - 1)
			
			if index == palette.slot then
				sel_i, sel_j = i, j
			end
		
		end
	
	end
	
	-- Selected color
	if sel_i ~= -1 then
		lg.setColor(c_outline_light)
		lg.rectangle("line", palx + (sel_j - 1) * psize, paly + sel_i * psize, psize - 1, psize - 1)
		lg.setColor(c_outline_dark)
		lg.rectangle("line", palx - 1 + (sel_j - 1) * psize, paly - 1 + sel_i * psize, psize + 1, psize + 1)
	end
	
	-- Current color
	lg.setColor(palette.active)
	lg.rectangle("fill", palx - 4, paly + (16 * 8) - 5, palw - 9, 30)
	ui.drawOutline(palx - 4, paly + (16 * 8) - 5, palw - 9, 30)
	
	-- Draw layer menu
	local layx, layy = screen_width - 208, 325
	local layw = 208 - 2 - 16
	local layh = screen_height - 376
	
	-- Fill area
	lg.setColor(col_box)
	lg.rectangle("fill", layx, layy, 208, screen_height - layy)
	
	ui.drawOutline(layx + 1, layy + 10, layw + 16, 30)
	
	-- Draw add + trash icons
	lg.setColor(c_white)
	lg.draw(icon_add,   layx + 4, layy + 13)
	ui.drawOutline(layx + 4, layy + 13, 24, 24, true)
	
	lg.setColor(c_white)
	lg.draw(icon_trash, layx + 4 + 24 + 8, layy + 13)
	ui.drawOutline(layx + 4 + 24 + 8, layy + 13, 24, 24, true)
	
	-- Draw layers in window
	local layer_amt = #ui.layer
	
	local layer_element_size = math.max((25 * layer_amt) - layh - 1, 0)
	
	if (layer_element_size == 0 and not ui.lyr_scroll) then
		ui.lyr_scroll_percent = 0
	end
	
	local scroll_offset = math.floor(ui.lyr_scroll_percent * layer_element_size)
	
	-- use scissor to cull other layers
	lg.setScissor(layx + 1, layy + 40, layw, layh)
	lg.translate(0, -scroll_offset)
	
	if ui.layer[1] ~= nil then
		local i
		for i = layer_amt, 1, -1 do
			local yy = 40 + ((layer_amt - i) * 25)
			
			local box_color = col_inactive
			
			if ui.layer[i].count == tm.polygon_loc then
				lg.setColor(c_highlight_active)
				lg.rectangle("fill", layx + 32, layy + yy, layw, 25)
				box_color = c_layer_box
			end
			
			lg.setColor(c_outline_dark)
			lg.print(ui.layer[i].name, layx + 77, layy + yy + 3)
			lg.rectangle("fill", layx + 1, layy + yy + 24, layw, 1)
			lg.rectangle("fill", layx + 32, layy + yy, 1, 24)
			
			lg.setColor(c_white)
			
			if ui.layer[i].visible then
			lg.draw(icon_eye, layx + 5, layy + yy)
			else
			lg.draw(icon_blink, layx + 5, layy + yy)
			end
			
			local body_color = palette.active
			if polygon.data[ui.layer[i].count] ~= nil then
				body_color = polygon.data[ui.layer[i].count].color
			end
			
			lg.setColor(body_color)
			lg.rectangle("fill", layx + 37, layy + yy + 3, 31, 17)
			lg.setColor(box_color)
			lg.rectangle("line", layx + 37, layy + yy + 3, 31, 17)
			
		end
	end
	
	lg.translate(0, scroll_offset)
	lg.setScissor(0, 0, screen_width, screen_height)
	
	local draw_l = false
	local lx, ly, lw, lh
	
	if ui.lyr_clicked ~= 0 and (math.abs(my - ui.lyr_click_y) > 4) then
	
		ui.lyr_click_y = 9999
		
		local l_alpha = 0.1
		local yy = 40 + ((layer_amt - ui.lyr_clicked) * 25)
		local box_color = {col_inactive[1], col_inactive[2], col_inactive[3], l_alpha}
		
		local sel_x, sel_y = 0, my - layy - yy
		lg.translate(sel_x, sel_y)
		
		lg.setColor({c_highlight_active[1], c_highlight_active[2], c_highlight_active[3], l_alpha})
		lg.rectangle("fill", layx + 32, layy + yy, layw - 32, 25)
		box_color = {c_layer_box[1], c_layer_box[2], c_layer_box[3], l_alpha}
		
		lg.setColor({0,0,0,l_alpha})
		lg.print(ui.layer[ui.lyr_clicked].name, layx + 77, layy + yy + 3)
		lg.rectangle("fill", layx + 1, layy + yy + 24, layw - 1, 1)
		lg.rectangle("fill", layx + 1, layy + yy, layw - 1, 1)
		lg.rectangle("fill", layx + 32, layy + yy, 1, 24)
		
		lg.setColor({c_outline_dark[1],c_outline_dark[2],c_outline_dark[3],l_alpha})
		
		if ui.layer[ui.lyr_clicked].visible then
		lg.draw(icon_eye, layx + 5, layy + yy)
		else
		lg.draw(icon_blink, layx + 5, layy + yy)
		end
		
		local body_color = {palette.active[1], palette.active[2], palette.active[3], l_alpha}
		if polygon.data[ui.layer[ui.lyr_clicked].count] ~= nil then
			local old_cc = polygon.data[ui.layer[ui.lyr_clicked].count].color
			body_color = {old_cc[1], old_cc[2], old_cc[3], l_alpha}
		end
		
		lg.setColor(body_color)
		lg.rectangle("fill", layx + 37, layy + yy + 3, 31, 17)
		lg.setColor(box_color)
		lg.rectangle("line", layx + 37, layy + yy + 3, 31, 17)
		
		lg.translate(-sel_x, -sel_y)
		
		-- Highlight bars when rearranging layers
		local moffset = my - 365
		local y_test = (moffset + scroll_offset)
		local layer_top = math.floor((moffset + scroll_offset) / 25) * 25
		local layer_num = layer_amt - math.floor((moffset + scroll_offset) / 25)	
		
		if (my >= 365 - 6) and (my <= screen_height - 6) then -- Keep within bounds of layer selector
		
			if layer_num >= 0 and layer_num <= layer_amt then
			
				if math.abs(y_test - layer_top) < 8 then
					lx = layx + 32
					ly = 365 + layer_top - 3 - scroll_offset
					lw = layw - 32
					lh = 5
					draw_l = true
				end
				
				if math.abs(y_test - layer_top + 24) < 8 then
					lx = layx + 32
					ly = 365 + layer_top + 21 - scroll_offset
					lw = layw - 32
					lh = 5
					draw_l = true
				end
				
			elseif (layer_num >= 0) and (my >= 365 - 6) then
			
				lx = layx + 32
				ly = 365 - 3 - scroll_offset
				lw = layw - 32
				lh = 5
				draw_l = true
			
			end
			
			-- Scroll layer window when placing a layer outside of bounds
			if (my >= 365 - 6) and (my <= 365) then
				ui.lyr_dir = "up"
				ui.lyr_spd = 3
			end
			
			if (my >= screen_height - 10) then
				ui.lyr_dir = "down"
				ui.lyr_spd = 3
			end
			
		end
	
	end
	
	-- Draw layer slider
	ui.drawOutline(screen_width - 16, layy + 41, 15, 14, true)
	ui.drawOutline(screen_width - 16, screen_height - 24, 15, 14, true)
	
	lg.setColor(c_white)
	lg.draw(tex_gradient,   screen_width - 16, layy + 41 + 14, 0, 1, layh - 28)
	lg.draw(spr_arrow_up,   screen_width - 12, layy + 41 + 4)
	lg.draw(spr_arrow_down, screen_width - 12, screen_height - 24 + 4)
	
	-- Scroll button
	lg.setColor(col_box)
	local scroll_len = screen_height - 38 - (layy + 41 + 14)
	lg.rectangle("fill", screen_width - 16, layy + 41 + 14 + math.floor(scroll_len * ui.lyr_scroll_percent), 15, 14)
	ui.drawOutline(screen_width - 16, layy + 41 + 14 + math.floor(scroll_len * ui.lyr_scroll_percent), 15, 14, true)
	
	ui.drawOutline(layx + 1, layy + 10 + 29, layw, screen_height - layy - 20 - 29)
	
	if draw_l then
		
		-- Keep ly within bounds of layer menu
		ly = lume.clamp(ly, 365-6+3, screen_height-6-7)
		
		lg.setColor(c_off_white)
		lg.rectangle("fill", lx, ly, lw, lh)
		lg.setColor(c_outline_dark)
		lg.rectangle("fill", lx, ly + 2, lw, lh - 4)
			
	end
	
	-- Draw popup box
	if ui.popup[1] ~= nil then
	
		local px, py, pw, ph, pxo = ui.popup_x, ui.popup_y, ui.popup_w, ui.popup_h, ui.popup_x_offset
	
		lg.setColor(col_box)
		lg.rectangle("fill", px, py, pw, ph)
		lg.setColor(c_white)
		lg.draw(grad_active, px, py + 1, 0, pw/256, 23)
		
		lg.print(ui.popup[1][1].name, px + 10, py + 3)
		ui.drawOutline(px + 1, py + 25, pw - 2, ph - 26)
		
		local i
		local h = 12
		for i = 2, #ui.popup do
			
			local j
			for j = 1, #ui.popup[i] do
			
				lg.setColor(c_black)
				
				local name = ui.popup[i][j].name
				local kind = ui.popup[i][j].kind
				
				local col = col_inactive
				local this_selected = (i == ui.popup_sel_a and j == ui.popup_sel_b)
				if this_selected then
					col = c_highlight_active
					lg.setLineWidth(2)
				end
			
				if kind == "text" then
					lg.print(name, px + (pw / 2) - font:getWidth(name) - 12 + pxo, py + 25 + h)
				elseif kind == "textbox" then
					lg.setColor(c_off_white)
					lg.rectangle("fill", px + (pw / 2) - 5 + pxo, py + 25 + h - 1, 251, 20)
					lg.setColor(col)
					lg.rectangle("line", px + (pw / 2) - 5 + pxo, py + 25 + h - 1, 251, 20)
					lg.setColor(c_black)
					lg.print(name, px + (pw / 2) + pxo, py + 25 + h)
				elseif kind == "number" then
					lg.setColor(c_off_white)
					lg.rectangle("fill", px + (pw / 2) - 5 + pxo, py + 25 + h - 1, 46, 20)
					lg.setColor(col)
					lg.rectangle("line", px + (pw / 2) - 5 + pxo, py + 25 + h - 1, 46, 20)
					lg.setColor(c_black)
					lg.print(name, px + (pw / 2) + pxo, py + 25 + h)
				elseif kind == "ok" then
					local bx, by
					bx = px + (pw / 2) - 32 - 19
					by = py + 25 + h + 6
					ui.drawOutline(bx - 8, by - 3, 35, 25, true)
					lg.print(name, bx, by)
				elseif kind == "cancel" then
					local bx, by
					bx = px + (pw / 2) + 32 - 19
					by = py + 25 + h + 6
					ui.drawOutline(bx - 8, by - 3, 55, 25, true)
					lg.print(name, bx, by)
				end
				
				lg.setLineWidth(1)
				
				if ui.input_cursor_visible and this_selected then
					local lxx, lyy = px + (pw / 2) + pxo + font:getWidth(name) + 3, py + 25 + h + 2
					lg.line(lxx, lyy, lxx, lyy + 14)
				end
			
			end
			
			h = h + 28
		
		end
	
	end
	
	-- Draw context menu
	if ui.context_menu[1] ~= nil then
	
		lg.setColor(col_box)
		lg.rectangle("fill", ui.context_x, ui.context_y, ui.context_w, ui.context_h)
		
		ui.drawOutline(ui.context_x + 1, ui.context_y + 1, ui.context_w - 2, ui.context_h - 2, false)
		
		-- Draw highlight
		local i
		local h = 0
		for i = 1, #ui.context_menu do
		
			-- Set colors for the menu text and background color when highlighted
			local tc, bc
			
			if ui.context_menu[i].active then
				tc = c_black
				bc = c_highlight_active
			else
				tc = c_gray
				bc = col_inactive
			end
			
			-- If entry in the menu
			if ui.context_menu[i]._break == nil then
				
				local low = ui.context_y + h + 8
				local upp = low + 20
				
				if mx >= ui.context_x and mx <= ui.context_x + ui.context_w then
					lg.setColor(bc)
					if my >= low and my <= upp then
						lg.rectangle("fill", ui.context_x + 4, ui.context_y + h + 8, ui.context_w - 8, 20)
					end
				end
				
				lg.setColor(tc)
				lg.print(ui.context_menu[i].name, ui.context_x + 12, ui.context_y + h + 9)
				
				h = h + 22
			else -- If entry is a break
				lg.setColor(c_line_dark)
				lg.rectangle("fill", ui.context_x + 4, ui.context_y + h + 14, ui.context_w - 8, 1)
				lg.setColor(c_line_light)
				lg.rectangle("fill", ui.context_x + 4, ui.context_y + h + 15, ui.context_w - 8, 1)
			
				h = h + 11
			end
		
		end
	
	end
	
end

return ui