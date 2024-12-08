function HandleFillCommand(Split, Player)
    local Response

    -- Ensure proper arguments: /fill <x1> <y1> <z1> <x2> <y2> <z2> <blockID>
    if (#Split ~= 8) then
        Player:SendMessage("Usage: /fill <x1> <y1> <z1> <x2> <y2> <z2> <blockID>")
        return true
    end

    -- Parse coordinates with support for relative notation
    local pos = Player:GetPosition() -- Get the player's current position
    local x1 = ParseCoordinate(Split[2], pos.x)
    local y1 = ParseCoordinate(Split[3], pos.y)
    local z1 = ParseCoordinate(Split[4], pos.z)
    local x2 = ParseCoordinate(Split[5], pos.x)
    local y2 = ParseCoordinate(Split[6], pos.y)
    local z2 = ParseCoordinate(Split[7], pos.z)
    local blockTypeName = Split[8]:lower()

    -- Check if coordinates are valid
    if not (x1 and y1 and z1 and x2 and y2 and z2) then
        Player:SendMessageFailure("Invalid coordinates! Ensure you enter numbers or use valid relative syntax (~).")
        return true
    end

    -- Sort coordinates to ensure x1, y1, z1 are the minimum values
    if x1 > x2 then x1, x2 = x2, x1 end
    if y1 > y2 then y1, y2 = y2, y1 end
    if z1 > z2 then z1, z2 = z2, z1 end

    -- Get the player's world
    local world = Player:GetWorld()

    -- Compute the chunk range
    local chunkX1, chunkZ1 = math.floor(x1 / 16), math.floor(z1 / 16)
    local chunkX2, chunkZ2 = math.floor(x2 / 16), math.floor(z2 / 16)

    local chunks = {}
    for cx = chunkX1, chunkX2 do
        for cz = chunkZ1, chunkZ2 do
            table.insert(chunks, {cx, cz})
        end
    end

    -- Load the necessary chunks
    world:ChunkStay(chunks, nil, function()
        -- Fill the area with the specified block type using vector-based method
        local i = 0
        for x = x1, x2 do
            for y = y1, y2 do
                for z = z1, z2 do
                    local pos = Vector3i(x, y, z)
                    world:SetBlock(pos, blockTypeName, 0)
                    i = i + 1
                end
            end
        end

        Player:SendMessageSuccess("Filled " .. i .. " blocks with " .. blockTypeName .. ".")
        LOGINFO("[" .. Player:GetName() .. "]: " .. StripColorCodes("filled " .. i .. " blocks with " .. blockTypeName .. "."))
    end)

    return true, Response
end

function HandleConsoleFill(Split)
    return HandleFillCommand(Split)
end

