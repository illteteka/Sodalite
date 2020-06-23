local import = {}

FILE_EXTENSION = "soda"

-- Import vars
line_count = 0
file_state = "SETUP"
file_pos = 0

function import.open(file)
	
	local fname = file:getFilename()
	local file_dot = string.find(fname,"%.")
	local file_ext = ""
	
	if file_dot ~= nil then
	
		file_ext = fname:sub(file_dot + 1)
		
		local dname = fname
		dname = dname:sub(0, dname:len() - file_ext:len() - 1)
		while (string.find(dname,"\\")) do
			local sl = string.find(dname,"\\")
			dname = dname:sub(sl + 1)
		end
		
		document_name = dname
	
	end
	
	if (file_ext == FILE_EXTENSION) then
		local old_w, old_h = document_w, document_h
		local file_contents = file:read("string")
		-- Reset import vars
		line_count = 0
		file_state = "SETUP"
		file_pos = 0
		
		resetEditor(true, false, false)
		import.read(file_contents)
		
		artboard.init()
		ui.preview_zoom = 1
		ui.preview_window_x = 0
		ui.preview_window_y = 0

		camera_zoom = 1
		if old_w ~= document_w or old_h ~= document_h then
			camera_zoom = 1
			resetCamera()
		end
		palette.updateAccentColor()
		updateTitle()
		
		empty_document = false
		
		splash_active = false
	end

end

function import.read(file)

	local poly_count = 1
	
	local load_line = file:find("\n")
	
	local i
	while file ~= "" do
		i = file:sub(file_pos,load_line)
		i = i:gsub("\n", "")
		
		-- Start load
		if (line_count ~= 0) then
			local cursor = 0
			
			if file_state == "SETUP" then
				-- Width
				local sub_cursor = string.find(i, ",")
				document_w = tonumber(i:sub(cursor, sub_cursor - 1))
				
				-- Height
				cursor = sub_cursor + 1
				sub_cursor = string.find(i, ";", cursor)
				document_h = tonumber(i:sub(cursor, sub_cursor - 1))
				
				file_state = "DATA"
				
			elseif file_state == "DATA" then
			
				table.insert(polygon.data, {})
				polygon.data[poly_count].cache = {}
			
				local vv, nn
			
				-- Visible
				local sub_cursor = string.find(i, ",")
				if i:sub(cursor, sub_cursor - 1) == "1" then
					vv = true
				else
					vv = false
				end
				
				-- Layer name
				cursor = sub_cursor + 1
				sub_cursor = string.find(i, ",", cursor)
				nn = i:sub(cursor, sub_cursor - 1)
				
				ui.importLayer(vv, nn)
				
				-- Shape kind
				cursor = sub_cursor + 1
				sub_cursor = string.find(i, ",", cursor)
				polygon.data[poly_count].kind = i:sub(cursor, sub_cursor - 1)
				
				local rr,gg,bb,aa
				
				-- R
				cursor = sub_cursor + 1
				sub_cursor = string.find(i, ",", cursor)
				rr = tonumber(i:sub(cursor, sub_cursor - 1)) / 255
				
				-- G
				cursor = sub_cursor + 1
				sub_cursor = string.find(i, ",", cursor)
				gg = tonumber(i:sub(cursor, sub_cursor - 1)) / 255
				
				-- B
				cursor = sub_cursor + 1
				sub_cursor = string.find(i, ",", cursor)
				bb = tonumber(i:sub(cursor, sub_cursor - 1)) / 255
				
				-- A
				cursor = sub_cursor + 1
				sub_cursor = string.find(i, ":", cursor)
				aa = tonumber(i:sub(cursor, sub_cursor - 1)) / 255
				
				polygon.data[poly_count].color = {rr,gg,bb,aa}
				
				-- Load data
				i = i:sub(sub_cursor + 1)
				cursor = 0
				
				local new_vertex = false
				local data_count = 1
				local vertex_count = 1
				
				polygon.data[poly_count].raw = {}
				
				while i:len() > 0 do
				
					if new_vertex then
						data_count = 1
						vertex_count = vertex_count + 1
						new_vertex = false
					end
					
					local sub_cursor = string.find(i, ",")
					local sub_cc = string.find(i, ":")
					
					if (sub_cc == nil) then
						sub_cc = string.find(i, ";")
					end
					
					if sub_cursor == nil then
						sub_cursor = i:len()
					else
						if sub_cc < sub_cursor then
							sub_cursor = sub_cc
							new_vertex = true
						end
					end
					
					local string_test = i:sub(cursor, sub_cursor - 1)
					string_test = string_test:gsub(";", "")
					
					local data_value = tonumber(string_test)
					
					if (data_count == 1) then
						polygon.data[poly_count].raw[vertex_count] = {}
						polygon.data[poly_count].raw[vertex_count].x = data_value
					elseif (data_count == 2) then
						polygon.data[poly_count].raw[vertex_count].y = data_value
					elseif (data_count == 3) then
						if polygon.data[poly_count].kind == "polygon" then
							polygon.data[poly_count].raw[vertex_count].va = data_value
							table.insert(polygon.data[poly_count].cache, {vertex_count, polygon.data[poly_count].raw[vertex_count].va})
						else
							polygon.data[poly_count].segments = data_value
						end
					elseif (data_count == 4) then
						if polygon.data[poly_count].kind == "polygon" then
							polygon.data[poly_count].raw[vertex_count].vb = data_value
							table.insert(polygon.data[poly_count].cache, {vertex_count, polygon.data[poly_count].raw[vertex_count].vb})
						else
							polygon.data[poly_count]._angle = data_value
						end
					end
					
					-- Repeat
					i = i:sub(sub_cursor + 1)
					cursor = 0
					
					data_count = data_count + 1
				
				end
				
				if polygon.data[poly_count].kind == "polygon" then
				
					local cache = polygon.data[poly_count].cache
					
					-- Retrieve lines inside the shape
					local repeats = {}
					local j = 1
					while j <= #cache do
						
						if cache[j][1] ~= 3 and j + 1 <= #cache then
							table.insert(repeats,{cache[j][2], cache[j+1][2]})
							j = j + 2
						else
							j = j + 1
						end
						
					end
					
					-- Remove lines inside the shape
					while #repeats ~= 0 do
					
						j = 1
						while j <= #cache + 1 do
							
							if j == #cache + 1 then
								table.remove(repeats, 1)
								j = #cache + 2
							else
								
								if cache[j][1] == repeats[1][1] and cache[j][2] == repeats[1][2] then
									table.remove(cache, j)
									table.remove(repeats, 1)
									j = #cache + 2
								end
								
								j = j + 1
								
							end
							
						end
					
					end
				
				end
				
				poly_count = poly_count + 1
			
			end
			
		end
		
		line_count = line_count + 1
		-- End load
		file = file:sub(load_line + 1)
		file_pos = 0
		load_line = file:find("\n")
		
		if load_line == nil then
			load_line = file:len()
		end
	end

end

return import