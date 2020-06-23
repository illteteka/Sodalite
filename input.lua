local input = {}

_OFF = 0
_ON = 1
_PRESS = 2
_RELEASE = 3

mouse_switch = _OFF
rmb_switch = _OFF
middle_switch = _OFF

function input.printSwitch(x)
	if x == _OFF then
		return "off"
	elseif math.floor(x) == _PRESS then
		return "pressed"
	elseif math.floor(x) == _RELEASE then
		return "released"
	else
		return "on"
	end
end

function input.combo(a, b)
	return (a == _ON and b == _PRESS) or (a == _PRESS and b == _ON) or (a == _PRESS and b == _PRESS)
end

function input.ctrlCombo(a)
	return input.combo(lctrl_key, a) or input.combo(rctrl_key, a)
end

function input.shiftEither()
	return (lshift_key ~= _OFF and lshift_key ~= _RELEASE) or (rshift_key ~= _OFF and rshift_key ~= _RELEASE)
end

function input.ctrlEither()
	return (lctrl_key ~= _OFF and lctrl_key ~= _RELEASE) or (rctrl_key ~= _OFF and rctrl_key ~= _RELEASE)
end

function input.pullSwitch(a, b)

	local output = b

	if a then

		if b == _OFF or b == _RELEASE then
			output = _PRESS
		elseif b == _PRESS then
			output = _ON
		end

	else

		if b == _ON or b == _PRESS then
			output = _RELEASE
		elseif b == _RELEASE then
			output = _OFF
		end

	end

	return output

end

function input.update(dt)

	mouse_switch    = input.pullSwitch(love.mouse.isDown(1), mouse_switch)
	rmb_switch      = input.pullSwitch(love.mouse.isDown(2), rmb_switch)
	middle_switch   = input.pullSwitch(love.mouse.isDown(3), middle_switch)
	
end

return input
