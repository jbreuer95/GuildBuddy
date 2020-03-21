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


GuildBuddy.Chain = {
    database = '',
    requestHash = '',
    requestPlayer = '',
    syncing = false,
    waitForCache = false,
    syncTimer = '',
    mt = {},
    Load = function(self, database)
        setmetatable(self, GuildBuddy.Chain.mt)
        self.database = database

        GuildBuddy:RegisterComm("GB_UPDATE", function(prefix, data, channel, player)
            if player ~= GuildBuddy.PlayerName then
                print("update cache")
                self.waitForCache = true
            end
        end)

        GuildBuddy:RegisterComm("GB_RH", function(prefix, hash, channel, player)
            if player ~= GuildBuddy.PlayerName then
                local block = self.database[hash]
                if block then
                    print("Sending block existence to "..player)
                    GuildBuddy:SendCommMessage("GB_CH", hash, "WHISPER", player)
                end
            end
        end)
        GuildBuddy:RegisterComm("GB_CH", function(prefix, hash, channel, player)
            if self.requestPlayer == '' then
                self.requestPlayer = player
                print(player..' has block')
                GuildBuddy:SendCommMessage("GB_GB", hash, "WHISPER", player)
            end
        end)
        GuildBuddy:RegisterComm("GB_GB", function(prefix, hash, channel, player)
            local block = self.database[hash]
            block = GuildBuddy.Block.Load(block)
            block:Validate()
            print('sending block to '..player)
            GuildBuddy:SendCommMessage("GB_RB", compressData(block:ToTable()), "WHISPER", player)
        end)
        GuildBuddy:RegisterComm("GB_RB", function(prefix, data, channel, player)
            local success, block = decompressData(data)
            if self.requestHash == block.h then
                if self.requestPlayer == player then
                    print('receiving block from '..player)
                    block = GuildBuddy.Block.Load(block)
                    block:Validate()
                    self.database[block.h] = block:ToTable()
                    GuildBuddy:CancelTimer(self.syncTimer)
                    self.syncing = false

                    if block.p ~= "" then
                        local previous = self.database[block.p]
                        if not previous then
                            self:RequestBlock(block.p)
                        else
                            self:Sync()
                        end
                    end
                end
            end
        end)

    end,
    GetLastBlock = function(self)
        local lastHash = GetGuildInfoText()
        local lastBlock = self.database[lastHash]
        if lastBlock then
            return GuildBuddy.Block.Load(lastBlock)
        end
        return nil
    end,
    Sync = function(self)
        if not self.syncing then
            if not self:IsUpToDate() then
                print("Chain not up to date, starting sync")
                local block = self:GetLastBlock()
                if not block then
                    self:RequestBlock(GetGuildInfoText())
                else
                    local success = true
                    while success == true and block.p ~= "" do
                        block:Validate()
                        local hash = block.p
                        block = self.database[hash]
                        if not block then
                            success = false
                            print("Chain is missing a block in the middle somehow?")
                            self:RequestBlock(hash)
                        end
                    end
                end
            end
        end
    end,
    RequestBlock = function(self, hash)
        self.requestPlayer = ''
        self.syncing = true
        self.requestHash = hash
        print('requesting '..hash)
        GuildBuddy:SendCommMessage("GB_RH", hash, "GUILD")
        self.syncTimer = GuildBuddy:ScheduleTimer(function()
            print("Syncing "..self.requestHash.." timed out")
            self.syncing = false
        end, 5)
    end,
    IsUpToDate = function(self)
        local lastBlock = self:GetLastBlock()
        local lastHash = GetGuildInfoText()

        if not lastBlock and lastHash == "startchain" then
            return true
        end


        if lastBlock then
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
        local lastBlock = self:GetLastBlock()
        local lastHash = GetGuildInfoText()

        if self.waitForCache then
            print("Guild info cache out of date wait 11 seconds")
            return false
        end

        if not lastBlock and lastHash ~= "startchain" then
            print("chain not up to date sync before adding")
            return false
        end

        if lastBlock and lastBlock.p ~= "" then
            lastBlock:Validate()
        end

        local block = GuildBuddy.Block.New(data, lastBlock)
        block:Validate()

        self.database[block.h] = block:ToTable()
        SetGuildInfoText(block.h)
        GuildBuddy:SendCommMessage("GB_UPDATE", "Update Chain", "GUILD")
        return block
    end
}

GuildBuddy.Chain.mt.__metatable = "Private"

GuildBuddy.Chain.mt.__index = function(tab, key)
    if tab[key] then
        return tab[key]
    else
        error(key.." is not a property belonging on a Chain")
    end
end

GuildBuddy.Chain.mt.__newindex = function(tab, key, value)
    if tab[key] then
        rawset(tab, key, value)
    else
        error(key.." is not a property belonging on a block")
    end
end

GuildBuddy.Chain.mt.__tostring = function(b)
    print('-----CHAIN-----')
    print('-------------------')
end

