local NS = TargetCopy
NS.UI = {}
local UI = NS.UI
UI.selectedMark = 0

local f = CreateFrame("Frame","TargetCopyWindow",UIParent,"BackdropTemplate")
UI.frame = f

f:SetSize(350,525); f:SetPoint("CENTER"); f:SetFrameStrata("DIALOG")
f:SetClampedToScreen(true); f:SetMovable(true); f:EnableMouse(true); f:RegisterForDrag("LeftButton"); f:Hide()

if f.SetBackdrop then
    f:SetBackdrop({bgFile="Interface\\DialogFrame\\UI-DialogBox-Background",edgeFile="Interface\\DialogFrame\\UI-DialogBox-Border",tile=true,tileSize=32,edgeSize=24,insets={left=8,right=8,top=8,bottom=8}})
end

f:SetScript("OnDragStart",function(self) self:StartMoving() end)
f:SetScript("OnDragStop",function(self)
    self:StopMovingOrSizing()
    if NS.db then
        local p,_,rp,x,y=self:GetPoint(1)
        NS.db.window={point=p or "CENTER",relativePoint=rp or "CENTER",x=x or 0,y=y or 0}
    end
end)
f:SetScript("OnHide", function() NS:CloseAuxiliaryWindows() end)

local function Txt(template,value)
    local s=f:CreateFontString(nil,"OVERLAY",template); s:SetText(value or ""); return s
end
local function Btn(label,w,h)
    local b=CreateFrame("Button",nil,f,"UIPanelButtonTemplate"); b:SetSize(w or 140,h or 28); b:SetText(label); return b
end

local function MarkerButton(index,size)
    local b=CreateFrame("Button",nil,f,"BackdropTemplate")
    b:SetSize(size or 54,size or 54)

    if b.SetBackdrop then
        b:SetBackdrop({
            bgFile="Interface\\Buttons\\WHITE8X8",
            edgeFile="Interface\\Tooltips\\UI-Tooltip-Border",
            edgeSize=10,
            insets={left=2,right=2,top=2,bottom=2}
        })
        b:SetBackdropColor(.03,.03,.03,.75)
        b:SetBackdropBorderColor(.30,.30,.30,.85)
    end

    local icon=b:CreateTexture(nil,"ARTWORK")
    icon:SetSize(30,30)
    icon:SetPoint("CENTER",0,0)
    icon:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcons")
    SetRaidTargetIconTexture(icon,index)


    local selected=CreateFrame("Frame",nil,b,"BackdropTemplate")
    selected:SetPoint("TOPLEFT",-2,2)
    selected:SetPoint("BOTTOMRIGHT",2,-2)
    selected:SetFrameLevel(b:GetFrameLevel()+2)

    if selected.SetBackdrop then
        selected:SetBackdrop({
            edgeFile="Interface\\Tooltips\\UI-Tooltip-Border",
            edgeSize=12
        })
        selected:SetBackdropBorderColor(1,.82,.15,1)
    end

    selected:Hide()

    b.markerIndex=index
    b.markerIcon=icon
    b.selectedTexture=selected

    b:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square","ADD")

    b:SetScript("OnEnter",function(self)
        GameTooltip:SetOwner(self,"ANCHOR_RIGHT")
        GameTooltip:SetText(NS.Marker.names[index])
        GameTooltip:AddLine("Macro command: /tm "..index,1,1,1)
        GameTooltip:Show()
    end)

    b:SetScript("OnLeave",function()
        GameTooltip:Hide()
    end)

    function b:SetSelected(value)
        if value then
            self.selectedTexture:Show()
        else
            self.selectedTexture:Hide()
        end
    end

    return b
end
local function Enabled(b,v) if v then b:Enable(); b:SetAlpha(1) else b:Disable(); b:SetAlpha(.45) end end
local function Status(v) UI.status:SetText(v or "") end

UI.title=Txt("GameFontNormalLarge","TargetCopy"); UI.title:SetPoint("TOPLEFT",20,-18)
UI.settings=Btn("Options",70,22); UI.settings:SetPoint("TOPRIGHT",-42,-11); UI.settings:SetScript("OnClick",function() NS.Settings:Toggle() end)
UI.close=CreateFrame("Button",nil,f,"UIPanelCloseButton"); UI.close:SetPoint("TOPRIGHT",-5,-5)

local h=Txt("GameFontNormalSmall","CURRENT TARGET"); h:SetPoint("TOPLEFT",20,-58)
UI.name=Txt("GameFontHighlightLarge","No target selected"); UI.name:SetPoint("TOPLEFT",20,-79); UI.name:SetWidth(275); UI.name:SetJustifyH("LEFT"); UI.name:SetWordWrap(false)
UI.meta=Txt("GameFontHighlightSmall",""); UI.meta:SetPoint("TOPLEFT",20,-103)

local q=Txt("GameFontNormalSmall","QUICK ACTIONS"); q:SetPoint("TOPLEFT",20,-138)
UI.copy=Btn("Copy Name",145); UI.copy:SetPoint("TOPLEFT",20,-159)
UI.target=Btn("Copy /target",145); UI.target:SetPoint("LEFT",UI.copy,"RIGHT",10,0)

local r=Txt("GameFontNormalSmall","MACRO MARK"); r:SetPoint("TOPLEFT",20,-207)

UI.noMark=Btn("Target Only",92,22)
UI.noMark:SetPoint("TOPRIGHT",-20,-200)
UI.noMark:SetScript("OnClick",function()
    UI.selectedMark=0
    Status("Target-only macro selected")
    UI:Refresh()
end)

UI.markerButtons={}
for i=1,8 do
    local b=MarkerButton(i,54)
    local row=math.floor((i-1)/4)
    local col=(i-1)%4
    b:SetPoint("TOPLEFT",28+col*75,-232-row*58)
    b:SetScript("OnClick",function()
        UI.selectedMark=i
        Status(NS.Marker.names[i].." selected")
        UI:Refresh()
    end)
    UI.markerButtons[i]=b
end


local ph=Txt("GameFontNormalSmall","PREVIEW"); ph:SetPoint("TOPLEFT",20,-358)
local bg=CreateFrame("Frame",nil,f,"BackdropTemplate"); bg:SetSize(305,62); bg:SetPoint("TOPLEFT",20,-374)
if bg.SetBackdrop then
    bg:SetBackdrop({bgFile="Interface\\Buttons\\WHITE8X8",edgeFile="Interface\\Tooltips\\UI-Tooltip-Border",edgeSize=12,insets={left=3,right=3,top=3,bottom=3}})
    bg:SetBackdropColor(.03,.03,.03,.9)
end
UI.preview=CreateFrame("EditBox",nil,bg); UI.preview:SetPoint("TOPLEFT",8,-7); UI.preview:SetPoint("BOTTOMRIGHT",-8,7)
UI.preview:SetMultiLine(true); UI.preview:SetAutoFocus(false); UI.preview:SetFontObject("ChatFontNormal"); UI.preview:SetMaxLetters(255)
UI.preview:SetScript("OnEscapePressed",function(self) self:ClearFocus() end)

UI.select=Btn("Select / Copy",145); UI.select:SetPoint("TOPLEFT",20,-448)
UI.create=Btn("Create Macro",145); UI.create:SetPoint("LEFT",UI.select,"RIGHT",10,0)
local sep=f:CreateTexture(nil,"ARTWORK"); sep:SetColorTexture(.35,.28,.18,.65); sep:SetSize(305,1); sep:SetPoint("BOTTOMLEFT",20,31)
UI.status=Txt("GameFontHighlightSmall","Ready"); UI.status:SetPoint("BOTTOMLEFT",20,14); UI.status:SetWidth(305); UI.status:SetJustifyH("LEFT")

function UI:GetTarget() return NS.Unit:GetName("target") end
function UI:BuildPreview()
    local name=self:GetTarget()
    if not name then return "" end
    if self.selectedMark and self.selectedMark > 0 then
        return NS.Macro:Build("both",name,self.selectedMark)
    end
    return NS.Macro:Build("target",name,0)
end
function UI:Refresh()
    local exists=NS.Unit:Exists("target")
    local name=exists and NS.Unit:GetName("target") or nil
    self.name:SetText(name or "No target selected")
    self.meta:SetText(exists and NS.Unit:GetMeta("target") or "Select a unit to enable target actions.")
    Enabled(self.copy,exists and name~=nil); Enabled(self.target,exists and name~=nil)
    Enabled(self.noMark,true)
    self.noMark:LockHighlight()
    if self.selectedMark ~= 0 then self.noMark:UnlockHighlight() end
    for i,b in ipairs(self.markerButtons) do
        b:SetSelected(self.selectedMark == i)
    end
    for _,b in ipairs(self.markerButtons) do Enabled(b,true) end
    local body=self:BuildPreview(); self.preview:SetText(body)
    Enabled(self.create,body~="" and NS.Compat:CanCreateMacro() and not NS.Compat:InCombat())
end
function UI:Show() f:Show(); self:Refresh() end
function UI:Hide() f:Hide() end
function UI:Toggle() if f:IsShown() then self:Hide() else self:Show() end end
function UI:ResetPosition()
    f:ClearAllPoints(); f:SetPoint("CENTER")
    if NS.db then NS.db.window={point="CENTER",relativePoint="CENTER",x=0,y=0} end
    Status("Window position reset")
end
function UI:RestorePosition()
    local w=NS.db and NS.db.window
    f:ClearAllPoints()
    local ok=pcall(function() f:SetPoint((w and w.point) or "CENTER",UIParent,(w and w.relativePoint) or "CENTER",(w and w.x) or 0,(w and w.y) or 0) end)
    if not ok then self:ResetPosition() end
end

UI.copy:SetScript("OnClick",function()
    local name=UI:GetTarget(); if not name then Status("No target selected"); return end
    UI.preview:SetText(name); UI.preview:SetFocus(); UI.preview:HighlightText(); Status("Name selected - press Ctrl+C")
end)
UI.target:SetScript("OnClick",function()
    local name=UI:GetTarget()
    if not name then Status("No target selected"); return end
    UI.preview:SetText("/target "..name)
    UI.preview:SetFocus()
    UI.preview:HighlightText()
    Status("/target selected - press Ctrl+C")
end)
UI.select:SetScript("OnClick",function()
    UI:Refresh(); UI.preview:SetFocus(); UI.preview:HighlightText(); Status("Macro selected - press Ctrl+C")
end)
UI.create:SetScript("OnClick",function()
    local targetName=UI:GetTarget()
    local ok,result,macroName=NS.Macro:CreateOrUpdate(UI:BuildPreview(),targetName)
    if ok then Status("Macro "..string.lower(tostring(result))..": "..tostring(macroName))
    elseif result=="COMBAT" then Status("Create Macro unavailable during combat.")
    else Status("Create Macro failed: "..tostring(result)) end
    UI:Refresh()
end)
