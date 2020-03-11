local ADDON_NAME, NS = ...
local AceGUI = LibStub("AceGUI-3.0")

local function GetTree()
    local tree = {}
    for key, announcement in pairs(NS.db.char.announcements) do
        table.insert(
            tree,
            {
                value = key,
                text = announcement.title
            }
        )
    end
    return tree
end

local function DrawAddAnnouncement()
    local title = AceGUI:Create("EditBox")
    title:SetLabel("The title")
    title:DisableButton(true)
    title:SetFullWidth(true)

    local body = AceGUI:Create("MultiLineEditBox")
    body:SetLabel("The announcement")
    body:DisableButton(true)
    body:SetFullWidth(true)
    body:SetFullHeight(true)
    body:SetNumLines(17)
    body:SetCallback(
        "OnTextChanged",
        function(...)
            local text = (select(3, ...))
        end
    )

    local save = AceGUI:Create("Button")
    save:SetText("Save")

    NS.UI.Announcements:ReleaseChildren()
    NS.UI.Announcements:AddChild(title)
    NS.UI.Announcements:AddChild(body)
    NS.UI.Announcements:AddChild(save)
end

local function DrawAnnouncement(announcement)
    local title = AceGUI:Create("Heading")
    title:SetText(announcement.title)
    title:SetFullWidth(true)

    local body = AceGUI:Create("Label")
    body:SetText("\n"..announcement.body)
    body:SetFont(GameFontNormal:GetFont())
    body:SetFullWidth(true)

    NS.UI.Announcements:ReleaseChildren()
    NS.UI.Announcements:AddChild(title)
    NS.UI.Announcements:AddChild(body)
end

local function OnGroupSelected(...)
    local key = (select(3, ...))

    DrawAnnouncement(NS.db.char.announcements[key])
end

function NS.UI.DrawAnnouncements(container)
    local timestamp = GetServerTime()
    table.insert(
        NS.db.char.announcements,
        timestamp,
        {
            ["title"] = "Fury warrior class leader!",
            ["body"] = "Recently I asked anyone interested in taking on the Class Leader for the Fury warrior to let me know, and I was very happy to see Sebb showing an large interest in this.\nWe feel that Sebb's dedication to the class, his try-hardness and skill is a good fit for this role.\nSo please everyone join me in congratulating Sebb in his new role as Class Leader for the Fury Warriors..\nThanks Sebb!\n\n-Apil"
        }
    )

    local addGroup = AceGUI:Create("SimpleGroup")
    addGroup:SetFullWidth(true)
    addGroup:SetLayout("Right")

    local add = AceGUI:Create("Button")
    add:SetText("Add")
    add:SetWidth(150)
    add:SetCallback("OnClick", function(...)
        DrawAddAnnouncement()
    end)

    addGroup:AddChild(add)

    local treegroup = AceGUI:Create("TreeGroup")
    treegroup:SetTree(GetTree())
    treegroup:SetFullWidth(true)
    treegroup:SetFullHeight(true)
    treegroup:SelectByPath(1)
    treegroup:SetCallback("OnGroupSelected", OnGroupSelected)

    container:AddChild(addGroup)
    container:AddChild(treegroup)

    NS.UI.Announcements = treegroup
end
