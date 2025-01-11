Config = {}

Config.Shops = {
    {
        npcModel = 's_m_y_shop_mask',
        coords = vector4(182.4445, -1319.3136, 29.3162, 239.9444), -- Vector4 includes heading
        dialog = {
            title = "Electronic Shop",
            greeting = "Hey there! What do you want to do?",
            options = {
                {
                    id = 'sell_fruits',
                    label = "Sell Electronics",
                    icon = 'fas fa-apple-alt',
                    close = true,
                    items = {
                        { name = 'phone', label = 'Phone', price = 5 },
                        { name = 'radio', label = 'Radio', price = 5 },
                    },
                },
                {
                    id = 'close',
                    label = "Never mind",
                    icon = 'fas fa-ban',
                    close = true,
                },
            },
        },
        blip = {
            enabled = true, -- Enable/disable blip for this shop
            sprite = 52,    -- Blip sprite ID
            color = 1,      -- Blip color ID
            scale = 0.8,    -- Blip size/scale
            name = "Blip Name", -- Blip text
        },
    },
}
