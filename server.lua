local ox_inventory = exports.ox_inventory

lib.callback.register('custom_shop:processTransaction', function(source, itemName, quantity, price)
    local xPlayer = source
    local totalPrice = quantity * price

    local currentItemCount = ox_inventory:Search(xPlayer, 'count', itemName) or 0

    if currentItemCount >= quantity then
        local removed = ox_inventory:RemoveItem(xPlayer, itemName, quantity)

        if removed then
            ox_inventory:AddItem(xPlayer, 'cash', totalPrice)

            return true, 'You sold ' .. quantity .. ' ' .. itemName .. '(s) for $' .. totalPrice
        else
            return false, 'Failed to remove items from your inventory.'
        end
    else
        return false, 'You don’t have enough ' .. itemName .. '!'
    end
end)
