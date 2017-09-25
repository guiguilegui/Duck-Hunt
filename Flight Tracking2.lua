-- Create the output file
local file = io.open("FlightTracking2.tsv", "w")
-- Header of the file
file:write("Iteration" .. "\t" .. "level" .. "\t".. "Time" .. "\t".. "DuckType" .. "\t" .. "xmin" .. "\t".. "xmax" .. "\t".. "ymin" .. "\t".. "ymax" .. "\n")
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
	for i=1, math.random(10, 200) do 
		emu.frameadvance()
	end
	
	--assign a random level number
	level = math.random(1,99)
	level_digit1 = math.floor(level/10)
	level_digit2 = level % 10
	
	-- start the game
	for i=1, 2 do 
		Fire['Fire'] = true
		joypad.set(Fire, 2)

		emu.frameadvance()
	end

	--stop pressing fire
	Fire['Fire'] = false 
	joypad.set(Fire, 2)

	--wait until the game starts
	while memory.readbyte(0x4C) == 0 do 
		emu.frameadvance()
		memory.writebyte(0xC1,level_digit1 * 16 + level_digit2) 	
	end
	
	t = 5
	
	while memory.readbyte(0x4C) ~= 0 or memory.readbyte(0x0203) ~= 0xF4 do -- capture info until duck exits screen

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
		xmin =  math.huge
		ymin =  math.huge
		xmax = -math.huge
		ymax = -math.huge
		
		for i=1, 16 do --Get the min and the max for the boxes
			memx = memory.readbyte(512+4*i-1) 
			memy = memory.readbyte(512+4*i-4) 
			if memx ~= 0xF4 then
				xmin = math.min(xmin, memx)
				xmax = math.max(xmax, memx)
			end		
			if memy ~= 0xF4 then
				ymin = math.min(ymin, memy)
				ymax = math.max(ymax, memy)
			end		
		end
		
		if xmin ~= math.huge and ymin ~= math.huge then
		-- console.write(
		file:write(
			iteration .. "\t" ..
			level.. "\t"..
			t.. "\t" .. -- Time
			memory.readbyte(0x3F) .. "\t" .. -- duck type
			xmin .. "\t".. 
			xmax .. "\t".. 
			ymin .. "\t".. 
			ymax .. "\n"
		)
		end
		for j=1, 3 do
			emu.frameadvance()
		end
		memory.writebyte(0xBA,3) --replenish the munitions
		t = t + 8
	end
	
	file:flush()

end
file:close() -- close output file