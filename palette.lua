local palette = {}

-- COLOR CONSTANTS
c_white = {1, 1, 1, 1}
c_black = {0, 0, 0, 1}
c_gray = {93/255, 102/255, 113/255, 1}
c_off_white = {237/255, 241/255, 246/255, 1}

c_background = {40/255, 40/255, 40/255, 1}
c_box = {179/255, 192/255, 209/255, 1}
c_outline_dark = {33/255, 27/255, 18/255, 1}
c_outline_light = {222/255, 228/255, 237/255, 1}
c_line_dark = {139/255, 148/255, 161/255, 1}
c_line_light = {198/255, 209/255, 223/255, 1}
c_header_active = {58/255, 58/255, 58/255, 1}
c_highlight_active = {151/255, 97/255, 227/255, 1}
c_highlight_inactive = {155/255, 173/255, 195/255, 1}
c_layer_box = {107/255, 62/255, 66/255, 1}

c_art_box = {224/255, 195/255, 229/255, 1}
c_art_inactive = {202/255, 167/255, 208/255, 1}
c_art_line_dark = {163/255, 149/255, 166/255, 1}
c_art_line_light = {234/255, 217/255, 236/255, 1}

c_btn_gray_top = {126/255, 133/255, 143/255, 1}
c_btn_gray_mid = {156/255, 163/255, 170/255, 1}
c_btn_pink_top = {161/255, 126/255, 156/255, 1}
c_btn_pink_mid = {193/255, 153/255, 187/255, 1}
c_btn_high_top = {223/255, 203/255, 251/255, 1}
c_btn_high_bot = {107/255, 60/255, 172/255, 1}

palette.lines = c_white
palette.select  = c_white

BTN_DEFAULT = 0
BTN_GRAY = 1
BTN_PINK = 2
BTN_HIGHLIGHT_ON = 3
BTN_HIGHLIGHT_OFF = 4

palette.w = 12
palette.h = 6

palette.slot = -1
palette.active = {1,1,1,1}
palette.activeIsEditable = false
palette.startingColor = {1,1,1,1}

palette.copy = nil
palette.canPaste = false

function palette.init()

	palette.colors = {}
	palette.loadPalette("default.pal")

end

function palette.defaultValue(x)

	return math.floor(x/3) * 255

end

function palette.loadPalette(location)

	-- Read palette file to be opened
	file = love.filesystem.getInfo(location)

	if (not file) then
		-- Error, file not found
	else
		-- File loaded
		for line in love.filesystem.lines(location) do

			if (line ~= "") then

				local new_line = line
				local rgba = {}
				local i = 1
				while (i ~= 5) do

					local position, comma_finder
					position = 0
					comma_finder = string.find(new_line, ",") or string.len(new_line) + 1

					if (not comma_finder) then

						-- Error, comma not found
						rgba[i] = palette.defaultValue(i) / 255
						i = i + 1

					else

						-- Comma found!
						rgba[i] = tonumber(string.sub(new_line, position, comma_finder - 1))
						if (not rgba[i]) then
							rgba[i] = palette.defaultValue(i) / 255
						else
							rgba[i] = math.max(0, rgba[i])
							rgba[i] = math.min(255, rgba[i])
							rgba[i] = rgba[i] / 255
						end

						new_line = string.sub(new_line, comma_finder + 1)

						i = i + 1

						if (i <= 3) and (new_line == "") then
							new_line = palette.defaultValue(i)
						end

					end

				end

				table.insert(palette.colors, rgba)

			end

		end
		
		palette.slot = math.random(#palette.colors) - 1
		
		-- Fill remaining palette with black
		local i
		for i = #palette.colors, palette.w * palette.h do
			table.insert(palette.colors, {0, 0, 0, 1})
		end

		palette.active = palette.colors[palette.slot + 1]
		palette.updateFromBoxes()
		palette.updateAccentColor()

	end

end

function palette.updateFromRGB()
	local _floor = math.floor
	palette.active[1], palette.active[2], palette.active[3] = ui.palette[1].value / 255, ui.palette[2].value / 255, ui.palette[3].value / 255
	local aa = palette.active[4]
	ui.palette[4].value, ui.palette[5].value, ui.palette[6].value = palette.RGB(ui.palette[1].value, ui.palette[2].value, ui.palette[3].value, aa)
	ui.palette[4].value, ui.palette[5].value, ui.palette[6].value = _floor(ui.palette[4].value), _floor(ui.palette[5].value), _floor(ui.palette[6].value)
end

function palette.updateFromHSL()
	local _floor = math.floor
	palette.active[1], palette.active[2], palette.active[3], palette.active[4] = palette.HSL(ui.palette[4].value, ui.palette[5].value, ui.palette[6].value, palette.active[4])
	ui.palette[1].value, ui.palette[2].value, ui.palette[3].value = _floor(palette.active[1] * 255), _floor(palette.active[2] * 255), _floor(palette.active[3] * 255)
end

function palette.updateFromBoxes()

	local _floor = math.floor
	ui.palette[1].value = _floor(palette.active[1] * 255)
	ui.palette[2].value = _floor(palette.active[2] * 255)
	ui.palette[3].value = _floor(palette.active[3] * 255)
	local aa = palette.active[4]
	ui.palette[4].value, ui.palette[5].value, ui.palette[6].value = palette.RGB(ui.palette[1].value, ui.palette[2].value, ui.palette[3].value, aa)
	ui.palette[4].value, ui.palette[5].value, ui.palette[6].value = _floor(ui.palette[4].value), _floor(ui.palette[5].value), _floor(ui.palette[6].value)
	
end

function palette.updateAccentColor()

	local qr, qg, qb
	local o_col = palette.active
	if polygon.data[1] ~= nil and polygon.data[tm.polygon_loc] ~= nil then --and = polygon.data[tm.polygon_loc].color
		o_col = polygon.data[tm.polygon_loc].color
	end
	
	qr, qg, qb = o_col[1], o_col[2], o_col[3] -- Copy current color
	
	-- Find if color is closer to white or black
	local mix = (qr + qg + qb)/3
	
	local light = 0
	local mix_strength = 2.5
	
	local xr, xg, xb, yr, yg, yb
	if mix < 0.5 then
		light = 1
		mix_strength = 1.5
	end
	
	xr, xg, xb = (qr + light) / mix_strength, (qg + light) / mix_strength, (qb + light) / mix_strength

	xr = math.min(xr, 1)
	xg = math.min(xg, 1)
	xb = math.min(xb, 1)
	
	mix = (xr + xg + xb)/3
	
	if mix < 0.3 and mix > 0.2 then
		yr, yg, yb = o_col[1], o_col[2], o_col[3]
	else
		yr, yg, yb = xr, xg, xb
	end
	
	palette.lines = {xr, xg, xb, 1}
	palette.select  = {yr, yg, yb, (200/255)}

end

-- Converts HSL to RGB
function palette.HSL(h, s, l, a)
	if s<=0 then return l/255,l/255,l/255,a end
	h, s, l = h/256*6, s/255, l/255
	local c = (1-math.abs(2*l-1))*s
	local x = (1-math.abs(h%2-1))*c
	local m,r,g,b = (l-.5*c), 0,0,0
	if h < 1     then r,g,b = c,x,0
	elseif h < 2 then r,g,b = x,c,0
	elseif h < 3 then r,g,b = 0,c,x
	elseif h < 4 then r,g,b = 0,x,c
	elseif h < 5 then r,g,b = x,0,c
	else              r,g,b = c,0,x
	end return (r+m),(g+m),(b+m),a
end

function palette.RGB(r, g, b, a)
	r,g,b = r/255, g/255, b/255
	local _max = math.max(r,g,b)
	local _min = math.min(r,g,b)
	local def = (_max + _min) / 2
	local h,s,l = def,def,def
	if (_max == _min) then h,s = 0,0
	else
	local d = _max - _min
	if (l > 0.5) then s = d / (2 - _max - _min) else s = d / (_max + _min) end
	if r == _max then
		if (g < b) then h = (g - b) / d + 6 else h = (g - b) / d end
	elseif g == _max then
		h = (b - r) / d + 2
	elseif b == _max then
		h = (r - g) / d + 4
	end
	h = h/6
	end
	return math.ceil(h*255),s*255,l*255,a
end

return palette