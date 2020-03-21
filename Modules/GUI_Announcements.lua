local _, NS = ...
local GuildBuddy = NS.GuildBuddy
local AceGUI = LibStub("AceGUI-3.0")
local StdUi = LibStub('StdUi')

local this = {}

function this:GetTable(container)
    local cols = {

        {
            name         = 'Index',
            width        = 60,
            align        = 'LEFT',
            index        = 'i',
            sort        = 'asc',
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
            width        = 100,
            align        = 'LEFT',
            index        = 'author',
            format       = 'string',
        },
    }


    local rowHeight = 24
    local rows = math.floor((container:GetHeight() - 35) / rowHeight)

    this.st = StdUi:ScrollTable(container, cols, rows, rowHeight)
    this.st:EnableSelection(true)
    this.st:SetBackdrop(nil)
    this.st:SetData(this.announcements)

    return this.st

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

    GuildBuddy:LoadAnnouncements()
    this:DrawIndex()
end

function GuildBuddy:LoadAnnouncements()
    local data = {}
    for hash, block in pairs(GuildBuddy.db.char.blockchain) do
        block = GuildBuddy.Block.Load(block)
        block:Validate()
        local announcement = block:GetData()
        table.insert(data, {
            i = block.i,
            hash = block.h,
            author = announcement.author,
            title = announcement.title,
        })
    end

    this.announcements = data
end

function GuildBuddy:ReloadAnnouncements()
    if this.st then
        GuildBuddy:LoadAnnouncements()
        this.st:SetData(this.announcements)
    end
end