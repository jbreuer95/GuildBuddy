local ADDON_NAME, NS = ...
local AceGUI = LibStub("AceGUI-3.0")

function NS.UI.DrawAnnouncements(container)
    local treegroup = AceGUI:Create("TreeGroup")
    local tree = {
        {
            value = "F",
            text = "Foxtrot",
        }
    }
    treegroup:SetTree(tree)
    treegroup:SetFullWidth(true)
    treegroup:SetFullHeight(true)
    treegroup:SelectByPath(1)

    container:AddChild(treegroup)
end
