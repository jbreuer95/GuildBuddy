local ADDON_NAME, NS = ...
local GuildBuddy = NS.GuildBuddy

function GuildBuddy:RegisterMinimapIcon()
    local ldb = LibStub("LibDataBroker-1.1")
    local icon = LibStub("LibDBIcon-1.0")

    local btn = ldb:NewDataObject(ADDON_NAME, {
        type = "data source",
        icon = "Interface\\AddOns\\"..ADDON_NAME.."\\Icon",
        OnClick = function(self, button)
            GuildBuddy:ToggleMainFrame()
        end,
        OnTooltipShow = function(tooltip)
            if not tooltip or not tooltip.AddLine then return end
            tooltip:AddLine(GuildBuddy.GuildName)
        end,
    })

    icon:Register(ADDON_NAME, btn, GuildBuddy.db.char.minimap)
end