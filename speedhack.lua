script_author('LUCHARE')
script_url('blast.hk')

local inicfg = require 'inicfg'
local samem = require 'SAMemory'
local imgui = require 'imgui'
local key = require 'vkeys'

samem.require 'CTrain'

local config = inicfg.load(
	{
		general = {
			limit = 1.1;
			mult = 1.04;
			timestep = 0.2;
			safe_train_speed = true;
			key = 'Left Alt';
		}
	},
	'speedhack'
)
local options = config.general
local player_vehicle = samem.cast('CVehicle **', samem.player_vehicle)
local ImBuffer = imgui.ImBuffer
local ImFloat = imgui.ImFloat
local ImBool = imgui.ImBool

local draw_options = ImBool(false)
local input_key = ImBuffer(options.key, 64)
local slider_mult = ImFloat(options.mult)
local slider_limit = ImFloat(options.limit)
local slider_timestep = ImFloat(options.timestep)

function imgui.OnDrawFrame()
	if draw_options.v then
		imgui.Begin('Speedhack options', draw_options)
		if imgui.InputText('Key', input_key, imgui.InputTextFlags.EnterReturnsTrue) then
			if key.name_to_id(input_key.v, false) ~= nil then
				options.key = input_key.v
			else
				input_key.v = '<invalid key>'
			end
		end
		if imgui.SliderFloat('Mult.', slider_mult, 0.001, 100.0) then
			options.mult = slider_mult.v
		end
		if imgui.SliderFloat('Limit', slider_limit, 0.01, 1000.0) then
			options.limit = slider_limit.v
		end
		if imgui.SliderFloat('Time step', slider_timestep, 0.0, 1.0) then
			options.timestep = slider_timestep.v
		end
		if imgui.Checkbox('Safe train speed', ImBool(options.safe_train_speed)) then
			options.safe_train_speed = not options.safe_train_speed
		end
		imgui.End()
	end
end

local timer = {
	prev_time = 0;
}

function timer:process(timestep)
	local curr_time = os.clock()
	if (curr_time - self.prev_time) >= timestep then
		self.prev_time = curr_time
		return true
	end
	return false
end

function main()
	while true do
		if isKeyDown(key.VK_CONTROL) and wasKeyPressed(key.VK_S) then
			draw_options.v = not draw_options.v
		end

		local veh = player_vehicle[0]
		if veh ~= samem.nullptr then
			if isKeyDown(key.name_to_id(options.key or 'Left Alt', false)) then
				if timer:process(options.timestep) then

					if veh.nVehicleClass == 6 then
						local train = samem.cast('CTrain *', veh)

						while train ~= samem.nullptr do
							local new_speed = train.fTrainSpeed * options.mult

							if options.safe_train_speed then
								if new_speed >= 0.99 then
									new_speed = 0.9
								end
							end

							if new_speed <= options.limit then
								train.fTrainSpeed = new_speed
							end

							train = train.pNextCarriage
						end

					else

						while veh ~= samem.nullptr do
							local new_speed = veh.vMoveSpeed * options.mult

							if new_speed:magnitude() <= options.limit then
								veh.vMoveSpeed = new_speed
							end

							veh = veh.pTrailer
						end

					end
				end
			end
		end
		imgui.Process = draw_options.v
		wait(0)
	end
end

function onScriptTerminate(script, quitGame)
	if script == thisScript() then
		inicfg.save(config, 'speedhack')
	end
end
