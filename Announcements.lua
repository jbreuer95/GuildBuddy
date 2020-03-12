local ADDON_NAME, NS = ...
local AceGUI = LibStub("AceGUI-3.0")
local tab = nil
local announcement = nil

local function reload()
    if tab then
        tab:ReleaseChildren()
        NS.UI.DrawAnnouncements(tab)
    end
end

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

local function Save(title, body)
    local timestamp = GetServerTime()
    table.insert(
        NS.db.char.announcements,
        timestamp,
        {
            ["title"] = title,
            ["body"] = body
        }
    )
    reload()
end

local function Delete()
    if announcement then
        NS.db.char.announcements[announcement] = nil
        announcement = nil
        reload()
    end
end


local function DrawAdd()
    announcement = nil
    reload()

    local title = AceGUI:Create("EditBox")
    local titleText = ""
    title:SetLabel("The title")
    title:DisableButton(true)
    title:SetFullWidth(true)
    title:SetCallback(
        "OnTextChanged",
        function(...)
            titleText = (select(3, ...))
        end
    )
    NS.UI.Announcements:AddChild(title)

    local body = AceGUI:Create("MultiLineEditBox")
    local bodyText = ""
    body:SetLabel("The announcement")
    body:DisableButton(true)
    body:SetFullWidth(true)
    body:SetNumLines(16)
    body:SetCallback(
        "OnTextChanged",
        function(...)
            bodyText = (select(3, ...))
        end
    )
    NS.UI.Announcements:AddChild(body)

    local save = AceGUI:Create("Button")
    save:SetText("Save")
    save:SetCallback(
        "OnClick",
        function(...)
            Save(titleText, bodyText)
        end
    )

    NS.UI.Announcements:AddChild(save)
end

local function Draw(data)
    reload()

    local title = AceGUI:Create("Heading")
    title:SetText(data.title)
    title:SetFullWidth(true)
    NS.UI.Announcements:AddChild(title)

    local body = AceGUI:Create("Label")
    body:SetText("\n"..data.body)
    body:SetFont(GameFontNormal:GetFont())
    body:SetFullWidth(true)

    NS.UI.Announcements:AddChild(body)

    local backContainer = NS.UI.GetRightContainer()
    local back = AceGUI:Create("Button")
    back:SetText("Back")
    back:SetWidth(100)
    back:SetCallback("OnClick", function(...)
        announcement = nil
        reload()
    end)
    backContainer:AddChild(back)

    NS.UI.Announcements:AddChild(backContainer)
end

local function OnGroupSelected(...)
    local key = (select(3, ...))

    announcement = key
    Draw(NS.db.char.announcements[key])
end

local function AddButtons()
    local outerGroup = AceGUI:Create("SimpleGroup")
    outerGroup:SetFullWidth(true)
    outerGroup:SetLayout("Right")

    if announcement then
        local innerGroup = AceGUI:Create("SimpleGroup")
        innerGroup:SetFullWidth(true)
        innerGroup:SetLayout("Flow")

        local edit = AceGUI:Create("Button")
        edit:SetText("Edit")
        edit:SetWidth(150)
        edit:SetCallback("OnClick", function(...)
            print("edit")
        end)
        innerGroup:AddChild(edit)

        local delete = AceGUI:Create("Button")
        delete:SetText("Delete")
        delete:SetWidth(150)
        delete:SetCallback("OnClick", function(...)
            Delete()
        end)
        innerGroup:AddChild(delete)
        outerGroup:AddChild(innerGroup)
    else
        local add = AceGUI:Create("Button")
        add:SetText("Add")
        add:SetWidth(150)
        add:SetCallback("OnClick", function(...)
            DrawAdd()
        end)
        outerGroup:AddChild(add)
    end

    return outerGroup
end

function NS.UI.DrawAnnouncements(container)
    tab = container

    local buttons = AddButtons()

    local treegroup = AceGUI:Create("TreeGroup")
    treegroup:SetTree(GetTree())
    treegroup:SetFullWidth(true)
    treegroup:SetFullHeight(true)
    treegroup:SelectByPath(1)
    treegroup:SetCallback("OnGroupSelected", OnGroupSelected)
    treegroup:SetLayout("Fill")

    tab:AddChild(buttons)
    tab:AddChild(treegroup)

    local bodyContainer = NS.UI.GetScrollContainer()
    treegroup:AddChild(bodyContainer)

    NS.UI.Announcements = bodyContainer
end
