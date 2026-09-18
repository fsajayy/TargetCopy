local NS = TargetCopy
NS.QuickCopyPopup = {}
local P = NS.QuickCopyPopup

local f=CreateFrame("Frame","TargetCopyQuickPopup",UIParent,"BackdropTemplate")
P.frame=f
f:SetSize(330,82); f:SetPoint("CENTER",0,130); f:SetFrameStrata("TOOLTIP"); f:SetClampedToScreen(true); f:Hide()
if f.SetBackdrop then
    f:SetBackdrop({bgFile="Interface\\Buttons\\WHITE8X8",edgeFile="Interface\\Tooltips\\UI-Tooltip-Border",edgeSize=12,insets={left=3,right=3,top=3,bottom=3}})
    f:SetBackdropColor(.035,.03,.025,.96)
end

local edit=CreateFrame("EditBox",nil,f,"InputBoxTemplate")
edit:SetPoint("TOPLEFT",15,-15); edit:SetPoint("TOPRIGHT",-15,-15); edit:SetHeight(28)
edit:SetAutoFocus(false); edit:SetMaxLetters(255); edit:SetFontObject("ChatFontNormal")
local hint=f:CreateFontString(nil,"OVERLAY","GameFontHighlightSmall"); hint:SetPoint("BOTTOMLEFT",18,13); hint:SetText("Ctrl+C to copy  |  Enter / Escape to close")

local generation=0
local function Later(seconds, fn)
    if C_Timer and C_Timer.After then C_Timer.After(seconds,fn) end
end
local function Hide()
    generation=generation+1
    edit:ClearFocus(); f:Hide()
end

edit:SetScript("OnEscapePressed",Hide)
edit:SetScript("OnEnterPressed",Hide)
edit:SetScript("OnKeyDown",function(_,key)
    if key=="C" and IsControlKeyDown and IsControlKeyDown() then
        hint:SetText("Copy command detected")
        local mine=generation
        Later(.8,function() if mine==generation then Hide() end end)
    end
end)

function P:ShowCopy(value)
    generation=generation+1
    local mine=generation
    f:Show(); edit:Show(); edit:SetText(value or ""); edit:SetFocus(); edit:HighlightText()
    hint:SetText("Ctrl+C to copy  |  Enter / Escape to close")
    Later(10,function() if mine==generation and f:IsShown() then Hide() end end)
end

function P:ShowNotice(message, seconds)
    generation=generation+1
    local mine=generation
    f:Show(); edit:Show(); edit:SetText(message or ""); edit:ClearFocus(); edit:HighlightText(0,0)
    hint:SetText("")
    Later(seconds or 1.5,function() if mine==generation then Hide() end end)
end

function P:Hide() Hide() end
