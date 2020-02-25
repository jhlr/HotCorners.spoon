local pkg = {}

-- Metadata
pkg.name = "HotCorners"
pkg.version = "1.0"
pkg.author = "Joao Rietra <joaorietra@gmail.com>"
pkg.github = "@jhlr"
pkg.license = "MIT - https://opensource.org/licenses/MIT"

-- Error messages
local nomultiscreen = "It does not support multiple screens."
local onlyfunction = "Callback has to be a function or nil."

-- Properties
-- Delta is in pixels
-- area to be considered as a corner
pkg.delta = 10
-- Delay is in seconds
-- avoid triggering repeatedly
pkg.delay = 1

-- Callbacks
local upperLeft = nil
local lowerLeft = nil
local upperRight = nil
local lowerRight = nil

-- Local variables
local sframe
local mouseWatcher
local screenWatcher

-- Local booleans
local middle = true
local ulbusy = false
local llbusy = false
local urbusy = false
local lrbusy = false

function pkg:init()
	screenWatcher = hs.screen.watcher.new(function()
		hs.notify.show(pkg.name, "Disabled", nomultiscreen)
		pkg:stop()
	end)
	mouseWatcher = hs.eventtap.new({
		hs.eventtap.event.types.mouseMoved
	}, function(e)
		local p = e:location()
		if p.x < pkg.delta and p.y < pkg.delta then
			if upperLeft ~= nil and middle and not ulbusy then
				ulbusy = true
				upperLeft()
				hs.timer.doAfter(pkg.delay, function()
					ulbusy = false
				end)
			end
			middle = false
		elseif p.x < pkg.delta and p.y > (sframe.h - pkg.delta) then
			if lowerLeft ~= nil and middle and not llbusy then
				llbusy = true
				lowerLeft()
				hs.timer.doAfter(pkg.delay, function()
					llbusy = false
				end)
			end
			middle = false
		elseif p.x > (sframe.w - pkg.delta) and p.y < pkg.delta then
			if upperRight ~= nil and middle and not urbusy then
				urbusy = true
				upperRight()
				hs.timer.doAfter(pkg.delay, function()
					urbusy = false
				end)
			end
			middle = false
		elseif p.x > (sframe.w - pkg.delta) and p.y > (sframe.h - pkg.delta) then
			if lowerRight ~= nil and middle and not llbusy then
				lrbusy = true
				lowerRight()
				hs.timer.doAfter(pkg.delay, function()
					lrbusy = false
				end)
			end
			middle = false
		else
			middle = true
		end
	end)
end

function pkg:start()
	local screens = hs.screen.allScreens()
	if #screens > 1 then
		hs.notify.show(pkg.name, "Not started", nomultiscreen)
	else
		sframe = hs.screen.primaryScreen():fullFrame()
		mouseWatcher:start()
		screenWatcher:start()
	end
	return self
end

function pkg:stop()
	mouseWatcher:stop()
	screenWatcher:stop()
	return self
end

function pkg:setUpperLeft(fn)
	assert(fn == nil or type(fn) == "function", onlyfunction)
	upperLeft = fn
	return self
end

function pkg:setLowerLeft(fn)
	assert(fn == nil or type(fn) == "function", onlyfunction)
	lowerLeft = fn
	return self
end

function pkg:setUpperRight(fn)
	assert(fn == nil or type(fn) == "function", onlyfunction)
	upperRight = fn
	return self
end

function pkg:setLowerRight(fn)
	assert(fn == nil or type(fn) == "function", onlyfunction)
	lowerRight = fn
	return self
end

return pkg
