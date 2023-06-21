script_name("AutoBicycleRunSwimOnMaxSpeed")
script_author("checkdasound")
script_version("4.0")
script_url("https://perfect-soft.net/")

bike = {[481] = true, [509] = true, [510] = true}
moto = {[448] = true, [461] = true, [462] = true, [463] = true, [468] = true, [471] = true, [521] = true, [522] = true, [523] = true, [581] = true, [586] = true}

function main()
while true do
	wait(0)
	
		if isCharOnAnyBike(playerPed) and isKeyCheckAvailable() and isKeyDown(0xA0) then	-- onBike&onMoto SpeedUP [[LSHIFT]] --
			if bike[getCarModel(storeCarCharIsInNoSave(playerPed))] then
				setGameKeyState(16, 255)
				wait(10)
				setGameKeyState(16, 0)
			elseif moto[getCarModel(storeCarCharIsInNoSave(playerPed))] then
				setGameKeyState(1, -128)
				wait(10)
				setGameKeyState(1, 0)
			end
		end
		
		if isCharOnFoot(playerPed) and isKeyDown(0x31) and isKeyCheckAvailable() then -- onFoot&inWater SpeedUP [[1]] --
			setGameKeyState(16, 256)
			wait(10)
			setGameKeyState(16, 0)
		elseif isCharInWater(playerPed) and isKeyDown(0x31) and isKeyCheckAvailable() then
			setGameKeyState(16, 256)
			wait(10)
			setGameKeyState(16, 0)
		end
	end
end

function isKeyCheckAvailable()
	if not isSampLoaded() then
		return true
	end
	if not isSampfuncsLoaded() then
		return not sampIsChatInputActive() and not sampIsDialogActive()
	end
	return not sampIsChatInputActive() and not sampIsDialogActive() and not isSampfuncsConsoleActive()
end