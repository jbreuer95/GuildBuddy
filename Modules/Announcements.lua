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


function GuildBuddy:BuildAnnouncements()
    local announcements = {}
    for hash, block in pairs(GuildBuddy.db.char.blockchain) do
        block = GuildBuddy.Block.Load(block)
        block:Validate()
        local data = block:GetData()
        if data.type == 'announcement' then
            if data.action == 'add' then
                announcements[block.h] = {
                    created = block.t,
                    author = data.author,
                    title = data.title,
                    body = data.body,
                }
            -- elseif data.action == 'edit' then
            --     announcements[data.hash] = {
            --         author = data.author,
            --         title = data.title,
            --         body = data.body,
            --     }
            -- elseif data.action == 'delete' then
            --     announcements[data.hash] = nil
            end
        end
    end
    GuildBuddy.db.char.announcements = announcements
end

GuildBuddy:RegisterCallback("ChainUpdated", function()
    GuildBuddy:BuildAnnouncements()
    GuildBuddy:LoadAnnouncements()
end)