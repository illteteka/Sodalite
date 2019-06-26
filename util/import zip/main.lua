scaryword = ""

function love.filedropped(file)
	love.filesystem.mount(file, "content")
	local waszip = false
	waszip = love.filesystem.getInfo("content/beans.txt")
	
	if waszip then
		for line in love.filesystem.lines("content/beans.txt") do
		  scaryword = line
		end
		
		local fname = file:getFilename()
		love.filesystem.unmount(fname)
	end
end

function love.draw()
	love.graphics.print(scaryword, 100, 100)
end