local NS = TargetCopy

NS.DebugPanel = {}
local D = NS.DebugPanel

local frame = CreateFrame("Frame", "TargetCopyDebugPanel", UIParent, "BasicFrameTemplateWithInset")
frame:SetSize(560, 430)
frame:SetPoint("CENTER")
frame:SetFrameStrata("DIALOG")
frame:SetClampedToScreen(true)
frame:EnableMouse(true)
frame:SetMovable(true)
frame:RegisterForDrag("LeftButton")

frame:SetScript("OnDragStart", function(self)
    self:StartMoving()
end)

frame:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
end)

frame:Hide()

frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
frame.title:SetPoint("LEFT", frame.TitleBg, "LEFT", 5, 0)
frame.title:SetText("TargetCopy Debug")

local scroll = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
scroll:SetPoint("TOPLEFT", 12, -32)
scroll:SetPoint("BOTTOMRIGHT", -32, 48)

local editBox = CreateFrame("EditBox", nil, scroll)
editBox:SetMultiLine(true)
editBox:SetAutoFocus(false)
editBox:SetFontObject(ChatFontNormal)
editBox:SetWidth(500)
editBox:SetTextInsets(6, 6, 6, 6)
editBox:EnableMouse(true)

editBox:SetScript("OnEscapePressed", function(self)
    self:ClearFocus()
end)

scroll:SetScrollChild(editBox)

local refresh = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
refresh:SetSize(90, 24)
refresh:SetPoint("BOTTOMLEFT", 12, 12)
refresh:SetText("Refresh")

local selectAll = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
selectAll:SetSize(110, 24)
selectAll:SetPoint("LEFT", refresh, "RIGHT", 8, 0)
selectAll:SetText("Select All")

local close = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
close:SetSize(90, 24)
close:SetPoint("BOTTOMRIGHT", -12, 12)
close:SetText("Close")

local function RefreshReport()
    if not NS.Compat or not NS.Compat.GetDebugReport then
        editBox:SetText("TargetCopy diagnostics unavailable.")
        return
    end

    editBox:SetText(NS.Compat:GetDebugReport())
    editBox:SetCursorPosition(0)
    editBox:ClearFocus()
end

refresh:SetScript("OnClick", RefreshReport)

selectAll:SetScript("OnClick", function()
    editBox:SetFocus()
    editBox:HighlightText()
end)

close:SetScript("OnClick", function()
    frame:Hide()
end)

function D:Show()
    RefreshReport()
    frame:Show()
    frame:Raise()
end

function D:Hide()
    frame:Hide()
end

function D:Toggle()
    if frame:IsShown() then
        frame:Hide()
    else
        self:Show()
    end
end
