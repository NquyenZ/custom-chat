local QBCore = exports['qb-core']:GetCoreObject()
local chatActive = false
local commandHistory = {}
local historyIndex = 0
local displayText = nil
local displayTime = 0

RegisterCommand('toggleChat', function()
    if chatActive then
        return
    end

    if not IsPauseMenuActive() then
        chatActive = true

        TriggerEvent("dvn-typing:input", true)

        SetNuiFocus(true, true)

        SendNUIMessage(
        {
            action = 'enableInput'
        })
    else
        print("[nquyenZ Chat] Cannot Open Chat Box While In Pause Menu")
    end
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

    SendNUIMessage(
    {
        action = 'updateSuggestions',
        suggestions = suggestions
    })

    cb('ok')
end)

RegisterNUICallback('sendMessage', function(data, cb)
    chatActive = false

    TriggerEvent("dvn-typing:input", false)

    SetNuiFocus(false, false)
    
    SendNUIMessage(
    {
        action = 'disableInput',
        clear = true
    })
    
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

local playerBubbles = {}

RegisterNetEvent('custom-chat:showBubble', function(playerSrc, text, color, range, duration)
    local playerId = GetPlayerFromServerId(playerSrc)
    
    if playerId == -1 then
        return
    end

    SetPlayerChatBubble(playerId, text, color, range, duration)
end)

function SetPlayerChatBubble(playerId, text, color, range, duration)
    local ped = GetPlayerPed(playerId)

    if not DoesEntityExist(ped) then
        return
    end

    local bubbleId = GetPlayerServerId(playerId)
    local endTime = GetGameTimer() + (duration or 5000)
    local range = range or 15.0
    local color = color or
    {
        r = 255,
        g = 255,
        b = 255, 
        a = 255
    }

    if playerBubbles[bubbleId] then
        SendNUIMessage(
        {
            action = "removeChatBubble",
            serverId = bubbleId
        })
        playerBubbles[bubbleId] = nil
    end

    playerBubbles[bubbleId] = true

    CreateThread(function()
        while GetGameTimer() < endTime and playerBubbles[bubbleId] do
            local myPed = PlayerPedId()
            local myCoords = GetEntityCoords(myPed)
            local pedCoords = GetPedBoneCoords(ped, 0x796E)

            myCoords = vector3(myCoords.x, myCoords.y, myCoords.z)
            pedCoords = vector3(pedCoords.x, pedCoords.y, pedCoords.z)

            local dist = #(myCoords - pedCoords)

            if dist <= range then
                local onScreen, screenX, screenY = World3dToScreen2d(pedCoords.x, pedCoords.y, pedCoords.z + 0.4)

                if onScreen then
                    SendNUIMessage(
                    {
                        action = "showChatBubble",
                        serverId = bubbleId,
                        text = text,
                        color = color,
                        screen =
                        {
                            x = screenX,
                            y = screenY
                        },
                        time = duration or 5000
                    })
                end
            end

            Wait(0)
        end

        SendNUIMessage(
        {
            action = "removeChatBubble",
            serverId = bubbleId
        })

        playerBubbles[bubbleId] = nil
    end)
end

-- # Hide Chat Box When In Pause Menu
CreateThread(function()
    local wasPaused = false

    while true do
        Wait(500)

        local paused = IsPauseMenuActive()

        if paused and not wasPaused then
            SendNUIMessage(
            {
                action = 'hideChatMessages'
            })

            wasPaused = true
        elseif not paused and wasPaused then
            SendNUIMessage(
            {
                action = 'showChatMessages'
            })

            wasPaused = false
        end
    end
end)

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
