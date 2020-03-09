local ADDON_NAME, NS = ...

Conflux = LibStub("AceAddon-3.0"):NewAddon("Conflux", "AceConsole-3.0")


function Conflux:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("ConfluxDB", {
        global = {
            minimap = {
                hide = false,
            },
        },
    })

    NS.UI.MinimapIcon:Register(ADDON_NAME, NS.UI.MinimapButton, self.db.global.minimap)

    local player = UnitName('player');
    Conflux:Print("Welcome back "..player..'!')
end