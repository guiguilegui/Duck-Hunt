-- Create the output file
local file = io.open("RandomStart.tsv", "w")
-- Header of the file
file:write("level" .. "\t".. "DuckType" .. "\t" .. "xmin" .. "\t".. "xmax" .. "\n")
-- Set random seed
math.randomseed(9370707)
-- Assign the reset button
Resetbutton = {}
Resetbutton['Reset'] = true

for iteration = 1,1000 do --iterate the over the number of wanted samples
	joypad.set(Resetbutton) --Start by pushing the Reset button
	--Initialize the fire button
	Fire = {}

	--wait a random amount of time
	for i=1, math.random(10, 200) do --wait a random amount of time
		emu.frameadvance()
	end
	
	
	-- level = math.random(1,99)
	level = 1
	level_digit1 = math.floor(level/10)
	level_digit2 = level % 10
	
	
	for i=1, 2 do -- start a game
		Fire['Fire'] = true
		joypad.set(Fire, 2)

		emu.frameadvance()
	end

	Fire['Fire'] = false --stop pressing fire
	joypad.set(Fire, 2)


	while memory.readbyte(0x4C) == 0 do --wait until the game starts
		emu.frameadvance()
		memory.writebyte(0xC1,level_digit1 * 16 + level_digit2) 	
	end


	--Shoot the duck
	for j=1, 2 do
		Fire['Fire'] = true
		joypad.set(Fire, 2)
		emu.frameadvance()

	end
	--Wait for results
	for j=1, 3 do
		Fire['Fire'] = false
		joypad.set(Fire, 2)
		emu.frameadvance()

	end
	--Check the hitbox data		
	xposarray = {}
	
	for i=1, 16 do
		mem = memory.readbyte(512+4*i-1) 
		if mem ~= 0xF4 then
			xposarray[i] = mem
		end
	end
	--console.write(level.. "\t".. memory.readbyte(0x3F) .. "\t" .. math.min(unpack(xposarray)) .. "\t".. math.max(unpack(xposarray)) .. "\n")
	-- output to file
	file:write(level.. "\t".. memory.readbyte(0x3F) .. "\t" .. math.min(unpack(xposarray)) .. "\t".. math.max(unpack(xposarray)) .. "\n")
	file:flush()

end
file:close()-- close output file