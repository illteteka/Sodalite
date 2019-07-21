--[[
MIT License

Copyright (c) 2019 Nick Gilmartin

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
--]]

local import = {}

FILE_EXTENSION = "lol"

-- Import vars
line_count = 0
file_state = "SETUP"
file_pos = 0

file = nil

function import.open(fname)
	
	local tbl = {}
	tbl.x = 0
	tbl.y = 0
	tbl.scale = 1
	
	local file_dot = string.find(fname,"%.")
	local file_ext = ""
	
	if file_dot ~= nil then
		file_ext = fname:sub(file_dot + 1)
	end
	
	if (file_ext == FILE_EXTENSION) then
	
		file = love.filesystem.getInfo(fname)
		
		if (not file) then
			print("Error: could not load .lol file")
		else
		
			-- Reset import vars
			line_count = 0
			file_state = "SETUP"
			file_pos = 0
			
			import.read(tbl, fname)
		
		end
		
	end
	
	return tbl

end

function import.read(tbl, file)

	local poly_count = 1
	
	local i
	for line in love.filesystem.lines(file) do
		local load_line = line:find("\n")
	
		i = line:sub(file_pos,load_line)
		i = i:gsub("\n", "")
		
		-- Start load
		if (line_count ~= 0) then
			local cursor = 0
			
			if file_state == "SETUP" then
				-- Width
				local sub_cursor = string.find(i, ",")
				tbl.width = tonumber(i:sub(cursor, sub_cursor - 1))
				
				-- Height
				cursor = sub_cursor + 1
				sub_cursor = string.find(i, ";", cursor)
				tbl.height = tonumber(i:sub(cursor, sub_cursor - 1))
				
				file_state = "DATA"
				
			elseif file_state == "DATA" then
			
				table.insert(tbl, {})
			
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
				
				tbl[poly_count].visible = vv
				
				-- Shape kind
				cursor = sub_cursor + 1
				sub_cursor = string.find(i, ",", cursor)
				tbl[poly_count].kind = i:sub(cursor, sub_cursor - 1)
				
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
				
				tbl[poly_count].color = {rr,gg,bb,aa}
				
				-- Load data
				i = i:sub(sub_cursor + 1)
				cursor = 0
				
				local new_vertex = false
				local data_count = 1
				local vertex_count = 1
				
				tbl[poly_count].raw = {}
				
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
						tbl[poly_count].raw[vertex_count] = {}
						tbl[poly_count].raw[vertex_count].x = data_value
					elseif (data_count == 2) then
						tbl[poly_count].raw[vertex_count].y = data_value
					elseif (data_count == 3) then
						if tbl[poly_count].kind == "polygon" then
							tbl[poly_count].raw[vertex_count].va = data_value
						else
							tbl[poly_count].segments = data_value
						end
					elseif (data_count == 4) then
						if tbl[poly_count].kind == "polygon" then
							tbl[poly_count].raw[vertex_count].vb = data_value
						else
							tbl[poly_count]._angle = data_value
						end
					end
					
					-- Repeat
					i = i:sub(sub_cursor + 1)
					cursor = 0
					
					data_count = data_count + 1
				
				end
				
				poly_count = poly_count + 1
			
			end
			
		end
		
		line_count = line_count + 1
		-- End load
		file_pos = 0
		load_line = line:find("\n")
		
		if load_line == nil then
			load_line = line:len()
		end
	end

end

return import