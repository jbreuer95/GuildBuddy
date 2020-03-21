local _, NS = ...
local GuildBuddy = NS.GuildBuddy
local sha1 = LibStub("LibSHA1")
local libS = LibStub:GetLibrary("AceSerializer-3.0")
local LibDeflate = LibStub:GetLibrary("LibDeflate")


function compressData(data)
    local serialized = libS:Serialize(data)
    local compressed = LibDeflate:CompressDeflate(serialized)
    local encoded = LibDeflate:EncodeForWoWAddonChannel(compressed)

    return encoded
end

function decompressData(data)
    local decoded = LibDeflate:DecodeForWoWAddonChannel(data)
    local decompressed = LibDeflate:DecompressDeflate(decoded)

    return libS:Deserialize(decompressed)
end

local prototype = {
    database = '',
}

GuildBuddy.Chain = {
    mt = {},
    Load = function(self, database)
        setmetatable(self, GuildBuddy.Chain.mt)
        self.database = database
    end,
    IsUpToDate = function(self)
        local lastHash = GetGuildInfoText()
        local lastBlock = self.database[lastHash]
        if lastBlock then
            lastBlock = GuildBuddy.Block.Load(lastBlock)
            lastBlock:Validate()

            local chainsize = 0
            for _ in pairs(self.database) do chainsize = chainsize + 1 end
            if chainsize == lastBlock.i then
                return true
            end
        end
        return false
    end,
    AddBlock = function(self, data)
        local lastHash = GetGuildInfoText()
        local lastBlock = self.database[lastHash]
        if not lastBlock and lastHash ~= "startchain" then
            print("chain not up to date sync before adding")
            return false
        end

        if lastBlock and lastBlock.p ~= "" then
            lastBlock = GuildBuddy.Block.Load(lastBlock)
            lastBlock:Validate()
        end

        local block = GuildBuddy.Block.New(data, lastBlock)
        block:Validate()

        self.database[block.h] = block:ToTable()
        SetGuildInfoText(block.h)
        return block
    end
}

GuildBuddy.Chain.mt.__metatable = "Private"

GuildBuddy.Chain.mt.__index = function(tab, key)
    if GuildBuddy.Chain[key] then
        return GuildBuddy.Chain[key]
    elseif prototype[key] then
        return prototype[key]
    else
        error(key.." is not a property belonging on a Chain")
    end
end

GuildBuddy.Chain.mt.__newindex = function(tab, key, value)
    if prototype[key] then
        rawset(tab, key, value)
    else
        error(key.." is not a property belonging on a block")
    end
end

GuildBuddy.Chain.mt.__tostring = function(b)
    print('-----CHAIN-----')
    print('-------------------')
end

