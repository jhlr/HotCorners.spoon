local pkg = {}

-- Metadata
pkg.name = "HotCorners"
pkg.version = "1.0"
pkg.author = "Joao Rietra <joaorietra@gmail.com>"
pkg.github = "@jhlr"
pkg.license = "MIT - https://opensource.org/licenses/MIT"

-- Error messages
local functionOrNil = "Callback has to be a function or nil."
local numberOrNil = "Delay has to be nil or a number >= 0."

-- Properties
-- Delta is in pixels
-- area to be considered as a corner
pkg.delta = 10

-- Delay is in seconds
-- avoid triggering repeatedly
pkg.delay = 1

-- Local variables
local sframe
local mouseWatcher
local screenWatcher

-- Local booleans
local moved = false
local middle = true

-- Corners
local ul, ll, ur, lr

function newCorner()
	local corner =  {
		one = nil,
		two = nil,
		hold = nil,
		busy = false,
		delay = nil,
		timer = nil
	}
	corner.timer = hs.timer.new(0, function()
		if corner.hold and not moved then
			-- Stayed inside the corner since the trigger
			corner.hold()
		elseif (corner.two or corner.hold) and corner.one and corner.busy then
			-- Left but did not enter again
			corner.one()
		end
		corner.busy = false
	end)
	return corner
end

function trigger(corner)
	local delay = pkg.delay
	if corner.delay ~= nil then
		delay = corner.delay
	end
	if not corner.hold and not corner.two then
		-- Only single tap
		if not corner.one or corner.busy then
			return
		end
		if delay >= 0 then
			corner.busy = true
		end
		corner.one()
		if delay >= 0 then
			corner.timer:setNextTrigger(delay)
		end
	elseif corner.two and corner.busy then
		-- Second tap
		-- dont trigger corner.one
		corner.timer:stop()
		corner.two()
		corner.busy = false
	elseif not corner.busy then
		-- moved will stay false if cursor stays inside
		moved = false
		corner.busy = true
		corner.timer:setNextTrigger(delay)
	end
end


function updateScreen()
	sframe = hs.screen.primaryScreen():fullFrame()
	middle = false
end

function pkg:init()
	ul = newCorner()
	ur = newCorner()
	ll = newCorner()
	lr = newCorner()
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
			-- outside the screen is not corner
			moved = true
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
			moved = true
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

function setCorner(corner, one, two, hold, delay)
	assert(one == nil or type(one) == "function", functionOrNil)
	assert(two == nil or type(two) == "function", functionOrNil)
	assert(hold == nil or type(hold) == "function", functionOrNil)
	assert(delay == nil or (type(delay) == "number" and delay >= 0), numberOrNil)

	corner.one = one
	corner.two = two
	corner.hold = hold

	corner.busy = false
	corner.delay = delay
end

function pkg:setUpperLeft(one, two, hold, delay)
	setCorner(ul, one, two, hold, delay)
	return self
end

function pkg:getULO()
	return ul.one
end

function pkg:getULT()
	return ul.two
end

function pkg:getULH()
	return ul.hold
end

function pkg:setLowerLeft(one, two, hold, delay)
	setCorner(ll, one, two, hold, delay)
	return self
end

function pkg:getLLO()
	return ll.one
end

function pkg:getLLT()
	return ll.two
end

function pkg:getLLH()
	return ll.hold
end

function pkg:setUpperRight(one, two, hold, delay)
	setCorner(ur, one, two, hold, delay)
	return self
end

function pkg:getURO()
	return ur.one
end

function pkg:getURT()
	return ur.two
end

function pkg:getURH()
	return ur.hold
end

function pkg:setLowerRight(one, two, hold, delay)
	setCorner(lr, one, two, hold, delay)
	return self
end

function pkg:getLRO()
	return lr.one
end

function pkg:getLRT()
	return lr.two
end

function pkg:getLRH()
	return lr.hold
end

return pkg
