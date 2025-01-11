local ox_inventory = exports.ox_inventory

local function handleCheater(playerId, reason)
    exports.qbx_core:ExploitBan(playerId, reason)
end

lib.callback.register('custom_shop:processTransaction', function(source, itemName, quantity, price)
    local xPlayer = source
    local totalPrice = quantity * price

    local itemPrice
    for _, shop in ipairs(Config.Shops) do
        for _, item in ipairs(shop.dialog.options[1].items) do
            if item.name == itemName then
                itemPrice = item.price
                break
            end
        end
    end

    if not itemPrice then
        return false, 'Invalid item.'
    end

    if price ~= itemPrice then
        handleCheater(xPlayer, 'Invalid price.')
        return false, 'Transaction failed.'
    end

    local currentItemCount = ox_inventory:Search(xPlayer, 'count', itemName) or 0

    if currentItemCount >= quantity then
        local removed = ox_inventory:RemoveItem(xPlayer, itemName, quantity)

        if removed then
            ox_inventory:AddItem(xPlayer, 'cash', totalPrice)
            return true, ('You sold %d %s(s) for $%d'):format(quantity, itemName, totalPrice)
        else
            handleCheater(xPlayer, 'Attempted to gain reward without item removal.')
            return false, 'Transaction failed.'
        end
    else
        return false, ('You don’t have enough %s!'):format(itemName)
    end
end)
