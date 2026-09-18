local NS=TargetCopy
NS.Settings={}
local S=NS.Settings
local f=CreateFrame("Frame","TargetCopySettings",UIParent,"BackdropTemplate")
S.frame=f
f:SetSize(350,355); f:SetPoint("CENTER",UIParent,"CENTER",370,0); f:SetFrameStrata("DIALOG"); f:SetClampedToScreen(true); f:Hide()
if f.SetBackdrop then
    f:SetBackdrop({bgFile="Interface\\DialogFrame\\UI-DialogBox-Background",edgeFile="Interface\\DialogFrame\\UI-DialogBox-Border",tile=true,tileSize=32,edgeSize=24,insets={left=8,right=8,top=8,bottom=8}})
end

local title=f:CreateFontString(nil,"OVERLAY","GameFontNormalLarge"); title:SetPoint("TOPLEFT",20,-18); title:SetText("TargetCopy Settings")
local close=CreateFrame("Button",nil,f,"UIPanelCloseButton"); close:SetPoint("TOPRIGHT",-5,-5)
local function Label(text,y)
    local t=f:CreateFontString(nil,"OVERLAY","GameFontNormalSmall"); t:SetPoint("TOPLEFT",20,y); t:SetText(text); return t
end
local function Check(label,y)
    local c=CreateFrame("CheckButton",nil,f,"UICheckButtonTemplate"); c:SetPoint("TOPLEFT",20,y)
    local t=f:CreateFontString(nil,"OVERLAY","GameFontHighlight"); t:SetPoint("LEFT",c,"RIGHT",3,0); t:SetText(label)
    return c
end
local function Btn(label,y,w)
    local b=CreateFrame("Button",nil,f,"UIPanelButtonTemplate"); b:SetSize(w or 190,27); b:SetPoint("TOPLEFT",20,y); b:SetText(label); return b
end

Label("FLOATING BUTTON",-58)
S.floatEnabled=Check("Enable floating button",-74)
S.floatLocked=Check("Lock floating button position",-105)
S.resetButton=Btn("Reset Button Position",-140)

Label("QUICK COPY",-190)
S.quickEnabled=Check("Enable Quick Copy keybind",-206)
S.key=f:CreateFontString(nil,"OVERLAY","GameFontHighlightSmall"); S.key:SetPoint("TOPLEFT",20,-244); S.key:SetText("Key binding: Unbound")
local note=f:CreateFontString(nil,"OVERLAY","GameFontDisableSmall"); note:SetPoint("TOPLEFT",20,-262); note:SetText("Change it in WoW Key Bindings > TargetCopy.")

S.modeLabel=f:CreateFontString(nil,"OVERLAY","GameFontHighlightSmall"); S.modeLabel:SetPoint("TOPLEFT",20,-286); S.modeLabel:SetText("Copy mode:")
S.mode=CreateFrame("Button",nil,f,"UIPanelButtonTemplate"); S.mode:SetSize(160,27); S.mode:SetPoint("LEFT",S.modeLabel,"RIGHT",10,0)

S.resetWindow=Btn("Reset Window Position",-318)

local modes={"name","target","both"}
local names={name="Name only",target="/target command",both="Name + /target"}
S.mode:SetScript("OnClick",function()
    if not NS.db then return end
    local cur=NS.db.quickCopy.mode
    local idx=1
    for i,v in ipairs(modes) do if v==cur then idx=i break end end
    idx=idx%#modes+1
    NS.db.quickCopy.mode=modes[idx]
    S:Refresh()
end)

S.floatEnabled:SetScript("OnClick",function(self) NS.db.floatingButton.enabled=self:GetChecked() and true or false; NS.FloatingButton:ApplySettings() end)
S.floatLocked:SetScript("OnClick",function(self) NS.db.floatingButton.locked=self:GetChecked() and true or false end)
S.quickEnabled:SetScript("OnClick",function(self) NS.db.quickCopy.enabled=self:GetChecked() and true or false end)
S.resetButton:SetScript("OnClick",function() NS.FloatingButton:ResetPosition(); NS:Print("Floating button position reset.") end)
S.resetWindow:SetScript("OnClick",function() NS.UI:ResetPosition(); NS:Print("Window position reset.") end)

function S:Refresh()
    if not NS.db then return end
    self.floatEnabled:SetChecked(NS.db.floatingButton.enabled)
    self.floatLocked:SetChecked(NS.db.floatingButton.locked)
    self.quickEnabled:SetChecked(NS.db.quickCopy.enabled)
    self.key:SetText("Key binding: "..NS.Compat:GetBindingText())
    self.mode:SetText(names[NS.db.quickCopy.mode] or "/target command")
end
function S:Show() self:Refresh(); f:Show() end
function S:Hide() f:Hide() end
function S:Toggle() if f:IsShown() then self:Hide() else self:Show() end end
