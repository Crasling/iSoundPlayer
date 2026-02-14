local addonName, iSP = ...
local L = iSP.L or {}
local Colors = iSP.Colors or {}

-- Retail requires BackdropTemplateMixin for BackdropTemplate
local BACKDROP_TEMPLATE = BackdropTemplateMixin and "BackdropTemplate" or nil

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                              Setup Guide Window                                │
-- ╰────────────────────────────────────────────────────────────────────────────────╯

local setupGuideFrame = nil

-- Create the setup guide window
function iSP:CreateSetupGuide()
    if setupGuideFrame then
        return setupGuideFrame
    end

    -- Main frame
    setupGuideFrame = CreateFrame("Frame", "iSPSetupGuide", UIParent, BACKDROP_TEMPLATE)
    setupGuideFrame:SetSize(520, 480)
    setupGuideFrame:SetPoint("CENTER")
    setupGuideFrame:SetFrameStrata("DIALOG")
    setupGuideFrame:SetMovable(true)
    setupGuideFrame:EnableMouse(true)
    setupGuideFrame:RegisterForDrag("LeftButton")
    setupGuideFrame:SetScript("OnDragStart", function(self) self:StartMoving() end)
    setupGuideFrame:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
    setupGuideFrame:Hide()

    -- Add to UISpecialFrames for ESC close
    if not tContains(UISpecialFrames, "iSPSetupGuide") then
        tinsert(UISpecialFrames, "iSPSetupGuide")
    end

    -- Backdrop
    setupGuideFrame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true,
        tileSize = 32,
        edgeSize = 32,
        insets = {left = 8, right = 8, top = 8, bottom = 8}
    })

    -- Header
    local header = setupGuideFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    header:SetPoint("TOP", 0, -20)
    header:SetText(L["SetupGuideHeader"])

    -- Close button
    local closeBtn = CreateFrame("Button", nil, setupGuideFrame, "UIPanelCloseButton")
    closeBtn:SetPoint("TOPRIGHT", -5, -5)

    -- Content scroll frame
    local scrollFrame = CreateFrame("ScrollFrame", nil, setupGuideFrame, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", 20, -50)
    scrollFrame:SetPoint("BOTTOMRIGHT", -30, 50)

    local scrollChild = CreateFrame("Frame", nil, scrollFrame)
    scrollChild:SetSize(450, 600)
    scrollFrame:SetScrollChild(scrollChild)

    -- Content
    local yOffset = -10

    -- Welcome text
    local welcomeText = scrollChild:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    welcomeText:SetPoint("TOPLEFT", 10, yOffset)
    welcomeText:SetWidth(430)
    welcomeText:SetJustifyH("LEFT")
    welcomeText:SetText(L["SetupGuideWelcome"])
    yOffset = yOffset - 80

    -- Step 1
    local step1Header = scrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    step1Header:SetPoint("TOPLEFT", 10, yOffset)
    step1Header:SetText(L["SetupGuideStep1Header"])
    yOffset = yOffset - 25

    local step1Text = scrollChild:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    step1Text:SetPoint("TOPLEFT", 20, yOffset)
    step1Text:SetWidth(420)
    step1Text:SetJustifyH("LEFT")
    step1Text:SetText(L["SetupGuideStep1Text"])
    yOffset = yOffset - 175

    -- Separator
    local sep1 = scrollChild:CreateTexture(nil, "ARTWORK")
    sep1:SetPoint("TOPLEFT", 10, yOffset)
    sep1:SetSize(430, 1)
    sep1:SetColorTexture(0.3, 0.3, 0.3, 0.8)
    yOffset = yOffset - 15

    -- Step 2
    local step2Header = scrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    step2Header:SetPoint("TOPLEFT", 10, yOffset)
    step2Header:SetText(L["SetupGuideStep2Header"])
    yOffset = yOffset - 25

    local step2Text = scrollChild:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    step2Text:SetPoint("TOPLEFT", 20, yOffset)
    step2Text:SetWidth(420)
    step2Text:SetJustifyH("LEFT")
    step2Text:SetText(L["SetupGuideStep2Text"])
    yOffset = yOffset - 155

    -- Separator
    local sep2 = scrollChild:CreateTexture(nil, "ARTWORK")
    sep2:SetPoint("TOPLEFT", 10, yOffset)
    sep2:SetSize(430, 1)
    sep2:SetColorTexture(0.3, 0.3, 0.3, 0.8)
    yOffset = yOffset - 15

    -- Step 3
    local step3Header = scrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    step3Header:SetPoint("TOPLEFT", 10, yOffset)
    step3Header:SetText(L["SetupGuideStep3Header"])
    yOffset = yOffset - 25

    local step3Text = scrollChild:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    step3Text:SetPoint("TOPLEFT", 20, yOffset)
    step3Text:SetWidth(420)
    step3Text:SetJustifyH("LEFT")
    step3Text:SetText(L["SetupGuideStep3Text"])
    yOffset = yOffset - 200

    -- Separator
    local sep3 = scrollChild:CreateTexture(nil, "ARTWORK")
    sep3:SetPoint("TOPLEFT", 10, yOffset)
    sep3:SetSize(430, 1)
    sep3:SetColorTexture(0.3, 0.3, 0.3, 0.8)
    yOffset = yOffset - 15

    -- Quick Tips
    local tipsHeader = scrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    tipsHeader:SetPoint("TOPLEFT", 10, yOffset)
    tipsHeader:SetText(L["SetupGuideQuickTipsHeader"])
    yOffset = yOffset - 25

    local tipsText = scrollChild:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    tipsText:SetPoint("TOPLEFT", 20, yOffset)
    tipsText:SetWidth(420)
    tipsText:SetJustifyH("LEFT")
    tipsText:SetText(L["SetupGuideQuickTipsText"])
    yOffset = yOffset - 165

    -- Bottom buttons
    local buttonContainer = CreateFrame("Frame", nil, setupGuideFrame)
    buttonContainer:SetPoint("BOTTOM", 0, 15)
    buttonContainer:SetSize(480, 30)

    -- Don't Show Again checkbox (centered in middle area)
    local dontShowAgain = CreateFrame("CheckButton", nil, buttonContainer, "UICheckButtonTemplate")
    dontShowAgain:SetPoint("CENTER", -60, 0)
    dontShowAgain:SetSize(24, 24)

    local dontShowText = buttonContainer:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    dontShowText:SetPoint("LEFT", dontShowAgain, "RIGHT", 5, 0)
    dontShowText:SetText(L["SetupGuideDontShow"])

    -- Open Settings button (left side)
    local openSettingsBtn = CreateFrame("Button", nil, buttonContainer, "UIPanelButtonTemplate")
    openSettingsBtn:SetSize(150, 25)
    openSettingsBtn:SetPoint("LEFT", 20, 0)
    openSettingsBtn:SetText(L["SetupGuideOpenSettings"])
    openSettingsBtn:SetScript("OnClick", function()
        setupGuideFrame:Hide()
        iSP:SettingsToggle()
    end)

    dontShowAgain:SetScript("OnClick", function(self)
        iSPSettings.SetupGuide = iSPSettings.SetupGuide or {}
        iSPSettings.SetupGuide.DontShowOnStartup = self:GetChecked()
    end)

    -- Close button
    local closeButton = CreateFrame("Button", nil, buttonContainer, "UIPanelButtonTemplate")
    closeButton:SetSize(80, 25)
    closeButton:SetPoint("RIGHT", -20, 0)
    closeButton:SetText(L["SetupGuideClose"])
    closeButton:SetScript("OnClick", function()
        setupGuideFrame:Hide()
    end)

    return setupGuideFrame
end

-- Show the setup guide
function iSP:ShowSetupGuide()
    if not setupGuideFrame then
        self:CreateSetupGuide()
    end

    -- Update checkbox state
    local dontShowAgain = setupGuideFrame:GetChildren()
    for i = 1, setupGuideFrame:GetNumChildren() do
        local child = select(i, setupGuideFrame:GetChildren())
        if child.GetChildren then
            for j = 1, child:GetNumChildren() do
                local grandchild = select(j, child:GetChildren())
                if grandchild:GetObjectType() == "CheckButton" then
                    iSPSettings.SetupGuide = iSPSettings.SetupGuide or {}
                    grandchild:SetChecked(iSPSettings.SetupGuide.DontShowOnStartup or false)
                end
            end
        end
    end

    setupGuideFrame:Show()
end

-- Hide the setup guide
function iSP:HideSetupGuide()
    if setupGuideFrame then
        setupGuideFrame:Hide()
    end
end

-- Check if we should show the guide on startup
function iSP:CheckShowSetupGuideOnStartup()
    iSPSettings.SetupGuide = iSPSettings.SetupGuide or {}

    -- Don't show if user has disabled it
    if iSPSettings.SetupGuide.DontShowOnStartup then
        return
    end

    -- Show if no sounds are registered
    local soundCount = iSPSettings.SoundFiles and #iSPSettings.SoundFiles or 0
    if soundCount == 0 then
        -- Delay showing to let the UI fully load
        C_Timer.After(2, function()
            iSP:ShowSetupGuide()
        end)
    end
end
