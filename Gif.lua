-- Set random seed
math.randomseed(9370707)
-- Assign the reset button
Resetbutton = {}
Resetbutton['Reset'] = true

for iteration = 1,50 do --iterate the over the number of wanted samples
	joypad.set(Resetbutton) --Start by pushing the Reset button
	--Initialize the fire button
	Fire = {}


	for i=1, math.random(10, 100) do --wait a random amount of time
		emu.frameadvance()
	end
	
	
	for i=1, 2 do -- start a game
		Fire['Fire'] = true
		joypad.set(Fire, 2)
		emu.frameadvance()
	end

	Fire['Fire'] = false --stop pressing fire
	joypad.set(Fire, 2)

	while memory.readbyte(0x004C) == 0 do --wait until the game starts
		emu.frameadvance()
	end

	i = 0

	while memory.readbyte(0x004C) ~= 0 do --record until background changes
		emu.frameadvance()
		
		i = i + 1
		client.screenshot("img/img".. string.format("%03d", i) .. "/Duck-" .. string.format("%02d", iteration) ..".png") --save image
		

	end
	console.write('iter' .. iteration.. "\n")
end
console.write(i .. "\n")
console.write('fini\n')




-- highlight the duck by differentiating the image with base.png
os.execute('FOR /R %i IN (Duck-*.png) DO (compare "%i" ./img/Base.png -compose Src -highlight-color White -lowlight-color Black :- | composite -compose CopyOpacity - "%i" "%~di%~piN%~ni%~xi")')
-- Stack all ducks image in one png 
os.execute('FOR /D %i in (./img/*) DO convert ./img/base.png ./img/%i/NDuck-*.png -layers flatten ./img/allducks%i.png')
-- Convert all pngs to a gif
os.execute('convert -delay 1.66667 -loop 0 ./img/allducksimg*.png ./img/ARGHDUCKS.gif') -- 1.6667 = 60 framerate / 8 frame to shoot







