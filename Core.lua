local _, NS = ...
local GuildBuddy = LibStub("AceAddon-3.0"):NewAddon("GuildBuddy", "AceConsole-3.0", "AceEvent-3.0", "AceTimer-3.0", "AceComm-3.0")
NS.GuildBuddy = GuildBuddy
local infoChecked = false

function GuildBuddy:GUILD_ROSTER_UPDATE(...)
    local guildName, guildRankName, guildRankIndex = GetGuildInfo("player");

    if guildName then
        if #GetGuildInfoText() == 0 and not infoChecked then
            infoChecked = true
            GuildBuddy:Print("Guild info empty can't load blockchain, checking again in 10sec")
            GuildBuddy:ScheduleTimer(function()
                GuildRoster()
            end, 10)

        elseif #GetGuildInfoText() == 0 and infoChecked then
            GuildBuddy:Print("It's really empty, just installed addon? Set guild information to: startchain")
            GuildBuddy:UnregisterEvent("GUILD_ROSTER_UPDATE")
        else
            GuildBuddy:UnregisterEvent("GUILD_ROSTER_UPDATE")


            GuildBuddy.PlayerName = UnitName("player")
            GuildBuddy.PlayerLevel = UnitLevel("player")
            GuildBuddy.GuildName = guildName
            GuildBuddy.GuildRankName = guildRankName

            GuildBuddy:RegisterMinimapIcon()

            GuildBuddy:Print("Welcome back "..GuildBuddy.GuildRankName..' '..GuildBuddy.PlayerName..'!')

            GuildBuddy.Chain:Load(GuildBuddy.db.char.blockchain)
            print(GuildBuddy.Chain)
            local starttime = GetServerTime()
            print(GuildBuddy.Chain:IsUpToDate())
            local endtime = GetServerTime()
            print("Up to date check took "..(endtime - starttime).." seconds")
            -- for i=1800,1,-1 do
            --     print("added block "..i)
            --     GuildBuddy.Chain:AddBlock(i)
            -- end
        end
    end
end

function GuildBuddy:OnInitialize()
    GuildRoster()
    GuildBuddy.db = LibStub("AceDB-3.0"):New("GuildBuddyDB", {
        char = {
            minimap = { hide = false },
            announcements = {},
            events = {},
            blockchain = {}
        },
    });
    GuildBuddy:RegisterEvent("GUILD_ROSTER_UPDATE")
end
