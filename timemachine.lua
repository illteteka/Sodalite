local tm = {}

TM_NEW_POLYGON  = 0
TM_ADD_VERTEX   = 1
TM_DEL_LINE     = 2

function tm.init()

	tm.data = {}
	tm.location = 1
	tm.cursor = 1
	tm.length = 1
	tm.enabled = true
	
	-- Data the tm remembers
	tm.polygon_loc = 1

end

--[[

we need a TM_PARENT_SWITCHER for when we switch shapes

]]

function tm.store(action, a, b, c, d)

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
			moment.index = a
			moment.kind = b
			moment.color = c
			
			tm.polygon_loc = a
		
		elseif (action == TM_ADD_VERTEX) then
		
			moment.action = TM_ADD_VERTEX
			moment.x = a
			moment.y = b
			moment.sequence = c
		
		elseif (action == TM_DEL_LINE) then
		
			moment.action = TM_DEL_LINE
			moment.index = a
			moment.va = b
			moment.vb = c
		
		end
		
		if tm.data[tm.location] == nil then
			tm.data[tm.location] = {}
		end
		table.insert(tm.data[tm.location], moment)
	end

end

function tm.step()

	if tm.enabled then
		tm.cursor = tm.location
		tm.location = tm.location + 1
		tm.length = tm.location
	end
	
end

return tm