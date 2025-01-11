local ox_inventory = exports.ox_inventory

lib.callback.register('custom_shop:processTransaction', function(source, itemName, quantity, price)
    local xPlayer = source
    local totalPrice = quantity * price

    -- Check player's item count
    local currentItemCount = ox_inventory:Search(xPlayer, 'count', itemName) or 0

    if currentItemCount >= quantity then
        -- Remove items from inventory
        local removed = ox_inventory:RemoveItem(xPlayer, itemName, quantity)

        if removed then
            -- Add money to the player
            ox_inventory:AddItem(xPlayer, 'cash', totalPrice)

            -- Return success
            return true, 'You sold ' .. quantity .. ' ' .. itemName .. '(s) for $' .. totalPrice
        else
            -- Return failure if the item could not be removed
            return false, 'Failed to remove items from your inventory.'
        end
    else
        -- Return failure if not enough items
        return false, 'You don’t have enough ' .. itemName .. '!'
    end
end)
