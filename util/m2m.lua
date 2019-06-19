--[[

M2M: A magma raw+svg decompiler
alpha v0.1 - triangle stripper

--]]

export = require "export"

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

f_raw = nil
f_svg = nil

document_name = "converted"
document_w = 512
document_h = 512

ui = {}
ui.layer = {}

polygon = {}
polygon.data = {}

shape_count = 0

-- Get file names from args

arg[1] = arg[1] or ""
arg[2] = arg[2] or ""

if string.match(arg[1], "raw") then
	f_raw = arg[1]
elseif string.match(arg[1], "svg") then
	f_svg = arg[1]
end

if string.match(arg[2], "raw") then
	f_raw = arg[2]
elseif string.match(arg[2], "svg") then
	f_svg = arg[2]
end

if f_raw == nil or f_svg == nil then
	print("Error: missing .svg or .raw input")
	print("Ex: m2m.lua ex.raw ex.svg")
	return
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

function addVertex(x, y, a, b)

	local vert = {}
	vert.x = x
	vert.y = y
	
	if a then
	vert.va = a
	end
	
	if b then
	vert.vb = b
	end
	
	return vert

end

function numToTable(str, color)

	local tab = {}
	
	while str ~= "" do
	
		local com_find = string.find(str, ",")
		local spa_find = string.find(str, " ")
		
		if spa_find ~= nil and spa_find < com_find then
			table.insert(tab, tonumber(str:sub(0, spa_find - 1)))
			str = str:sub(spa_find + 1)
		elseif com_find ~= nil then
			table.insert(tab, tonumber(str:sub(0, com_find - 1)))
			str = str:sub(com_find + 1)
		else
			table.insert(tab, tonumber(str))
			str = ""
		end
	
	end
	
	if color then
		tab[1] = tab[1] / 255
		tab[2] = tab[2] / 255
		tab[3] = tab[3] / 255
		table.insert(tab, 1)
	end
	
	return tab

end

-- Open .svg

io.open(f_svg, "r")

local i
for i in io.lines(f_svg) do
	
	-- todo: load width + height from svg
	
	if string.match(i, "polygon points") and not string.match(i, "stroke-opacity:0") then
	
		-- Retrieve raw info from line
		local find_points = string.find(i, "points=\"")
		i = i:sub(find_points + 8)
		local end_points = string.find(i, "\"")
		
		local raw_points = i:sub(0,end_points - 1)
		
		i = i:sub(end_points + 18)
		end_points = string.find(i, ")")
		local raw_rgb = i:sub(0,end_points - 1)
		
		-- if rgb is different or if shape doesnt contain points in current shape, break!
		
		-- else...
		
		local v = numToTable(raw_points)
		local ap, bp = -1, -1
		
		-- Match points
		if polygon.data[shape_count] ~= nil then
			local j
			for j = 1, #polygon.data[shape_count].raw do
			
				local p = polygon.data[shape_count].raw[j]
				if p.x == v[3] and p.y == v[4] then
					ap = j
				elseif p.x == v[5] and p.y == v[6] then
					bp = j
				end
			
			end
		end
		
		-- Add new vertex to shape
		if ap ~= -1 and bp ~= -1 then
			
			-- Find and delete line ap,bp
			local j = 1
			while j <= #polygon.data[shape_count].cache do
			
				local tl = polygon.data[shape_count].cache[j]
				if (tl[1] == ap and tl[2] == bp) or (tl[2] == ap and tl[1] == bp) then
					table.remove(polygon.data[shape_count].cache, j)
					j = #polygon.data[shape_count].cache + 1
				end
				
				j = j + 1
			
			end
			
			-- Make new vertex
			table.insert(polygon.data[shape_count].raw, addVertex(v[1], v[2]))
			local new_p = #polygon.data[shape_count].raw
			
			-- Make new lines
			table.insert(polygon.data[shape_count].cache, {new_p, bp})
			table.insert(polygon.data[shape_count].cache, {new_p, ap})
			
			-- Update vertex
			polygon.data[shape_count].raw[new_p].va = bp
			polygon.data[shape_count].raw[new_p].vb = ap
			
		else
		
			shape_count = shape_count + 1
			
			ui.addLayer()
			-- Make a new polygon
			polygon.data[shape_count] = {}
			polygon.data[shape_count].cache = {}
			polygon.data[shape_count].raw = {}
			polygon.data[shape_count].kind = "polygon"
			polygon.data[shape_count].color = numToTable(raw_rgb, true)
			
			local v = numToTable(raw_points)
			
			-- Add temp lines to cache
			table.insert(polygon.data[shape_count].cache, {1,2})
			table.insert(polygon.data[shape_count].cache, {1,3})
			table.insert(polygon.data[shape_count].cache, {3,2})
			
			-- Add first triangle to shape
			table.insert(polygon.data[shape_count].raw, addVertex(v[1], v[2], 2, 3))
			table.insert(polygon.data[shape_count].raw, addVertex(v[3], v[4]))
			table.insert(polygon.data[shape_count].raw, addVertex(v[5], v[6], 2))
		
		end
		
		
	end
	
end

--print_r(polygon.data)
export.saveLOL()