local export = {}

function export.saveLOL()

	if polygon.data[ui.layer[1].count] ~= nil then
	
		local prefix = ""
		if love ~= nil then
			prefix = love.filesystem.getSourceBaseDirectory() .. "/"
		end
	
		local file = io.open(prefix .. document_name .. ".lol", "w")
		file:write("Magma v1.0\n")
		file:write(document_w .. "," .. document_h .. ";\n")
		
		local i = 1
		while i <= #ui.layer do
		
			if polygon.data[ui.layer[i].count] ~= nil then
			
				local clone = polygon.data[ui.layer[i].count]
				
				if ui.layer[i].visible then
					file:write("1,")
				else
					file:write("0,")
				end
				
				file:write(ui.layer[i].name .. "," .. clone.kind .. "," .. math.floor(clone.color[1]*255) .. "," .. math.floor(clone.color[2]*255) .. "," .. math.floor(clone.color[3]*255) .. "," .. math.floor(clone.color[4]*255) .. ":")
				
				local j = 1
				while j <= #clone.raw do
					
					local raw_copy = clone.raw[j]
					
					file:write(raw_copy.x .. ",")
					file:write(raw_copy.y)
					
					if raw_copy.va ~= nil then
						file:write("," .. raw_copy.va)
					end
					
					if raw_copy.vb ~= nil then
						file:write("," .. raw_copy.vb)
					end
					
					if clone.segments ~= nil and j == 1 then
						file:write("," .. clone.segments)
					end
					
					if clone._angle ~= nil and j == 1 then
						file:write("," .. clone._angle)
					end
					
					if i == #ui.layer and j == #clone.raw then
						file:write(";")
					elseif j == #clone.raw then
						file:write(";\n")
					else
						file:write(":")
					end
					
					j = j + 1
				end
			
			end
		
			i = i + 1
		end
		
		file:flush()
		file:close()
	
	end

end

function export.saveSVG()

	if polygon.data[ui.layer[1].count] ~= nil then
	
		local prefix = ""
		if love ~= nil then
			prefix = love.filesystem.getSourceBaseDirectory() .. "/"
		end
		
		local file = io.open(prefix .. document_name .. ".svg", "w")
		
		file:write('<?xml version="1.0" encoding="UTF-8" ?>')
		file:write('\n')
		file:write('<svg xmlns="http://www.w3.org/2000/svg" version="1.1" width="', document_w, '" height="', document_h, '">\n')
		
		local i = 1
		while i <= #ui.layer do
		
			if polygon.data[ui.layer[i].count] ~= nil and ui.layer[i].visible then
			
				local clone = polygon.data[ui.layer[i].count]
				
				local j = 1
				while j <= #clone.raw do
					
					local raw_copy = clone.raw[j]
					
					local colour = math.floor(clone.color[1]*255) .. "," .. math.floor(clone.color[2]*255) .. "," .. math.floor(clone.color[3]*255)
					
					-- Export ellipse
					if clone.segments ~= nil then
						
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
								
								local verts = cx .. "," .. cy .. " " .. (cx + cxx2) .. "," .. (cy + cyy2) .. " " .. (cx + cxx3) .. "," .. (cy + cyy3)
								file:write('  <polygon points="' .. verts .. '" style="fill:rgb(' .. colour .. ')" stroke="rgb(' .. colour .. ')" stroke-width="1" />')
							
								if not (k + 1 < cseg) then
									-- Do nothing
								else
									file:write("\n")
								end
								
								v = v + cinc
								k = k + 1
							
							end
						
						end
						
					end
					
					-- Export polygon
					if raw_copy.vb ~= nil then
					
						local verts = raw_copy.x .. "," .. raw_copy.y .. " " .. clone.raw[raw_copy.va].x .. "," .. clone.raw[raw_copy.va].y .. " " .. clone.raw[raw_copy.vb].x .. "," .. clone.raw[raw_copy.vb].y
						file:write('  <polygon points="' .. verts .. '" style="fill:rgb(' .. colour .. ')" stroke="rgb(' .. colour .. ')" stroke-width="1" />')
					
						if i == #ui.layer then
							-- Do nothing
						else
							file:write("\n")
						end
					
					end
					
					j = j + 1
				end
				
			end
			
			i = i + 1
		end
		
		file:write('\n')
		file:write('</svg>')

		file:flush()
		file:close()
	
	end

end

function export.saveArtboard()
	
	if artboard.edited then
	
		artboard.saveCache(true)
		
		local copy_png = io.open(love.filesystem.getSaveDirectory() .. "/cache/export.png", "rb")
		local copy_str = copy_png:read("*a")
		copy_png:close()
		
		local prefix = ""
		if love ~= nil then
			prefix = love.filesystem.getSourceBaseDirectory() .. "/"
		end
		
		local save_png = io.open(prefix .. document_name .. ".png", "wb")
		save_png:write(copy_str)
		save_png:close()
	
	end
	
end

return export