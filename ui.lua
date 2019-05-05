local ui = {}

screen_width = 800
screen_height = 600

c_white = {1, 1, 1, 1}
c_black = {0, 0, 0, 1}
c_gray = {0.5, 0.5, 0.5, 1}

c_background = {40/255, 40/255, 40/255, 1}
c_box = {179/255, 192/255, 209/255, 1}
c_outline_dark = {33/255, 27/255, 18/255, 1}
c_outline_light = {222/255, 228/255, 237/255, 1}
c_line_dark = {139/255, 148/255, 161/255, 1}
c_line_light = {198/255, 209/255, 223/255, 1}
c_header_active = {58/255, 58/255, 58/255, 1}

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

function ui.init()
	ui.addTitle("File",     ".file")
	ui.addTitle("Edit",     ".edit")
	ui.addTitle("Search",   ".search")
	ui.addTitle("View",     ".view")
	ui.addTitle("Encoding", ".encoding")
end

function ui.addTitle(name, ref)

	local item = {}
	item.name = name
	item.ref = ref
	item.active = false
	
	table.insert(ui.title, item)

end

function ui.addCM(name, active, ref)

	local item = {}
	item.name = name
	item.ref = ref
	item.active = active
	
	table.insert(ui.context_menu, item)

end

function ui.addCMBreak()

	local item = {}
	item._break = true
	table.insert(ui.context_menu, item)

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

function ui.update(dt)

	local ui_active = false
	
	local has_interaction = (mouse_switch == _PRESS or ui.context_menu[1] ~= nil)
	
	if love.mouse.getY() < 24 then
	
		-- Clear selection on interaction
		if has_interaction and #vertex_selection ~= 0 then
			vertex_selection = {}
		end
	
		local i
		local title_len = 12
		local hit_item = false
		for i = 1, #ui.title do
			
			local mx = love.mouse.getX()
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
	
	return ui_active

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

function ui.draw()

	lg.setColor(c_box)
	lg.rectangle("fill", 0, 0, 800, 25)
	lg.setColor(c_white)
	lg.draw(grad_large, 0, 1, 0, 800/256, 23)
	
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
	
	-- Draw context menu
	if ui.context_menu[1] ~= nil then
	
		lg.setColor(c_box)
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
				bc = {0,0,1,1}
			else
				tc = c_gray
				bc = {0.5,0.5,1,1}
			end
			
			-- If entry in the menu
			if ui.context_menu[i]._break == nil then
				
				local mx = love.mouse.getX()
				local my = love.mouse.getY()
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