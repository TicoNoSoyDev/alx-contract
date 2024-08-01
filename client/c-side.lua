local QBCore = exports['qb-core']:GetCoreObject()

-- Esperar a que CFG esté disponible
Citizen.CreateThread(function()
    while CFG == nil do
        Citizen.Wait(100)
    end

    local missionStarted = false
    local npcSpawned = false
    local npcs = {}
    local carryingNPC = false
    local npcDead = false
    local interactableNPC = nil
    local killedByFirearm = false
    local areaBlip = nil

    local npcCoords = CFG.Points.Point[1]
    local possibleNPCLocations = CFG.Points.Locations

    local function GetRandomSpawnLocation()
        return possibleNPCLocations[math.random(#possibleNPCLocations)]
    end

    local npcCoords2 = GetRandomSpawnLocation()

    local npcModel = GetHashKey("mp_m_freemode_01")
    local npcHeading = 181.55493

    RequestModel(npcModel)
    while not HasModelLoaded(npcModel) do
        Wait(1)
    end

    -- Create the mission giver NPC
    local npc = CreatePed(4, npcModel, npcCoords.x, npcCoords.y, npcCoords.z, npcHeading, false, true)
    SetEntityInvincible(npc, true)
    FreezeEntityPosition(npc, true)
    SetBlockingOfNonTemporaryEvents(npc, true)

    -- Set NPC appearance
    SetPedComponentVariation(npc, 14, 0, 0, 2)
    SetPedComponentVariation(npc, 2, 3, 2, 2)
    SetPedComponentVariation(npc, 3, 1, 0, 2)
    SetPedComponentVariation(npc, 4, 5, 2, 2)
    SetPedComponentVariation(npc, 6, 1, 0, 2)
    SetPedComponentVariation(npc, 8, 0, 0, 2)
    SetPedComponentVariation(npc, 11, 7, 2, 2)
    SetPedPropIndex(npc, 1, 0, 0, true)
    SetModelAsNoLongerNeeded(npcModel)

    function CreateRedArea()
        areaBlip = AddBlipForRadius(npcCoords2.x, npcCoords2.y, npcCoords2.z, 100.0)
        SetBlipColour(areaBlip, 1)
        SetBlipAlpha(areaBlip, 128)
    end

    function RemoveRedArea()
        if areaBlip ~= nil then
            RemoveBlip(areaBlip)
            areaBlip = nil
        end
    end

    function MakeNPCAggressive(npc)
        SetPedCombatAttributes(npc, 46, true)
        SetPedCombatAttributes(npc, 5, true)
        SetPedCombatAttributes(npc, 20, true)
        SetPedCombatAbility(npc, 100)
        SetPedCombatMovement(npc, 2)
        SetPedCombatRange(npc, 2)
        SetPedTargetLossResponse(npc, 1)
        SetPedAlertness(npc, 3)
        SetPedAccuracy(npc, 100)
        TaskCombatPed(npc, PlayerPedId(), 0, 16)
    end

    function SpawnNPC()
        local model = GetHashKey("a_m_y_skater_01")
        RequestModel(model)
        while not HasModelLoaded(model) do
            Wait(1)
        end

        npcCoords2 = GetRandomSpawnLocation()
        local numNPCs = math.random(5, 7)
        local npcList = {}

        for i = 1, numNPCs do
            local spawnCoords = vector3(
                npcCoords2.x + math.random(-3, 3),
                npcCoords2.y + math.random(-3, 3),
                npcCoords2.z
            )

            local npcPed = CreatePed(4, model, spawnCoords.x, spawnCoords.y, spawnCoords.z, 0.0, true, true)
            SetEntityAsMissionEntity(npcPed, true, true)
            SetBlockingOfNonTemporaryEvents(npcPed, true)

            table.insert(npcs, npcPed)
            MakeNPCAggressive(npcPed)
            table.insert(npcList, npcPed)
        end

        if #npcList > 0 then
            interactableNPC = npcList[math.random(#npcList)]
        end

        npcSpawned = true
        CreateRedArea()
    end

    function SetupNPCInteraction()
        for _, npc in ipairs(npcs) do
            exports['qb-target']:AddTargetEntity(npc, {
                options = {
                    {
                        type = "client",
                        event = "npc:pickup",
                        icon = "fas fa-user-injured",
                        label = CFG.TargetTexts.PickUpNPC,
                        canInteract = function(entity)
                            return entity == interactableNPC and IsEntityDead(entity)
                        end,
                    },
                },
                distance = 2.0
            })
        end
    end

    function WasKilledByFirearm(ped)
        local cause = GetPedCauseOfDeath(ped)
        for _, weapon in ipairs(CFG.FirearmWeapons) do
            if cause == GetHashKey(weapon) then
                return true
            end
        end
        return false
    end

    function PickupNPC()
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        
        if not interactableNPC or not DoesEntityExist(interactableNPC) then
            QBCore.Functions.Notify(CFG.Notifications.NoNPCNearby, "error")
            return
        end

        if carryingNPC then
            NetworkRequestControlOfEntity(interactableNPC)
            ClearPedTasks(playerPed)
            DetachEntity(interactableNPC, true, false)
            carryingNPC = false

            SetEntityHealth(interactableNPC, 0)
            SetEntityCanBeDamaged(interactableNPC, true)
            SetPedCanRagdoll(interactableNPC, true)
            SetPedCanRagdollFromPlayerImpact(interactableNPC, true)
            SetPedConfigFlag(interactableNPC, 166, false)
            SetPedConfigFlag(interactableNPC, 170, false)
            SetPedToRagdoll(interactableNPC, 10000, 10000, 0, true, true, false)

            QBCore.Functions.Notify(CFG.Notifications.DroppedBody, "success")
        else
            if WasKilledByFirearm(interactableNPC) then
                killedByFirearm = true
            end

            carryingNPC = true

            RequestAnimDict("missfinale_c2mcs_1")
            RequestAnimDict("nm")

            while not HasAnimDictLoaded("missfinale_c2mcs_1") or not HasAnimDictLoaded("nm") do
                Citizen.Wait(100)
            end

            TaskPlayAnim(playerPed, "missfinale_c2mcs_1", "fin_c2_mcs_1_camman", 8.0, -8.0, -1, 49, 0, false, false, false)
            TaskPlayAnim(interactableNPC, "nm", "firemans_carry", 8.0, -8.0, -1, 33, 0, false, false, false)
            AttachEntityToEntity(interactableNPC, playerPed, 0, 0.27, 0.15, 0.63, 0.5, 0.5, 0.0, false, false, false, false, 2, false)

            QBCore.Functions.Notify(CFG.Notifications.PickedUpBody, "success")
        end
    end

    RegisterNetEvent('npc:pickup')
    AddEventHandler('npc:pickup', function()
        PickupNPC()
    end)

    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(0)
            if carryingNPC then
                local playerPed = PlayerPedId()
                if not IsEntityPlayingAnim(playerPed, "missfinale_c2mcs_1", "fin_c2_mcs_1_camman", 3) then
                    TaskPlayAnim(playerPed, "missfinale_c2mcs_1", "fin_c2_mcs_1_camman", 8.0, -8.0, -1, 49, 0, false, false, false)
                end

                if not IsEntityPlayingAnim(interactableNPC, "nm", "firemans_carry", 3) then
                    TaskPlayAnim(interactableNPC, "nm", "firemans_carry", 8.0, -8.0, -1, 33, 0, false, false, false)
                end

                if IsControlJustPressed(0, 38) then
                    PickupNPC()
                end

                DrawText3D(GetEntityCoords(playerPed), "Press ~g~E~w~ to drop the body")
            end
        end
    end)

    exports['qb-target']:AddTargetEntity(npc, {
        options = {
            {
                type = "client",
                event = "npcmission:startMissionTarget",
                icon = "fas fa-user-secret",
                label = CFG.TargetTexts.StartMission,
                canInteract = function()
                    return not missionStarted
                end
            },
            {
                type = "client",
                event = "npcmission:finishMissionTarget",
                icon = "fas fa-check",
                label = CFG.TargetTexts.FinishMission,
                canInteract = function()
                    return carryingNPC
                end
            }
        },
        distance = 2.0
    })

    RegisterNetEvent('npcmission:startMissionTarget')
    AddEventHandler('npcmission:startMissionTarget', function()
        if not missionStarted then
            TriggerServerEvent('npcmission:checkCooldown')
            
            Citizen.Wait(500)
            
            local PlayerData = QBCore.Functions.GetPlayerData()
            local canStartMission = PlayerData.metadata.canStartNPCMission
            local remainingTime = PlayerData.metadata.npcMissionCooldown or 0
            
            if canStartMission then
                TriggerServerEvent('npcmission:startMission')
                missionStarted = true
                ShowInterface()
            else
                if remainingTime > 0 then
                    QBCore.Functions.Notify(string.format(CFG.Notifications.WaitForNextMission, remainingTime), "error")
                else
                    QBCore.Functions.Notify(CFG.Notifications.CantStartMission, "error")
                end
            end
        else
            QBCore.Functions.Notify(CFG.Notifications.MissionStarted, "error")
        end
    end)

    RegisterNetEvent('npcmission:finishMissionTarget')
    AddEventHandler('npcmission:finishMissionTarget', function()
        if carryingNPC then
            if killedByFirearm then
                QBCore.Functions.Notify(CFG.Notifications.KilledWithFirearm, "error")
            else
                local reward = math.random(CFG.Reward[1], CFG.Reward[2])
                TriggerServerEvent('npcmission:giveReward', reward)
                QBCore.Functions.Notify(string.format(CFG.Notifications.RewardReceived, reward), "success")
            end

            TriggerServerEvent('npcmission:finishMission')
            missionStarted = false
            DeleteEntity(interactableNPC)
            carryingNPC = false
            killedByFirearm = false
            RemoveRedArea()
        end
    end)

    function DrawText3D(coords, text)
        local x, y, z = table.unpack(coords)
        local onScreen,_x,_y=World3dToScreen2d(x, y, z)
        local px,py,pz=table.unpack(GetGameplayCamCoords())
        local dist = GetDistanceBetweenCoords(px,py,pz, x,y,z, 1)

        local scale = (1/dist)*2
        local fov = (1/GetGameplayCamFov())*100
        local scale = scale*fov
        if onScreen then
            SetTextScale(0.0*scale, .3*scale)
            SetTextFont(0)

            SetTextProportional(1)
            SetTextColour(255, 255, 255, 255)
            SetTextDropShadow(0, 0, 0, 0, 255)
            SetTextEdge(2, 0, 0, 0, 150)
            SetTextDropShadow()
            SetTextOutline()
            SetTextEntry("STRING")
            SetTextCentre(5)
            AddTextComponentString(text)
            DrawText(_x,_y)
        end
    end

    function ShowInterface()
        SetNuiFocus(true, true)
        SendNUIMessage({
            type = "open"
        })
    end

    RegisterNUICallback('accept', function(data, cb)
        print("ACCEPT clicked")
        SpawnNPC()
        SetupNPCInteraction()
        print("Mission started!")
        SetNuiFocus(false, false)
        QBCore.Functions.Notify(CFG.Notifications.GoGetTargets, "success")
        cb('ok')
    end)

    RegisterNUICallback('cancel', function(data, cb)
        print("CANCEL clicked")
        missionStarted = false
        SetNuiFocus(false, false)
        cb('ok')
    end)

    function AreAllNPCsDead()
        for _, npc in ipairs(npcs) do
            if not IsEntityDead(npc) then
                return false
            end
        end
        return true
    end

    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(1000)
            if npcSpawned and AreAllNPCsDead() then
                RemoveRedArea()
                npcSpawned = false
                break
            end
        end
    end)

    Citizen.CreateThread(function()
        if CFG.Blip == 'yes' then
            local blip = AddBlipForCoord(npcCoords.x, npcCoords.y, npcCoords.z) -- Coordenadas x, y, z
        
            SetBlipSprite(blip, 792)
            SetBlipDisplay(blip, 4)
            SetBlipScale(blip, 1.0)
            SetBlipColour(blip, 1)
            SetBlipAsShortRange(blip, true)
        
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString("Mission 1")
            EndTextCommandSetBlipName(blip)
        end
    end)
end)