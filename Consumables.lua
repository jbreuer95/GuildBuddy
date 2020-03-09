local ADDON_NAME, NS = ...
local AceGUI = LibStub("AceGUI-3.0")

function NS.UI.DrawConsumables(container)
    local desc = AceGUI:Create("Label")
    desc:SetText("Coming soon")
    desc:SetFullWidth(true)
    container:AddChild(desc)
end