local autosave = {}

autosave.timer = 0
autosave.INTERVAL = 10 * 60 * 60
autosave.BACKUP_INTERVAL = 2 * 60 * 60
autosave.DAYS_TO_KEEP = 7

autosave.today = ""

function recursivelyRename(from, to)
	if love.filesystem.getInfo( from , "directory" ) then
		for _, child in pairs( love.filesystem.getDirectoryItems( from )) do
			recursivelyRename( from .. '/' .. child, to .. '/' .. child)
		end
	elseif love.filesystem.getInfo( from ) then
		love.filesystem.write(to, love.filesystem.read(from))
	end
end

function autosave.init()

	-- Get today's date
	autosave.today = os.date("%m") .. "-" .. os.date("%d") .. "-" .. os.date("%y")

	-- Check save directory
	if not love.filesystem.getInfo( "Autosave" , "directory" ) then
		-- Create autosave folder if it doesn't exist
		love.filesystem.createDirectory("Autosave")
	end
	
	local move_up_autosave_folders = false
	
	-- Check autosave directory
	local autosave_dir = love.filesystem.getDirectoryItems( "Autosave" )
	local i = 1
	while i <= #autosave_dir do
		
		local find_space = string.find(autosave_dir[i], " ")
		
		if find_space ~= nil then
			
			local get_order = autosave_dir[i]:sub(0,find_space-1)
			local get_order_num = tonumber(get_order)
			
			if get_order_num ~= nil then
				
				if get_order_num == 1 then
				
					-- Check if folder 1 is today's date
					local remaining_folder_name = autosave_dir[i]:sub(find_space+1)
					local today_date = autosave.today
					
					-- Only move up the folders if folder 1 exists and is not today's date
					-- double check both condiitions of aboce
					if today_date ~= remaining_folder_name then
						love.filesystem.createDirectory("Autosave/" .. "1 " .. today_date)
						move_up_autosave_folders = true
					end
					
					i = #autosave_dir + 1
				
				end
				
			end
			
		end
		
		i = i + 1
		
	end
	
	-- Create autosave dir for today if it doesn't exist
	if #autosave_dir == 0 then
		love.filesystem.createDirectory("Autosave/" .. "1 " .. autosave.today)
	end
	
	if move_up_autosave_folders then
	
		for i = #autosave_dir, 1, -1 do
			
			local find_space = string.find(autosave_dir[i], " ")
			
			if find_space ~= nil then
				local get_order = autosave_dir[i]:sub(0,find_space-1)
				local get_order_num = tonumber(get_order)
				
				if get_order_num ~= nil then -- Only consider backup folders with appropriate names
				
					if get_order_num >= autosave.DAYS_TO_KEEP then
						-- Delete backups older than autosave.DAYS_TO_KEEP
						recursivelyDelete("Autosave/" .. autosave_dir[i])
					else
						-- Rename the folder to be one day older
						local remaining_folder_name = autosave_dir[i]:sub(find_space+1)
						local new_folder_name = (get_order_num + 1) .. " " .. remaining_folder_name
						love.filesystem.createDirectory("Autosave/" .. new_folder_name)
						recursivelyRename("Autosave/" .. autosave_dir[i], "Autosave/" .. new_folder_name)
						recursivelyDelete("Autosave/" .. autosave_dir[i])
					end
					
				end
				
			end
		end
		
	end

end

return autosave