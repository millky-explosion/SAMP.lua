require "lib.moonloader"

function main()
    if not isSampfuncsLoaded() or not isSampLoaded() then return end
    while not isSampAvailable() do wait(100) end
    sampAddChatMessage("[Информация] {ffffff}Бесконечный бег на B успешно запущен! Автор скрипта: {C500FF}Devin {03FB03}[Vk - @devin_martynov]", 0x73b461)
    while true do
        wait(0)
       if isKeyJustPressed(VK_B) and not sampIsCursorActive() then
      sampSendChat("/anims 9")
       end
        end
    end
    