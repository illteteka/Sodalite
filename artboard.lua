local artboard = {}

artboard.w = 0
artboard.h = 0
artboard.canvas = nil
artboard.visible = true
artboard.active = false
artboard.draw_top = false
artboard.transparent = false

function artboard.init()

	-- Reset canvas and collect garbage
	artboard.canvas = nil
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

end

function artboard.save()

end

function artboard.add(x, y, a, b, erase)

	local thickness = math.max(math.floor(document_w / 32), 1)

	lg.setCanvas(artboard.canvas)
	
	lg.setColor(palette.active)
	if erase then lg.setColor(0,0,0,0) lg.setBlendMode("replace", "premultiplied") end
	
	if x == a and y == b then
		lg.rectangle("fill", x - (thickness/2), y - (thickness/2), thickness, thickness)
	else
		
		local llerp = lume.lerp
		local dist = lume.distance(x, y, a, b, true)
		
		local i = 1
		while i <= dist do
			local aa, bb = llerp(x, a, i/dist), llerp(y, b, i/dist)
			lg.rectangle("fill", aa - (thickness/2), bb - (thickness/2), thickness, thickness)
			i = i + 1
		end
		
	end
	
	if erase then lg.setBlendMode("alpha") end
	
	lg.setCanvas()

end

return artboard