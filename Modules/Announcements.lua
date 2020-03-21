local _, NS = ...
local GuildBuddy = NS.GuildBuddy

local this =  {}

function GuildBuddy:SaveAnnouncement(title, body)
    local content = {
        ["type"] = "announcement",
        ["action"] = "add",
        ["author"] = GuildBuddy.PlayerName,
        ["title"] = title,
        ["body"] = body
    }
    local block = GuildBuddy.Chain:AddBlock(content)
    if block then
        print(block)
        return true
    end

    return false
end
