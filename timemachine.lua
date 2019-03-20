local tm = {}

TM_NEW_POLYGON  = 0
TM_ADD_VERTEX   = 1
TM_ADD_LINE     = 2
TM_ADD_TRIANGLE = 3
TM_DEL_LINE     = 4

function tm.init()

	tm.data = {}
	tm.location = 1
	tm.length = 1

end

function tm.store(action, a, b, c, d)

	-- Remove items from the undo array tm.data before overwriting the slot
	--[[
	if (tm.location < tm.length) then

		local i
		for i = #tm.data, tm.location, -1 do

			table.remove(tm.data, i)
			tm.length = tm.location

		end

	end
	--]]

	local moment = {}
	
	if (action == TM_NEW_POLYGON) then
	
		moment.action = TM_NEW_POLYGON
		moment.index = a
		moment.kind = b
		moment.color = c
	
	elseif (action == TM_ADD_VERTEX) then
	
		moment.action = TM_ADD_VERTEX
		moment.parent = a
		moment.index = b
		moment.x = c
		moment.y = d
	
	elseif (action == TM_ADD_LINE) then
	
		moment.action = TM_ADD_LINE
		moment.parent = a
		moment.va = b
		moment.vb = c
	
	elseif (action == TM_ADD_TRIANGLE) then
	
		moment.action = TM_ADD_TRIANGLE
		moment.parent = a
		moment.va = b
		moment.vb = c
	
	elseif (action == TM_DEL_LINE) then
	
		moment.action = TM_DEL_LINE
		moment.parent = a
		moment.index = b
		moment.va = c
		moment.vb = d
	
	end
	
	if tm.data[tm.location] == nil then
		tm.data[tm.location] = {}
	end
	table.insert(tm.data[tm.location], moment)

end

function tm.step()

	tm.location = tm.location + 1
	tm.length = tm.location
	
end

return tm