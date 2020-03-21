local _, NS = ...
local GuildBuddy = NS.GuildBuddy
local StdUi = LibStub('StdUi');

local this = {}

local function Open()
    this.frame = StdUi:Window(UIParent, GetScreenWidth() / 2, GetScreenHeight() / 1.5, GuildBuddy.GuildName);
    this.frame:SetPoint('CENTER');

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

    local tabFrameH = StdUi:TabPanel(this.frame, nil, nil, t, false);
    StdUi:GlueAcross(tabFrameH, this.frame, 10, -40, -10, 10);
    
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