local ADDON_NAME, NS = ...

GuildBuddy = LibStub("AceAddon-3.0"):NewAddon("GuildBuddy", "AceConsole-3.0", "AceEvent-3.0")
NS.core = GuildBuddy

local loaded = false

function GuildBuddy:GUILD_ROSTER_UPDATE()
    if not loaded then
        local guildName, guildRankName, guildRankIndex = GetGuildInfo("player");
        if guildName then
            NS.guild = {
                ["name"] = guildName,
                ["rankName"] = guildRankName,
                ["rank"] = guildRankIndex
            }

            NS.db.char.announcements = {}

            NS.UI.MinimapIcon:Register(ADDON_NAME, NS.UI.MinimapButton, NS.db.char.minimap)

            local player = UnitName('player');
            GuildBuddy:Print("Welcome back "..player..'!')
            loaded = true
        end
    end
end
GuildBuddy:RegisterEvent("GUILD_ROSTER_UPDATE")

function GuildBuddy:OnInitialize()
    NS.db = LibStub("AceDB-3.0"):New("GuildBuddyDB", {
        char = {
            minimap = {
                hide = false,
            },
            announcements = {}
        },
    });
end