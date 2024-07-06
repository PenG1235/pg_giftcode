if Config.Framework == 'ESX' then
    ESX = exports["es_extended"]:getSharedObject()

    ESX.RegisterServerCallback('pg_giftcode:checkAdmin', function(source, cb)
        local xPlayer = ESX.GetPlayerFromId(source)
        if xPlayer.getGroup() == Config.AllowedGroup then
            cb(true)
        else
            cb(false)
        end
    end)

    function redeemGiftcode(xPlayer, giftcode)
        if not giftcode then
            print("Giftcode is nil")
            return
        end
        MySQL.Async.execute('UPDATE pg_giftcodes SET current_redeem = current_redeem + 1 WHERE code = @code', {
            ['@code'] = giftcode.code
        }, function(rowsChanged)
            if rowsChanged > 0 then
                if giftcode.reward_type == 'money' then
                    xPlayer.addAccountMoney(giftcode.reward, giftcode.amount)
                    TriggerClientEvent('ox_lib:notify', xPlayer.source, {
                        description = Config.Notify['received_reward']:format(giftcode.amount, giftcode.reward),
                        type = 'success'
                    })
                elseif giftcode.reward_type == 'item' then
                    xPlayer.addInventoryItem(giftcode.reward, tonumber(giftcode.amount))
                    TriggerClientEvent('ox_lib:notify', xPlayer.source, {
                        description = Config.Notify['received_reward']:format(giftcode.amount, giftcode.reward),
                        type = 'success'
                    })
                elseif giftcode.reward_type == 'vehicle' then
                    TriggerClientEvent('ox_lib:notify', xPlayer.source, {
                        description = Config.Notify['received_vehicle']:format(giftcode.reward),
                        type = 'success'
                    })
                    TriggerClientEvent('pg_giftcode:SpawnVehicle', xPlayer.source, giftcode.reward)
                else
                    TriggerClientEvent('ox_lib:notify', xPlayer.source, {
                        description = Config.Notify['invalid_reward'],
                        type = 'error'
                    })
                end
            else
                TriggerClientEvent('ox_lib:notify', xPlayer.source, {
                    description = Config.Notify['unable_update'],
                    type = 'error'
                })
            end
        end)
    end
    
elseif Config.Framework == 'QBCore' then
    QBCore = exports['qb-core']:GetCoreObject()

    QBCore.Functions.CreateCallback('pg_giftcode:checkAdmin', function(source, cb)
        local Player = QBCore.Functions.HasPermission(source, Config.AllowedGroup)
        if Player or IsPlayerAceAllowed(source, 'command') then
            cb(true)
        else
            cb(false)
        end
    end)

    function redeemGiftcode(Player, giftcode)
        if not giftcode then
            print("Giftcode is nil")
            return
        end
        exports.oxmysql:execute('UPDATE pg_giftcodes SET current_redeem = current_redeem + 1 WHERE code = @code', {
            ['@code'] = giftcode.code
        }, function(result)
            local rowsChanged = result and result.affectedRows or 0
            
            if rowsChanged > 0 then
                if giftcode.reward_type == 'money' then
                    Player.Functions.AddMoney(giftcode.reward, giftcode.amount)
                    TriggerClientEvent('ox_lib:notify', Player.PlayerData.source, {
                        description = Config.Notify['received_reward']:format(giftcode.amount, giftcode.reward),
                        type = 'success'
                    })
                elseif giftcode.reward_type == 'item' then
                    Player.Functions.AddItem(giftcode.reward, tonumber(giftcode.amount))
                    TriggerClientEvent('ox_lib:notify', Player.PlayerData.source, {
                        description = Config.Notify['received_reward']:format(giftcode.amount, giftcode.reward),
                        type = 'success'
                    })
                elseif giftcode.reward_type == 'vehicle' then
                    TriggerClientEvent('ox_lib:notify', Player.PlayerData.source, {
                        description = Config.Notify['received_vehicle']:format(giftcode.reward),
                        type = 'success'
                    })
                    TriggerClientEvent('pg_giftcode:SpawnVehicle', Player.PlayerData.source, giftcode.reward)
                else
                    TriggerClientEvent('ox_lib:notify', Player.PlayerData.source, {
                        description = Config.Notify['invalid_reward'],
                        type = 'error'
                    })
                end
            else
                TriggerClientEvent('ox_lib:notify', Player.PlayerData.source, {
                    description = Config.Notify['unable_update'],
                    type = 'error'
                })
            end
        end)
    end
end

RegisterServerEvent('pg_giftcode:addGiftcode')
AddEventHandler('pg_giftcode:addGiftcode', function(input)
    local source = source
    local code = input[1]
    local reward = input[2]
    local amount = input[3]
    local reward_type = input[4]
    local max_redeem = tonumber(input[5])
    local expire_at = input[6]

    local year, month, day = string.match(expire_at, '(%d+)-(%d+)-(%d+)')
    if not (year and month and day) then
        TriggerClientEvent('ox_lib:notify', source, {
            description = Config.Notify['invalid_date'],
            type = 'error'
        })
        return
    end
    expire_at = string.format('%s-%s-%s 00:00:00', year, month, day)
    
    if Config.Framework == 'ESX' then 
        MySQL.Async.execute('INSERT INTO pg_giftcodes (code, reward, amount, reward_type, max_redeem, current_redeem, expire_at) VALUES (@code, @reward, @amount, @reward_type, @max_redeem, 0, @expire_at)', {
            ['@code'] = code,
            ['@reward'] = reward,
            ['@amount'] = amount,
            ['@reward_type'] = reward_type,
            ['@max_redeem'] = max_redeem,
            ['@expire_at'] = expire_at
        }, function(rowsChanged)
            if rowsChanged > 0 then
                TriggerClientEvent('ox_lib:notify', source, {
                    description = Config.Notify['create_success'],
                    type = 'success'
                })
            else
                TriggerClientEvent('ox_lib:notify', source, {
                    description = Config.Notify['cannot_create'],
                    type = 'error'
                })
            end
        end)
    elseif Config.Framework == 'QBCore' then
        exports.oxmysql:execute('INSERT INTO pg_giftcodes (code, reward, amount, reward_type, max_redeem, current_redeem, expire_at) VALUES (@code, @reward, @amount, @reward_type, @max_redeem, 0, @expire_at)', {
            ['@code'] = code,
            ['@reward'] = reward,
            ['@amount'] = amount,
            ['@reward_type'] = reward_type,
            ['@max_redeem'] = max_redeem,
            ['@expire_at'] = expire_at
        }, function(result)
            if result and result.affectedRows and result.affectedRows > 0 then
                TriggerClientEvent('ox_lib:notify', source, {
                    description = Config.Notify['create_success'],
                    type = 'success'
                })
            else
                TriggerClientEvent('ox_lib:notify', source, {
                    description = Config.Notify['cannot_create'],
                    type = 'error'
                })
            end
        end)
    end
end)

RegisterServerEvent('pg_giftcode:redeemGiftcode')
AddEventHandler('pg_giftcode:redeemGiftcode', function(input)
    if Config.Framework == 'ESX' then   
        local source = source
        local xPlayer = ESX.GetPlayerFromId(source)
        local code = input[1]

        MySQL.Async.fetchAll('SELECT * FROM pg_giftcodes WHERE code = @code', {
            ['@code'] = code
        }, function(result)
            if #result > 0 then
                local giftcode = result[1]
                if Config.ExpireGiftcode and giftcode.expire_at then
                    local expire_time = tonumber(giftcode.expire_at)
                    if expire_time then
                        if expire_time > 9999999999 then
                            expire_time = expire_time / 1000
                        end
                        if os.time() > expire_time then
                            TriggerClientEvent('ox_lib:notify', source, {
                                description = Config.Notify['has_expired'],
                                type = 'error'
                            })
                            return
                        end
                    else
                        TriggerClientEvent('ox_lib:notify', source, {
                            description = Config.Notify['invalid_date'],
                            type = 'error'
                        })
                        return
                    end
                end
                if Config.LimitRedeem and giftcode.current_redeem >= giftcode.max_redeem then
                    TriggerClientEvent('ox_lib:notify', source, {
                        description = Config.Notify['usage_limit'],
                        type = 'error'
                    })
                    return
                end
                if Config.CheckUserRedeem then
                    MySQL.Async.fetchAll('SELECT * FROM pg_user_giftcodes WHERE identifier = @identifier AND code = @code', {
                        ['@identifier'] = xPlayer.identifier,
                        ['@code'] = code
                    }, function(userResult)
                        if #userResult > 0 then
                            TriggerClientEvent('ox_lib:notify', source, {
                                description = Config.Notify['already_used'],
                                type = 'error'
                            })
                            return
                        end

                        MySQL.Async.execute('INSERT INTO pg_user_giftcodes (identifier, code) VALUES (@identifier, @code)', {
                            ['@identifier'] = xPlayer.identifier,
                            ['@code'] = code
                        })

                        redeemGiftcode(xPlayer, giftcode)
                    end)
                else
                    redeemGiftcode(xPlayer, giftcode)
                end
            else
                TriggerClientEvent('ox_lib:notify', source, {
                    description = Config.Notify['giftcode_invalid'],
                    type = 'error'
                })
            end
        end)
    elseif Config.Framework == 'QBCore' then
        local source = source
        local Player = QBCore.Functions.GetPlayer(source)
        local code = input[1]

        exports.oxmysql:fetch('SELECT * FROM pg_giftcodes WHERE code = @code', {
            ['@code'] = code
        }, function(result)
            if result and #result > 0 then
                local giftcode = result[1]
                if Config.ExpireGiftcode and giftcode.expire_at then
                    local expire_time = tonumber(giftcode.expire_at)
                    if expire_time then
                        if expire_time > 9999999999 then
                            expire_time = expire_time / 1000
                        end
                        if os.time() > expire_time then
                            TriggerClientEvent('ox_lib:notify', source, {
                                description = Config.Notify['has_expired'],
                                type = 'error'
                            })
                            return
                        end
                    else
                        TriggerClientEvent('ox_lib:notify', source, {
                            description = Config.Notify['invalid_date'],
                            type = 'error'
                        })
                        return
                    end
                end
                if Config.LimitRedeem and giftcode.current_redeem >= giftcode.max_redeem then
                    TriggerClientEvent('ox_lib:notify', source, {
                        description = Config.Notify['usage_limit'],
                        type = 'error'
                    })
                    return
                end
                if Config.CheckUserRedeem then
                    exports.oxmysql:fetch('SELECT * FROM pg_user_giftcodes WHERE identifier = @identifier AND code = @code', {
                        ['@identifier'] = Player.PlayerData.citizenid,
                        ['@code'] = code
                    }, function(userResult)
                        if #userResult > 0 then
                            TriggerClientEvent('ox_lib:notify', source, {
                                description = Config.Notify['already_used'],
                                type = 'error'
                            })
                            return
                        end

                        exports.oxmysql:insert('INSERT INTO pg_user_giftcodes (identifier, code) VALUES (@identifier, @code)', {
                            ['@identifier'] = Player.PlayerData.citizenid,
                            ['@code'] = code
                        })

                        redeemGiftcode(Player, giftcode)
                    end)
                else
                    redeemGiftcode(Player, giftcode)
                end
            else
                TriggerClientEvent('ox_lib:notify', source, {
                    description = Config.Notify['giftcode_invalid'],
                    type = 'error'
                })
            end
        end)
    end
end)

RegisterServerEvent('pg_giftcode:giveVehicle')
AddEventHandler('pg_giftcode:giveVehicle', function(vehicleProps, modelname)
    if Config.Framework == 'ESX' then
        local xPlayer = ESX.GetPlayerFromId(source)
        if xPlayer then
            MySQL.Async.execute('INSERT INTO owned_vehicles (vehicle, owner, plate) VALUES (@vehicle, @owner, @plate)',
            {
                ['@owner']   = xPlayer.identifier,
                ['@plate'] = vehicleProps.plate,
                ['@vehicle'] = json.encode(vehicleProps)
            })
        end
    elseif Config.Framework == 'QBCore' then
        local Player = QBCore.Functions.GetPlayer(source)
        local cid = Player.PlayerData.citizenid
        local vehicle = modelname
        local plate = vehicleProps.plate
        if Player then
            exports.oxmysql:execute('INSERT INTO player_vehicles (license, citizenid, vehicle, hash, mods, plate, garage, state) VALUES (?, ?, ?, ?, ?, ?, ?, ?)', {
                Player.PlayerData.license,
                cid,
                vehicle,
                GetHashKey(vehicleProps),
                '{}',
                plate,
                'pillboxgarage',
                0
            })
        end
    end
end)