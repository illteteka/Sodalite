local export = {}

function export.saveLOL()

	if polygon.data[ui.layer[1].count] ~= nil then
	
		local prefix = ""
		if love ~= nil then
			prefix = love.filesystem.getSourceBaseDirectory() .. "/"
		end
	
		file = io.open(prefix .. document_name .. ".lol", "w")
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
		
		file:close()
	
	end

end

return export