polygon = require "polygon"

lg = love.graphics

dinosaur = {}
monster = {}

function love.load()
	
	dinosaur = polygon.new("dino.lol")
	monster = polygon.new("scary.lol")
	
	dinosaur.x = 300
	dinosaur.y = 100
	dinosaur.scale = 0.7
	
	monster.x = 112
	monster.y = 400
	monster.scale = 0.2

end

function love.draw()

	polygon.draw(dinosaur)
	polygon.draw(monster)

end

function love.update(dt)

	local lk = love.keyboard

	-- Movement
	if lk.isDown("up") then
		dinosaur.y = dinosaur.y - 1
	end
	
	if lk.isDown("down") then
		dinosaur.y = dinosaur.y + 1
	end
	
	if lk.isDown("left") then
		dinosaur.x = dinosaur.x - 1
	end
	
	if lk.isDown("right") then
		dinosaur.x = dinosaur.x + 1
	end
	
	-- Scale
	if lk.isDown("-") then
		dinosaur.scale = dinosaur.scale - 0.01
		monster.scale = monster.scale - 0.01
	end
	
	if lk.isDown("=") then
		dinosaur.scale = dinosaur.scale + 0.01
		monster.scale = monster.scale + 0.01
	end
	
	-- Movement
	if lk.isDown("w") then
		monster.y = monster.y - 1
	end
	
	if lk.isDown("s") then
		monster.y = monster.y + 1
	end
	
	if lk.isDown("a") then
		monster.x = monster.x - 1
	end
	
	if lk.isDown("d") then
		monster.x = monster.x + 1
	end

end