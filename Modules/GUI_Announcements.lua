local _, NS = ...
local GuildBuddy = NS.GuildBuddy
local AceGUI = LibStub("AceGUI-3.0")
local StdUi = LibStub('StdUi')

local this = {}


function this:GetTree()
    local tree = {}
    for key, announcement in pairs(GuildBuddy.db.char.announcements) do
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

function this.OnGroupSelected(...)
    local key = (select(3, ...))

    announcement = key
    Draw(NS.db.char.announcements[key])
end

function this:GetButtons()
    local outerGroup = AceGUI:Create("SimpleGroup")
    outerGroup:SetFullWidth(true)
    outerGroup:SetLayout("Right")

    local innerGroup = AceGUI:Create("SimpleGroup")
    innerGroup:SetLayout("Flow")

    if this.announcement then
        innerGroup:SetWidth(200)
        local edit = AceGUI:Create("Button")
        edit:SetText("Edit")
        edit:SetWidth(100)
        edit:SetCallback("OnClick", function(...)
            print('edit')
        end)
        innerGroup:AddChild(edit)

        local delete = AceGUI:Create("Button")
        delete:SetText("Delete")
        delete:SetWidth(100)
        delete:SetCallback("OnClick", function(...)
            print('delete')
        end)
        innerGroup:AddChild(delete)
    else
        innerGroup:SetWidth(100)
        local add = AceGUI:Create("Button")
        add:SetText("Add")
        add:SetWidth(100)
        add:SetCallback("OnClick", function(...)
            this:DrawAdd()
        end)
        innerGroup:AddChild(add)
    end

    outerGroup:AddChild(innerGroup)

    return outerGroup
end

function this:Reload()
    if this.tab then
        this.tab:ReleaseChildren()
        GuildBuddy:DrawAnnouncements(this.tab)
    end
end

function GuildBuddy:ReloadAnnouncements()
    this:Reload()
end


function this:GetTable(container)
    local data = {
        { i= 4, hash = "wjhdwjkldw", author = "Breuer", title = "Its the end of the world as we know it" },
        { i= 1, hash = "wjhdwjkldw", author = "Breuer", title = "Its the end of the world as we know it" },
        { i= 2, hash = "wjhdwjkldw", author = "Breuer", title = "Its the end of the world as we know it" },
        { i= 3, hash = "wjhdwjkldw", author = "Breuer", title = "Its the end of the world as we know it" },
    }
    local cols = {

        {
            name         = 'Index',
            width        = 60,
            align        = 'LEFT',
            index        = 'i',
            sort        = 'desc',
            format       = 'number',
        },

        {
            name         = 'Hash',
            width        = 100,
            align        = 'LEFT',
            index        = 'hash',
            format       = 'number',
        },
        {
            name         = 'Title',
            width        = 300,
            align        = 'LEFT',
            index        = 'title',
            format       = 'string',
        },
        {
            name         = 'Author',
            width        = 60,
            align        = 'LEFT',
            index        = 'author',
            format       = 'string',
        },
    }


    local rowHeight = 24
    local rows = math.floor((container:GetHeight() - 35) / rowHeight)

    local st = StdUi:ScrollTable(container, cols, rows, rowHeight)
    st:EnableSelection(true)
    st:SetBackdrop(nil)
    st:SetData(data)

    return st

end

function this:DrawAdd()
    this.add = StdUi:Frame(this.tab)
    StdUi:GlueAcross(this.add, this.tab)

    local title = StdUi:SimpleEditBox(this.add, 300, 20, '')
    StdUi:GlueTop(title, this.add, 10, -30, 'LEFT')
    StdUi:AddLabel(this.add, title, 'Title', 'TOP')

    local body = StdUi:MultiLineBox(this.add, 1, 1, '')
    StdUi:GlueAcross(body, this.add, 10, -80, -10, 10)
    StdUi:AddLabel(this.add, body, 'Content', 'TOP')

    local save = StdUi:Button(this.add, 75, 20, 'Save')
    StdUi:GlueTop(save, this.add, -10, -10, 'RIGHT')

    save:SetScript('OnClick', function()
        if #title:GetText() > 0 and #body:GetText() > 0 then
            local success = GuildBuddy:SaveAnnouncement(title:GetText(), body:GetText())
            if success then
                title:SetText('')
                body:SetText('')
                this:ToggleAdd()
                this:ToggleIndex()
            end
        end
    end)
end

function this:ToggleAdd()
    if not this.add then
        this:DrawAdd()
    elseif this.add:IsVisible() then
        this.add:Hide()
    else
        this.add:Show()
    end
end


function this:ToggleIndex()
    if not this.index then
        this:DrawIndex()
    elseif this.index:IsVisible() then
        this.index:Hide()
    else
        this.index:Show()
    end
end

function this:DrawIndex()
    this.index = StdUi:Frame(this.tab)
    StdUi:GlueAcross(this.index, this.tab)

    local add = StdUi:Button(this.index, 75, 20, 'Add')
    StdUi:GlueTop(add, this.index, -10, -10, 'RIGHT')

    add:SetScript('OnClick', function()
        this.ToggleIndex()
        this:ToggleAdd()
    end)

    this.table = this:GetTable(this.index)
    StdUi:GlueAcross(this.table, this.index, 0, -35, 0, 0)
end

function GuildBuddy:DrawAnnouncements(tab)
    this.tab = tab.frame

    this:DrawIndex()
end
