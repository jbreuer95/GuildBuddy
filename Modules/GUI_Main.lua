local _, NS = ...
local GuildBuddy = NS.GuildBuddy
local StdUi = LibStub('StdUi')
local lwin = LibStub("LibWindow-1.1")

GuildBuddy.Fonts = {
	Roboto = "Interface\\Addons\\GuildBuddy\\Fonts\\Roboto-Regular.ttf",
}

local this = {}

local function Open()
    this.frame = StdUi:Window(UIParent, GetScreenWidth() / 2, GetScreenHeight() / 1.5, GuildBuddy.GuildName)
    this.frame:SetPoint('CENTER')

    lwin.RegisterConfig(this.frame, GuildBuddy.db.char.mainposition)
    lwin.RestorePosition(this.frame)
    lwin.MakeDraggable(this.frame)

    this.frame:SetScript('OnShow', function()
        lwin.RestorePosition(this.frame)
    end)

    local t = {
        {
            name = 'tab1',
            title = 'Announcements',
        },
        {
            name = 'tab2',
            title = 'Events',
        },
        {
            name = 'tab3',
            title = 'Guild Bank'
        },
        {
            name = 'tab4',
            title = 'Consumables'
        }
    }

    local tabFrameH = StdUi:TabPanel(this.frame, nil, nil, t, false)
    StdUi:GlueAcross(tabFrameH, this.frame, 10, -40, -10, 10)

    GuildBuddy.MainFrame = this.frame
    GuildBuddy:DrawAnnouncements(tabFrameH:GetTabByName("tab1"))
end

function GuildBuddy:ToggleMainFrame()
    if not this.frame then
        Open()
    elseif this.frame:IsVisible() then
        this.frame:Hide()
    else
        this.frame:Show()
    end
end
