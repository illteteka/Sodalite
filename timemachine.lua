local tm = {}

TM_NEW_POLYGON   = 0
TM_ADD_VERTEX    = 1
TM_DEL_LINE      = 2
TM_MOVE_VERTEX   = 3
TM_CHANGE_COLOR  = 4
TM_PICK_LAYER    = 5
TM_MOVE_LAYER    = 6
TM_ADD_ELLIPSE   = 7
TM_ELLIPSE_SEG   = 8
TM_ELLIPSE_ANGLE = 9

function tm.init()

	tm.data = {}
	tm.location = 1
	tm.cursor = 1
	tm.length = 1
	tm.enabled = true
	
	-- Data the tm remembers
	tm.polygon_loc = 1

end

function tm.store(action, a, b, c, d, e)

	if tm.enabled then
		-- Remove items from the undo array tm.data before overwriting the slot
		if (tm.location < tm.length) then

			local i
			for i = #tm.data, tm.location, -1 do

				table.remove(tm.data, i)
				tm.length = tm.location

			end

		end

		local moment = {}
		
		if (action == TM_NEW_POLYGON) then
		
			moment.action = TM_NEW_POLYGON
			moment.kind = a
			moment.color = b
		
		elseif (action == TM_ADD_VERTEX) then
		
			moment.action = TM_ADD_VERTEX
			moment.x = a
			moment.y = b
			moment.sequence = c
			moment.grid = not ui.toolbar[ui.toolbar_grid].active
			moment.gx, moment.gy = tm.repairGrid(a, b)
		
		elseif (action == TM_DEL_LINE) then
		
			moment.action = TM_DEL_LINE
			moment.index = a
			moment.va = b
			moment.vb = c
		
		elseif (action == TM_MOVE_VERTEX) then
		
			moment.action = TM_MOVE_VERTEX
			moment.index = a
			moment.x = b
			moment.y = c
			moment.ox = d
			moment.oy = e
			moment.grid = not ui.toolbar[ui.toolbar_grid].active
			moment.gx, moment.gy = tm.repairGrid(b, c)
			moment.gox, moment.goy = tm.repairGrid(d, e)
		
		elseif (action == TM_CHANGE_COLOR) then
		
			moment.action = TM_CHANGE_COLOR
			local ca = {a[1], a[2], a[3], a[4]}
			moment.original = ca
			local cb = {b[1], b[2], b[3], b[4]}
			moment.new = cb
		
		elseif (action == TM_PICK_LAYER) then
		
			moment.action = TM_PICK_LAYER
			moment.original = a
			moment.new = b
			moment.created_layer = c
			moment.trash_layer = d
		
		elseif (action == TM_MOVE_LAYER) then
		
			moment.action = TM_MOVE_LAYER
			moment.original = a
			moment.new = b
		
		elseif (action == TM_ADD_ELLIPSE) then
		
			moment.action = TM_ADD_ELLIPSE
			moment.segments = a
			moment._angle = b
		
		elseif (action == TM_ELLIPSE_SEG) then
		
			moment.action = TM_ELLIPSE_SEG
			moment.original = a
			moment.new = b
			
		elseif (action == TM_ELLIPSE_ANGLE) then
		
			moment.action = TM_ELLIPSE_ANGLE
			moment.original = a
			moment.new = b
		
		end
		
		if tm.data[tm.location] == nil then
			tm.data[tm.location] = {}
		end
		table.insert(tm.data[tm.location], moment)
	end

end

function tm.repairGrid(a, b)
	if ui.toolbar[ui.toolbar_grid].active == false then
		a = a + math.floor(camera_x)
		b = b + math.floor(camera_y)
		a = ((math.floor((mx - camera_x) / grid_w) * grid_w) + (grid_x % grid_w) + math.floor(camera_x))
		b = ((math.floor((my - camera_y) / grid_h) * grid_h) + (grid_y % grid_h) + math.floor(camera_y))
	end
	return a, b
end

function tm.step()

	if tm.enabled then
		tm.cursor = tm.location
		tm.location = tm.location + 1
		tm.length = tm.location
	end
	
end

return tm