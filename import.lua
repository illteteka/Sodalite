local import = {}

FILE_EXTENSION = "lol"

-- Import vars
line_count = 0
file_state = "SETUP"
file_pos = 0

function import.open(file)
	
	local fname = file:getFilename()
	local file_ext = fname:sub(fname:len() - FILE_EXTENSION:len() + 1)
	
	if (file_ext == FILE_EXTENSION) then
		local file_contents = file:read("string")
		-- Reset import vars
		line_count = 0
		file_state = "SETUP"
		file_pos = 0
		
		ui.popup = {}
		ui_active = true
		ui.context_menu = {}
		ui.title_active = false
		
		tm.init()
		polygon.data = {}
		ui.layer = {}
		
		import.read(file_contents)
		
		resetCamera()
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
				-- Document name
				local sub_cursor = string.find(i, ",")
				document_name = i:sub(cursor, sub_cursor - 1)
				
				-- Width
				cursor = sub_cursor + 1
				sub_cursor = string.find(i, ",", cursor)
				document_w = tonumber(i:sub(cursor, sub_cursor - 1))
				
				-- Height
				cursor = sub_cursor + 1
				sub_cursor = string.find(i, ";", cursor)
				document_h = tonumber(i:sub(cursor, sub_cursor - 1))
				
				file_state = "LINES"
			elseif file_state == "LINES" then
				
				table.insert(polygon.data, {})
				polygon.data[poly_count].cache = {}
				
				-- Get lines
				while i:len() > 1 do
				
					local aa, bb
				
					-- A
					local sub_cursor = string.find(i, "-")
					aa = tonumber(i:sub(cursor, sub_cursor - 1))
					
					-- B
					cursor = sub_cursor + 1
					sub_cursor = string.find(i, ",")
					if (sub_cursor == nil) then
						sub_cursor = string.find(i, ";")
					end
					bb = tonumber(i:sub(cursor, sub_cursor - 1))
					
					table.insert(polygon.data[poly_count].cache, {aa, bb})
					
					-- Repeat
					i = i:sub(sub_cursor + 1)
					cursor = 0
				
				end
				
				file_state = "DATA"
				
			elseif file_state == "DATA" then
			
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
				rr = tonumber(i:sub(cursor, sub_cursor - 1))
				
				-- G
				cursor = sub_cursor + 1
				sub_cursor = string.find(i, ",", cursor)
				gg = tonumber(i:sub(cursor, sub_cursor - 1))
				
				-- B
				cursor = sub_cursor + 1
				sub_cursor = string.find(i, ",", cursor)
				bb = tonumber(i:sub(cursor, sub_cursor - 1))
				
				-- A
				cursor = sub_cursor + 1
				sub_cursor = string.find(i, ":", cursor)
				aa = tonumber(i:sub(cursor, sub_cursor - 1))
				
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
						polygon.data[poly_count].raw[vertex_count].va = data_value
					elseif (data_count == 4) then
						polygon.data[poly_count].raw[vertex_count].vb = data_value
					end
					
					-- Repeat
					i = i:sub(sub_cursor + 1)
					cursor = 0
					
					data_count = data_count + 1
				
				end
				
				file_state = "LINES"
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