local pkg = {}

-- Metadata
pkg.name = "HotCorners"
pkg.version = "1.0"
pkg.author = "Joao Rietra <joaorietra@gmail.com>"
pkg.github = "@jhlr"
pkg.license = "MIT - https://opensource.org/licenses/MIT"

-- Error messages
local functionOrNil = "Callback has to be a function or nil."
local numberOrNil = "Delay has to be a number or nil."

-- Properties
-- Delta is in pixels
-- area to be considered as a corner
pkg.delta = 10

-- Delay is in seconds
-- avoid triggering repeatedly
pkg.delay = 1

function newCorner()
	local corner =  {
		one = nil,
		two = nil,
		busy = false,
		delay = nil,
		timer = nil
	}
	corner.timer = hs.timer.new(0, function()
		if corner.two and corner.one then
			corner.one()
		end
		corner.busy = false
	end)
	return corner
end

function trigger(corner)
	if not corner.two then
		if not corner.one or corner.busy then
			return
		end

		local delay = pkg.delay
		if corner.delay ~= nil then
		 	delay = corner.delay
		end

		if delay >= 0 then
			corner.busy = true
		end
		corner.one()
		if delay >= 0 then
			corner.timer:setNextTrigger(delay)
		end
	elseif not corner.busy then
		corner.busy = true
		corner.timer:setNextTrigger(corner.delay)
	else
		corner.timer:stop()
		corner.two()
		corner.busy = false
	end
end

-- Corners
local ul = newCorner()
local ll = newCorner()
local ur = newCorner()
local lr = newCorner()

-- Local variables
local sframe
local mouseWatcher
local screenWatcher

-- Local booleans
local middle = true
local delay = 1

function updateScreen()
	sframe = hs.screen.primaryScreen():fullFrame()
	middle = false
end

function pkg:init()
	screenWatcher = hs.screen.watcher.new(updateScreen)
	mouseWatcher = hs.eventtap.new({
		hs.eventtap.event.types.mouseMoved
	}, function(e)
		local p = e:location()
		-- Inside the main screen ?
		if p.x >= sframe.x and p.x < (sframe.x + sframe.w) and
			p.y >= sframe.y and p.y < (sframe.y + sframe.h) then
			p.x = p.x - sframe.x
			p.y = p.y - sframe.y
		else
			middle = true
			return
		end

		-- Check corners
		if p.x < pkg.delta and p.y < pkg.delta then
			if middle then
				trigger(ul)
			end
			middle = false
		elseif p.x < pkg.delta and p.y > (sframe.h - pkg.delta) then
			if middle then
				trigger(ll)
			end
			middle = false
		elseif p.x > (sframe.w - pkg.delta) and p.y < pkg.delta then
			if middle then
				trigger(ur)
			end
			middle = false
		elseif p.x > (sframe.w - pkg.delta) and p.y > (sframe.h - pkg.delta) then
			if middle then
				trigger(lr)
			end
			middle = false
		else
			middle = true
		end
	end)
end

function pkg:start()
	updateScreen()
	mouseWatcher:start()
	screenWatcher:start()
	return self
end

function pkg:stop()
	mouseWatcher:stop()
	screenWatcher:stop()
	return self
end

function setCorner(corner, one, delay, two)
	assert(one == nil or type(one) == "function", functionOrNil)
	assert(two == nil or type(two) == "function", functionOrNil)
	assert(delay == nil or type(delay) == "number", numberOrNil)
	corner.one = one
	corner.two = two
	corner.busy = false
	if not delay or delay >= 0 then
		corner.delay = delay
	end
end

function pkg:setUpperLeft(one, delay, two)
	setCorner(ul, one, delay, two)
	return self
end

function pkg:setLowerLeft(one, delay, two)
	setCorner(ll, one, delay, two)
	return self
end

function pkg:setUpperRight(one, delay, two)
	setCorner(ur, one, delay, two)
	return self
end

function pkg:setLowerRight(one, delay, two)
	setCorner(lr, one, delay, two)
	return self
end

return pkg
