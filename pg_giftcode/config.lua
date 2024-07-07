Config = {}

Config.Framework = 'QBCore' -- ESX, QBCore
Config.CheckUserRedeem = false  -- Check if the player has entered a giftcode
Config.LimitRedeem = false      -- Limit the number of times a giftcode can be entered in the server
Config.ExpireGiftcode = false   -- Time when giftcode can be used
Config.AllowedGroup = 'admin' -- Groups that can use the Command
Config.Inventory = 'ox_inventory' -- ox_inventory, qb-inventory, ps-inventory

Config.Notify = {
    ['cancelled_create'] = 'Giftcode creation has been cancelled.',
    ['no_perm'] = 'You do not have permission to use this command.',
    ['invalid_date'] = 'Invalid date format',
    ['create_success'] = 'Giftcode has been successfully created.',
    ['enter_success'] = 'Giftcode has been successfully enter.',
    ['cannot_create'] = 'Cannot create giftcode.',
    ['has_expired'] = 'Giftcode has expired',
    ['usage_limit'] = 'Giftcode has reached its usage limit',
    ['already_used'] = 'You have already used this giftcode',
    ['giftcode_invalid'] = 'Giftcode is invalid or has been used',
    ['received_reward'] = 'You have received your reward %s %s',
    ['received_vehicle'] = 'You have received your reward %s',
    ['invalid_reward'] = 'Invalid reward type.',
    ['unable_update'] = 'Unable to update giftcode usage times.',
}