local artboard = {}

artboard.w = 0
artboard.h = 0
artboard.canvas = nil
artboard.visible = true
artboard.active = false
artboard.draw_top = false
artboard.transparent = false
artboard.brush_size = 1
artboard.edited = false

artboard.step_location = 0
artboard.length = 0

function recursivelyDelete( item )
	if love.filesystem.getInfo( item , "directory" ) then
		for _, child in pairs( love.filesystem.getDirectoryItems( item )) do
			recursivelyDelete( item .. '/' .. child )
			love.filesystem.remove( item .. '/' .. child )
		end
	elseif love.filesystem.getInfo( item ) then
		love.filesystem.remove( item )
	end
	love.filesystem.remove( item )
end

function artboard.init()

	-- Clear undo cache
	if love.filesystem.getInfo("cache") == nil then
		love.filesystem.createDirectory("cache")
	else
		recursivelyDelete("cache")
		love.filesystem.createDirectory("cache")
	end
	
	artboard.edited = false
	artboard.step_location = 0
	artboard.length = 0

	-- Reset canvas and collect garbage
	if artboard.canvas ~= nil then
		artboard.canvas:release()
	end
	
	artboard.canvas = nil
	collectgarbage()
	collectgarbage()

	-- Make the w/h a power of 2
	local ax, ay = 2, 2
	while ax < document_w do ax = ax * 2 end
	while ay < document_h do ay = ay * 2 end
	
	artboard.w, artboard.h = ax, ay
	
	-- Create canvas
	artboard.canvas = lg.newCanvas(artboard.w, artboard.h)
	artboard.canvas:setFilter("nearest", "nearest")
	
	-- Clear canvas
	lg.setCanvas(artboard.canvas)
	lg.clear()
	lg.setCanvas()
	
	artboard.brush_size = math.max(math.floor(document_w / 32), 1)

end

function artboard.loadFile(fname, save)

	-- Load image dragged on window
	local fload = io.open(fname, "rb")
	local nfd, err = love.filesystem.newFileData(fload:read("*a"), "")
	local test_load_image = nil
	
	-- Image is nil if the image is corrupt/unsupported
	pcall(function() test_load_image = lg.newImage(nfd) end)

	fload:close()
	
	-- Draw imported image to canvas
	if (test_load_image ~= nil) then
		lg.push()
		lg.setScissor()
		lg.setCanvas(artboard.canvas)
		lg.clear()
		lg.setColor(c_white)
		lg.draw(test_load_image, 0, 0)
		lg.setCanvas()
		lg.pop()
		
		if save then
			artboard.saveCache()
		end
		
		-- Delete image from memory
		test_load_image:release()
		test_load_image = nil
	end

end

function artboard.saveCache(export)

	if love.filesystem.getInfo("cache") == nil then
		love.filesystem.createDirectory("cache")
	end

	if artboard.step_location == artboard.length then
		artboard.step_location = artboard.step_location + 1
		artboard.length = artboard.length + 1
	else
		print(artboard.step_location, artboard.length)
		artboard.step_location = artboard.step_location + 1
		artboard.length = artboard.step_location
	end
	
	--print("aefe" .. (export or " nope"))
	
	local fname = ""
	if not export then
		fname = "cache/art_" .. artboard.step_location .. ".png"
	else
		fname = "cache/export.png"
	end
	
	local save_state = artboard.canvas:newImageData() 
	save_state:encode("png", fname)
	save_state = nil

end

function artboard.add(x, y, a, b, erase)

	artboard.edited = true

	lg.push()
	lg.setScissor()

	local thickness = artboard.brush_size

	lg.setCanvas(artboard.canvas)
	
	lg.setColor(palette.active)
	if erase then lg.setColor(0,0,0,0) lg.setBlendMode("replace", "premultiplied") end
	
	if x == a and y == b then
		if thickness == 1 then
			lg.rectangle("fill", x, y, 1, 1)
		else
			lg.circle("fill", x, y, thickness)
		end
	else
		
		local llerp = lume.lerp
		local dist = lume.distance(x, y, a, b, true)
		
		local i = 1
		while i <= dist do
			local aa, bb = llerp(x, a, i/dist), llerp(y, b, i/dist)
			if thickness == 1 then
				lg.rectangle("fill", aa, bb, 1, 1)
			else
				lg.circle("fill", aa, bb, thickness)
			end
			i = i + 1
		end
		
	end
	
	if erase then lg.setBlendMode("alpha") end
	
	-- The artboard is a power of two and might be larger than the canvas
	-- If the user draws outsize of the canvas but into legal artboard territory, just erase it
	if (document_w < artboard.w) or (document_h < artboard.h) then
		lg.setColor(0,0,0,0)
		lg.setBlendMode("replace", "premultiplied")
		lg.rectangle("fill", document_w + 1, 0, artboard.w - document_w, artboard.h)
		lg.rectangle("fill", 0, document_h + 1, artboard.w, artboard.h - document_h)
		lg.setBlendMode("alpha")
	end
	
	lg.setCanvas()
	
	lg.pop()

end

function artboard.undo()

	artboard.step_location = artboard.step_location - 1
	
	if artboard.step_location <= 0 then
		lg.setCanvas(artboard.canvas)
		lg.clear()
		lg.setCanvas()
		
		artboard.step_location = 0
	else
	
		local ab_path = "cache/art_" .. artboard.step_location .. ".png"
		
		if love.filesystem.getInfo(ab_path) ~= nil then
			artboard.loadFile(love.filesystem.getSaveDirectory() .. "/" .. ab_path, false)
		end
	
	end

end

function artboard.clear()
	lg.setCanvas(artboard.canvas)
	lg.push()
	lg.setScissor()
	lg.clear()
	lg.pop()
	lg.setCanvas()
	artboard.saveCache()
end

return artboard