local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('npcmission:checkCooldown')
AddEventHandler('npcmission:checkCooldown', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if Player then
        local lastMissionTime = Player.PlayerData.metadata.lastNPCMissionTime or 0
        local currentTime = os.time()
        local timeDiff = currentTime - lastMissionTime
        
        if timeDiff < 2700 then -- 45 minutos = 2700 segundos
            local remainingTime = math.ceil((2700 - timeDiff) / 60)
            Player.Functions.SetMetaData("canStartNPCMission", false)
            Player.Functions.SetMetaData("npcMissionCooldown", remainingTime)
        else
            Player.Functions.SetMetaData("canStartNPCMission", true)
            Player.Functions.SetMetaData("npcMissionCooldown", 0)
        end
    end
end)

RegisterNetEvent('npcmission:startMission')
AddEventHandler('npcmission:startMission', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if Player then
        Player.Functions.SetMetaData("canStartNPCMission", false)
    end
end)

RegisterNetEvent('npcmission:finishMission')
AddEventHandler('npcmission:finishMission', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if Player then
        Player.Functions.SetMetaData("lastNPCMissionTime", os.time())
        Player.Functions.SetMetaData("canStartNPCMission", false)
        Player.Functions.SetMetaData("npcMissionCooldown", 45)
    end
end)

RegisterNetEvent('npcmission:giveReward')
AddEventHandler('npcmission:giveReward', function(amount)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if Player then
        Player.Functions.AddMoney('cash', amount, "NPC mission reward")
    end
end)

QBCore.Commands.Add("removenpcmission", "Remove NPC mission cooldown for a player (Admin Only)", {{name="id", help="Player ID"}}, true, function(source, args)
    local src = source
    local admin = QBCore.Functions.GetPlayer(src)
    
    if QBCore.Functions.HasPermission(src, "admin") or QBCore.Functions.HasPermission(src, "god") then
        if args[1] then
            local playerId = tonumber(args[1])
            local targetPlayer = QBCore.Functions.GetPlayer(playerId)
            
            if targetPlayer then
                targetPlayer.Functions.SetMetaData("lastNPCMissionTime", 0)
                targetPlayer.Functions.SetMetaData("canStartNPCMission", true)
                targetPlayer.Functions.SetMetaData("npcMissionCooldown", 0)
                TriggerClientEvent('QBCore:Notify', src, "NPC mission cooldown removed for Player ID: " .. playerId, "success")
                TriggerClientEvent('QBCore:Notify', playerId, "Your NPC mission cooldown has been reset by an admin", "info")
            else
                TriggerClientEvent('QBCore:Notify', src, "Player not found", "error")
            end
        else
            TriggerClientEvent('QBCore:Notify', src, "Please provide a player ID", "error")
        end
    else
        TriggerClientEvent('QBCore:Notify', src, "You don't have permission to use this command", "error")
    end
end, "admin")