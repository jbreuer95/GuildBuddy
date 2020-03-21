local _, NS = ...
local GuildBuddy = LibStub("AceAddon-3.0"):NewAddon("GuildBuddy", "AceConsole-3.0", "AceEvent-3.0", "AceTimer-3.0", "AceComm-3.0")
NS.GuildBuddy = GuildBuddy

local loaded = false

local function OnLoad()
    local guildName, guildRankName, guildRankIndex = GetGuildInfo("player");
    GuildBuddy:CancelTimer(GuildBuddy.loadTimer)
    loaded = true

    GuildBuddy.PlayerName = UnitName("player")
    GuildBuddy.PlayerLevel = UnitLevel("player")
    GuildBuddy.GuildName = guildName
    GuildBuddy.GuildRankName = guildRankName

    GuildBuddy:RegisterMinimapIcon()

    GuildBuddy:Print("Welcome back "..GuildBuddy.GuildRankName..' '..GuildBuddy.PlayerName..'!')

    GuildBuddy.Chain:Load(GuildBuddy.db.char.blockchain)
    -- for i=1800,1,-1 do
    --     print("added block "..i)
    --     GuildBuddy.Chain:AddBlock(i)
    -- end
end

function GuildBuddy:GUILD_ROSTER_UPDATE(...)
    local guildName = GetGuildInfo("player");

    if guildName then
        local lastHash = GetGuildInfoText()
        if string.len(lastHash) == 40 or lastHash == "startchain" then
            if not loaded then
                OnLoad()
            end
            GuildBuddy.Chain.waitForCache = false
            GuildBuddy.Chain:Sync()
        end
    end
end

function GuildBuddy:OnInitialize()
    GuildBuddy.db = LibStub("AceDB-3.0"):New("GuildBuddyDB", {
        char = {
            minimap = { hide = false },
            announcements = {},
            events = {},
            blockchain = {}
        },
    });
    GuildBuddy:RegisterEvent("GUILD_ROSTER_UPDATE")
    GuildBuddy:ScheduleTimer(function()
        GuildRoster()
    end, 1)
    GuildBuddy:ScheduleRepeatingTimer(function()
        GuildRoster()
    end, 11)

    GuildBuddy.loadTimer = GuildBuddy:ScheduleTimer(function()
        if loaded == false then
            GuildBuddy:Print("Cant load, your guild information should be 'startchain' or the latest hash in the blockchain, see documentation")
        end
    end, 12)
end
