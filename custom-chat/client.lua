local QBCore = exports['qb-core']:GetCoreObject()
local chatActive = false
local commandHistory = {}
local historyIndex = 0

RegisterCommand('toggleChat', function()
    if chatActive then
        return
    end

    chatActive = true

    TriggerEvent("dvn-typing:input", true)

    SetNuiFocus(true, true)

    SendNUIMessage({action='enableInput'})
end)

RegisterKeyMapping('toggleChat', 'Mo Chat Box', 'keyboard', 'T')

RegisterNUICallback('sendMessage', function(data, cb)
    local msg = data.message or ""

    chatActive = false

    SetNuiFocus(false, false)

    if msg ~= "" then
        table.insert(commandHistory, msg)

        historyIndex = #commandHistory + 1

        if string.sub(msg,1,1) ~= '/' then
            SendClientMessage("{FF6347}[Error]{FFFFFF} Bạn cần phải thêm {F5DEB3}/{FFFFFF} trước mỗi câu lệnh")
        else
            if msg == '/clear' then
                SendNUIMessage({action='clearChat'})
            else
                ExecuteCommand(string.sub(msg,2))
            end
        end
    end

    SendNUIMessage({action='disableInput', clear=true})

    cb('ok')
end)

RegisterNUICallback('closeInput', function(_, cb)
    chatActive = false

    TriggerEvent("dvn-typing:input", false)

    SetNuiFocus(false, false)

    SendNUIMessage({action='disableInput', clear=true})

    cb('ok')
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    chatActive = false

    SetNuiFocus(false, false)

    SendNUIMessage({action='disableInput'})
end)

RegisterNUICallback('getSuggestions', function(data, cb)
    local suggestions = {}

    for _, cmd in ipairs(GetRegisteredCommands()) do
        if string.find(cmd.name, data.input) then
            table.insert(suggestions, '/'..cmd.name)
        end
    end

    SendNUIMessage({action='updateSuggestions', suggestions=suggestions})

    cb('ok')
end)

RegisterNUICallback('sendMessage', function(data, cb)
    chatActive = false

    TriggerEvent("dvn-typing:input", false)

    SetNuiFocus(false, false)
    
    SendNUIMessage({action='disableInput', clear=true})
    
    cb('ok')
end)

RegisterNetEvent('custom-chat:addMessage', function(msg)
    SendNUIMessage(
    {
        action = 'addMessage',
        message = msg
    })
end)

function SendClientMessage(msg)
    TriggerEvent('custom-chat:addMessage', msg)
end

local bubbles = {}

RegisterNetEvent('custom-chat:showBubble', function(text, color, range, duration)
    local src = source
    local ped = GetPlayerPed(GetPlayerFromServerId(src))

    if not ped or ped == 0 then
        return
    end

    local bubble =
    {
        ped = ped,
        text = text,
        color = color or {r = 255, g = 255, b = 255, a = 255},
        range = range or 15.0,
        expire = GetGameTimer() + (duration or 5000)
    }

    table.insert(bubbles, bubble)
end)

function SetPlayerChatBubble(ped, text, color, range, duration)
    duration = duration or 7000

    local found = false

    for i, bubble in ipairs(bubbles) do
        if bubble.ped == ped then
            bubble.text = text
            bubble.color = color
            bubble.range = range or 15.0
            bubble.expire = GetGameTimer() + duration

            found = true
            break
        end
    end

    if not found then
        table.insert(bubbles,
        {
            ped = ped,
            text = text,
            color = color or { r = 255, g = 255, b = 255, a = 255 },
            range = range or 15.0,
            expire = GetGameTimer() + duration
        })
    end
end

CreateThread(function()
    while true do
        Wait(0)

        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)

        for i = #bubbles, 1, -1 do
            local bubble = bubbles[i]

            if GetGameTimer() > bubble.expire then
                table.remove(bubbles, i)
            else
                local headBone = GetPedBoneIndex(bubble.ped, 0x796E) -- SKEL_Head
                local pedCoords = GetWorldPositionOfEntityBone(bubble.ped, headBone)
                local dist = #(playerCoords - pedCoords)

                if dist <= tonumber(bubble.range) then
                    DrawText3D(pedCoords.x, pedCoords.y, pedCoords.z + 0.5, bubble.text, bubble.color)
                end
            end
        end
    end
end)

function DrawText3D(x, y, z, text, color)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local px, py, pz = table.unpack(GetGameplayCamCoords())
    local dist = GetDistanceBetweenCoords(px, py, pz, x, y, z, 1)
    local scale = (1 / dist) * 2
    local fov = (1 / GetGameplayCamFov()) * 100

    scale = scale * fov

    if onScreen then
        SetTextScale(0.35 * scale, 0.35 * scale)
        SetTextFont(10)
        SetTextProportional(1)
        SetTextColour(color.r, color.g, color.b, color.a)
        SetTextCentre(1)
        SetTextDropshadow(1, 0, 0, 0, 255)
        SetTextOutline()

        BeginTextCommandDisplayText("STRING")

        AddTextComponentSubstringPlayerName(text)

        EndTextCommandDisplayText(_x, _y)
    end
end

--# Hide Player Blip On Map
CreateThread(function()
    while true do
        Wait(1000)

        for _, id in ipairs(GetActivePlayers()) do
            local ped = GetPlayerPed(id)

            if ped ~= PlayerPedId() then
                local blip = GetBlipFromEntity(ped)
                
                if blip ~= 0 then
                    RemoveBlip(blip)
                end
            end
        end
    end
end)

--# Disable Autoaim
CreateThread(function()
    while true do
        Wait(0)

        SetPlayerLockon(PlayerId(), false)
        SetPlayerTargetingMode(0)
    end
end)
