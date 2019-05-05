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
	
	end

end

function ui.update(dt)

	local ui_active = false
	
	-- Check if title bar was interacted with
	if mouse_switch == _PRESS and love.mouse.getY() < 24 then
		
		if #vertex_selection ~= 0 then
			vertex_selection = {}
		end
	
		-- Check title bar pos
		local i
		local title_len = 12
		for i = 1, #ui.title do
			
			local mx = love.mouse.getX()
			local title_size = font:getWidth(ui.title[i].name)
			
			if mx >= title_len - 6 and mx <= title_len + title_size then
				ui.loadCM(title_len - 4, 24, ui.title[i].ref)
			end
			
			title_len = title_len + title_size + 15
		end
	
		ui_active = true
	end
	
	return ui_active

end

function ui.draw()

	lg.setColor(c_box)
	lg.rectangle("fill", 0, 0, 800, 25)
	lg.setColor(c_white)
	lg.draw(grad_large, 0, 1, 0, 800/256, 23)
	
	-- Draw title bar
	local i
	local title_len = 0
	for i = 1, #ui.title do
		lg.print(ui.title[i].name, 12 + title_len, 3)
		title_len = title_len + font:getWidth(ui.title[i].name) + 15
	end
	
	-- Draw context menu
	if ui.context_menu[1] ~= nil then
	
		lg.setColor(c_box)
		lg.rectangle("fill", ui.context_x, ui.context_y, ui.context_w, ui.context_h)
		
		lg.setColor(c_outline_dark)
		lg.rectangle("fill", ui.context_x + 1, ui.context_y + 1, ui.context_w - 3, 1)
		lg.rectangle("fill", ui.context_x + 1, ui.context_y + 1, 1, ui.context_h - 2)
		lg.setColor(c_outline_light)
		lg.rectangle("fill", ui.context_x + ui.context_w - 2, ui.context_y + 1, 1, ui.context_h - 2)
		lg.rectangle("fill", ui.context_x + 2, ui.context_y + ui.context_h - 2, ui.context_w - 3, 1)
		
		local i
		local h = 0
		for i = 1, #ui.context_menu do
		
			if ui.context_menu[i].active then
				lg.setColor(c_black)
			else
				lg.setColor(c_gray)
			end
			
			-- If entry in the menu
			if ui.context_menu[i]._break == nil then
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