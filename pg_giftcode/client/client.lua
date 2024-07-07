if Config.Framework == 'ESX' then
    ESX = exports["es_extended"]:getSharedObject()
elseif Config.Framework == 'QBCore' then
    QBCore = exports['qb-core']:GetCoreObject()
end

RegisterCommand('addgiftcode', function()
    if Config.Framework == 'ESX' then
        ESX.TriggerServerCallback('pg_giftcode:checkAdmin', function(isAdmin)
            if isAdmin then
                local input = lib.inputDialog('Create Giftcode', {
                    {type = 'input', label = 'Code', description = 'Giftcode', required = true, min = 4, max = 16},
                    {type = 'input', label = 'Reward', description = 'For type money (bank, black_money, money)', required = true, min = 4, max = 16},
                    {type = 'number', label = 'Quantity', description = 'Quantity received', icon = 'hashtag', required = true},
                    {type = 'input', label = 'Reward type', description = 'item, vehicle, money', required = true, min = 4, max = 16},
                    {type = 'number', label = 'Max redeem', description = 'Maximum number of uses', icon = 'hashtag', required = true},
                    {type = 'input', label = 'Expire At (YYYY-MM-DD)', required = true }
                })

                if input then
                    TriggerServerEvent('pg_giftcode:addGiftcode', input)
                else
                    lib.notify({
                        description = Config.Notify['cancelled_create'],
                        type = 'error'
                    })
                end
            else
                lib.notify({
                    description = Config.Notify['no_perm'],
                    type = 'error'
                })
            end
        end)
    elseif Config.Framework == 'QBCore' then
        QBCore.Functions.TriggerCallback('pg_giftcode:checkAdmin', function(isAdmin)
            if isAdmin then
                local input = lib.inputDialog('Create Giftcode', {
                    {type = 'input', label = 'Code', description = 'Giftcode', required = true, min = 4, max = 16},
                    {type = 'input', label = 'Reward', description = 'For type money (bank, black_money, money)', required = true, min = 4, max = 16},
                    {type = 'number', label = 'Quantity', description = 'Quantity received', icon = 'hashtag', required = true},
                    {type = 'input', label = 'Reward type', description = 'item, vehicle, money', required = true, min = 4, max = 16},
                    {type = 'number', label = 'Max redeem', description = 'Maximum number of uses', icon = 'hashtag', required = true},
                    {type = 'input', label = 'Expire At (YYYY-MM-DD)', required = true }
                })
        
                if input then
                    TriggerServerEvent('pg_giftcode:addGiftcode', input)
                else
                    lib.notify({
                        description = Config.Notify['cancelled_create'],
                        type = 'error'
                    })
                end
            else
                lib.notify({
                    description = Config.Notify['no_perm'],
                    type = 'error'
                })
            end
        end)
    end
end, false)

RegisterCommand('redeem', function()
    local input = lib.inputDialog('Enter Giftcode', {
        {type = 'input', label = 'Giftcode', description = 'Enter your giftcode', required = true, min = 4, max = 16},
    })

    if input then
        TriggerServerEvent('pg_giftcode:redeemGiftcode', input)
    end
end, false)

RegisterNetEvent('pg_giftcode:SpawnVehicle')
AddEventHandler('pg_giftcode:SpawnVehicle', function(model, reward)
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)
    local heading = GetEntityHeading(playerPed)
    local vehicle = model
    if Config.Framework == 'ESX' then
        ESX.Game.SpawnVehicle(vehicle, coords, heading, function(vehicle)
            local vehicleProps = ESX.Game.GetVehicleProperties(vehicle)
            SetPedIntoVehicle(playerPed, vehicle, -1)
            SetVehicleHasBeenOwnedByPlayer(playerPed, true)
            TriggerServerEvent('pg_giftcode:giveVehicle', vehicleProps)
        end)
    elseif Config.Framework == 'QBCore' then
        QBCore.Functions.SpawnVehicle(vehicle, function(vehicle)
            local vehicleProps = QBCore.Functions.GetVehicleProperties(vehicle)
            SetPedIntoVehicle(playerPed, vehicle, -1)
            SetVehicleHasBeenOwnedByPlayer(playerPed, true)
            TriggerServerEvent('pg_giftcode:giveVehicle', vehicleProps, reward)
            TriggerEvent('vehiclekeys:client:SetOwner', QBCore.Functions.GetPlate(vehicle))
        end, coords, true)
    end
end)
