local _, NS = ...
local GuildBuddy = NS.GuildBuddy
local sha1 = LibStub("LibSHA1")
local libS = LibStub:GetLibrary("AceSerializer-3.0")

local prototype = {
    i = 1,
    t = GetServerTime(),
    d = '',
    p = '',
    h = '',
}
GuildBuddy.Block = {
    mt = {},

    New = function(data, previous)
        local b = {}
        setmetatable(b, GuildBuddy.Block.mt)

        b.d = libS:Serialize(data)

        if previous then
            b.i = previous.i + 1
            b.p = previous.h
        end

        b.h = sha1(b.i..b.p..b.t..b.d)

        return b
    end,

    Load = function(data)
        local b = {}
        setmetatable(b, GuildBuddy.Block.mt)

        for k,v in pairs(data) do
            b[k] = v
        end

        return b
    end,

    Validate = function(self)
        local truehash = sha1(self.i..self.p..self.t..self.d)
        if truehash ~= self.h then
            error("Block is invalid")
        end
    end,

    ToTable = function(self)
        local t = {}
        for k,v in pairs(prototype) do
            t[k] = self[k]
        end

        return t
    end,
}

GuildBuddy.Block.mt.__metatable = "Private"

GuildBuddy.Block.mt.__tostring = function(b)
    print('-----BLOCK-----')
    print('index: '..b.i)
    print('timestamp: '..b.t)
    print('data: '..b.d)
    print('previousHash: '..b.p)
    print('hash: '..b.h)
    print('-------------------')
end


GuildBuddy.Block.mt.__index = function(tab, key)
    if GuildBuddy.Block[key] then
        return GuildBuddy.Block[key]
    elseif prototype[key] then
        return prototype[key]
    else
        error(key.." is not a property belonging on a block")
    end
end

local validateHashType = function (data)
    if type(data) == "string" then
        return string.len(data) == 40
    end
    return false
end

local validateData = function (data)
    if type(data) == "string" then
        return string.len(data) <= 1000
    end
    return false
end

local validateNumber = function (data)
    return type(data) == "number"
end

GuildBuddy.Block.mt.__newindex = function(tab, key, value)
    if prototype[key] then
        if key == "i" and not validateNumber(value) then
            error("Index of block is not a number")
        end
        if key == "t" and not validateNumber(value) then
            error("Timestamp of block is not a number")
        end
        if key == "d" and not validateData(value) then
            error("Data is not a string or longer than a 1000 characters")
        end
        if key == "h" and not validateHashType(value) then
            error("That hash is not a string of 40 characters")
        end
        if key == "p" and not validateHashType(value) then
            error("That previousHash is not a string of 40 characters")
        end
        rawset(tab, key, value)
    else
        error(key.." is not a property belonging on a block")
    end
end
