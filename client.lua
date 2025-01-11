local ox_inventory = exports.ox_inventory

local function openSellMenu(items)
    local menu = {}

    for _, item in ipairs(items) do
        -- Fetch item count from ox_inventory
        local itemData = ox_inventory:Search('count', item.name)
        local itemCount = 0

        if type(itemData) == "number" then
            itemCount = itemData
        elseif type(itemData) == "table" then
            itemCount = itemData[1] or 0
        end

        table.insert(menu, {
            title = item.label .. " ($" .. item.price .. " each)",
            description = itemCount > 0 and "You have " .. itemCount .. " " .. item.label or "You have none to sell",
            icon = "nui://ox_inventory/web/images/" .. item.name .. ".png",
            onSelect = function()
                if itemCount > 0 then
                    local input = lib.inputDialog("Sell " .. item.label, {
                        {
                            type = "slider",
                            label = "Quantity to sell",
                            min = 1,
                            max = itemCount,
                        },
                    })

                    if input and tonumber(input[1]) > 0 then
                        local quantityToSell = tonumber(input[1])

                        lib.callback('custom_shop:processTransaction', false, function(success, message)
                            if success then
                                lib.notify({
                                    title = 'Transaction Successful',
                                    description = message,
                                    type = 'success',
                                })
                            else
                                lib.notify({
                                    title = 'Transaction Failed',
                                    description = message,
                                    type = 'error',
                                })
                            end
                        end, item.name, quantityToSell, item.price)
                    else
                        lib.notify({
                            title = 'Invalid Input',
                            description = 'Please select a valid quantity.',
                            type = 'error',
                        })
                    end
                else
                    lib.notify({
                        title = 'No Items',
                        description = 'You don’t have any ' .. item.label .. ' to sell.',
                        type = 'error',
                    })
                end
            end,
        })
    end

    lib.registerContext({
        id = "sell_menu",
        title = "Sell Items",
        options = menu,
    })

    lib.showContext("sell_menu")
end

-- Rest of your client script remains unchanged


local function handleDialogOption(option)
    if option.id == "sell_fruits" and option.items then
        openSellMenu(option.items)
    end
end

local function openShopDialogue(shop, ped)
    local options = {}

    for _, option in ipairs(shop.dialog.options) do
        table.insert(options, {
            id = option.id,
            label = option.label,
            icon = option.icon,
            close = option.close,
            action = function()
                handleDialogOption(option)
            end,
        })
    end

    exports.mt_lib:showDialogue({
        ped = ped,
        label = shop.dialog.title,
        speech = shop.dialog.greeting,
        options = options,
    })
end

CreateThread(function()
    for _, shop in pairs(Config.Shops) do
        local pedModel = GetHashKey(shop.npcModel)

        RequestModel(pedModel)
        while not HasModelLoaded(pedModel) do
            Wait(500)
        end

        local ped = CreatePed(4, pedModel, shop.coords.x, shop.coords.y, shop.coords.z - 1, shop.coords.w, false, true)

        if DoesEntityExist(ped) then
            FreezeEntityPosition(ped, true)
            SetEntityInvincible(ped, true)
            TaskStartScenarioInPlace(ped, 'WORLD_HUMAN_STAND_IMPATIENT', 0, true)

            -- Passive behavior to prevent aggression
            SetBlockingOfNonTemporaryEvents(ped, true)
            SetPedCanRagdoll(ped, false)
            SetPedConfigFlag(ped, 287, true) -- Disable being scared
            SetPedConfigFlag(ped, 209, true) -- Prevent attacks on hit
            SetPedConfigFlag(ped, 208, true) -- Prevent fight back

            exports.ox_target:addLocalEntity(ped, {
                {
                    label = 'Talk to ' .. shop.dialog.title,
                    icon = 'fas fa-comments',
                    onSelect = function()
                        openShopDialogue(shop, ped)
                    end,
                },
            })

            -- Blip logic
            if shop.blip and shop.blip.enabled then
                local blip = AddBlipForCoord(shop.coords.x, shop.coords.y, shop.coords.z)
                SetBlipSprite(blip, shop.blip.sprite)
                SetBlipColour(blip, shop.blip.color)
                SetBlipScale(blip, shop.blip.scale)
                SetBlipAsShortRange(blip, true)
                BeginTextCommandSetBlipName("STRING")
                AddTextComponentSubstringPlayerName(shop.blip.name)
                EndTextCommandSetBlipName(blip)
            end
        else
            print('Failed to create ped for shop "' .. shop.dialog.title .. '". Check model and coordinates.')
        end

        SetModelAsNoLongerNeeded(pedModel)
    end
end)
