require 'lib.moonloader'
local se = require 'lib.samp.events'
local imgui = require 'imgui'
local inicfg = require 'inicfg'
local encoding = require 'encoding'
encoding.default = 'CP1251'
u8 = encoding.UTF8

local cfg = inicfg.load({
	chests = {
		starter = false,
		donate = false,
		platinum = false,
		elon_musk = false,
		los_santos = false,
		vice_city = false
	}, 
	settings = {
		delay_time = 60,
		random_delay = false,
		add_vip = false,
		open_inventory = false
	}
}, 'auto_opening_chests')

if not doesFileExist('auto_opening_chests.ini') then
    inicfg.save(cfg, 'auto_opening_chests.ini')
end

local sw, sh = getScreenResolution()
local main_window = imgui.ImBool(false)
local imgui_page = 1
local work = false
local inventory_fix = false
local inventory_id = nil
local first_start = true
local starter = imgui.ImBool(cfg.chests.starter)
local check_starter = false
local donate = imgui.ImBool(cfg.chests.donate)
local check_donate = false
local block_donate = false
local platinum = imgui.ImBool(cfg.chests.platinum)
local check_platinum = false
local block_platinum = false
local elon_musk = imgui.ImBool(cfg.chests.elon_musk)
local check_elon_musk = false
local block_elon_musk = false
local los_santos = imgui.ImBool(cfg.chests.los_santos)
local check_los_santos = false
local vice_city = imgui.ImBool(cfg.chests.vice_city)
local check_vice_city = false
local delay = imgui.ImBool(true)
local delay_time = imgui.ImBuffer(tostring(cfg.settings.delay_time), 4)
local random_delay = imgui.ImBool(cfg.settings.random_delay)
local add_vip = imgui.ImBool(cfg.settings.add_vip)
local open_inventory = imgui.ImBool(cfg.settings.open_inventory)
local timer = imgui.ImBool(false)
local timer_time = imgui.ImBuffer(tostring(''), 4)

local textdraw = {
	[1] = {_, _, 500},
	[2] = {_, _, 500},
	[3] = {_, _, 500},
	[4] = {_, _, 500},
	[5] = {_, _, 500},
	[6] = {_, _, 500},
} 

function main()
	if not isSampLoaded() or not isSampfuncsLoaded() then return end
	while not isSampAvailable() do wait(100) end

	sampRegisterChatCommand('chest', 
	function()
		main_window.v = not main_window.v 
		imgui.Process = main_window.v
	end)
	
	sampRegisterChatCommand('aoc', 
	function()
		if not work then
			if starter.v == false and donate.v == false and platinum.v == false and elon_musk.v == false and los_santos.v == false and vice_city.v == false and delay_time.v == '' then
				sampAddChatMessage('[Информация] {FFFFFF}Вы не выбрали сундук и не указали задержку.', 0xFFFF00)
			elseif starter.v == false and donate.v == false and platinum.v == false and elon_musk.v == false and los_santos.v == false and vice_city.v == false then
				sampAddChatMessage('[Информация] {FFFFFF}Вы не выбрали сундук.', 0xFFFF00)
			elseif delay_time.v == '' then
				sampAddChatMessage('[Информация] {FFFFFF}Вы не указали задержку.', 0xFFFF00) 
			else
				work = true
				showCursor(false)
				main_window.v = false
				sampAddChatMessage('[Информация] {FFFFFF}Автоматическое открытие сундуков: {00FF00}включено{FFFFFF}.', 0xFFFF00)
			end
		else
			sampSendClickTextdraw(65535)
			showCursor(false)
			thisScript():reload()
			sampAddChatMessage('[Информация] {FFFFFF}Автоматическое открытие сундуков: {FF0000}выключено{FFFFFF}.', 0xFFFF00)
		end
	end)

	while true do
		wait(0)
		if work then
			if first_start and timer.v then
				sampAddChatMessage('[Информация] {FFFFFF}Вы включили таймер. Запуск через {FFFF00}'..timer_time.v..' {FFFFFF}мин.', 0xFFFF00)
				wait(timer_time.v*60000)
				timer_time.v = ''
			end
			if first_start then
				sampSendClickTextdraw(65535)
				sampAddChatMessage('[Информация] {FFFFFF}Сейчас откроется инвентарь.', 0xFFFF00)
			elseif not first_start and not open_inventory.v then
				sampSendClickTextdraw(65535)
				sampAddChatMessage('[Информация] {FFFFFF}Сейчас откроется инвентарь.', 0xFFFF00)
			end
			wait(500)
			inventory_fix = true
			sampSendChat('/donate')
			wait(1000)
			if first_start then
				sampSendChat('/invent')
			elseif not first_start and not open_inventory.v then
				sampSendChat('/invent')
			elseif not first_start and open_inventory.v and not sampTextdrawIsExists(inventory_id) then
				sampSendChat('/invent')
			end
			repeat wait(1) until sampTextdrawIsExists(inventory_id)
			wait(500)
			if starter.v then
				if textdraw[1][1] ~= nil then
					check_starter = true
					repeat
						if not sampTextdrawIsExists(inventory_id) then
							sampSendChat('/invent')
							wait(1000)
						end
						sampSendClickTextdraw(textdraw[1][1])
						wait(textdraw[1][3])
						sampSendClickTextdraw(textdraw[1][2])
						wait(textdraw[1][3])
					until check_starter == false
				else
					starter.v = false
					cfg.chests.starter = false
					inicfg.save(cfg, 'auto_opening_chests.ini')
					sampAddChatMessage('[Информация] {FFFFFF}«Cундук рулетки» не найден.', 0xFFFF00)
				end
			end
			if donate.v and not block_donate then
				if textdraw[2][1] ~= nil then
					check_donate = true
					repeat
						if not sampTextdrawIsExists(inventory_id) then
							sampSendChat('/invent')
							repeat wait(1) until sampTextdrawIsExists(inventory_id)
							wait(500)
						end
						sampSendClickTextdraw(textdraw[2][1])
						wait(textdraw[2][3])
						sampSendClickTextdraw(textdraw[2][2])
						wait(textdraw[2][3])
					until check_donate == false
				else
					donate.v = false
					cfg.chests.donate = false
					inicfg.save(cfg, 'auto_opening_chests.ini')
					sampAddChatMessage('[Информация] {FFFFFF}«Cундук рулетки (донат)» не найден.', 0xFFFF00)
				end
			elseif donate.v and block_donate then
				block_donate = false
			end
			if platinum.v and not block_platinum then
				if textdraw[3][1] ~= nil then
					check_platinum = true
					repeat
						if not sampTextdrawIsExists(inventory_id) then
							sampSendChat('/invent')
							repeat wait(1) until sampTextdrawIsExists(inventory_id)
							wait(500)
						end
						sampSendClickTextdraw(textdraw[3][1])
						wait(textdraw[3][3])
						sampSendClickTextdraw(textdraw[3][2])
						wait(textdraw[3][3])
					until check_platinum == false
				else
					platinum.v = false
					cfg.chests.platinum = false
					inicfg.save(cfg, 'auto_opening_chests.ini')
					sampAddChatMessage('[Информация] {FFFFFF}«Сундук платиновой рулетки» не найден.', 0xFFFF00)
				end
			elseif platinum.v and block_platinum then
				block_platinum = false
			end
			if elon_musk.v and not block_elon_musk then
				if textdraw[4][1] ~= nil then
					check_elon_musk = true
					repeat
						if not sampTextdrawIsExists(inventory_id) then
							sampSendChat('/invent')
							repeat wait(1) until sampTextdrawIsExists(inventory_id)
							wait(500)
						end
						sampSendClickTextdraw(textdraw[4][1])
						wait(textdraw[4][3])
						sampSendClickTextdraw(textdraw[4][2])
						wait(textdraw[4][3])
					until check_elon_musk == false
				else
					elon_musk.v = false
					cfg.chests.elon_musk = false
					inicfg.save(cfg, 'auto_opening_chests.ini')
					sampAddChatMessage('[Информация] {FFFFFF}«Тайник Илона Маска» не найден.', 0xFFFF00)
				end
			elseif elon_musk.v and block_elon_musk then
				block_elon_musk = false
			end
			if los_santos.v then
				if textdraw[5][1] ~= nil then
					check_los_santos = true
					repeat
						if not sampTextdrawIsExists(inventory_id) then
							sampSendChat('/invent')
							repeat wait(1) until sampTextdrawIsExists(inventory_id)
							wait(500)
						end
						sampSendClickTextdraw(textdraw[5][1])
						wait(textdraw[5][3])
						sampSendClickTextdraw(textdraw[5][2])
						wait(textdraw[5][3])
					until check_los_santos == false
				else
					los_santos.v = false
					cfg.chests.los_santos = false
					inicfg.save(cfg, 'auto_opening_chests.ini')
					sampAddChatMessage('[Информация] {FFFFFF}«Тайник Лос Сантоса» не найден.', 0xFFFF00)
				end
			end
			if vice_city.v then
				if textdraw[6][1] ~= nil then
					check_vice_city = true
					repeat
						if not sampTextdrawIsExists(inventory_id) then
							sampSendChat('/invent')
							repeat wait(1) until sampTextdrawIsExists(inventory_id)
							wait(500)
						end
						sampSendClickTextdraw(textdraw[6][1])
						wait(textdraw[6][3])
						sampSendClickTextdraw(textdraw[6][2])
						wait(textdraw[6][3])
					until check_vice_city == false
				else
					vice_city.v = false
					cfg.chests.vice_city = false
					inicfg.save(cfg, 'auto_opening_chests.ini')
					sampAddChatMessage('[Информация] {FFFFFF}«Тайник Vice City» не найден.', 0xFFFF00)
				end
			end
			if starter.v == false and donate.v == false and platinum.v == false and elon_musk.v == false and los_santos.v == false and vice_city.v == false then
				sampSendClickTextdraw(65535)
				showCursor(false)
				thisScript():reload()
				sampAddChatMessage('[Информация] {FFFFFF}Автоматическое открытие сундуков: {FF0000}выключено{FFFFFF}.', 0xFFFF00)
			end
			wait(500)
			if not open_inventory.v then
				sampSendClickTextdraw(65535)
			end
			if not random_delay.v then
				wait(delay_time.v*60000)
			else
				wait(delay_time.v*60000+math.random(0, 300000))
			end
			first_start = false
        end
    end
end

function imgui.OnDrawFrame()
	if not main_window.v then imgui.Process = false end
	if main_window.v then
	imgui.SetNextWindowPos(imgui.ImVec2(sw/2, sh/2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
	imgui.SetNextWindowSize(imgui.ImVec2(343, 206), imgui.Cond.FirstUseEver)
	imgui.Begin(u8'Автоматическое открытие сундуков', main_window, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize)
	imgui.BeginChild('##menu', imgui.ImVec2(116, 172), true)
	imgui.CenterText(u8'Меню')
	imgui.Separator()
	if imgui.Button(u8'Cундуки', imgui.ImVec2(100, 28)) then imgui_page = 1 end
	if imgui.Button(u8'Настройки', imgui.ImVec2(100, 28)) then imgui_page = 2 end
	if imgui.Button(u8'Информация', imgui.ImVec2(100, 28)) then imgui_page = 3 end
	imgui.Separator()
	if work then 
		imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.13, 0.13, 0.13, 1.00))
		imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.66, 0.00, 0.00, 1.00))
		imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.50, 0.00, 0.00, 1.00))
	else
		imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.13, 0.13, 0.13, 1.00))
		imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.00, 0.66, 0.00, 1.00))
		imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.00, 0.50, 0.00, 1.00))
	end
	if imgui.Button(work and u8'Выключить' or u8'Включить', imgui.ImVec2(100, 30)) then 
		if not work then
			if starter.v == false and donate.v == false and platinum.v == false and elon_musk.v == false and los_santos.v == false and vice_city.v == false and delay_time.v == '' then
				sampAddChatMessage('[Информация] {FFFFFF}Вы не выбрали сундук и не указали задержку.', 0xFFFF00)
			elseif starter.v == false and donate.v == false and platinum.v == false and elon_musk.v == false and los_santos.v == false and vice_city.v == false then
				sampAddChatMessage('[Информация] {FFFFFF}Вы не выбрали сундук.', 0xFFFF00)
			elseif delay_time.v == '' then
				sampAddChatMessage('[Информация] {FFFFFF}Вы не указали задержку.', 0xFFFF00) 
			else
				work = true
				showCursor(false)
				main_window.v = false
				sampAddChatMessage('[Информация] {FFFFFF}Автоматическое открытие сундуков: {00FF00}включено{FFFFFF}.', 0xFFFF00)
			end
		else
			sampSendClickTextdraw(65535)
			showCursor(false)
			thisScript():reload()
			sampAddChatMessage('[Информация] {FFFFFF}Автоматическое открытие сундуков: {FF0000}выключено{FFFFFF}.', 0xFFFF00)
		end
	end
	imgui.PopStyleColor(3)
	imgui.EndChild()
	imgui.SameLine()
	if imgui_page == 1 then
		imgui.BeginChild('##chests', imgui.ImVec2(206, 172), true)
		imgui.CenterText(u8'Сундуки')
		imgui.Separator()
		imgui.Checkbox(u8'Сундук рулетки', starter)
		if starter.v then 
			cfg.chests.starter = true
			inicfg.save(cfg, 'auto_opening_chests.ini')
		else
			cfg.chests.starter = false
			inicfg.save(cfg, 'auto_opening_chests.ini')
		end
		imgui.Checkbox(u8'Сундук рулетки (донат)', donate)
		if donate.v then 
			cfg.chests.donate = true
			inicfg.save(cfg, 'auto_opening_chests.ini')
		else
			cfg.chests.donate = false
			inicfg.save(cfg, 'auto_opening_chests.ini')
		end
		imgui.Checkbox(u8'Сундук платиновой рулетки', platinum)
		if platinum.v then 
			cfg.chests.platinum = true
			inicfg.save(cfg, 'auto_opening_chests.ini')
		else
			cfg.chests.platinum = false
			inicfg.save(cfg, 'auto_opening_chests.ini')
		end
		imgui.Checkbox(u8'Тайник Илона Маска', elon_musk)
		if elon_musk.v then 
			cfg.chests.elon_musk = true
			inicfg.save(cfg, 'auto_opening_chests.ini')
		else
			cfg.chests.elon_musk = false
			inicfg.save(cfg, 'auto_opening_chests.ini')
		end
		imgui.Checkbox(u8'Тайник Лос Сантоса', los_santos)
		if los_santos.v then 
			cfg.chests.los_santos = true
			inicfg.save(cfg, 'auto_opening_chests.ini')
		else
			cfg.chests.los_santos = false
			inicfg.save(cfg, 'auto_opening_chests.ini')
		end
		imgui.Checkbox(u8'Тайник Vice City', vice_city)
		if vice_city.v then 
			cfg.chests.vice_city = true
			inicfg.save(cfg, 'auto_opening_chests.ini')
		else
			cfg.chests.vice_city = false
			inicfg.save(cfg, 'auto_opening_chests.ini')
		end
		imgui.EndChild()
	end
	if imgui_page == 2 then
		imgui.BeginChild('##settings', imgui.ImVec2(206, 172), true)
		imgui.CenterText(u8'Настройки')
		imgui.Separator()
		imgui.Checkbox(u8'Задержка:', delay)
		if delay_time.v ~= '' then
			delay.v = true
		else
			delay.v = false
		end
		imgui.SameLine()
		imgui.PushItemWidth(26)
		imgui.InputText(u8'мин.##delay', delay_time, imgui.InputTextFlags.CharsDecimal)
		if delay_time.v then
			cfg.settings.delay_time = delay_time.v
			inicfg.save(cfg, 'auto_opening_chests.ini')
		end
		imgui.Checkbox(u8'Рандомная задержка', random_delay)
		if random_delay.v then 
			cfg.settings.random_delay = true
			inicfg.save(cfg, 'auto_opening_chests.ini')
		else
			cfg.settings.random_delay = false
			inicfg.save(cfg, 'auto_opening_chests.ini')
		end
		imgui.Checkbox(u8'ADD VIP', add_vip)
		if add_vip.v then 
			cfg.settings.add_vip = true
			inicfg.save(cfg, 'auto_opening_chests.ini')
		else
			cfg.settings.add_vip = false
			inicfg.save(cfg, 'auto_opening_chests.ini')
		end
		imgui.Checkbox(u8'Не закрывать инвентарь', open_inventory)
		if open_inventory.v then 
			cfg.settings.open_inventory = true
			inicfg.save(cfg, 'auto_opening_chests.ini')
		else
			cfg.settings.open_inventory = false
			inicfg.save(cfg, 'auto_opening_chests.ini')
		end
		imgui.Checkbox(u8'Запустить через:', timer)
		imgui.SameLine()
		imgui.InputText(u8'мин.##timer', timer_time, imgui.InputTextFlags.CharsDecimal)
		if timer_time.v ~= '' then
			timer.v = true
		else
			timer.v = false
		end
		imgui.PopItemWidth()
		imgui.EndChild()
	end
	if imgui_page == 3 then
		imgui.BeginChild('##information', imgui.ImVec2(206, 172), true)
		imgui.CenterText(u8'Информация')
		imgui.Separator()
		imgui.Text(u8'Автор скрипта: Severus')
		imgui.Text(u8'Обновление: 04.01.2023')
		imgui.Text(u8'Запуск командой: /aoc')
		imgui.Text(u8'')
		imgui.Text(u8'')
		imgui.CenterText(u8'Ссылка на BlastHack:')
		if imgui.Link(u8'www.blast.hk/threads/150314') then
			os.execute(('explorer.exe "%s"'):format('http://www.blast.hk/threads/150314/'))
		end
		imgui.EndChild()
	end
	imgui.End()
	end
end

function se.onShowTextDraw(id, data)
	if work then
		if starter.v and data.modelId == 19918 and data.rotation.x == 161 and data.rotation.y == 174 and data.rotation.z == 126 then textdraw[1][1] = id end
		if donate.v and data.modelId == 19613 and data.rotation.x == 180 and data.rotation.y == 180 and data.rotation.z == 0 then textdraw[2][1] = id end
		if platinum.v and data.modelId == 1353 and data.rotation.x == 0 and data.rotation.y == 180 and data.rotation.z == 120 then textdraw[3][1] = id end
		if elon_musk.v and data.modelId == 1733 and data.rotation.x == 180 and data.rotation.y == 0 and data.rotation.z == 20 then textdraw[4][1] = id end
		if los_santos.v and data.modelId == 2887 and data.rotation.x == 0 and data.rotation.y == 0 and data.rotation.z == 180 then textdraw[5][1] = id end
		if vice_city.v and data.modelId == 1333 and data.rotation.x == -120 and data.rotation.y == 0 and data.rotation.z == 180 then textdraw[6][1] = id end
		if data.text == 'USE' or data.text == '…CЊO‡’€O‹AЏ’' then 
			textdraw[1][2] = id + 1
			textdraw[2][2] = id + 1
			textdraw[3][2] = id + 1
			textdraw[4][2] = id + 1
			textdraw[5][2] = id + 1
			textdraw[6][2] = id + 1
		end
	end
	if data.text == 'INVENTORY' or data.text == '…H‹EHЏAP’' and data.letterColor == -1 and data.style == 2 then
		inventory_id = id
	end
end

function se.onShowDialog(dialogId, style, title, b1, b2, text)
	if inventory_fix and text:find('Курс пополнения счета') then
		sampSendDialogResponse(dialogId, 0, 0, '')
		inventory_fix = false
		return false
	end
	if dialogId == 0 and text:find('{FF0000}К сожалению сундук сейчас открыть не получится') and work then
		sampSendClickTextdraw(65535)
		showCursor(false)
		thisScript():reload()
	end
	if dialogId == 0 and text:find('Удача!') then 
		sampAddChatMessage('[Информация] {FFFFFF}Вам был добавлен предмет «Эффект x4 пополнение счёта».', 0xFFFF00)
		sampSendDialogResponse(id, 0, _, _)
		return false
	end
end

function se.onServerMessage(color, text)
	if work then
		if check_starter and text:find('Вы использовали сундук с рулетками и получили') or text:find('Время после прошлого использования ещё не прошло!') then
			check_starter = false
		elseif check_starter and text:find('Открывать этот сундук можно только с 3 уровня!') then
			sampSendClickTextdraw(65535)
			showCursor(false)
			thisScript():reload()
		end
		if check_donate and text:find('Вы использовали сундук с рулетками и получили') then
			if add_vip.v then block_donate = true end
			check_donate = false
		elseif check_donate and text:find('Время после прошлого использования ещё не прошло!') then
			if add_vip.v then block_donate = false end
			check_donate = false
		end
		if check_platinum and text:find('Вы использовали платиновый сундук с рулетками и получили') then
			if add_vip.v then block_platinum = true end
			check_platinum = false
		elseif check_platinum and text:find('Время после прошлого использования ещё не прошло!') then
			if add_vip.v then block_platinum = false end
			check_platinum = false
		end
		if check_elon_musk and text:find('Вы использовали тайник Илона Маска и получили') then
			if add_vip.v then block_elon_musk = true end
			check_elon_musk = false
		elseif check_elon_musk and text:find('Время после прошлого использования ещё не прошло!') then
			if add_vip.v then block_elon_musk = false end
			check_elon_musk = false
		end
		if check_los_santos and text:find('Вы использовали Тайник Лос Сантоса и получили') or text:find('Время после прошлого использования ещё не прошло!') then
			check_los_santos = false
		end
		if check_vice_city and text:find('Вы использовали Тайник Vice City и получили') or text:find('Время после прошлого использования ещё не прошло!') then
			check_vice_city = false
		end
	end
end

function imgui.CenterText(text)
	local width = imgui.GetWindowWidth()
	local size = imgui.CalcTextSize(text)
	imgui.SetCursorPosX(width/2-size.x/2)
	imgui.Text(text)
end

function imgui.Link(label, description)
	local width = imgui.GetWindowWidth()
	local size = imgui.CalcTextSize(label)
	local p = imgui.GetCursorScreenPos()
	local p2 = imgui.GetCursorPos()
	local result = imgui.InvisibleButton(label, imgui.ImVec2(width-16, size.y))
	imgui.SetCursorPos(p2)
	imgui.SetCursorPosX(width/2-size.x/2)
	if imgui.IsItemHovered() then
		if description then
			imgui.BeginTooltip()
			imgui.PushTextWrapPos(500)
			imgui.TextUnformatted(description)
			imgui.PopTextWrapPos()
			imgui.EndTooltip()
		end
		imgui.TextColored(imgui.GetStyle().Colors[imgui.Col.CheckMark], label)
		imgui.GetWindowDrawList():AddLine(imgui.ImVec2(width/2-size.x/2+p.x-8, p.y + size.y), imgui.ImVec2(width/2-size.x/2+p.x-8 + size.x, p.y + size.y), imgui.GetColorU32(imgui.GetStyle().Colors[imgui.Col.CheckMark]))
	else
		imgui.TextColored(imgui.GetStyle().Colors[imgui.Col.CheckMark], label)
	end
	return result
end

function theme()
	imgui.SwitchContext()
	local style = imgui.GetStyle()
	local colors = style.Colors
	local clr = imgui.Col
	local ImVec4 = imgui.ImVec4
	local ImVec2 = imgui.ImVec2

	style.WindowPadding = ImVec2(8, 8)
	style.WindowRounding = 5.0
	style.ChildWindowRounding = 5.0
	style.FramePadding = ImVec2(2, 2)
	style.FrameRounding = 5.0
	style.ItemSpacing = ImVec2(5, 5)
	style.ItemInnerSpacing = ImVec2(5, 5)
	style.TouchExtraPadding = ImVec2(0, 0)
	style.IndentSpacing = 5.0
	style.ScrollbarSize = 13.0
	style.ScrollbarRounding = 5.0
	style.GrabMinSize = 20.0
	style.GrabRounding = 5.0
	style.WindowTitleAlign = ImVec2(0.5, 0.5)

	colors[clr.Text]                    = ImVec4(1.00, 1.00, 1.00, 1.00)
	colors[clr.TextDisabled]            = ImVec4(0.20, 0.20, 0.20, 1.00)
	colors[clr.WindowBg]                = ImVec4(0.05, 0.05, 0.05, 1.00)
	colors[clr.ChildWindowBg]           = ImVec4(0.05, 0.05, 0.05, 1.00)
	colors[clr.PopupBg]                 = ImVec4(0.05, 0.05, 0.05, 1.00)
	colors[clr.Border]                  = ImVec4(1.00, 1.00, 1.00, 1.00)
	colors[clr.BorderShadow]            = ImVec4(0.05, 0.05, 0.05, 1.00)
	colors[clr.FrameBg]                 = ImVec4(0.13, 0.13, 0.13, 1.00)
	colors[clr.FrameBgHovered]          = ImVec4(0.20, 0.20, 0.20, 1.00)
	colors[clr.FrameBgActive]           = ImVec4(0.13, 0.13, 0.13, 1.00)
	colors[clr.TitleBg]                 = ImVec4(0.13, 0.13, 0.13, 1.00)
	colors[clr.TitleBgCollapsed]        = ImVec4(0.13, 0.13, 0.13, 1.00)
	colors[clr.TitleBgActive]           = ImVec4(0.13, 0.13, 0.13, 1.00)
	colors[clr.MenuBarBg]               = ImVec4(0.13, 0.13, 0.13, 1.00)
	colors[clr.ScrollbarBg]             = ImVec4(0.05, 0.05, 0.05, 1.00)
	colors[clr.ScrollbarGrab]           = ImVec4(0.13, 0.13, 0.13, 1.00)
	colors[clr.ScrollbarGrabHovered]    = ImVec4(0.20, 0.20, 0.20, 1.00)
	colors[clr.ScrollbarGrabActive]     = ImVec4(0.13, 0.13, 0.13, 1.00)
	colors[clr.ComboBg]                 = ImVec4(0.13, 0.13, 0.13, 1.00)
	colors[clr.CheckMark]               = ImVec4(1.00, 1.00, 1.00, 1.00)
	colors[clr.SliderGrab]              = ImVec4(1.00, 1.00, 1.00, 1.00)
	colors[clr.SliderGrabActive]        = ImVec4(1.00, 1.00, 1.00, 1.00)
	colors[clr.Button]                  = ImVec4(0.13, 0.13, 0.13, 1.00)
	colors[clr.ButtonHovered]           = ImVec4(0.20, 0.20, 0.20, 1.00)
	colors[clr.ButtonActive]            = ImVec4(0.13, 0.13, 0.13, 1.00)
	colors[clr.Header]                  = ImVec4(0.13, 0.13, 0.13, 1.00)
	colors[clr.HeaderHovered]           = ImVec4(0.20, 0.20, 0.20, 1.00)
	colors[clr.HeaderActive]            = ImVec4(0.13, 0.13, 0.13, 1.00)
	colors[clr.ResizeGrip]              = ImVec4(0.13, 0.13, 0.13, 1.00)
	colors[clr.ResizeGripHovered]       = ImVec4(0.20, 0.20, 0.20, 1.00)
	colors[clr.ResizeGripActive]        = ImVec4(0.13, 0.13, 0.13, 1.00)
	colors[clr.CloseButton]             = ImVec4(0.05, 0.05, 0.05, 1.00)
	colors[clr.CloseButtonHovered]      = ImVec4(0.05, 0.05, 0.05, 1.00)
	colors[clr.CloseButtonActive]       = ImVec4(0.05, 0.05, 0.05, 1.00)
	colors[clr.PlotLines]               = ImVec4(0.13, 0.13, 0.13, 1.00)
	colors[clr.PlotLinesHovered]        = ImVec4(0.20, 0.20, 0.20, 1.00)
	colors[clr.PlotHistogram]           = ImVec4(0.13, 0.13, 0.13, 1.00)
	colors[clr.PlotHistogramHovered]    = ImVec4(0.20, 0.20, 0.20, 1.00)
	colors[clr.TextSelectedBg]          = ImVec4(0.05, 0.05, 0.05, 1.00)
	colors[clr.ModalWindowDarkening]    = ImVec4(1.00, 1.00, 1.00, 1.00)
end
theme()