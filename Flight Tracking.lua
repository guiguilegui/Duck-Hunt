-- Create the output file
local file = io.open("FlightTracking.tsv", "w")
-- Header of the file
file:write("Iteration" .. "\t" .. "Time" .. "\t".. "DuckType" .. "\t" .. "xmin" .. "\t".. "xmax" .. "\t"..  "ymin" .. "\t".. "ymax" .. "\n")

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
	
	
	
	for i=1, 2 do -- start a game
		Fire['Fire'] = true
		joypad.set(Fire, 2)

		emu.frameadvance()
	end

	Fire['Fire'] = false --stop pressing fire
	joypad.set(Fire, 2)


	while memory.readbyte(0x4C) == 0 do --wait until the game starts
		emu.frameadvance()
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
		
		for i=1, 16 do
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
		
		-- if non-bogus hitbox, output to file
		if xmin ~= math.huge and ymin ~= math.huge then
		-- console.write(
		file:write(
			iteration .. "\t" ..
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
file:close()-- close output file