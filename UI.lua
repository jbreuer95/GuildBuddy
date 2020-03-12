local ADDON_NAME, NS = ...
local AceGUI = LibStub("AceGUI-3.0")

NS.UI = {}

-------------------------------------------------------------------------------
-- MinimapIcon
-------------------------------------------------------------------------------

do
    local ldb = LibStub("LibDataBroker-1.1")
    NS.UI.MinimapButton = ldb:NewDataObject(ADDON_NAME, {
        type = "data source",
        icon = "Interface\\AddOns\\GuildBuddy\\Icon",
        OnClick = function(self, button)
            NS.UI.Toggle()
        end,
        OnTooltipShow = function(tooltip)
            if not tooltip or not tooltip.AddLine then return end
            tooltip:AddLine(NS.guild.name)
        end,
    })

    NS.UI.MinimapIcon = LibStub("LibDBIcon-1.0")
end

--------------------------------------------------------------------------------

do
    local xpcall = xpcall

    local function errorhandler(err)
        return geterrorhandler()(err)
    end

    local function safecall(func, ...)
        if func then
            return xpcall(func, errorhandler, ...)
        end
    end

    AceGUI:RegisterLayout("Right", function(content, children)
        children[1].frame:SetPoint("TOPRIGHT", content, "TOPRIGHT", -5, -5)
        children[1].frame:Show()

        safecall(content.obj.LayoutFinished, content.obj, nil, children[1].frame:GetHeight() + 9)
    end)
end

local function SelectGroup(container, event, group)
    container:ReleaseChildren()
    if group == "tab1" then
        NS.UI.DrawAnnouncements(container)
    elseif group == "tab2" then
        NS.UI.DrawEvents(container)
    elseif group == "tab3" then
        NS.UI.DrawBank(container)
    elseif group == "tab4" then
        NS.UI.DrawConsumables(container)
    end
end

function NS.UI.OpenMainFrame()
    NS.UI.MainFrame = AceGUI:Create("Frame")
    NS.UI.MainFrame:SetTitle(NS.guild.name)
    NS.UI.MainFrame:SetStatusText("Status Bar")
    NS.UI.MainFrame:SetCallback("OnClose", function(widget) AceGUI:Release(widget) end)
    NS.UI.MainFrame:SetLayout("Fill")

    local tab = AceGUI:Create("TabGroup")
    tab:SetLayout("Flow")

    tab:SetTabs({
        {text="Announcements", value="tab1"},
        {text="Events", value="tab2"},
        {text="Guild Bank", value="tab3"},
        {text="Consumables", value="tab4"},
    })

    tab:SetCallback("OnGroupSelected", SelectGroup)

    tab:SelectTab("tab1")

    NS.UI.MainFrame:AddChild(tab)

end

function NS.UI.Toggle()
    if NS.UI.MainFrame and NS.UI.MainFrame:IsVisible() then
        NS.UI.MainFrame:Hide()
    else
        NS.UI.OpenMainFrame()
    end
end

function NS.UI.GetFilledContainer()
    local container = AceGUI:Create("SimpleGroup") -- "InlineGroup" is also good
    container:SetFullWidth(true)
    container:SetFullHeight(true) -- probably?
    container:SetLayout("Fill") -- important!
    return container
end

function NS.UI.GetScrollContainer()
    local container = AceGUI:Create("ScrollFrame")
    container:SetLayout("Flow") -- probably?
    return container
end

function NS.UI.GetRightContainer()
    local container = AceGUI:Create("SimpleGroup")
    container:SetFullWidth(true)
    container:SetLayout("Right")
    return container
end