local _, NS = ...
local GuildBuddy = NS.GuildBuddy
local AceGUI = LibStub("AceGUI-3.0")
local StdUi = LibStub('StdUi')

local this = {}

function this:GetTable(container)
    local cols = {
        {
            name         = 'Title',
            width        = container:GetWidth() - 250,
            align        = 'LEFT',
            index        = 'title',
            format       = 'string',
            events         = {
                OnClick = function(_, _, _, data)
                    this:select(data)
                end,
                OnDoubleClick = function(_, _, _, data)
                    this:DrawRead(data)
                end,
            },
        },
        {
            name         = 'Time',
            width        = 125,
            align        = 'LEFT',
            index        = 'created',
            sort         = 'asc',
            format       = function(value)
                return date("%d/%b/%y %H:%M", value)
            end,
            events         = {
                OnClick = function(_, _, _, data)
                    this:select(data)
                end,
                OnDoubleClick = function(_, _, _, data)
                    this:DrawRead(data)
                end,
            },
        },
        {
            name         = 'Author',
            width        = 100,
            align        = 'LEFT',
            index        = 'author',
            format       = 'string',
            events         = {
                OnClick = function(_, _, _, data)
                    this:select(data)
                end,
                OnDoubleClick = function(_, _, _, data)
                    this:DrawRead(data)
                end,
            },
        },
    }


    local rowHeight = 24
    local rows = math.floor((container:GetHeight() - 35) / rowHeight)

    this.st = StdUi:ScrollTable(container, cols, rows, rowHeight)
    this.st:EnableSelection(true)
    this.st:SetBackdrop(nil)
    GuildBuddy:LoadAnnouncements()

    return this.st
end

function this:DrawRead(data)
    GuildBuddy:ToggleMainFrame()
    this.read = StdUi:Window(UIParent, GetScreenWidth() / 2, GetScreenHeight() / 1.5, data.title);
    this.read:SetPoint('CENTER');
    -- this.read:SetBackdropColor(0,0,0,0.9)
    this.read.closeBtn:HookScript("OnClick", function()
        GuildBuddy:ToggleMainFrame()
    end)

    local widget = StdUi:ScrollFrame(this.read, this.read:GetWidth(), this.read:GetHeight() - 40);
    StdUi:GlueBottom(widget, this.read, 0, 0, 'LEFT')
    -- widget:SetBackdrop(nil)

    local body = StdUi:FontString(widget.scrollChild, data.body);
    body:SetWidth(widget:GetWidth() - 40)
    body:SetTextColor(1, 1, 1)
    StdUi:GlueTop(body, widget.scrollChild, 15, -15, 'LEFT')

    local padding = StdUi:Frame(widget.scrollChild, body:GetWidth(), 100);
    StdUi:GlueBelow(padding, body)
end

function this:DrawAdd()
    this.add = StdUi:Window(UIParent, GetScreenWidth() / 2, GetScreenHeight() / 1.5, "Add announcement");
    this.add:SetPoint('CENTER');

    local save = StdUi:Button(this.add, 75, 20, 'Save')
    local title = StdUi:SimpleEditBox(this.add, 300, 20, '')
    local body = StdUi:MultiLineBox(this.add, this.add:GetWidth() - 30, 200, '')

    StdUi:AddLabel(this.add, title, 'Title', 'TOP')
    StdUi:AddLabel(this.add, body, 'Content', 'TOP')

    StdUi:GlueBottom(save, this.add, -10, 10, 'RIGHT')

    StdUi:GlueTop(title, this.add, 15, -50, 'LEFT')
    StdUi:GlueAcross(body, this.add, 15, -100, -15, 40)

    this.add.closeBtn:HookScript("OnClick", function()
        GuildBuddy:ToggleMainFrame()
    end)


    save:SetScript('OnClick', function()
        if #title:GetText() > 0 and #body:GetText() > 0 then
            local success = GuildBuddy:SaveAnnouncement(title:GetText(), body:GetText())
            if success then
                title:SetText('')
                body:SetText('')
                this:ToggleAdd()
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
    GuildBuddy:ToggleMainFrame()
end

function this:select(data)
    if GuildBuddy.Admin then
        this.selected = data
        this.editBtn:Show()
        this.deleteBtn:Show()
    else
        this:DrawRead(data)
    end
end

function this:clear()
    if GuildBuddy.Admin then
        this.st:ClearSelection();
        this.selected = nil
        this.editBtn:Hide()
        this.deleteBtn:Hide()
    end
end

function GuildBuddy:DrawAnnouncements(tab)
    this.tab = tab.frame

    GuildBuddy.MainFrame:SetScript('OnMouseDown', function()
        this:clear()
    end)

    GuildBuddy.MainFrame:SetScript('OnHide', function()
        this:clear()
    end)

    this.index = StdUi:Frame(this.tab)
    StdUi:GlueAcross(this.index, this.tab)

    if GuildBuddy.Admin then
        local add = StdUi:Button(this.index, 75, 20, 'Add')
        StdUi:GlueAbove(add, this.index, 0, 5, 'RIGHT')

        add:SetScript('OnClick', function()
            this:ToggleAdd()
        end)

        this.editBtn = StdUi:Button(this.index, 75, 20, 'Edit')
        StdUi:GlueLeft(this.editBtn, add, -5, 0)
        this.editBtn:Hide()

        this.deleteBtn = StdUi:Button(this.index, 75, 20, 'Delete')
        StdUi:GlueLeft(this.deleteBtn, this.editBtn, -5, 0)
        this.deleteBtn:Hide()
    end

    this.table = this:GetTable(this.index)
    StdUi:GlueAcross(this.table, this.index, 0, -35, 0, 0)
end

function GuildBuddy:LoadAnnouncements()
    if this.st then
        local data = {}
        for k,v in pairs(GuildBuddy.db.char.announcements) do
            v.hash = k
            table.insert(data, v)
        end
        this.st:SetData(data)
    end
end