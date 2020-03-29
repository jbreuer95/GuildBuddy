
local _, NS = ...
local GuildBuddy = NS.GuildBuddy
local StdUi = LibStub('StdUi')
local lwin = LibStub('LibWindow-1.1')

local this = {}

function GuildBuddy:OpenNotifications()
    if not this.panel then
        this.panel = StdUi:PanelWithTitle(UIParent, GetScreenWidth() / 4, GetScreenHeight(), 'Conflux notifications')
        this.panel:SetPoint('RIGHT')
        this.panel:SetFrameStrata('TOOLTIP')
        this.panel:SetFrameLevel(128)
    end
    this.panel:Show()
    this.button.icon:SetTexCoord(0.42187500,0.23437500,0.01562500,0.20312500)
end

function GuildBuddy:CloseNotifications()
    if this.panel and this.panel:IsVisible() then
        this.panel:Hide()
    end
    this.button.icon:SetTexCoord(0.23437500,0.42187500,0.01562500,0.20312500)
end


function GuildBuddy:RegisterNotificationButton()
    this.button = StdUi:SquareButton(UIParent, 15, 150, 'LEFT')
    this.button:SetPoint('RIGHT')
    this.button:SetFrameStrata('TOOLTIP')
    this.button:SetFrameLevel(129)

    this.button:SetScript('OnClick', function()
        if this.panel and this.panel:IsVisible() then
            GuildBuddy:CloseNotifications()
        else
            GuildBuddy:OpenNotifications()
        end
    end)
end