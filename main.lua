function love.load()
    require 'luafft'

    sound = love.sound.newSoundData('test1.mp3')
    rate = sound:getSampleRate()
    channels = sound:getChannels()
    print(rate)
    print(channels)

    music = love.audio.newSource(sound)
    music:play()

    spectrum = {}
    gTime = 0
    -- love.graphics.setLine(1,'smooth')
end

function love.update(dt)
	local curSample = music:tell('samples')
	local wave = {}
	local size = next_possible_size(2048)
    -- print(curSample)
    if channels == 2 then
        for i=curSample, (curSample+(size-1) / 2) do
            local sample = (sound:getSample(i * 2) + sound:getSample(i * 2 + 1)) * 0.5
            table.insert(wave,complex.new(sample,0))
        end
    else
        for i=curSample, curSample+(size-1) do
            table.insert(wave,complex.new(sound:getSample(i),0))
        end
    end
    
	local spec = fft(wave,false)
	--local reconstructed = fft(spec,true)
	
	
	function divide(list, factor)
		for i,v in ipairs(list) do
			list[i] = list[i] / factor
		end
	end
	
	--divide(reconstructed,size)
	divide(spec,size/2)
	
	spectrum = spec
end

function love.draw()
    count = 0
	local division = 10
	for i=1, #spectrum/division do
	--for i=1, #spectrum do
	--for i=1, 20 do
		local height = love.graphics.getHeight()
		local width = love.graphics.getWidth()
		local dist = width / (#spectrum/division)
		
		local v = spectrum[i]
		local n = height * 2 * v:abs(),0
        
		love.graphics.rectangle(
			'fill',
			(i-1)*dist,height/2 - n/2,
			5,n
		)
	    if n > 350 and i < 7 and count == 0 then
            count = 1
            print(i, n)
            max = 255
            r = love.math.random( max )
            g = love.math.random( max )
            b = love.math.random( max )
            love.graphics.setBackgroundColor( r, g, b )
        end
	    --love.graphics.print(n,0,i*12)
	end
end

function limit_max(v,limit)
	if v > limit then
		return limit
	end
	return v
end

function limit_min(v,limit)
	if v < limit then
		return limit
	end
	return v
end

