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

function GuildBuddy:DeleteAnnouncement(hash)
    local content = {
        ["type"] = "announcement",
        ["action"] = "delete",
        ["hash"] = hash,
    }
    local block = GuildBuddy.Chain:AddBlock(content)
    if block then
        print(block)
        return true
    end

    return false
end

function GuildBuddy:EditAnnouncement(hash, title, body)
    local content = {
        ["type"] = "announcement",
        ["action"] = "edit",
        ["hash"] = hash,
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
                local announcement = announcements[block.h]
                if announcement == nil then
                    announcements[block.h] = {
                        created = block.t,
                        author = data.author,
                        title = data.title,
                        body = data.body,
                    }
                elseif type(announcement) == 'table' then
                    announcement.created = block.t
                    announcement.author = data.author
                end
            elseif data.action == 'edit' then
                local announcement = announcements[data.hash]
                if announcement == nil then
                    announcements[data.hash] = {
                        edited = block.t,
                        title = data.title,
                        body = data.body,
                        editAuthor = data.author,
                    }
                elseif type(announcement) == 'table' then
                    if announcement.edited == nil or announcement.edited < block.t then
                        announcement.edited = block.t
                        announcement.title = data.title
                        announcement.body = data.body
                        announcement.editAuthor = data.author
                    end
                end
            elseif data.action == 'delete' then
                announcements[data.hash] = 'deleted'
            end
        end
    end
    for k,v in pairs(announcements) do
        if type(v) ~= 'table' then
            announcements[k] = nil
        end
    end
    GuildBuddy.db.char.announcements = announcements
end

GuildBuddy:RegisterCallback("ChainUpdated", function()
    GuildBuddy:BuildAnnouncements()
    GuildBuddy:LoadAnnouncements()
end)