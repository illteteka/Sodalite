COMP_PATH = "\"C:\\Users\\Sick\\Documents\\Git\\MDOS\\"
LUA_PATH = "\"C:\\Users\\Sick\\Documents\\LuaJIT-2.0.0\\src\""

BINS = {}
LUAS = {}
DIRS = {}

local handle = io.popen('dir /b')

for line in handle:lines() do
	if string.match(line, ".") then
		
		if string.match(line, ".txt") or string.match(line, ".pal") or string.match(line, ".ttf") then
			table.insert(BINS, line)
		elseif string.match(line, ".lua") then
			table.insert(LUAS, line)
		elseif not (string.match(line, ".bat") or string.match(line, "util") or string.match(line, "compile")) then
			table.insert(DIRS, line)
		end
		
	end
end

handle:close()

---------------------------------------

os.execute("mkdir " .. COMP_PATH .. "\"compile\"")

local i
for i = 1, #DIRS do
os.execute("mkdir " .. COMP_PATH .. "\"compile\\" .. DIRS[i] .. "\"")
os.execute("xcopy " .. COMP_PATH .. DIRS[i] .. "\" " .. COMP_PATH .. "compile\\" .. DIRS[i] .. "\"")
end

local i
for i = 1, #BINS do
os.execute("copy " .. COMP_PATH .. BINS[i] .. "\" " .. COMP_PATH .. "compile\\" .. BINS[i] .. "\"")
end

local i
for i = 1, #LUAS do
os.execute("cd " .. LUA_PATH .. " & " .. "luajit.exe -b " .. COMP_PATH .. LUAS[i] .. "\" " .. COMP_PATH .. "\\compile\\" .. LUAS[i] .. "\"")
end

os.execute("cd " .. COMP_PATH .. "\\compile\" & 7z a -r game.zip * & ren game.zip game.love & move game.love ../game.love & RMDIR /S /Q .")