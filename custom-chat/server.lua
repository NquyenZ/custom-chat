QBCore = exports['qb-core']:GetCoreObject()

function SendClientMessage(target, msg)
    TriggerClientEvent('custom-chat:addMessage', target, msg)
end

RegisterNetEvent('custom-chat:showBubble', function(text, color, range, time)
    local src = source

    TriggerClientEvent('custom-chat:showBubble', -1, src, text, color, range, time)
end)

local function GetPlayersInRange(src, range)
    local players = {}
    local srcPed = GetPlayerPed(src)
    local srcCoords = GetEntityCoords(srcPed)

    for _, playerId in ipairs(GetPlayers()) do
        local ped = GetPlayerPed(playerId)

        if ped and DoesEntityExist(ped) then
            local coords = GetEntityCoords(ped)

            if #(coords - srcCoords) <= range then
                table.insert(players, playerId)
            end
        end
    end

    return players
end

function ProxDetector(range, src, msg, colors)
    local nearbyPlayers = GetPlayersInRange(src, range)

    for _, target in ipairs(nearbyPlayers) do
        if type(colors) == "table" then
            for _, color in ipairs(colors) do
                SendClientMessage(target, color .. msg)
            end
        else
            SendClientMessage(target, colors .. msg)
        end
    end
end

RegisterCommand("b", function(source, args)
    local msg = table.concat(args, " ")

    if not msg or msg == "" then
        SendClientMessage(source, "{FF6347}Sử Dụng:{FFFFFF} /b [Nội Dung]")
        return
    end
    
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player then
        return
    end

    local fullname = Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname
    local id = source
    local text = string.format("(( [%d] %s: %s ))", id, fullname, msg)

    ProxDetector(20.0, source, text, "{AFAFAF}")
end)

RegisterCommand("me", function(source, args)
    local msg = table.concat(args, " ")

    if not msg or msg == "" then
        SendClientMessage(source, "{FF6347}Sử Dụng:{FFFFFF} /me [Hành Động]")
        return
    end

    local Player = QBCore.Functions.GetPlayer(source)

    if not Player then
        return
    end

    local fullname = Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname
    local text = string.format("* %s %s", fullname, msg)

    ProxDetector(20.0, source, text, "{C2A2DA}")
end)

RegisterCommand("do", function(source, args)
    local msg = table.concat(args, " ")

    if not msg or msg == "" then
        SendClientMessage(source, "{FF6347}Sử Dụng:{FFFFFF} /do [Hành Động]")
        return
    end

    local Player = QBCore.Functions.GetPlayer(source)

    if not Player then
        return
    end

    local fullname = Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname
    local text = string.format("* %s (( %s ))", msg, fullname)

    ProxDetector(20.0, source, text, "{C2A2DA}")
end)

RegisterCommand('ame', function(source, args)
    local msg = table.concat(args, " ")

    if not msg or msg == "" then
        SendClientMessage(source, "{FF6347}Sử Dụng:{FFFFFF} /ame [Hành Động]")
        return
    end

    local Player = QBCore.Functions.GetPlayer(source)

    if not Player then
        return
    end

    local fullname = Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname
    local text = string.format("* %s", msg)

    TriggerClientEvent('custom-chat:showBubble', -1, source, text,
    {
        r = 194,
        g = 162,
        b = 218,
        a = 255
    }, 15.0, 4000)
end)

RegisterCommand('pm', function(source, args)
    if not Config.EnablePM then
        SendClientMessage(source, "{FFFFFF}PM hiện {FF6347}đang bị tắt")
        return
    end

    if #args < 2 then
        SendClientMessage(source, "{FF6347}Sử Dụng:{FFFFFF} /pm [Người Chơi] [Nội Dung]")
        return
    end

    local target = tonumber(args[1])
    local msg = table.concat(args, " ", 2)

    if not target then
        SendClientMessage(source, "{FF6347}[Error]{FFFFFF} Người chơi không tồn tại")
        return
    end

    local targetPlayer = QBCore.Functions.GetPlayer(target)

    if not targetPlayer then
        SendClientMessage(source, "{FF6347}[Error]{FFFFFF} Người chơi không tồn tại")
        return
    end

    if target == source and not Config.PMSelf then
        SendClientMessage(source, "{FFFFFF}Bạn {FF6347}không thể{FFFFFF} PM chính mình")
        return
    end

    local sender = QBCore.Functions.GetPlayer(source)
    local senderName = sender.PlayerData.charinfo.firstname .. " " .. sender.PlayerData.charinfo.lastname
    local targetName = targetPlayer.PlayerData.charinfo.firstname .. " " .. targetPlayer.PlayerData.charinfo.lastname
    local senderText = string.format("{FF8000}(( PM gửi đến %s (%d): %s ))", targetName, target, msg)
    local targetText = string.format("{FFFF00}(( %s (%d) đã PM cho bạn: %s ))", senderName, source, msg)

    TriggerClientEvent('custom-chat:addMessage', target, targetText)
    TriggerClientEvent('custom-chat:addMessage', source, senderText)
end)

RegisterCommand("pmconfig", function(source, args, rawCommand)
    if not QBCore.Functions.HasPermission(source, "admin") then
        SendClientMessage(source, "{FFFFFF}Bạn {FF6347}không đủ quyền hạn{FFFFFF} để sử dụng lệnh này")
        return
    end

    if #args < 2 then
        SendClientMessage(source, "{FF6347}Sử Dụng:{FFFFFF} /pmconfig [Enable/Self] [True/False]")
        return
    end

    local option = string.lower(args[1])
    local value = string.lower(args[2])

    if value ~= "true" and value ~= "false" then
        SendClientMessage(source, "{FF6347}[Error]{FFFFFF} Giá trị phải là {33AA33}True{FFFFFF} hoặc {AA3333}False")
        return
    end

    value = (value == "true")

    if option == "enable" then
        Config.EnablePM = value

        TriggerClientEvent('custom-chat:addMessage', -1, "{F5DEB3}[PM Config]{FFFFFF} PM đã được " .. (value and "{33AA33}Bật" or "{AA3333}Tắt"))
    elseif option == "self" then
        Config.PMSelf = value

        TriggerClientEvent('custom-chat:addMessage', -1, "{F5DEB3}[PM Config]{FFFFFF} PM chính bản thân đã được " .. (value and "{33AA33}Bật" or "{AA3333}Tắt"))
    else
        SendClientMessage(source, "{FF6347}[Error]{FFFFFF} Tùy chọn không hợp lệ [Chỉ có thể chọn Enable/Self]")
    end
end, false)
