local _, NS = ...
local GuildBuddy = NS.GuildBuddy
local sha1 = LibStub("LibSHA1")
local libS = LibStub:GetLibrary("AceSerializer-3.0")
local LibDeflate = LibStub:GetLibrary("LibDeflate")

local this =  {}

function this:compressData(data)
    local serialized = libS:Serialize(data)
    local compressed = LibDeflate:CompressDeflate(serialized)
    local encoded = LibDeflate:EncodeForWoWAddonChannel(compressed)

    return encoded
end

function this:decompressData(data)
    local decoded = LibDeflate:DecodeForWoWAddonChannel(data)
    local decompressed = LibDeflate:DecompressDeflate(decoded)

    return libS:Deserialize(decompressed)
end

function GuildBuddy:NewBlock(data)
    local chain = GuildBuddy.db.char.blockchain
    local lastHash = GetGuildInfoText()
    local lastBlock = nil

    if string.len(lastHash) == 40 then
        lastBlock = chain[lastHash]
        if not lastBlock then
            print("chain not up to date sync before adding")
            return false
        end
    elseif lastHash ~= "startchain" then
        print("Someone changed the guild info, no last block found.\nJust installed addon? set guild information to: startchain")
        return false
    end

    local block = {
        index = 1,
        timestamp = GetServerTime(),
        data = nil,
        previousHash = "",
        hash = nil,
    }

    if lastBlock then
        block.index = lastBlock.index + 1
        block.previousHash = lastBlock.hash
    end

    block.data = libS:Serialize(data)

    block.hash = sha1(block.index..block.previousHash..block.timestamp..block.data)

    chain[block.hash] = block
    SetGuildInfoText(block.hash)

    return block
end

function GuildBuddy:PrintBlock(block)
    if block then
        print('-----BLOCK-----')
        print('index: '..block.index)
        print('timestamp: '..block.timestamp)
        print('data: '..block.data)
        print('previousHash: '..block.previousHash)
        print('hash: '..block.hash)
        print('---------------')
    end
end

function GuildBuddy:CheckChain()
    local chain = GuildBuddy.db.char.blockchain
    local block = nil

    local lastHash = GetGuildInfoText()
    if string.len(lastHash) == 40 then
        block = chain[lastHash]
        if not block then
            print("chain not up to date sync before checking")
            GuildBuddy:RequestBlock(lastHash)
            return false
        end
    elseif lastHash ~= "startchain" then
        print("Someone changed the guild info, no last block found.\nJust installed addon? set guild information to: startchain")
        return false
    else
        print("chain is yet to start be patient ;)")
        return false
    end

    local success = true
    while block.previousHash ~= "" and success == true  do
        success = GuildBuddy:CheckHash(block.hash)
        local hash = block.previousHash
        block = chain[hash]
        if not block then
            print("Chain is missing a block in the middle somehow?")
            GuildBuddy:RequestBlock(hash)
            return false
        end
    end

    if success then
        -- for i = 200,1,-1
        -- do
        --     local content = {
        --         ["type"] = "announcement",
        --         ["action"] = "add",
        --         ["author"] = GuildBuddy.PlayerName,
        --         ["title"] = "some genertic title",
        --         ["body"] = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. In cursus elementum dolor, nec tempor urna tempus non. Donec urna nunc, placerat ut erat ac, euismod commodo quam. Nunc venenatis eros eget posuere feugiat. Etiam ornare pharetra quam, eget tempus neque aliquet et. Duis maximus ullamcorper nunc, nec porta tellus pellentesque ac. Ut vitae ex eget lectus molestie molestie. Proin sit amet sem a arcu condimentum facilisis vel quis nulla. Nunc rhoncus ultrices maximus."
        --     }
        --     GuildBuddy:NewBlock(content)
        -- end
        print("Chain up to date and valid")
    end

end

function GuildBuddy:CheckHash(data)
    local chain = GuildBuddy.db.char.blockchain
    local hash = nil
    local block = nil
    if type(data) == "string" then
        hash = data
        block = chain[hash]

        if not block then
            print("Hash not found")
            return false
        end

    else
        hash = data.hash
        block = data
    end

    if hash ~= block.hash then
        print("error 1")
        return false
    end

    local calulatedHash = sha1(block.index..block.previousHash..block.timestamp..block.data)

    if hash ~= calulatedHash then
        print("error 2")
        return false
    end

    return true
end

function GuildBuddy:RequestBlock(hash)
    print("requesting block to guild")
    this.requestHash = hash
    if string.len(hash) == 40 then
        GuildBuddy:SendCommMessage("GB_RH", hash, "GUILD")
    end
end

function GuildBuddy:EVENT_REQUEST_HASH(prefix, hash, channel, player)
    local chain = GuildBuddy.db.char.blockchain
    if player ~= GuildBuddy.PlayerName then
        if string.len(hash) == 40 then
            local block = chain[hash]
            if block then
                print("Sending block existents to "..player)
                GuildBuddy:SendCommMessage("GB_CH", hash, "WHISPER", player)
            end
        end
    end
end

function GuildBuddy:EVENT_CONFIRM_HASH(prefix, hash, channel, player)
    print(player..' has block')
    GuildBuddy:SendCommMessage("GB_GB", hash, "WHISPER", player)
end

function GuildBuddy:EVENT_REQUEST_BLOCK(prefix, hash, channel, player)
    local chain = GuildBuddy.db.char.blockchain
    local block = chain[hash]
    if block then
        print('sending block to '..player)
        GuildBuddy:SendCommMessage("GB_RB", this:compressData(block), "WHISPER", player)
    end
end

function GuildBuddy:EVENT_RECEIVE_BLOCK(prefix, data, channel, player)
    local chain = GuildBuddy.db.char.blockchain
    local success, block = this:decompressData(data)
    if success then
        if this.requestHash == block.hash then
            local success = GuildBuddy:CheckHash(block)
            if success then
                print('receiving block from '..player)
                chain[block.hash] = block
                if block.previousHash ~= "" then
                    local previous = chain[block.previousHash]
                    if not previous then
                        GuildBuddy:RequestBlock(block.previousHash)
                    end
                end
            else
                print(player.." tried to mess with the blockchain, punish him badly!")
            end
        end
    end
end

GuildBuddy:RegisterComm("GB_RH", "EVENT_REQUEST_HASH")
GuildBuddy:RegisterComm("GB_CH", "EVENT_CONFIRM_HASH")

GuildBuddy:RegisterComm("GB_GB", "EVENT_REQUEST_BLOCK")
GuildBuddy:RegisterComm("GB_RB", "EVENT_RECEIVE_BLOCK")
